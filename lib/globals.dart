import 'dart:io';

import 'package:download_assets/download_assets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import './services/transfer.dart';

class App {
  static SharedPreferences? localStorage;
  static DownloadAssetsController downloadAssetsController =
      DownloadAssetsController();
  static bool assetExists = false;
  static var tflite_model = "";
  //static var transfer;
  //static Interpreter? inter;
  static Future init() async {
    localStorage = await SharedPreferences.getInstance();
    await downloadAssetsController.init();
    assetExists = await downloadAssetsController.assetsDirAlreadyExists();
    if (assetExists) localStorage?.setBool("downloaded", true);
    tflite_model =
        "${downloadAssetsController.assetsDir}/lite-model_mirnet-fixed_integer_1.tflite";
   // inter = await Interpreter.fromAsset("lite-model_mirnet-fixed_integer_1.tflite");
   // transfer = Transfer(inter!);
  }
//   static Future<File> getFile(String fileName) async {
// //final appDir = await getTemporaryDirectory();
// //final appPath = appDir.path;
// final fileOnDevice = File(tflite_model);
// final rawAssetFile = await rootBundle.load(fileName);
// final rawBytes = rawAssetFile.buffer.asUint8List();
// await fileOnDevice.writeAsBytes(rawBytes, flush: true);
// return fileOnDevice;
// }
}
