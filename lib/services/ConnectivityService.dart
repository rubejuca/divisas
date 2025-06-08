import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static Map<String, double> defaultRates = {
    'USD': 0.00026,
    'EUR': 0.00024,
    'GBP': 0.00020,
  };
}
