/// Base failure type surfaced from the data layer to cubits.
class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class CoreNotFoundFailure extends Failure {
  const CoreNotFoundFailure() : super('sing-box binary not found');
}

class CoreStartFailure extends Failure {
  const CoreStartFailure(super.message);
}

class ConfigFailure extends Failure {
  const ConfigFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
