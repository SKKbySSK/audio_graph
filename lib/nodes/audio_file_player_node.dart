import 'dart:convert';

import 'package:audio_graph/audio_format.dart';
import 'package:audio_graph/nodes/audio_node.dart';
import 'package:audio_graph/pins/pins.dart';
import 'package:flutter/services.dart';

/// AudioFilePlayerNode can decode the local audio file and control playback.
class AudioFilePlayerNode extends AudioSourceNode {
  AudioFilePlayerNode._(this.path) {
    _commonInit();
  }

  AudioFilePlayerNode.fromJson(Map<String, dynamic> json)
      : path = json['path'] as String {
    _commonInit();
  }

  static const String name = 'audio_file_player_node';
  static const MethodChannel _channel = MethodChannel('audio_graph/file');

  bool _isPlaying = false;
  double _position = 0;
  double _duration = 0;

  bool get isPlaying => _isPlaying;
  double get position => _position;
  set position(double value) {
    _position = value;
    send<void>('set_position', <dynamic>[_position]);
  }

  double get duration => _duration;

  final String path;
  OutputPin outputPin;

  final _inputs = <InputPin>[];
  final _outputs = <OutputPin>[];

  @override
  List<InputPin> get inputPins => List.unmodifiable(_inputs);

  @override
  List<OutputPin> get outputPins => List.unmodifiable(_outputs);

  static Future<AudioFilePlayerNode> createNode(String path) async {
    final node = AudioFilePlayerNode._(path);
    await node._prepare();
    return node;
  }

  Future _prepare() async {
    _duration = await _channel.invokeMethod('get_duration', [path]);
    final jsonFormat =
        await _channel.invokeMethod<String>('get_format', <dynamic>[path]);
    final format =
        AudioFormat.fromJson(jsonDecode(jsonFormat) as Map<String, dynamic>);
    outputPin = OutputPin(format);
    _outputs.add(outputPin);
  }

  void _commonInit() {
    parameters['path'] = path;
  }

  @override
  String get nodeName => name;

  Future play() async {
    _isPlaying = true;
    await send<void>('play', <dynamic>[]);
  }

  Future pause() async {
    _isPlaying = false;
    await send<void>('pause', <dynamic>[]);
  }

  Future<double> updatePosition() async {
    final pos = await send<double>('get_position', <dynamic>[]);
    return _position = pos;
  }
}
