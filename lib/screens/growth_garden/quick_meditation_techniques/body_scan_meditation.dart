import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../utils/constants/colors.dart';

class BodyScanMeditationScreen extends StatefulWidget {
  const BodyScanMeditationScreen({super.key});

  @override
  State<BodyScanMeditationScreen> createState() =>
      _BodyScanMeditationScreenState();
}

class _BodyScanMeditationScreenState extends State<BodyScanMeditationScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'z8zX-QbXIT4',
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Body Scan Meditation'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 800,
              child: YoutubePlayer(controller: _controller),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to Body Scan Meditation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
