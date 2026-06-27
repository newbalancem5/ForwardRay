import 'package:equatable/equatable.dart';

/// How traffic is routed by the core.
enum RoutingMode { global, rule, direct }

/// User-tunable application settings.
class AppSettings extends Equatable {
  const AppSettings({
    this.localPort = 2080,
    this.clashApiPort = 9090,
    this.clashApiSecret = 'forwardray',
    this.themeModeName = 'system', // system | light | dark
    this.languageCode, // null = system
    this.minimizeToTray = true,
    this.launchAtStartup = false,
    this.autoConnectOnStart = false,
    this.routingMode = RoutingMode.rule,
    this.bypassLan = true,
    this.blockAds = false,
    this.logLevel = 'info',
    this.selectedNodeId,
  });

  final int localPort;
  final int clashApiPort;
  final String clashApiSecret;
  final String themeModeName;
  final String? languageCode;
  final bool minimizeToTray;
  final bool launchAtStartup;
  final bool autoConnectOnStart;
  final RoutingMode routingMode;
  final bool bypassLan;
  final bool blockAds;
  final String logLevel;
  final String? selectedNodeId;

  AppSettings copyWith({
    int? localPort,
    int? clashApiPort,
    String? clashApiSecret,
    String? themeModeName,
    String? languageCode,
    bool clearLanguage = false,
    bool? minimizeToTray,
    bool? launchAtStartup,
    bool? autoConnectOnStart,
    RoutingMode? routingMode,
    bool? bypassLan,
    bool? blockAds,
    String? logLevel,
    String? selectedNodeId,
    bool clearSelectedNode = false,
  }) {
    return AppSettings(
      localPort: localPort ?? this.localPort,
      clashApiPort: clashApiPort ?? this.clashApiPort,
      clashApiSecret: clashApiSecret ?? this.clashApiSecret,
      themeModeName: themeModeName ?? this.themeModeName,
      languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      launchAtStartup: launchAtStartup ?? this.launchAtStartup,
      autoConnectOnStart: autoConnectOnStart ?? this.autoConnectOnStart,
      routingMode: routingMode ?? this.routingMode,
      bypassLan: bypassLan ?? this.bypassLan,
      blockAds: blockAds ?? this.blockAds,
      logLevel: logLevel ?? this.logLevel,
      selectedNodeId:
          clearSelectedNode ? null : (selectedNodeId ?? this.selectedNodeId),
    );
  }

  @override
  List<Object?> get props => [
        localPort,
        clashApiPort,
        clashApiSecret,
        themeModeName,
        languageCode,
        minimizeToTray,
        launchAtStartup,
        autoConnectOnStart,
        routingMode,
        bypassLan,
        blockAds,
        logLevel,
        selectedNodeId,
      ];
}
