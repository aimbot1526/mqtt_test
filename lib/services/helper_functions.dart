import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HelperFunctions {
  static const customFileFolder = "/storage/emulated/0";
  static double myLatitude = 0;
  static double myLongtitude = 0;
  static Uint8List customMarker = 0 as Uint8List;

  static Future<bool> requestLocationPermission() async {
    final serviceStatusLocation =
        await ph.Permission.locationWhenInUse.isGranted;

    bool isLocation = serviceStatusLocation == ph.ServiceStatus.enabled;

    final status = await ph.Permission.locationWhenInUse.request();

    if (status == ph.PermissionStatus.granted) {
      return true;
    } else if (status == ph.PermissionStatus.denied) {
      return false;
    } else if (status == ph.PermissionStatus.permanentlyDenied) {
      await ph.openAppSettings();
      return false;
    }
    return false;
  }

  static Future<Map<String, String>> getCurrentPosition(
      BuildContext context) async {
    final hasPermission = await requestLocationPermission();

    if (!hasPermission) return locationResponse(0, 0, true.toString());
    Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    myLatitude = p.latitude;
    myLongtitude = p.longitude;
    return locationResponse(p.latitude, p.longitude, false.toString());
  }

  static Map<String, String> locationResponse(
      double lat, double long, String err) {
    Map<String, String> temp = {
      "error": err,
      "lat": lat.toString(),
      "long": long.toString()
    };
    return temp;
  }

  static Future<Uint8List> getBytesFromAsset(
      {required String path, required int width}) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width, targetHeight: 200);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<void> changeImageToMarker() async {
    customMarker =
        await getBytesFromAsset(path: "assets/images/car.png", width: 100);
  }

  static Future<void> saveXFileToFolder(XFile xFile) async {
    if (await ph.Permission.manageExternalStorage.request().isGranted) {
      final filePath = '$customFileFolder/TestFlutter/${xFile.name}';
      final bytes = await xFile.readAsBytes();
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
  }

  static Future<void> saveFileToFolder(File f) async {
    if (await ph.Permission.manageExternalStorage.request().isGranted) {
      final filePath = '$customFileFolder/TestFlutter/${f.path}';
      final bytes = await f.readAsBytes();
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
  }

  static Future<File> getAudioFile() async {
    var content = await rootBundle.load("assets/audio/audio.wav");
    final directory = await getApplicationDocumentsDirectory();
    var file = File("${directory.path}/audio.wav");
    file.writeAsBytesSync(content.buffer.asUint8List());
    return file;
  }
}
