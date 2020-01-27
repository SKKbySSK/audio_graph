import 'package:audio_graph/nodes/audio_node.dart';
import 'package:audio_graph/pins/pins.dart';

import '../audio_format.dart';

class AudioDeviceOutputNode extends AudioOutputNode {
  static const String name = 'audio_device_output_node';

  InputPin inputPin = InputPin(AudioFormat.any());

  List<InputPin> _inputs = List();
  List<OutputPin> _outputs = List();

  @override
  List<InputPin> get inputPins => List.unmodifiable(_inputs);

  @override
  List<OutputPin> get outputPins => List.unmodifiable(_outputs);

  AudioDeviceOutputNode() {
    _inputs.add(inputPin);
  }

  @override
  String get nodeName => name;
}
