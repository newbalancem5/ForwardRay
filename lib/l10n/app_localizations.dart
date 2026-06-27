import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ForwardRay'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navServers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get navServers;

  /// No description provided for @navSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get navSubscriptions;

  /// No description provided for @navRouting.
  ///
  /// In en, this message translates to:
  /// **'Routing'**
  String get navRouting;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get statusConnected;

  /// No description provided for @statusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get statusDisconnected;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusError;

  /// No description provided for @tapToConnect.
  ///
  /// In en, this message translates to:
  /// **'Tap to connect'**
  String get tapToConnect;

  /// No description provided for @tapToDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Tap to disconnect'**
  String get tapToDisconnect;

  /// No description provided for @selectedServer.
  ///
  /// In en, this message translates to:
  /// **'Selected server'**
  String get selectedServer;

  /// No description provided for @noServerSelected.
  ///
  /// In en, this message translates to:
  /// **'No server selected'**
  String get noServerSelected;

  /// No description provided for @uploadSpeed.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadSpeed;

  /// No description provided for @downloadSpeed.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadSpeed;

  /// No description provided for @totalUp.
  ///
  /// In en, this message translates to:
  /// **'Total up'**
  String get totalUp;

  /// No description provided for @totalDown.
  ///
  /// In en, this message translates to:
  /// **'Total down'**
  String get totalDown;

  /// No description provided for @addServer.
  ///
  /// In en, this message translates to:
  /// **'Add server'**
  String get addServer;

  /// No description provided for @importFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Import from clipboard'**
  String get importFromClipboard;

  /// No description provided for @pingAll.
  ///
  /// In en, this message translates to:
  /// **'Test all'**
  String get pingAll;

  /// No description provided for @noServers.
  ///
  /// In en, this message translates to:
  /// **'No servers yet. Add one from a share link or a subscription.'**
  String get noServers;

  /// No description provided for @deleteServer.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteServer;

  /// No description provided for @renameServer.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameServer;

  /// No description provided for @testLatency.
  ///
  /// In en, this message translates to:
  /// **'Test latency'**
  String get testLatency;

  /// No description provided for @addFromLink.
  ///
  /// In en, this message translates to:
  /// **'Add from link'**
  String get addFromLink;

  /// No description provided for @pasteLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste vless:// vmess:// trojan:// ss:// links (one per line)'**
  String get pasteLinkHint;

  /// No description provided for @serversAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} server(s) added'**
  String serversAdded(int count);

  /// No description provided for @nothingParsed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t parse any servers'**
  String get nothingParsed;

  /// No description provided for @ms.
  ///
  /// In en, this message translates to:
  /// **'{value} ms'**
  String ms(int value);

  /// No description provided for @untested.
  ///
  /// In en, this message translates to:
  /// **'untested'**
  String get untested;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'timeout'**
  String get timeout;

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get addSubscription;

  /// No description provided for @subscriptionName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get subscriptionName;

  /// No description provided for @subscriptionUrl.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get subscriptionUrl;

  /// No description provided for @updateAll.
  ///
  /// In en, this message translates to:
  /// **'Update all'**
  String get updateAll;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get never;

  /// No description provided for @nodesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} servers'**
  String nodesCount(int count);

  /// No description provided for @noSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions. Add a subscription URL to fetch servers.'**
  String get noSubscriptions;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get updating;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(String error);

  /// No description provided for @routingMode.
  ///
  /// In en, this message translates to:
  /// **'Routing mode'**
  String get routingMode;

  /// No description provided for @routingModeDesc.
  ///
  /// In en, this message translates to:
  /// **'How traffic is routed through the core'**
  String get routingModeDesc;

  /// No description provided for @modeGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get modeGlobal;

  /// No description provided for @modeRule.
  ///
  /// In en, this message translates to:
  /// **'Rule based'**
  String get modeRule;

  /// No description provided for @modeDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get modeDirect;

  /// No description provided for @bypassLan.
  ///
  /// In en, this message translates to:
  /// **'Bypass LAN'**
  String get bypassLan;

  /// No description provided for @bypassLanDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep local / private addresses off the proxy'**
  String get bypassLanDesc;

  /// No description provided for @blockAds.
  ///
  /// In en, this message translates to:
  /// **'Block ads'**
  String get blockAds;

  /// No description provided for @blockAdsDesc.
  ///
  /// In en, this message translates to:
  /// **'Drop known ad/tracker domains (downloads rule database)'**
  String get blockAdsDesc;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @minimizeToTray.
  ///
  /// In en, this message translates to:
  /// **'Minimize to tray on close'**
  String get minimizeToTray;

  /// No description provided for @minimizeToTrayDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep running in the tray instead of quitting'**
  String get minimizeToTrayDesc;

  /// No description provided for @launchAtStartup.
  ///
  /// In en, this message translates to:
  /// **'Launch at startup'**
  String get launchAtStartup;

  /// No description provided for @autoConnect.
  ///
  /// In en, this message translates to:
  /// **'Auto-connect on launch'**
  String get autoConnect;

  /// No description provided for @settingsNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get settingsNetwork;

  /// No description provided for @localPort.
  ///
  /// In en, this message translates to:
  /// **'Local proxy port'**
  String get localPort;

  /// No description provided for @clashApiPort.
  ///
  /// In en, this message translates to:
  /// **'Clash API port'**
  String get clashApiPort;

  /// No description provided for @settingsCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get settingsCore;

  /// No description provided for @coreInstalled.
  ///
  /// In en, this message translates to:
  /// **'sing-box installed'**
  String get coreInstalled;

  /// No description provided for @coreNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'sing-box not found'**
  String get coreNotInstalled;

  /// No description provided for @installCore.
  ///
  /// In en, this message translates to:
  /// **'Install core…'**
  String get installCore;

  /// No description provided for @downloadCore.
  ///
  /// In en, this message translates to:
  /// **'Download core'**
  String get downloadCore;

  /// No description provided for @downloadingCore.
  ///
  /// In en, this message translates to:
  /// **'Downloading sing-box…'**
  String get downloadingCore;

  /// No description provided for @coreInstalledOk.
  ///
  /// In en, this message translates to:
  /// **'Core installed'**
  String get coreInstalledOk;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteNode.
  ///
  /// In en, this message translates to:
  /// **'Delete server \"{name}\"?'**
  String confirmDeleteNode(String name);

  /// No description provided for @confirmDeleteSub.
  ///
  /// In en, this message translates to:
  /// **'Delete subscription \"{name}\"? Its servers will be removed too.'**
  String confirmDeleteSub(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
