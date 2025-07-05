import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import '../../../utils/constants/colors.dart';

class GratitudeMeditationScreen extends StatefulWidget {
  const GratitudeMeditationScreen({super.key});

  @override
  _GratitudeMeditationScreenState createState() => _GratitudeMeditationScreenState();
}

class _GratitudeMeditationScreenState extends State<GratitudeMeditationScreen> {
  late YoutubePlayerController _controller;
  Timer? _timer;
  int _timeLeft = 300; // 5-minute timer

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId("https://www.youtube.com/watch?v=zyUy9w953L0")!,
      flags: const YoutubePlayerFlags(
        autoPlay: false, // Let user play manually
        mute: false,
        loop: false,
      ),
    );
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) => setState(() {
        if (_timeLeft <= 0) {
          timer.cancel();
        } else {
          _timeLeft--;
        }
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detecting the current orientation
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white, // White background
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
        title: const Text("Gratitude Meditation"),
        backgroundColor: Colors.white, // White app bar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Black back button
      ),
      body: isLandscape
          ? Stack(
        children: [
          // Fullscreen video player
          Center(
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
          // Back button in landscape
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Switch to portrait mode before navigating back
                SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

              },
            ),
          ),
        ],
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🌟 Welcome Section
              Text(
                "Welcome to Gratitude Meditation",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MyColors.color1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Take a few moments to reflect on what you're grateful for. "
                    "This 5-minute guided meditation will help you embrace gratitude.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 🎥 YouTube Video Player
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)], // Subtle shadow
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
              const SizedBox(height: 30),

              // 📖 About Gratitude Meditation
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What is Gratitude Meditation?",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.color1),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Gratitude Meditation helps you focus on positive aspects of life by appreciating the good things around you.",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "How Can It Help?",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.color1),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "• Enhances positive emotions\n"
                          "• Reduces stress and anxiety\n"
                          "• Improves overall mental well-being\n"
                          "• Strengthens relationships",
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
