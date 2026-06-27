import 'package:flutter/material.dart';

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  double v = bytes / 1024;
  int i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v.toStringAsFixed(v >= 100 ? 0 : 1)} ${units[i]}';
}

String formatSpeed(int bytesPerSec) => '${formatBytes(bytesPerSec)}/s';

/// Color for a latency value: null = untested, <0 = failed.
Color latencyColor(int? ms, ColorScheme scheme) {
  if (ms == null) return scheme.outline;
  if (ms < 0) return scheme.error;
  if (ms < 150) return const Color(0xFF2BBF6A);
  if (ms < 350) return const Color(0xFFE0A100);
  return const Color(0xFFE0593F);
}
