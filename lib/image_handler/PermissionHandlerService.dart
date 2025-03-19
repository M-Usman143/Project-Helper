import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  static Future<bool> requestCameraPermission() async {
    final cameraStatus = await Permission.camera.request();
    return cameraStatus.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final storageStatus = await Permission.photos.request();
    return storageStatus.isGranted;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }

  static Future<bool> requestPhonePermission() async {
    final phoneStatus = await Permission.phone.request();
    if (phoneStatus.isGranted) {
      return true;
    } else if (phoneStatus.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }
}
