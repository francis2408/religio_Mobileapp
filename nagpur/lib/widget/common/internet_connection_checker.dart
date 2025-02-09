import 'package:connectivity/connectivity.dart';

class CheckInternetConnection {
  static Future checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }
}