import 'dart:io';

/// Lightweight TCP-connect latency probe — works whether or not the core is
/// running.
class TcpPinger {
  const TcpPinger();

  Future<int> measure(String host, int port,
      {Duration timeout = const Duration(seconds: 4)}) async {
    final sw = Stopwatch()..start();
    Socket? socket;
    try {
      socket = await Socket.connect(host, port, timeout: timeout);
      sw.stop();
      return sw.elapsedMilliseconds;
    } catch (_) {
      return -1;
    } finally {
      await socket?.close();
    }
  }
}
