import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_graph/audio_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      files.add(await AudioFilePlayerNode.createNode(path));
    }

    // AudioDeviceOutputNode is an output node to produce audio data to the speaker.
    final output = AudioDeviceOutputNode();

    // When all players and output node is prepared, set AudioMixerNode and rebuild UI.
    setState(() {
      mixer = AudioMixerNode();
      this.files = files;
    });

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
    }

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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: <Widget>[
            Center(
              child: Text("Main Mixer"),
            ),
            Center(
              child: IconButton(
                icon: Icon(Icons.audiotrack),
                onPressed: () {
                  for (final file in files) {
                    if (playAll) {
                      file.play();
                    } else {
                      file.pause();
                    }
                  }

                  playAll = !playAll;
                },
              ),
            ),
            Slider(
              value: mixer?.volume ?? 0,
              onChanged: (value) {
                setState(() {
                  mixer?.volume = value;
                });
              },
            ),
          ]..addAll(files?.map((f) => buildListTile(f)) ?? []),
        ),
      ),
    );
  }

  Widget buildListTile(AudioFilePlayerNode file) {
    return Column(
      children: <Widget>[
        Text(path.basename(file.path)),
        IconButton(
          icon: Icon(Icons.audiotrack),
          onPressed: () {
            if (file.isPlaying) {
              file.pause();
            } else {
              file.play();
            }
          },
        ),
        Slider(
          value: file?.volume ?? 0,
          onChanged: (value) {
            setState(() {
              file.volume = value;
            });
          },
        ),
        Slider(
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
        )
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
    graph.dispose();
    super.dispose();
  }
}
