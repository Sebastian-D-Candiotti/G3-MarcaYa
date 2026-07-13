import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    Stream<List<ConnectivityResult>>? changes,
    Future<List<ConnectivityResult>> Function()? checker,
  })  : _connectivity = connectivity ?? Connectivity(),
        _changes = changes,
        _checker = checker;

  final Connectivity _connectivity;
  final Stream<List<ConnectivityResult>>? _changes;
  final Future<List<ConnectivityResult>> Function()? _checker;

  Stream<bool> get onConnectionChanged {
    return (_changes ?? _connectivity.onConnectivityChanged)
        .map(_hasConnection)
        .distinct();
  }

  Future<bool> hasConnection() async {
    final results = await (_checker?.call() ?? _connectivity.checkConnectivity());
    return _hasConnection(results);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
