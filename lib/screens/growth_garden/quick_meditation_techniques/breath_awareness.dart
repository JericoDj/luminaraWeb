import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../Footer.dart';
import '../../../utils/constants/colors.dart';

class BreathAwarenessMeditationScreen extends StatefulWidget {
  const BreathAwarenessMeditationScreen({super.key});

  @override
  State<BreathAwarenessMeditationScreen> createState() =>
      _BreathAwarenessMeditationScreenState();
}

class _BreathAwarenessMeditationScreenState extends State<BreathAwarenessMeditationScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'enJyOTvEn4M',
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
        automaticallyImplyLeading: false
        ,
        title: const Text('Breath Awareness Meditation'),
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
                "Welcome to Breath Awareness Meditation",
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
