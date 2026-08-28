import 'package:collaborative_inventory/core/network/connectivity_service.dart';
import 'package:collaborative_inventory/core/network/connectivity_service_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider=Provider<ConnectivityService>((ref)=>ConnectivityServiceImpl());