import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../Footer.dart';
import '../../../utils/constants/colors.dart';

class GratitudeMeditationScreen extends StatefulWidget {
  const GratitudeMeditationScreen({super.key});

  @override
  State<GratitudeMeditationScreen> createState() =>
      _GratitudeMeditationScreenState();
}

class _GratitudeMeditationScreenState extends State<GratitudeMeditationScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'zyUy9w953L0',
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
        title: const Text('Gratitude Meditation'),
      ),
      body: SingleChildScrollView(
        child: Center(
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
                "Welcome to Gratitude Meditation",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 100),
        
              AppFooter(),
        
            ],
          ),
        ),
      ),
    );
  }
}
