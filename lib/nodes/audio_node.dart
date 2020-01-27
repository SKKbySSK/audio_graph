import 'package:audio_graph/id_manager.dart';
import 'package:audio_graph/pins/pins.dart';
import 'package:flutter/services.dart';

abstract class AudioNode {
  static const MethodChannel _channel = MethodChannel("audio_graph/node");

  int _id = IdManager.generate("Node");
  get id => _id;

  double _volume = 1;
  get volume => _volume;
  set volume(double newValue) {
    _volume = newValue;
    send('volume', [newValue]);
  }

  Map<String, String> parameters = Map();

  String get nodeName;
  List<InputPin> get inputPins;
  List<OutputPin> get outputPins;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nodeName,
      'volume': volume,
      'inputs': inputPins,
      'outputs': outputPins,
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
