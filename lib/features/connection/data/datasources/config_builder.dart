import '../../../../core/constants/app_constants.dart';
import '../../../proxy/domain/entities/proxy_node.dart';
import '../../../settings/domain/entities/app_settings.dart';

/// Builds a sing-box `config.json` (targeting the stable 1.11.x schema) from the
/// selected node, settings and routing mode. System-proxy mode: a single
/// `mixed` inbound on localhost that the OS proxy points at.
class ConfigBuilder {
  const ConfigBuilder();

  Map<String, dynamic> build({
    required ProxyNode node,
    required AppSettings settings,
    required String cacheDir,
  }) {
    return {
      'log': {'level': settings.logLevel, 'timestamp': true},
      'experimental': {
        'clash_api': {
          'external_controller': '127.0.0.1:${settings.clashApiPort}',
          'secret': settings.clashApiSecret,
        },
        'cache_file': {'enabled': true, 'path': '$cacheDir/cache.db'},
      },
      'dns': _dns(),
      'inbounds': [
        {
          'type': 'mixed',
          'tag': 'mixed-in',
          'listen': '127.0.0.1',
          'listen_port': settings.localPort,
          'sniff': true,
          'sniff_override_destination': false,
        },
      ],
      // sing-box 1.11+ : `block`/`dns` outbounds are replaced by rule actions
      // (reject / hijack-dns) in the route section below.
      'outbounds': [
        outbound(node, AppConstants.proxyTag),
        {'type': 'direct', 'tag': AppConstants.directTag},
      ],
      'route': _route(settings, cacheDir),
    };
  }

  // --- Outbound for a node ---
  Map<String, dynamic> outbound(ProxyNode node, String tag) {
    final out = <String, dynamic>{
      'type': node.protocol.singBoxType,
      'tag': tag,
      'server': node.server,
      'server_port': node.port,
    };

    switch (node.protocol) {
      case ProxyProtocol.vless:
        out['uuid'] = node.uuid;
        if (node.flow.isNotEmpty) out['flow'] = node.flow;
        out['packet_encoding'] = 'xudp';
      case ProxyProtocol.vmess:
        out['uuid'] = node.uuid;
        out['alter_id'] = node.alterId;
        out['security'] = node.encryption.isEmpty ? 'auto' : node.encryption;
      case ProxyProtocol.trojan:
        out['password'] = node.password;
      case ProxyProtocol.shadowsocks:
        out['method'] = node.method;
        out['password'] = node.password;
    }

    final tls = _tls(node);
    if (tls != null) out['tls'] = tls;
    final transport = _transport(node);
    if (transport != null) out['transport'] = transport;
    return out;
  }

  Map<String, dynamic>? _tls(ProxyNode node) {
    if (!node.isTls) return null;
    final tls = <String, dynamic>{
      'enabled': true,
      if (node.sni.isNotEmpty) 'server_name': node.sni,
      if (node.allowInsecure) 'insecure': true,
      if (node.alpn.isNotEmpty) 'alpn': node.alpn,
    };
    if (node.fingerprint.isNotEmpty) {
      tls['utls'] = {'enabled': true, 'fingerprint': node.fingerprint};
    }
    if (node.security == 'reality') {
      tls['reality'] = {
        'enabled': true,
        if (node.realityPublicKey.isNotEmpty)
          'public_key': node.realityPublicKey,
        if (node.realityShortId.isNotEmpty) 'short_id': node.realityShortId,
      };
    }
    return tls;
  }

  Map<String, dynamic>? _transport(ProxyNode node) {
    switch (node.network) {
      case 'ws':
        return {
          'type': 'ws',
          'path': node.wsPath.isEmpty ? '/' : node.wsPath,
          if (node.wsHost.isNotEmpty) 'headers': {'Host': node.wsHost},
        };
      case 'grpc':
        return {'type': 'grpc', 'service_name': node.grpcServiceName};
      case 'http':
      case 'h2':
        return {
          'type': 'http',
          if (node.wsHost.isNotEmpty) 'host': [node.wsHost],
          'path': node.wsPath.isEmpty ? '/' : node.wsPath,
        };
      case 'httpupgrade':
        return {
          'type': 'httpupgrade',
          if (node.wsHost.isNotEmpty) 'host': node.wsHost,
          'path': node.wsPath.isEmpty ? '/' : node.wsPath,
        };
      default:
        return null;
    }
  }

  // --- DNS ---
  Map<String, dynamic> _dns() => {
        'servers': [
          {
            'tag': 'remote',
            'address': 'https://1.1.1.1/dns-query',
            'detour': AppConstants.proxyTag,
          },
          {
            'tag': 'local',
            'address': 'https://223.5.5.5/dns-query',
            'detour': AppConstants.directTag,
          },
          {'tag': 'block-dns', 'address': 'rcode://success'},
        ],
        'rules': [
          {'outbound': 'any', 'server': 'local'},
        ],
        'final': 'remote',
        'strategy': 'prefer_ipv4',
        'disable_cache': false,
      };

  // --- Route ---
  Map<String, dynamic> _route(AppSettings settings, String cacheDir) {
    final rules = <Map<String, dynamic>>[
      // Hijack DNS queries into the dns engine (rule action, 1.11+).
      {'protocol': 'dns', 'action': 'hijack-dns'},
    ];

    switch (settings.routingMode) {
      case RoutingMode.global:
        if (settings.bypassLan) rules.addAll(_lanRules());
      case RoutingMode.direct:
        break;
      case RoutingMode.rule:
        if (settings.bypassLan) rules.addAll(_lanRules());
        if (settings.blockAds) {
          rules.add({'geosite': 'category-ads-all', 'action': 'reject'});
        }
    }

    final finalOut = settings.routingMode == RoutingMode.direct
        ? AppConstants.directTag
        : AppConstants.proxyTag;

    final route = <String, dynamic>{
      'rules': rules,
      'final': finalOut,
      'auto_detect_interface': true,
    };

    if (settings.routingMode == RoutingMode.rule && settings.blockAds) {
      route['geosite'] = {
        'path': '$cacheDir/geosite.db',
        'download_detour': AppConstants.proxyTag,
      };
      route['geoip'] = {
        'path': '$cacheDir/geoip.db',
        'download_detour': AppConstants.proxyTag,
      };
    }
    return route;
  }

  List<Map<String, dynamic>> _lanRules() => [
        {'ip_is_private': true, 'outbound': AppConstants.directTag},
        {
          'domain_suffix': ['.local', '.lan'],
          'outbound': AppConstants.directTag,
        },
      ];
}
