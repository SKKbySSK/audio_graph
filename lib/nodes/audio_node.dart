import 'package:audio_graph/id_manager.dart';
import 'package:audio_graph/pins/pins.dart';
import 'package:flutter/services.dart';

/// AudioNode is a abstract base class.
/// All nodes have one or more input pin and output pin.
/// You can connect these pins using AudioGraphBuilder.
/// Also, all nodes have volume property to control it.
/// Due to audio processing requires high performance process, We don't support creating custom node
abstract class AudioNode {
  static const MethodChannel _channel = MethodChannel("audio_graph/node");

  int _id = IdManager.generate("Node");
  get id => _id;

  double _volume = 1;

  /// Get volume of the node
  get volume => _volume;

  /// Set volume of the node
  set volume(double newValue) {
    _volume = newValue;
    send('volume', [newValue]);
  }

  /// Custom parameters of the node
  /// This property is used internally
  Map<String, String> parameters = Map();

  /// Name to determine the type of the node
  /// This property is used internally
  String get nodeName;

  /// All InputPins of the node
  List<InputPin> get inputPins;

  /// All OutputPins of the node
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

  /// Send the message using PlatformChannel
  /// Do not use this function outside of the node class
  Future<dynamic> send(String method, List<dynamic> arguments) {
    List<dynamic> args = [id];
    args.addAll(arguments);
    return _channel.invokeMethod(method, args);
  }
}

/// AudioSourceNode have one or more output pins and no input pin
abstract class AudioSourceNode extends AudioNode {}

/// AudioOutputNode have one or more input pins and no output pin
abstract class AudioOutputNode extends AudioNode {}
