import 'dart:convert';

import 'package:audio_graph/audio_format.dart';
import 'package:audio_graph/audio_graph.dart';
import 'package:audio_graph/nodes/audio_node.dart';
import 'package:audio_graph/pins/pins.dart';
import 'package:flutter/services.dart';

/// AudioGraphBuilder will build the AudioGraph
/// Add AudioNodes to nodes property and connect pins. Then call build()
class AudioGraphBuilder {
  static const MethodChannel _channel =
      MethodChannel('audio_graph/graph_builder');

  /// AudioNodes used by AudioGraph
  final List<AudioNode> nodes = <AudioNode>[];
  final _connections = <OutputPin, InputPin>{};

  /// Connect the output pin to input pin
  void connect(OutputPin output, InputPin input) {
    if (input.format != const AudioFormat.any()) {
      assert(output.format == input.format);
    }
    _connections[output] = input;
  }

  /// Disconnect the output pin
  void disconnect(OutputPin output) {
    _connections.remove(output);
  }

  /// Build the AudioGraph if the connection is valid
  /// If it is not valid state, Exception will be thrown
  Future<AudioGraph> build() async {
    final connections = <String, int>{};
    for (final out in _connections.keys) {
      connections[out.id.toString()] = _connections[out].id;
    }

    final jsonGraph = jsonEncode({
      'connections': connections,
      'nodes': nodes,
    });

    final id = await _channel.invokeMethod<int>('build', [jsonGraph]);
    if (id != null) {
      return AudioGraph(id);
    }

    return null;
  }
}
