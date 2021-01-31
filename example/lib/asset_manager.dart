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

  static final Map<String, String> _cachedSampleAssetItems = {};

  // Extract the asset data and export to the app's document directory
  static Future<String> exportMusicFile(String asset) async {
    if (_cachedSampleAssetItems.containsKey(asset)) {
      return _cachedSampleAssetItems[asset];
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$asset');

    try {
      var data = await rootBundle.load('assets/$asset');
      await file.writeAsBytes(data.buffer.asInt8List());
      _cachedSampleAssetItems[asset] = file.path;

      return file.path;
    } catch (_) {
      return null;
    }
  }
}
