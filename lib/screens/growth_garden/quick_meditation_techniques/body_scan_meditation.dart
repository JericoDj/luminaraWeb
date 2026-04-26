import 'package:flutter/material.dart';
import 'package:luminarawebsite/Footer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../utils/constants/colors.dart';
import '../../../providers/user_tracking_provider.dart';
import 'package:provider/provider.dart';

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
    
    // Start tracking Body Scan Meditation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserTrackingProvider>(context, listen: false).startTracking('Meditation', itemName: 'Body Scan Meditation');
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          Provider.of<UserTrackingProvider>(context, listen: false).stopTracking(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Body Scan Meditation'),
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
                  "Welcome to Body Scan Meditation",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
               AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
