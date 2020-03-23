import 'package:audio_graph/nodes/audio_node.dart';
import 'package:audio_graph/pins/pins.dart';

import '../audio_format.dart';

/// AudioDeviceOutputNode writes the audio data to the device's default output.
/// Currently, we don't support changing device's output.
class AudioDeviceOutputNode extends AudioOutputNode {
  AudioDeviceOutputNode() {
    _inputs.add(inputPin);
  }

  static const String name = 'audio_device_output_node';

  final InputPin inputPin = InputPin(const AudioFormat.any());

  final _inputs = <InputPin>[];
  final _outputs = <InputPin>[];

  @override
  List<InputPin> get inputPins => List.unmodifiable(_inputs);

  @override
  List<OutputPin> get outputPins => List.unmodifiable(_outputs);

  @override
  String get nodeName => name;
}
