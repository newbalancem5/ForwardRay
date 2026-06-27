// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'ForwardRay';

  @override
  String get navHome => 'Главная';

  @override
  String get navServers => 'Серверы';

  @override
  String get navSubscriptions => 'Подписки';

  @override
  String get navRouting => 'Маршруты';

  @override
  String get navSettings => 'Настройки';

  @override
  String get connect => 'Подключить';

  @override
  String get disconnect => 'Отключить';

  @override
  String get connecting => 'Подключение…';

  @override
  String get statusConnected => 'Подключено';

  @override
  String get statusDisconnected => 'Отключено';

  @override
  String get statusError => 'Ошибка';

  @override
  String get tapToConnect => 'Нажмите, чтобы подключиться';

  @override
  String get tapToDisconnect => 'Нажмите, чтобы отключиться';

  @override
  String get selectedServer => 'Выбранный сервер';

  @override
  String get noServerSelected => 'Сервер не выбран';

  @override
  String get uploadSpeed => 'Отдача';

  @override
  String get downloadSpeed => 'Загрузка';

  @override
  String get totalUp => 'Всего отдано';

  @override
  String get totalDown => 'Всего принято';

  @override
  String get addServer => 'Добавить сервер';

  @override
  String get importFromClipboard => 'Импорт из буфера';

  @override
  String get pingAll => 'Проверить все';

  @override
  String get noServers =>
      'Серверов пока нет. Добавьте по ссылке или через подписку.';

  @override
  String get deleteServer => 'Удалить';

  @override
  String get renameServer => 'Переименовать';

  @override
  String get testLatency => 'Проверить задержку';

  @override
  String get addFromLink => 'Добавить по ссылке';

  @override
  String get pasteLinkHint =>
      'Вставьте ссылки vless:// vmess:// trojan:// ss:// (по одной на строку)';

  @override
  String serversAdded(int count) {
    return 'Добавлено серверов: $count';
  }

  @override
  String get nothingParsed => 'Не удалось распознать ни одного сервера';

  @override
  String ms(int value) {
    return '$value мс';
  }

  @override
  String get untested => 'не проверено';

  @override
  String get timeout => 'таймаут';

  @override
  String get addSubscription => 'Добавить подписку';

  @override
  String get subscriptionName => 'Название';

  @override
  String get subscriptionUrl => 'URL';

  @override
  String get updateAll => 'Обновить все';

  @override
  String get update => 'Обновить';

  @override
  String get delete => 'Удалить';

  @override
  String lastUpdated(String date) {
    return 'Обновлено: $date';
  }

  @override
  String get never => 'никогда';

  @override
  String nodesCount(int count) {
    return 'Серверов: $count';
  }

  @override
  String get noSubscriptions =>
      'Подписок нет. Добавьте URL подписки, чтобы загрузить серверы.';

  @override
  String get updating => 'Обновление…';

  @override
  String updateFailed(String error) {
    return 'Ошибка обновления: $error';
  }

  @override
  String get routingMode => 'Режим маршрутизации';

  @override
  String get routingModeDesc => 'Как ядро направляет трафик';

  @override
  String get modeGlobal => 'Глобально';

  @override
  String get modeRule => 'По правилам';

  @override
  String get modeDirect => 'Напрямую';

  @override
  String get bypassLan => 'Обход локальной сети';

  @override
  String get bypassLanDesc => 'Локальные / приватные адреса мимо прокси';

  @override
  String get blockAds => 'Блокировать рекламу';

  @override
  String get blockAdsDesc =>
      'Отбрасывать рекламные/трекерные домены (скачает базу правил)';

  @override
  String get settingsGeneral => 'Общие';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get minimizeToTray => 'Сворачивать в трей при закрытии';

  @override
  String get minimizeToTrayDesc => 'Оставаться в трее, а не выходить';

  @override
  String get launchAtStartup => 'Запуск при старте системы';

  @override
  String get autoConnect => 'Автоподключение при запуске';

  @override
  String get settingsNetwork => 'Сеть';

  @override
  String get localPort => 'Порт локального прокси';

  @override
  String get clashApiPort => 'Порт Clash API';

  @override
  String get settingsCore => 'Ядро';

  @override
  String get coreInstalled => 'sing-box установлен';

  @override
  String get coreNotInstalled => 'sing-box не найден';

  @override
  String get installCore => 'Установить ядро…';

  @override
  String get downloadCore => 'Скачать ядро';

  @override
  String get downloadingCore => 'Загрузка sing-box…';

  @override
  String get coreInstalledOk => 'Ядро установлено';

  @override
  String get about => 'О программе';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get add => 'Добавить';

  @override
  String get close => 'Закрыть';

  @override
  String get confirmDeleteTitle => 'Удалить?';

  @override
  String confirmDeleteNode(String name) {
    return 'Удалить сервер «$name»?';
  }

  @override
  String confirmDeleteSub(String name) {
    return 'Удалить подписку «$name»? Её серверы тоже будут удалены.';
  }
}
