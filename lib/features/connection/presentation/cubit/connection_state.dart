part of 'connection_cubit.dart';

class ConnectionUiState extends Equatable {
  const ConnectionUiState({
    this.status = ConnectionStatus.disconnected,
    this.error,
    this.traffic = TrafficSample.zero,
    this.totals = TrafficTotals.zero,
    this.coreInstalled = false,
    this.coreDownloading = false,
    this.coreDownloadProgress = 0,
  });

  final ConnectionStatus status;
  final String? error;
  final TrafficSample traffic;
  final TrafficTotals totals;
  final bool coreInstalled;
  final bool coreDownloading;
  final double coreDownloadProgress;

  ConnectionUiState copyWith({
    ConnectionStatus? status,
    String? error,
    bool clearError = false,
    TrafficSample? traffic,
    TrafficTotals? totals,
    bool? coreInstalled,
    bool? coreDownloading,
    double? coreDownloadProgress,
  }) =>
      ConnectionUiState(
        status: status ?? this.status,
        error: clearError ? null : (error ?? this.error),
        traffic: traffic ?? this.traffic,
        totals: totals ?? this.totals,
        coreInstalled: coreInstalled ?? this.coreInstalled,
        coreDownloading: coreDownloading ?? this.coreDownloading,
        coreDownloadProgress: coreDownloadProgress ?? this.coreDownloadProgress,
      );

  @override
  List<Object?> get props => [
        status,
        error,
        traffic,
        totals,
        coreInstalled,
        coreDownloading,
        coreDownloadProgress,
      ];
}
