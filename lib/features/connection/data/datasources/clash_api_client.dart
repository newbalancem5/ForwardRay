import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/entities/traffic.dart';

/// Talks to sing-box's Clash API for liveness, live traffic and delay tests.
class ClashApiClient {
  ClashApiClient({required this.port, required this.secret});

  final int port;
  final String secret;

  String get _base => 'http://127.0.0.1:$port';
  Map<String, String> get _headers =>
      secret.isEmpty ? {} : {'Authorization': 'Bearer $secret'};

  WebSocketChannel? _trafficChannel;

  Stream<TrafficSample> trafficStream() {
    final tokenQuery = secret.isEmpty ? '' : '?token=$secret';
    final uri = Uri.parse('ws://127.0.0.1:$port/traffic$tokenQuery');
    final channel = WebSocketChannel.connect(uri);
    _trafficChannel = channel;
    return channel.stream.map((event) {
      try {
        final j = jsonDecode(event as String) as Map<String, dynamic>;
        return TrafficSample(
          (j['up'] as num?)?.toInt() ?? 0,
          (j['down'] as num?)?.toInt() ?? 0,
        );
      } catch (_) {
        return TrafficSample.zero;
      }
    });
  }

  void closeTraffic() {
    _trafficChannel?.sink.close();
    _trafficChannel = null;
  }

  Future<TrafficTotals> totals() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/connections'), headers: _headers)
          .timeout(const Duration(seconds: 3));
      if (res.statusCode != 200) return TrafficTotals.zero;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return TrafficTotals(
        (j['uploadTotal'] as num?)?.toInt() ?? 0,
        (j['downloadTotal'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return TrafficTotals.zero;
    }
  }

  /// Confirms the API is reachable (core up and listening).
  Future<bool> ping() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/version'), headers: _headers)
          .timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
