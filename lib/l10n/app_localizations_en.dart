// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ForwardRay';

  @override
  String get navHome => 'Home';

  @override
  String get navServers => 'Servers';

  @override
  String get navSubscriptions => 'Subscriptions';

  @override
  String get navRouting => 'Routing';

  @override
  String get navSettings => 'Settings';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connecting => 'Connecting…';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusDisconnected => 'Disconnected';

  @override
  String get statusError => 'Error';

  @override
  String get tapToConnect => 'Tap to connect';

  @override
  String get tapToDisconnect => 'Tap to disconnect';

  @override
  String get selectedServer => 'Selected server';

  @override
  String get noServerSelected => 'No server selected';

  @override
  String get uploadSpeed => 'Upload';

  @override
  String get downloadSpeed => 'Download';

  @override
  String get totalUp => 'Total up';

  @override
  String get totalDown => 'Total down';

  @override
  String get addServer => 'Add server';

  @override
  String get importFromClipboard => 'Import from clipboard';

  @override
  String get pingAll => 'Test all';

  @override
  String get noServers =>
      'No servers yet. Add one from a share link or a subscription.';

  @override
  String get deleteServer => 'Delete';

  @override
  String get renameServer => 'Rename';

  @override
  String get testLatency => 'Test latency';

  @override
  String get addFromLink => 'Add from link';

  @override
  String get pasteLinkHint =>
      'Paste vless:// vmess:// trojan:// ss:// links (one per line)';

  @override
  String serversAdded(int count) {
    return '$count server(s) added';
  }

  @override
  String get nothingParsed => 'Couldn\'t parse any servers';

  @override
  String ms(int value) {
    return '$value ms';
  }

  @override
  String get untested => 'untested';

  @override
  String get timeout => 'timeout';

  @override
  String get addSubscription => 'Add subscription';

  @override
  String get subscriptionName => 'Name';

  @override
  String get subscriptionUrl => 'URL';

  @override
  String get updateAll => 'Update all';

  @override
  String get update => 'Update';

  @override
  String get delete => 'Delete';

  @override
  String lastUpdated(String date) {
    return 'Updated: $date';
  }

  @override
  String get never => 'never';

  @override
  String nodesCount(int count) {
    return '$count servers';
  }

  @override
  String get noSubscriptions =>
      'No subscriptions. Add a subscription URL to fetch servers.';

  @override
  String get updating => 'Updating…';

  @override
  String updateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get routingMode => 'Routing mode';

  @override
  String get routingModeDesc => 'How traffic is routed through the core';

  @override
  String get modeGlobal => 'Global';

  @override
  String get modeRule => 'Rule based';

  @override
  String get modeDirect => 'Direct';

  @override
  String get bypassLan => 'Bypass LAN';

  @override
  String get bypassLanDesc => 'Keep local / private addresses off the proxy';

  @override
  String get blockAds => 'Block ads';

  @override
  String get blockAdsDesc =>
      'Drop known ad/tracker domains (downloads rule database)';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get minimizeToTray => 'Minimize to tray on close';

  @override
  String get minimizeToTrayDesc =>
      'Keep running in the tray instead of quitting';

  @override
  String get launchAtStartup => 'Launch at startup';

  @override
  String get autoConnect => 'Auto-connect on launch';

  @override
  String get settingsNetwork => 'Network';

  @override
  String get localPort => 'Local proxy port';

  @override
  String get clashApiPort => 'Clash API port';

  @override
  String get settingsCore => 'Core';

  @override
  String get coreInstalled => 'sing-box installed';

  @override
  String get coreNotInstalled => 'sing-box not found';

  @override
  String get installCore => 'Install core…';

  @override
  String get downloadCore => 'Download core';

  @override
  String get downloadingCore => 'Downloading sing-box…';

  @override
  String get coreInstalledOk => 'Core installed';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get confirmDeleteTitle => 'Delete?';

  @override
  String confirmDeleteNode(String name) {
    return 'Delete server \"$name\"?';
  }

  @override
  String confirmDeleteSub(String name) {
    return 'Delete subscription \"$name\"? Its servers will be removed too.';
  }
}
