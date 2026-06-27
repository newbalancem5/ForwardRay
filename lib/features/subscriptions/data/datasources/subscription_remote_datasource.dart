import 'package:http/http.dart' as http;

import '../../../../core/error/failure.dart';

/// Downloads the raw body of a subscription URL.
class SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSource();

  Future<String> download(String url) async {
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'ForwardRay/1.0 (sing-box)'},
      ).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        throw NetworkFailure('HTTP ${res.statusCode}');
      }
      return res.body;
    } on Failure {
      rethrow;
    } catch (e) {
      throw NetworkFailure('$e');
    }
  }
}
