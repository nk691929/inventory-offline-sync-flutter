import 'package:collaborative_inventory/core/network/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  ConnectivityServiceImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result.any((r) => r != ConnectivityResult.none),
    );
  }
}
