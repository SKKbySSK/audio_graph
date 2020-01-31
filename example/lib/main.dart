import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:audio_graph/audio_graph.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final List<String> filePaths = List();
    final assetFiles = [
      "test1.mp3",
      "test2.mp3",
      "test3.mp3",
    ];

    final List<AudioFilePlayerNode> files = List();

    for (final asset in assetFiles) {
      final path = await setupMusicFile(asset);
      files.add(await AudioFilePlayerNode.createNode(path));
    }

    for (final path in filePaths) {
      files.add(await AudioFilePlayerNode.createNode(path));
    }

    final output = AudioDeviceOutputNode();

    setState(() {
      mixer = AudioMixerNode();
      this.files = files;
    });

    final builder = AudioGraphBuilder();
    builder.nodes.addAll(files);
    builder.nodes.addAll([mixer, output]);

    for (final file in files) {
      builder.connect(file.outputPin, mixer.appendInputPin());
    }

    builder.connect(mixer.outputPin, output.inputPin);

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

  Future<String> setupMusicFile(String assetUri) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$assetUri');
    var data = await rootBundle.load('assets/$assetUri');
    await file.writeAsBytes(data.buffer.asInt8List());
    return file.path;
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
    graph.dispose();
    initPlatformState();
    super.reassemble();
  }

  @override
  void dispose() {
    graph.dispose();
    super.dispose();
  }
}
