import 'package:audio_graph/audio_format.dart';
import 'package:audio_graph/nodes/audio_node.dart';
import 'package:audio_graph/pins/pins.dart';

class AudioMixerNode extends AudioNode {
  static const String name = 'audio_mixer_node';
  OutputPin outputPin = OutputPin(AudioFormat.any());

  List<InputPin> _inputs = List();
  List<OutputPin> _outputs = List();

  @override
  List<InputPin> get inputPins => List.unmodifiable(_inputs);

  @override
  List<OutputPin> get outputPins => List.unmodifiable(_outputs);

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
