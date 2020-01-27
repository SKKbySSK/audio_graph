import 'dart:async';
import 'package:flutter/services.dart';

export 'package:audio_graph/audio_format.dart';
export 'package:audio_graph/audio_graph.dart';
export 'package:audio_graph/audio_graph_builder.dart';
export 'package:audio_graph/nodes/audio_node.dart';
export 'package:audio_graph/nodes/audio_device_output_node.dart';
export 'package:audio_graph/nodes/audio_file_player_node.dart';
export 'package:audio_graph/nodes/audio_mixer_node.dart';
export 'package:audio_graph/pins/pins.dart';

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
