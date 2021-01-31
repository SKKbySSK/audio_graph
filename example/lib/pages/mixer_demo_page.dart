import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audio_graph/audio_graph.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MixerDemoPage extends StatefulWidget {
  MixerDemoPage({Key key}) : super(key: key);

  @override
  _MixerDemoPageState createState() => _MixerDemoPageState();
}

class _MixerDemoPageState extends State<MixerDemoPage> {
  AudioGraph graph;
  List<AudioFilePlayerNode> files;
  AudioMixerNode mixer;
  bool ignoreUpdate = false;
  bool playAll = true;

  @override
  void initState() {
    super.initState();
    initAudioGraph();
  }

  // Extract the asset data and export to the app's document directory
  Future<String> setupMusicFile(String assetUri) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$assetUri');
    var data = await rootBundle.load('assets/$assetUri');
    await file.writeAsBytes(data.buffer.asInt8List());
    return file.path;
  }

  // Initialize the AudioGraph
  Future<void> initAudioGraph() async {
    final List<AudioFilePlayerNode> files = List();

    // Create AudioFilePlayerNodes from local files
    final List<String> filePaths = List();

    for (final path in filePaths) {
      files.add(await AudioFilePlayerNode.createNode(path));
    }

    // Create AudioFilePlayerNodes from assets
    // You should add these files to example/assets/ folder to test in your local workspace
    final assetFiles = [
      "test1.mp3",
      "test2.mp3",
      "test3.mp3",
    ];

    for (final asset in assetFiles) {
      final path = await setupMusicFile(asset);
      final node = await AudioFilePlayerNode.createNode(path);
      node.completion = () {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('${asset} finished!'),
          ),
        );
      };
      files.add(node);
    }

    // AudioDeviceOutputNode is an output node to produce audio data to the speaker.
    final output = AudioDeviceOutputNode();
    mixer = AudioMixerNode();

    // Add player, mixer, output nodes to the AudioGraphBuilder
    final builder = AudioGraphBuilder();
    builder.nodes.addAll(files);
    builder.nodes.addAll([mixer, output]);

    // Connect the AudioFilePlayerNode to AudioMixerNode's next input pin.
    // AudioGraph should look like this AudioFilePlayerNode -> AudioMixerNode
    for (final file in files) {
      builder.connect(file.outputPin, mixer.appendInputPin());
    }

    // Connect the AudioMixerNode's output pin to AudioDeviceOutputNode's input pin
    builder.connect(mixer.outputPin, output.inputPin);

    // Build the graph and receive it.
    // You MUST dispose the graph when you don't need it.
    try {
      graph = await builder.build();
    } on PlatformException catch (e) {
      print(e.code);
      print(e.message);
      return;
    }

    // When the graph is ready, set files and rebuild UI.
    setState(() {
      this.files = files;
    });

    Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (ignoreUpdate) {
        return;
      }

      for (final file in files) {
        await file.updatePosition();
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final fileTiles = files?.map((f) => buildListTile(f)) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixer Demo'),
      ),
      body: ListView(
        children: <Widget>[
          buildMixerTile(),
          ...fileTiles,
        ],
      ),
    );
  }

  Widget buildMixerTile() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: Text("Mixer"),
          ),
          Slider(
            value: mixer?.volume ?? 0,
            onChanged: (value) {
              setState(() {
                mixer?.volume = value;
              });
            },
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget buildListTile(AudioFilePlayerNode file) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: buildFileController(file),
          ),
          buildSeekBar(file),
          buildVolumeSlider(file),
          Divider(),
        ],
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
            '${current}/${duration}',
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
}
