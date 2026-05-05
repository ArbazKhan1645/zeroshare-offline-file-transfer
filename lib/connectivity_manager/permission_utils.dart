import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static Future<bool> requestPermissions() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      return false;
    }

    status = await Permission.bluetooth.request();
    if (!status.isGranted) {
      return false;
    }

    return true;
  }

  static Future<bool> checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final bluetoothStatus = await Permission.bluetooth.status;
    // var wifiStatus = await Permission.nearbyWifiDevices.status;

    return locationStatus.isGranted && bluetoothStatus.isGranted;
  }
}
