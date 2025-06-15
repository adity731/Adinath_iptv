
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

void main() => runApp(AdinathIPTV());

class AdinathIPTV extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adinath IPTV',
      theme: ThemeData.dark(),
      home: IPTVHome(),
    );
  }
}

class IPTVHome extends StatefulWidget {
  @override
  _IPTVHomeState createState() => _IPTVHomeState();
}

class _IPTVHomeState extends State<IPTVHome> {
  final TextEditingController _urlController = TextEditingController();
  List<Map<String, String>> _channels = [];
  String? _selectedUrl;
  VideoPlayerController? _videoController;

  Future<void> _parseM3U() async {
    final url = _urlController.text;
    final response = await http.get(Uri.parse(url));
    final lines = response.body.split('\n');
    final List<Map<String, String>> parsed = [];

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('#EXTINF')) {
        final title = lines[i].split(',').last;
        final link = lines[i + 1];
        parsed.add({'title': title, 'url': link});
      }
    }

    setState(() {
      _channels = parsed;
    });
  }

  void _playChannel(String url) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {
          _selectedUrl = url;
          _videoController!.play();
        });
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adinath IPTV'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Enter M3U Playlist URL',
                filled: true,
                fillColor: Colors.white,
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: _parseM3U,
            child: Text("Load Channels"),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: _channels.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_channels[index]['title']!),
                        onTap: () =>
                            _playChannel(_channels[index]['url']!),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _selectedUrl != null && _videoController != null
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : Center(child: Text('Select a channel to play')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
