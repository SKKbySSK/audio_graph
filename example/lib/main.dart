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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
