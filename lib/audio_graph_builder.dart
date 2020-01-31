import 'dart:convert';

import 'package:audio_graph/audio_format.dart';
import 'package:audio_graph/audio_graph.dart';
import 'package:audio_graph/nodes/audio_node.dart';
import 'package:audio_graph/pins/pins.dart';
import 'package:flutter/services.dart';

/// AudioGraphBuilder will build the AudioGraph
/// Add AudioNodes to AudioGraphBuilder.nodes and connect these pins. Then call AudioGraphBuilder.build()
class AudioGraphBuilder {
  static const MethodChannel _channel =
      MethodChannel("audio_graph/graph_builder");

  /// AudioNodes used by AudioGraph
  List<AudioNode> nodes = List();
  Map<OutputPin, InputPin> _connections = Map();

  /// Connect the output pin to input pin
  void connect(OutputPin output, InputPin input) {
    assert(input.format == AudioFormat.any() || output.format == input.format);
    _connections[output] = input;
  }

  /// Disconnect the output pin
  void disconnect(OutputPin output) {
    _connections.remove(output);
  }

  /// Build the AudioGraph if the connection is valid
  /// If it is not valid state, Exception will be thrown
  Future<AudioGraph> build() async {
    Map<String, int> connections = Map();
    for (var out in _connections.keys) {
      connections[out.id.toString()] = _connections[out].id;
    }

    final jsonGraph = jsonEncode({
      "connections": connections,
      "nodes": nodes,
    });

    final id = await _channel.invokeMethod('build', [jsonGraph]);
    if (id != null) {
      return AudioGraph(id);
    }

    return null;
  }
}
