import 'dart:convert';

import 'package:audio_graph/audio_format.dart';
import 'package:audio_graph/audio_graph.dart';
import 'package:audio_graph/id_manager.dart';
import 'package:audio_graph/pins/pins.dart';
import 'package:flutter/services.dart';
export 'package:audio_graph/nodes/audio_node.dart';

abstract class AudioNode {
  static const MethodChannel _channel = MethodChannel("audio_graph/node");

  List<InputPin> _inputs = List();
  List<OutputPin> _outputs = List();
  int _id = IdManager.generate("Node");
  double _volume = 1;

  get id => _id;
  get inputPins => List.unmodifiable(_inputs);
  get outputPins => List.unmodifiable(_outputs);
  get volume => _volume;
  set volume(double newValue) {
    _volume = newValue;
    send('volume', [newValue]);
  }

  Map<String, String> parameters = Map();

  String get nodeName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nodeName,
      'volume': volume,
      'inputs': _inputs,
      'outputs': _outputs,
      'parameters': parameters,
    };
  }

  Future<dynamic> send(String method, List<dynamic> arguments) {
    List<dynamic> args = [id];
    args.addAll(arguments);
    return _channel.invokeMethod(method, args);
  }
}

abstract class AudioSourceNode extends AudioNode {}

abstract class AudioOutputNode extends AudioNode {}

class AudioDeviceOutputNode extends AudioOutputNode {
  static const String name = 'audio_device_output_node';

  InputPin inputPin = InputPin(AudioFormat.any());

  AudioDeviceOutputNode() {
    _inputs.add(inputPin);
  }

  @override
  String get nodeName => name;
}

class AudioFileNode extends AudioSourceNode {
  static const String name = 'audio_file_node';

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

  AudioFileNode(this.path) {
    _commonInit();
  }

  AudioFileNode.fromJson(Map<String, dynamic> json) : path = json['path'] {
    _commonInit();
  }

  Future prepare() async {
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

class AudioMixerNode extends AudioNode {
  static const String name = 'audio_mixer_node';
  OutputPin outputPin = OutputPin(AudioFormat.any());

  AudioMixerNode() {
    _outputs.add(outputPin);
  }

  InputPin appendInputPin() {
    final pin = InputPin(AudioFormat.any());
    _inputs.add(pin);

    return pin;
  }

  @override
  String get nodeName => name;
}
