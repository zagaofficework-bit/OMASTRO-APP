import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  static Future<void> requestAppPermissions() async {
    if (kIsWeb) return;

    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isDenied) {
        await permission.request();
      }
    }
  }
}
