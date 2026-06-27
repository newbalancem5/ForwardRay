import 'package:equatable/equatable.dart';

/// Supported proxy protocols.
enum ProxyProtocol { vless, vmess, trojan, shadowsocks }

extension ProxyProtocolX on ProxyProtocol {
  String get label => switch (this) {
        ProxyProtocol.vless => 'VLESS',
        ProxyProtocol.vmess => 'VMess',
        ProxyProtocol.trojan => 'Trojan',
        ProxyProtocol.shadowsocks => 'Shadowsocks',
      };

  /// sing-box outbound `type` value.
  String get singBoxType => switch (this) {
        ProxyProtocol.vless => 'vless',
        ProxyProtocol.vmess => 'vmess',
        ProxyProtocol.trojan => 'trojan',
        ProxyProtocol.shadowsocks => 'shadowsocks',
      };

  static ProxyProtocol fromString(String s) => switch (s.toLowerCase()) {
        'vless' => ProxyProtocol.vless,
        'vmess' => ProxyProtocol.vmess,
        'trojan' => ProxyProtocol.trojan,
        'shadowsocks' || 'ss' => ProxyProtocol.shadowsocks,
        _ => throw ArgumentError('Unknown protocol: $s'),
      };
}

/// Immutable proxy server description (pure domain entity, no I/O concerns).
class ProxyNode extends Equatable {
  const ProxyNode({
    required this.id,
    required this.name,
    required this.protocol,
    required this.server,
    required this.port,
    this.uuid = '',
    this.password = '',
    this.method = '',
    this.alterId = 0,
    this.encryption = 'auto',
    this.flow = '',
    this.security = 'none', // none | tls | reality
    this.sni = '',
    this.alpn = const [],
    this.fingerprint = '',
    this.allowInsecure = false,
    this.realityPublicKey = '',
    this.realityShortId = '',
    this.network = 'tcp', // tcp | ws | grpc | http | httpupgrade
    this.wsPath = '/',
    this.wsHost = '',
    this.grpcServiceName = '',
    this.subscriptionId,
    this.rawLink = '',
  });

  final String id;
  final String name;
  final ProxyProtocol protocol;
  final String server;
  final int port;

  final String uuid;
  final String password;
  final String method;
  final int alterId;
  final String encryption;
  final String flow;

  final String security;
  final String sni;
  final List<String> alpn;
  final String fingerprint;
  final bool allowInsecure;
  final String realityPublicKey;
  final String realityShortId;

  final String network;
  final String wsPath;
  final String wsHost;
  final String grpcServiceName;

  /// Subscription this node came from, or null if added manually.
  final String? subscriptionId;
  final String rawLink;

  bool get isTls => security == 'tls' || security == 'reality';
  String get displayServer => '$server:$port';

  ProxyNode copyWith({String? name, String? subscriptionId}) => ProxyNode(
        id: id,
        name: name ?? this.name,
        protocol: protocol,
        server: server,
        port: port,
        uuid: uuid,
        password: password,
        method: method,
        alterId: alterId,
        encryption: encryption,
        flow: flow,
        security: security,
        sni: sni,
        alpn: alpn,
        fingerprint: fingerprint,
        allowInsecure: allowInsecure,
        realityPublicKey: realityPublicKey,
        realityShortId: realityShortId,
        network: network,
        wsPath: wsPath,
        wsHost: wsHost,
        grpcServiceName: grpcServiceName,
        subscriptionId: subscriptionId ?? this.subscriptionId,
        rawLink: rawLink,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        protocol,
        server,
        port,
        uuid,
        password,
        method,
        alterId,
        encryption,
        flow,
        security,
        sni,
        alpn,
        fingerprint,
        allowInsecure,
        realityPublicKey,
        realityShortId,
        network,
        wsPath,
        wsHost,
        grpcServiceName,
        subscriptionId,
        rawLink,
      ];
}
