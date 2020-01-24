import 'package:audio_graph/audio_format.dart';

import 'package:audio_graph/id_manager.dart';

enum AudioPinDirection {
  input,
  output,
}

class NodePin {
  final int id;
  final AudioPinDirection direction;
  final AudioFormat format;

  NodePin(this.direction, this.format)
      : this.id = IdManager.generate("NodePin");
}

class InputPin extends NodePin {
  InputPin(AudioFormat format) : super(AudioPinDirection.input, format) {
    _commonInit();
  }

  InputPin.fromPin(NodePin pin) : super(AudioPinDirection.input, pin.format) {
    _commonInit();
  }

  InputPin.fromJson(Map<String, dynamic> json)
      : super(json['direction'], json['format']) {
    _commonInit();
  }

  void _commonInit() {
    assert(direction == AudioPinDirection.input);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'format': format,
    };
  }
}

class OutputPin extends NodePin {
  OutputPin(AudioFormat format) : super(AudioPinDirection.output, format) {
    _commonInit();
  }

  OutputPin.fromPin(NodePin pin) : super(AudioPinDirection.output, pin.format) {
    _commonInit();
  }

  OutputPin.fromJson(Map<String, dynamic> json)
      : super(json['direction'], json['format']) {
    _commonInit();
  }

  void _commonInit() {
    assert(direction == AudioPinDirection.output);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'format': format,
    };
  }
}
