import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

import '../../../utils/constants/colors.dart';  // Import for SystemChrome

class BodyScanMeditationScreen extends StatefulWidget {
  const BodyScanMeditationScreen({super.key});

  @override
  _BodyScanMeditationScreenState createState() =>
      _BodyScanMeditationScreenState();
}

class _BodyScanMeditationScreenState extends State<BodyScanMeditationScreen> {
  late YoutubePlayerController _controller;
  double _currentPosition = 0.0; // Store current video position

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
          "https://www.youtube.com/watch?v=z8zX-QbXIT4")!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
      ),
    );

    // Listen to player's current position
    _controller.addListener(() {
      if (_controller.value.isPlaying) {
        _currentPosition = _controller.value.position.inSeconds.toDouble();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width < 510
        ? MediaQuery
        .of(context)
        .size
        .width // If screen width is smaller than 510, use full width
        : 510; // Set the width to 510 if screen width exceeds 510

    double height = MediaQuery
        .of(context)
        .size
        .height;

    final orientation = MediaQuery
        .of(context)
        .orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isLandscape
          ? null // Hide app bar in landscape mode
          : AppBar(
        toolbarHeight: 65,
        flexibleSpace: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF8F8F8),
                    Color(0xFFF1F1F1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.orangeAccent,
                      Colors.green,
                      Colors.greenAccent,
                    ],
                    stops: const [0.0, 0.5, 0.5, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: const Text("Body Scan Meditation"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLandscape
          ? Stack(
        children: [
          // Fullscreen video player
          Center(
            child: SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: MyColors.color2,
                progressColors: ProgressBarColors(
                  playedColor: MyColors.color2,
                  handleColor: MyColors.color1,
                ),
              ),
            ),
          ),
          // Back button in landscape
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Switch to portrait mode before navigating back
                SystemChrome.setPreferredOrientations(
                    [DeviceOrientation.portraitUp]);
              },
            ),
          ),
        ],
      )
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Welcome to Body Scan Meditation",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: MyColors.color1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Follow this 5-minute guided meditation to relax and restore your mind.",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Video Player Section
              Container(
                width: width,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: MyColors.color2,
                    progressColors: ProgressBarColors(
                      playedColor: MyColors.color2,
                      handleColor: MyColors.color1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Information Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What is Body Scan Meditation?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MyColors.color1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Body Scan Meditation is a mindfulness technique that helps you become aware of different parts of your body, reducing stress and improving relaxation.",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "How Can It Help?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MyColors.color1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "• Reduces stress and anxiety\n"
                          "• Improves sleep quality\n"
                          "• Enhances self-awareness\n"
                          "• Promotes relaxation",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );

  }
}
