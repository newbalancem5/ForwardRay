import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../domain/entities/proxy_node.dart';

/// Parses proxy share links (vless / vmess / trojan / ss) into [ProxyNode]s.
class LinkParser {
  const LinkParser();
  static const _uuid = Uuid();

  /// Parses a single share link. Returns null if it can't be understood.
  ProxyNode? parse(String raw) {
    final link = raw.trim();
    if (link.isEmpty) return null;
    try {
      if (link.startsWith('vless://')) return _parseVless(link);
      if (link.startsWith('vmess://')) return _parseVmess(link);
      if (link.startsWith('trojan://')) return _parseTrojan(link);
      if (link.startsWith('ss://')) return _parseShadowsocks(link);
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Parses many links from a blob of text (one per line, base64-aware).
  List<ProxyNode> parseMany(String text) {
    final decoded = decodeBase64Maybe(text);
    final nodes = <ProxyNode>[];
    for (final line in const LineSplitter().convert(decoded)) {
      final node = parse(line);
      if (node != null) nodes.add(node);
    }
    if (nodes.isEmpty) {
      final single = parse(text.trim());
      if (single != null) nodes.add(single);
    }
    return nodes;
  }

  // --- VLESS: vless://uuid@host:port?params#name ---
  ProxyNode _parseVless(String link) {
    final uri = Uri.parse(link);
    final q = uri.queryParameters;
    final security = (q['security'] ?? 'none').toLowerCase();
    return ProxyNode(
      id: _uuid.v4(),
      name: _decodeName(uri.fragment, '${uri.host}:${uri.port}'),
      protocol: ProxyProtocol.vless,
      server: uri.host,
      port: uri.port,
      uuid: uri.userInfo,
      flow: q['flow'] ?? '',
      encryption: q['encryption'] ?? 'none',
      security: security == 'xtls' ? 'tls' : security,
      sni: q['sni'] ?? q['peer'] ?? '',
      alpn: _splitAlpn(q['alpn']),
      fingerprint: q['fp'] ?? '',
      realityPublicKey: q['pbk'] ?? '',
      realityShortId: q['sid'] ?? '',
      allowInsecure: q['allowInsecure'] == '1' || q['insecure'] == '1',
      network: _normNetwork(q['type'] ?? 'tcp'),
      wsPath: _pathParam(q),
      wsHost: q['host'] ?? '',
      grpcServiceName: q['serviceName'] ?? '',
      rawLink: link,
    );
  }

  // --- VMess: vmess://base64(json) ---
  ProxyNode _parseVmess(String link) {
    final decoded = _b64(link.substring('vmess://'.length));
    final j = jsonDecode(decoded) as Map<String, dynamic>;
    String s(String k) => (j[k] ?? '').toString();
    final tls = s('tls').toLowerCase();
    return ProxyNode(
      id: _uuid.v4(),
      name: s('ps').isNotEmpty ? s('ps') : '${s('add')}:${s('port')}',
      protocol: ProxyProtocol.vmess,
      server: s('add'),
      port: int.tryParse(s('port')) ?? 0,
      uuid: s('id'),
      alterId: int.tryParse(s('aid')) ?? 0,
      encryption: s('scy').isNotEmpty ? s('scy') : 'auto',
      security: tls == 'tls' ? 'tls' : 'none',
      sni: s('sni').isNotEmpty ? s('sni') : s('host'),
      alpn: _splitAlpn(s('alpn')),
      fingerprint: s('fp'),
      network: _normNetwork(s('net').isNotEmpty ? s('net') : 'tcp'),
      wsPath: s('path').isNotEmpty ? s('path') : '/',
      wsHost: s('host'),
      grpcServiceName: s('path'),
      rawLink: link,
    );
  }

  // --- Trojan: trojan://password@host:port?params#name ---
  ProxyNode _parseTrojan(String link) {
    final uri = Uri.parse(link);
    final q = uri.queryParameters;
    final security = (q['security'] ?? 'tls').toLowerCase();
    return ProxyNode(
      id: _uuid.v4(),
      name: _decodeName(uri.fragment, '${uri.host}:${uri.port}'),
      protocol: ProxyProtocol.trojan,
      server: uri.host,
      port: uri.port,
      password: Uri.decodeComponent(uri.userInfo),
      security: security == 'none' ? 'none' : 'tls',
      sni: q['sni'] ?? q['peer'] ?? '',
      alpn: _splitAlpn(q['alpn']),
      fingerprint: q['fp'] ?? '',
      allowInsecure: q['allowInsecure'] == '1' || q['insecure'] == '1',
      network: _normNetwork(q['type'] ?? 'tcp'),
      wsPath: _pathParam(q),
      wsHost: q['host'] ?? '',
      grpcServiceName: q['serviceName'] ?? '',
      rawLink: link,
    );
  }

  // --- Shadowsocks (SIP002 + legacy) ---
  ProxyNode _parseShadowsocks(String link) {
    var body = link.substring('ss://'.length);
    String name = '';
    final hashIdx = body.indexOf('#');
    if (hashIdx >= 0) {
      name = Uri.decodeComponent(body.substring(hashIdx + 1));
      body = body.substring(0, hashIdx);
    }
    final qIdx = body.indexOf('?');
    if (qIdx >= 0) body = body.substring(0, qIdx);

    String method, password, host;
    int port;

    if (body.contains('@')) {
      final atIdx = body.lastIndexOf('@');
      final userInfo = _b64(body.substring(0, atIdx));
      final hostPart = body.substring(atIdx + 1);
      final colon = userInfo.indexOf(':');
      method = userInfo.substring(0, colon);
      password = userInfo.substring(colon + 1);
      final lastColon = hostPart.lastIndexOf(':');
      host = hostPart.substring(0, lastColon);
      port = int.tryParse(hostPart.substring(lastColon + 1)) ?? 0;
    } else {
      final decoded = _b64(body);
      final atIdx = decoded.lastIndexOf('@');
      final cred = decoded.substring(0, atIdx);
      final hostPart = decoded.substring(atIdx + 1);
      final colon = cred.indexOf(':');
      method = cred.substring(0, colon);
      password = cred.substring(colon + 1);
      final lastColon = hostPart.lastIndexOf(':');
      host = hostPart.substring(0, lastColon);
      port = int.tryParse(hostPart.substring(lastColon + 1)) ?? 0;
    }

    return ProxyNode(
      id: _uuid.v4(),
      name: name.isNotEmpty ? name : '$host:$port',
      protocol: ProxyProtocol.shadowsocks,
      server: host,
      port: port,
      method: method,
      password: password,
      rawLink: link,
    );
  }

  // --- Helpers ---
  String _pathParam(Map<String, String> q) {
    final p = q['path'] ?? q['serviceName'] ?? '/';
    return p.isEmpty ? '/' : p;
  }

  String _normNetwork(String net) {
    final n = net.toLowerCase();
    return switch (n) {
      'websocket' => 'ws',
      'h2' || 'http' => 'http',
      'httpupgrade' => 'httpupgrade',
      'grpc' => 'grpc',
      'tcp' || 'raw' || '' => 'tcp',
      _ => n,
    };
  }

  List<String> _splitAlpn(String? alpn) {
    if (alpn == null || alpn.isEmpty) return const [];
    return alpn
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _decodeName(String fragment, String fallback) {
    if (fragment.isEmpty) return fallback;
    try {
      return Uri.decodeComponent(fragment);
    } catch (_) {
      return fragment;
    }
  }

  String _b64(String input) {
    var s = input.trim().replaceAll('-', '+').replaceAll('_', '/');
    s = s.replaceAll(RegExp(r'\s'), '');
    final pad = s.length % 4;
    if (pad > 0) s = s + '=' * (4 - pad);
    return utf8.decode(base64.decode(s));
  }

  /// Decodes a base64 subscription body if needed; returns plain text otherwise.
  String decodeBase64Maybe(String text) {
    final t = text.trim();
    if (t.startsWith('vless://') ||
        t.startsWith('vmess://') ||
        t.startsWith('trojan://') ||
        t.startsWith('ss://')) {
      return t;
    }
    try {
      final decoded = _b64(t);
      if (decoded.contains('://')) return decoded;
    } catch (_) {}
    return t;
  }
}
