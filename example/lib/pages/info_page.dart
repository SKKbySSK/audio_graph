import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Info"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.view_in_ar),
            title: Text("audio_graph"),
            onTap: () async {
              const url = 'https://pub.dev/packages/audio_graph';
              if (await canLaunch(url)) {
                await launch(
                  url,
                  forceSafariVC: false,
                  forceWebView: false,
                );
              }
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("SKKbySSK"),
            subtitle: Text("Kaisei Sunaga"),
            trailing: IconButton(
              icon: Icon(EvaIcons.twitter),
              onPressed: () async {
                const url = 'https://twitter.com/SKKbySSK_TC';
                if (await canLaunch(url)) {
                  await launch(
                    url,
                    forceSafariVC: false,
                    forceWebView: false,
                  );
                }
              },
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
