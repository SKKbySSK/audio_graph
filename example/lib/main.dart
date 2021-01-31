import 'package:audio_graph_example/asset_manager.dart';
import 'package:audio_graph_example/pages/info_page.dart';
import 'package:audio_graph_example/pages/mixer_demo_page.dart';
import 'package:audio_graph_example/pages/simple_player_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    SimplePlayerPage(),
    MixerDemoPage(),
    InfoPage(),
  ];

  Future<bool> cacheAllAssets() async {
    final List<Future<String>> futures = [];
    for (var asset in AssetManager.sampleAssetItems) {
      futures.add(AssetManager.exportMusicFile(asset));
    }

    final paths = await Future.wait(futures);
    return !paths.any((element) => element == null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: cacheAllAssets(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data) {
              return _buildContent();
            } else {
              return _buildError();
            }
          }

          return _buildLoading();
        },
      ),
    );
  }

  Scaffold _buildLoading() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          value: null,
        ),
      ),
    );
  }

  Scaffold _buildError() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Some assets were not exist.\nPlease ensure that the example/assets contains",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              "${AssetManager.sampleAssetItems.join(", ")}.",
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }

  Scaffold _buildContent() {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill_rounded),
            label: 'Player',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shuffle),
            label: 'Mixer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onTabTapped,
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
