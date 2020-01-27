import 'dart:convert';

import 'package:audio_graph/audio_format.dart';
import 'package:audio_graph/audio_graph.dart';
import 'package:audio_graph/error.dart';
import 'package:audio_graph/nodes/audio_node.dart';
import 'package:audio_graph/pins/pins.dart';
import 'package:flutter/services.dart';

class AudioGraphBuilder {
  static const MethodChannel _channel =
      MethodChannel("audio_graph/graph_builder");
  List<AudioNode> nodes = List();
  Map<OutputPin, InputPin> _connections = Map();

  void connect(OutputPin output, InputPin input) {
    assert(input.format == AudioFormat.any() || output.format == input.format);
    _connections[output] = input;
  }

  void disconnect(OutputPin output) {
    _connections.remove(output);
  }

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
