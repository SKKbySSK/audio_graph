import 'package:audio_graph/audio_format.dart';
import 'package:audio_graph/nodes/audio_node.dart';
import 'package:audio_graph/pins/pins.dart';

/// AudioMixerNode can mix multiple audio data(output pin)
/// You can add input pin by calling appendInputPin()
class AudioMixerNode extends AudioNode {
  AudioMixerNode() {
    _outputs.add(outputPin);
  }

  static const String name = 'audio_mixer_node';
  OutputPin outputPin = OutputPin(const AudioFormat.any());

  final _inputs = <InputPin>[];
  final _outputs = <OutputPin>[];

  @override
  List<InputPin> get inputPins => List.unmodifiable(_inputs);

  @override
  List<OutputPin> get outputPins => List.unmodifiable(_outputs);

  InputPin appendInputPin() {
    final pin = InputPin(const AudioFormat.any());
    _inputs.add(pin);

    return pin;
  }

  @override
  String get nodeName => name;
}
