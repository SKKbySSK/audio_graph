import 'dart:async';
import 'dart:math';

import 'package:audio_graph_example/asset_manager.dart';
import 'package:flutter/material.dart';
import 'package:audio_graph/audio_graph.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class SimplePlayerPage extends StatefulWidget {
  SimplePlayerPage({Key key}) : super(key: key);

  @override
  _SimplePlayerPageState createState() => _SimplePlayerPageState();
}

class _SimplePlayerPageState extends State<SimplePlayerPage> {
  AudioGraph graph;
  AudioFilePlayerNode playerNode;
  bool ignoreUpdate = false;

  @override
  void initState() {
    super.initState();
    initAudioGraph();
  }

  @override
  void reassemble() {
    // Rebuild the graph when hot reload is executed
    graph?.dispose();
    initAudioGraph();
    super.reassemble();
  }

  @override
  void dispose() {
    graph?.dispose();
    super.dispose();
  }

  // Initialize the AudioGraph
  Future<void> initAudioGraph() async {
    // Create AudioFilePlayerNode from assets
    final asset = AssetManager.sampleAssetItems[0];
    final path = await AssetManager.exportMusicFile(asset);
    final playerNode = await AudioFilePlayerNode.createNode(path);
    playerNode.completion = () {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('$asset finished!'),
        ),
      );
    };

    // AudioDeviceOutputNode is an output node to produce audio data to the speaker.
    final output = AudioDeviceOutputNode();

    // Add player, mixer, output nodes to the AudioGraphBuilder
    final builder = AudioGraphBuilder();
    builder.nodes.addAll([playerNode, output]);

    // Connect the AudioMixerNode's output pin to AudioDeviceOutputNode's input pin
    builder.connect(playerNode.outputPin, output.inputPin);

    // Build the graph and receive it.
    // You MUST dispose the graph when you don't need it.
    try {
      graph = await builder.build();
    } on PlatformException catch (e) {
      print(e.code);
      print(e.message);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to build AudioGraph'),
        ),
      );
      return;
    }

    // When the graph is ready, set node and rebuild UI.
    setState(() {
      this.playerNode = playerNode;
    });

    Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (ignoreUpdate) {
        return;
      }

      await playerNode.updatePosition();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixer Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: buildFileController(playerNode),
            ),
            buildSeekBar(playerNode),
            buildVolumeSlider(playerNode),
          ],
        ),
      ),
    );
  }

  Widget buildSeekBar(AudioFilePlayerNode file) {
    final current = Duration(seconds: (file?.position ?? 0).toInt())
        .toString()
        .substring(2, 7);
    final duration = Duration(seconds: (file?.duration ?? 0).toInt())
        .toString()
        .substring(2, 7);

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$current/$duration',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Slider(
            min: 0,
            max: file?.duration ?? 0,
            value: min(file?.position ?? 0, file?.duration ?? 0),
            onChangeStart: (_) {
              ignoreUpdate = true;
            },
            onChangeEnd: (_) {
              ignoreUpdate = false;
            },
            onChanged: (value) {
              if (ignoreUpdate) {
                return setState(() {
                  file.position = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildVolumeSlider(AudioFilePlayerNode file) {
    final isMute = (file.volume <= 0);

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          icon: Icon(
            isMute ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          ),
          onPressed: () {
            setState(() {
              file.volume = isMute ? 1 : 0;
            });
          },
        ),
        Expanded(
          child: Slider(
            value: file?.volume ?? 0,
            onChanged: (value) {
              setState(() {
                file.volume = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildFileController(AudioFilePlayerNode file) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(path.basename(file.path)),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow_rounded),
              onPressed: () {
                file.play();
              },
            ),
            IconButton(
              icon: Icon(Icons.pause_rounded),
              onPressed: () {
                file.pause();
              },
            ),
          ],
        ),
      ],
    );
  }
}
