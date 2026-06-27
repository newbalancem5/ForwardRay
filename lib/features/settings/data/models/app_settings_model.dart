import '../../domain/entities/app_settings.dart';

extension AppSettingsMapper on AppSettings {
  Map<String, dynamic> toJson() => {
        'localPort': localPort,
        'clashApiPort': clashApiPort,
        'clashApiSecret': clashApiSecret,
        'themeModeName': themeModeName,
        'languageCode': languageCode,
        'minimizeToTray': minimizeToTray,
        'launchAtStartup': launchAtStartup,
        'autoConnectOnStart': autoConnectOnStart,
        'routingMode': routingMode.name,
        'bypassLan': bypassLan,
        'blockAds': blockAds,
        'logLevel': logLevel,
        'selectedNodeId': selectedNodeId,
      };
}

AppSettings appSettingsFromJson(Map<String, dynamic> j) => AppSettings(
      localPort: (j['localPort'] as num?)?.toInt() ?? 2080,
      clashApiPort: (j['clashApiPort'] as num?)?.toInt() ?? 9090,
      clashApiSecret: j['clashApiSecret'] as String? ?? 'forwardray',
      themeModeName: j['themeModeName'] as String? ?? 'system',
      languageCode: j['languageCode'] as String?,
      minimizeToTray: j['minimizeToTray'] as bool? ?? true,
      launchAtStartup: j['launchAtStartup'] as bool? ?? false,
      autoConnectOnStart: j['autoConnectOnStart'] as bool? ?? false,
      routingMode: RoutingMode.values.firstWhere(
        (m) => m.name == j['routingMode'],
        orElse: () => RoutingMode.rule,
      ),
      bypassLan: j['bypassLan'] as bool? ?? true,
      blockAds: j['blockAds'] as bool? ?? false,
      logLevel: j['logLevel'] as String? ?? 'info',
      selectedNodeId: j['selectedNodeId'] as String?,
    );
