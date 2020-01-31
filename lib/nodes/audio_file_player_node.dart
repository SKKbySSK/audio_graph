import 'dart:convert';

import 'package:audio_graph/audio_format.dart';
import 'package:audio_graph/nodes/audio_node.dart';
import 'package:audio_graph/pins/pins.dart';
import 'package:flutter/services.dart';

class AudioFilePlayerNode extends AudioSourceNode {
  static const String name = 'audio_file_player_node';
  static const MethodChannel _channel = MethodChannel("audio_graph/file");

  bool _isPlaying = false;
  double _position = 0;
  double _duration = 0;

  get isPlaying => _isPlaying;
  get position => _position;
  set position(double value) {
    _position = value;
    send('set_position', [_position]);
  }

  get duration => _duration;

  final String path;
  OutputPin outputPin;

  List<InputPin> _inputs = List();
  List<OutputPin> _outputs = List();

  @override
  List<InputPin> get inputPins => List.unmodifiable(_inputs);

  @override
  List<OutputPin> get outputPins => List.unmodifiable(_outputs);

  static Future<AudioFilePlayerNode> createNode(String path) async {
    final node = AudioFilePlayerNode._(path);
    await node._prepare();
    return node;
  }

  AudioFilePlayerNode._(this.path) {
    _commonInit();
  }

  AudioFilePlayerNode.fromJson(Map<String, dynamic> json)
      : path = json['path'] {
    _commonInit();
  }

  Future _prepare() async {
    _duration = await _channel.invokeMethod("get_duration", [path]);
    final jsonFormat = await _channel.invokeMethod("get_format", [path]);
    final format = AudioFormat.fromJson(jsonDecode(jsonFormat));
    outputPin = OutputPin(format);
    _outputs.add(outputPin);
  }

  void _commonInit() {
    parameters['path'] = this.path;
  }

  @override
  String get nodeName => name;

  Future play() async {
    _isPlaying = true;
    await send('play', []);
  }

  Future pause() async {
    _isPlaying = false;
    await send('pause', []);
  }

  Future<double> updatePosition() async {
    return _position = await send('get_position', []);
  }
}
