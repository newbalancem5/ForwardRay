/// App-wide constants and sing-box outbound tags.
class AppConstants {
  static const appName = 'ForwardRay';

  // sing-box outbound tags
  static const proxyTag = 'proxy';
  static const directTag = 'direct';
  static const blockTag = 'block';
  static const dnsTag = 'dns-out';

  // defaults
  static const defaultLocalPort = 2080;
  static const defaultClashApiPort = 9090;
  static const defaultClashSecret = 'forwardray';

  // pinned sing-box release we build the config schema against
  static const singBoxVersion = '1.11.15';

  static const coreBinaryName = 'sing-box';
}
