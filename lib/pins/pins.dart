import 'package:audio_graph/audio_format.dart';

import 'package:audio_graph/id_manager.dart';

/// Direction of the NodePin
enum NodePinDirection {
  input,
  output,
}

/// NodePin defines the direction and format of the pin.
/// You should use InputPin or OutputPin instead of NodePin
class NodePin {
  /// Identifier for managing pins internally
  final int id;

  /// Direction of the pin
  final NodePinDirection direction;

  /// Format of the pin
  final AudioFormat format;

  NodePin(this.direction, this.format)
      : this.id = IdManager.generate("NodePin");
}

/// InputPin can connect with OutputPin.
/// InputPin and OutputPin must have same format, if the InputPin doesn't have AudioFormat.any
class InputPin extends NodePin {
  InputPin(AudioFormat format) : super(NodePinDirection.input, format) {
    _commonInit();
  }

  InputPin.fromPin(NodePin pin) : super(NodePinDirection.input, pin.format) {
    _commonInit();
  }

  InputPin.fromJson(Map<String, dynamic> json)
      : super(json['direction'], json['format']) {
    _commonInit();
  }

  void _commonInit() {
    assert(direction == NodePinDirection.input);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'format': format,
    };
  }
}

/// OutputPin can connect with InputPin.
/// InputPin and OutputPin must have same format, if the InputPin doesn't have AudioFormat.any
class OutputPin extends NodePin {
  OutputPin(AudioFormat format) : super(NodePinDirection.output, format) {
    _commonInit();
  }

  OutputPin.fromPin(NodePin pin) : super(NodePinDirection.output, pin.format) {
    _commonInit();
  }

  OutputPin.fromJson(Map<String, dynamic> json)
      : super(json['direction'], json['format']) {
    _commonInit();
  }

  void _commonInit() {
    assert(direction == NodePinDirection.output);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'format': format,
    };
  }
}
