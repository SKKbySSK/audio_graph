import 'dart:async';

import 'package:flutter/services.dart';

export 'package:audio_graph/audio_format.dart';
export 'package:audio_graph/audio_graph.dart';
export 'package:audio_graph/audio_graph_builder.dart';
export 'package:audio_graph/nodes/audio_device_output_node.dart';
export 'package:audio_graph/nodes/audio_file_player_node.dart';
export 'package:audio_graph/nodes/audio_mixer_node.dart';
export 'package:audio_graph/nodes/audio_node.dart';
export 'package:audio_graph/pins/pins.dart';

/// AudioGraph manages AudioNodes and connection state.
/// You MUST call dispose, when the graph is not necessary
class AudioGraph {
  /// Use AudioGraphBuilder.build() instead of this constructor
  AudioGraph(this.graphId);

  static const MethodChannel _channel = MethodChannel('audio_graph/graph');

  /// Internally used identifier of the graph
  final int graphId;

  /// Release the audio resources and connection state.
  Future<bool> dispose() async {
    final result = await _channel.invokeMethod<bool>('dispose', [graphId]);
    return result;
  }
}
