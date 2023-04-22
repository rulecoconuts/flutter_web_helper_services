import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:web_helper_services/src/services/device_id/device_identification_service.dart';

/// A simple cross-platform (web, android, IOS)
class BasicDeviceIndentificationService
    extends DeviceIdentificationService<String> {
  @override
  Future<String> getDeviceId() async {
    String uniqueDeviceId = '';

    var deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      uniqueDeviceId = await getIdForWeb(deviceInfo);
    } else if (Platform.isIOS) {
      uniqueDeviceId = await getIdForIOS(deviceInfo);
    } else if (Platform.isAndroid) {
      uniqueDeviceId = await getIdForAndroid(deviceInfo);
    }

    return uniqueDeviceId;
  }

  /// Get ID for IOS device
  Future<String> getIdForIOS(DeviceInfoPlugin deviceInfo) async {
    String uniqueDeviceId = '';

    var iosDeviceInfo = await deviceInfo.iosInfo;

    List<String> propertiesToUse = [
      "I",
      iosDeviceInfo.name ?? "null",
      iosDeviceInfo.identifierForVendor ?? "null"
    ];

    uniqueDeviceId = propertiesToUse.join(":");

    return uniqueDeviceId;
  }

  /// Get ID for a web browser and device
  Future<String> getIdForWeb(DeviceInfoPlugin deviceInfo) async {
    String uniqueDeviceId = 'W:';
    var webDeviceInfo = await deviceInfo.webBrowserInfo;
    List<String> propertiesToUse = [
      "W",
      webDeviceInfo.browserName.name,
      webDeviceInfo.userAgent ?? "null"
    ];

    uniqueDeviceId = propertiesToUse.join(":");

    return uniqueDeviceId;
  }

  /// Get ID for an android device
  Future<String> getIdForAndroid(DeviceInfoPlugin deviceInfo) async {
    String uniqueDeviceId = '';

    var androidDeviceInfo = await deviceInfo.androidInfo;
    List<String> propertiesToUse = [
      "A",
      androidDeviceInfo.brand,
      androidDeviceInfo.product,
      androidDeviceInfo.model,
      androidDeviceInfo.device,
      androidDeviceInfo.manufacturer,
      androidDeviceInfo.display,
      androidDeviceInfo.id,
      androidDeviceInfo.fingerprint
    ];

    uniqueDeviceId = propertiesToUse.join(":");

    return uniqueDeviceId;
  }

  /// Get version string of IOS device
  @override
  Future<String> getIOSVersion() async {
    var iosDeviceInfo = await DeviceInfoPlugin().iosInfo;

    return iosDeviceInfo.utsname.machine ?? "";
  }
}
