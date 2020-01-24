import 'dart:async';

import 'package:flutter/services.dart';

class AudioGraph {
  static const MethodChannel _channel = MethodChannel("audio_graph/graph");

  final int graphId;

  bool _isPlaying = false;
  get isPlaying => _isPlaying;

  AudioGraph(this.graphId);

  Future<bool> dispose() async {
    final result = await _channel.invokeMethod('dispose', [graphId]);
    if (result) {
      _isPlaying = false;
    }

    return result;
  }
}
