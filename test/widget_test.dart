import 'package:flutter_test/flutter_test.dart';
import 'package:forwardray/features/proxy/data/datasources/link_parser.dart';
import 'package:forwardray/features/proxy/domain/entities/proxy_node.dart';

void main() {
  const parser = LinkParser();

  test('parses a vless reality link', () {
    final node = parser.parse(
      'vless://11111111-2222-3333-4444-555555555555@example.com:443'
      '?security=reality&sni=www.microsoft.com&fp=chrome&pbk=abcd&sid=ff'
      '&type=tcp&flow=xtls-rprx-vision#My%20Node',
    );
    expect(node, isNotNull);
    expect(node!.protocol, ProxyProtocol.vless);
    expect(node.server, 'example.com');
    expect(node.port, 443);
    expect(node.security, 'reality');
    expect(node.realityPublicKey, 'abcd');
    expect(node.flow, 'xtls-rprx-vision');
    expect(node.name, 'My Node');
  });

  test('parses a trojan link', () {
    final node = parser.parse('trojan://pass@host.net:8443?sni=host.net#T');
    expect(node, isNotNull);
    expect(node!.protocol, ProxyProtocol.trojan);
    expect(node.password, 'pass');
    expect(node.security, 'tls');
  });

  test('returns null for garbage', () {
    expect(parser.parse('not a link'), isNull);
  });
}
