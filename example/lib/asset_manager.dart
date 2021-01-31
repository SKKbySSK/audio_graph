import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AssetManager {
  AssetManager._();

  // You should add these files to example/assets/ folder to test in your local workspace
  static const sampleAssetItems = [
    'test1.mp3',
    'test2.mp3',
    'test3.mp3',
  ];

  // Extract the asset data and export to the app's document directory
  static Future<String> exportMusicFile(String asset) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$asset');
    var data = await rootBundle.load('assets/$asset');
    await file.writeAsBytes(data.buffer.asInt8List());
    return file.path;
  }
}
