import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:audio_graph/audio_graph_builder.dart';
import 'package:audio_graph/audio_graph.dart';
import 'package:audio_graph/nodes/audio_node.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioGraph graph;
  AudioFileNode file1, file2, file3;
  AudioMixerNode mixer;
  bool ignoreUpdate = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final path1 = await setupMusicFile("test1.mp3");
    final path2 = await setupMusicFile("test2.m4a");
    final path3 = await setupMusicFile("test3.m4a");

    final file1 = AudioFileNode(path1);
    final file2 = AudioFileNode(path2);
    final file3 = AudioFileNode(path3);
    final output = AudioDeviceOutputNode();

    await file1.prepare();
    await file2.prepare();
    await file3.prepare();

    setState(() {
      mixer = AudioMixerNode();
      this.file1 = file1;
      this.file2 = file2;
      this.file3 = file3;
    });

    final builder = AudioGraphBuilder();
    builder.nodes.addAll([mixer, file1, file2, file3, output]);

    final in1 = mixer.appendInputPin();
    final in2 = mixer.appendInputPin();
    final in3 = mixer.appendInputPin();

    builder.connect(file1.outputPin, in1);
    builder.connect(file2.outputPin, in2);
    builder.connect(file3.outputPin, in3);
    builder.connect(mixer.outputPin, output.inputPin);
    graph = await builder.build();

    Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (ignoreUpdate) {
        return;
      }

      await file1?.updatePosition();
      await file2?.updatePosition();
      await file3?.updatePosition();

      setState(() {});
    });
  }

  Future<String> setupMusicFile(String assetUri) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$assetUri');
    var data = await rootBundle.load('assets/${assetUri}');
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
            Slider(
              value: mixer?.volume ?? 0,
              onChanged: (value) {
                setState(() {
                  mixer?.volume = value;
                });
              },
            ),
            buildListTile(file1),
            buildListTile(file2),
            buildListTile(file3),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(AudioFileNode file) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
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
              value: file?.position ?? 0,
              onChangeStart: (_) {
                ignoreUpdate = true;
              },
              onChangeEnd: (_) {
                ignoreUpdate = false;
              },
              onChanged: (value) {
                setState(() {
                  file.position = value;
                });
              },
            )
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    graph.dispose();
    super.dispose();
  }
}
