import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

/// Makes every Dart HTTPS request trust the bundled Mozilla CA root set.
///
/// On Windows the engine's built-in root store is incomplete, which breaks
/// HTTPS with `CERTIFICATE_VERIFY_FAILED: unable to get local issuer
/// certificate` (e.g. downloading the core or subscriptions). Loading the
/// standard Mozilla bundle fixes this on every platform without weakening
/// verification (we trust a well-known root set, not "any" certificate).
class CaHttpOverrides extends HttpOverrides {
  CaHttpOverrides(this._caPem);

  final List<int> _caPem;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    try {
      final ctx = SecurityContext(withTrustedRoots: false)
        ..setTrustedCertificatesBytes(_caPem);
      return super.createHttpClient(ctx);
    } catch (_) {
      // Fall back to default trust if the bundle can't be applied.
      return super.createHttpClient(context);
    }
  }

  /// Loads the bundled CA set and installs the override globally. Safe no-op if
  /// the asset is missing.
  static Future<void> install() async {
    try {
      final data = await rootBundle.load('assets/ca/cacert.pem');
      HttpOverrides.global = CaHttpOverrides(data.buffer.asUint8List());
    } catch (_) {
      // Leave default behavior if the bundle isn't available.
    }
  }
}
