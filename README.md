# AudioGraph

Flutter plugin to build custom audio graph.

This plugin inspired by AVAudioEngine and DirectShow.

## Overview

You can create graph with following steps.

- Initialize AudioNode
- Initialize AudioGraphBuilder
- Connect the node's output pin to next AudioNode's input pin using AudioGraphBuilder.connect(output, input)
- Build AudioGraph using AudioGraphBuilder.build()

To dispose audio resources, use AudioGraph.dispose().

Please note that AudioNode can only be used once. If you dispose the parent graph, you must not use the node.

### AudioNodes
AudioNode is a base class.
You can use these AudioNodes
- AudioFileNode
  - Decode the audio file and pass the data to AudioFileNode.outputPin.
  - This node has play(), pause(), position to control audio state
- AudioMixerNode
  - AudioMixerNode.appendInputPin() to get the next mixer input pin. You have to connect the same AudioFormat output pin.
- AudioDeviceOutputNode
  - connect the output pin to AudioDeviceOutputNode.inputPin to play audio using the device's default output device.
  - You cannot use AudioDeviceOutputNode twice in a same graph.

### iOS implementation
AVAudioEngine is used in iOS.


### Android implementation
AudioFileNode is using MediaCodec and MediaExtractor.
AudioTrack is used for AudioDeviceOutputNode.
