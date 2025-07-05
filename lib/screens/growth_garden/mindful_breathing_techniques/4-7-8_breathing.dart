import 'dart:async';
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
class FourSevenEightBreathingScreen extends StatefulWidget {
  const FourSevenEightBreathingScreen({super.key});

  @override
  _FourSevenEightBreathingScreenState createState() =>
      _FourSevenEightBreathingScreenState();
}

class _FourSevenEightBreathingScreenState
    extends State<FourSevenEightBreathingScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _rippleAnimation;

  int _stepIndex = -1;
  bool _isPlaying = false;
  int _countdown = 4; // Adjust countdown to match the "Inhale" duration (4 seconds)
  bool isStarting = false; // Manage the starting state
  String _buttonText = "Start Meditation";

  final List<String> _breathingSteps = ['Inhale', 'Hold', 'Exhale'];
  final List<int> _stepDurations = [4, 7, 8]; // Duration for each step

  void _startCountdown() {
    setState(() {
      _stepIndex = -1;
      _countdown = _stepDurations[0]; // Set countdown to the duration of the "Inhale" step
      isStarting = true; // Disable start logic
      _buttonText = "Starting in $_countdown..."; // Show countdown on the button
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
          _buttonText = "Starting in $_countdown..."; // Update countdown text
        });
      } else {
        timer.cancel();
        _startBreathing();
      }
    });
  }

  void _startBreathing() {
    setState(() {
      _isPlaying = true;
      _stepIndex = 0;
      _countdown = _stepDurations[_stepIndex]; // Set countdown to the first breathing step's duration
      _buttonText = "Stop Meditation"; // Change to stop button after countdown
      isStarting = false; // Reset isStarting to false after meditation starts
    });

    // Reset the animation controller to start fresh
    _animationController.reset();

    // Set the duration based on the current step's duration (Inhale)
    _animationController.duration = Duration(seconds: _countdown);

    // Start the animation from the beginning
    _animationController.forward(from: 0);

    _updateBreathingStep();
  }


  void _updateBreathingStep() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        setState(() {
          _stepIndex = (_stepIndex + 1) % _breathingSteps.length;
          _countdown = _stepDurations[_stepIndex]; // Set countdown to the next step's duration
        });
        _updateAnimation();
      }
    });
  }

  void _updateAnimation() {
    _animationController.duration = Duration(seconds: _countdown);
    if (_stepIndex == 0) {
      _animationController.forward(from: 0);
    } else if (_stepIndex == 1) {
      _animationController.stop();
    } else {
      _animationController.reverse(from: 1);
    }
  }

  void _pauseBreathing() {
    setState(() {
      _isPlaying = false;
      _buttonText = "Start Meditation"; // Reset button text after stopping meditation
      _countdown = 3; // Reset countdown value
      isStarting = false; // Reset the starting flag to false
    });
    _timer.cancel();
    _animationController.reverse(from: 1); // Retract the animation back to the smallest size
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _sizeAnimation = Tween<double>(begin: 100, end: 200).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _rippleAnimation = Tween<double>(begin: 1, end: 1.5).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
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

                /// Gradient Bottom Border
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2, // Border thickness
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange, // Start - Orange
                          Colors.orangeAccent, // Stop 2 - Orange Accent
                          Colors.green, // Stop 3 - Green
                          Colors.greenAccent, // Stop 4 - Green Accent
                        ],
                        stops: const [0.0, 0.5, 0.5, 1.0],
                        // Define stops at 50% transition
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            title: const Text("4-7-8 Breathing Exercise")),


        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                height: 70,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    _isPlaying
                        ? '${_breathingSteps[_stepIndex]} $_countdown s'
                        : _stepIndex == -1
                        ? 'Welcome to 4-7-8\nBreathing Exercise!'
                        : 'Thank you for meditating!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _rippleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _rippleAnimation.value,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.color2.withOpacity(0.5),
                            boxShadow: [
                              BoxShadow(
                                color: MyColors.color2.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _sizeAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _rippleAnimation.value,
                        child: Container(
                          width: _sizeAnimation.value,
                          height: _sizeAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.color2.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: MyColors.color2.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.air,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  'The 4-7-8 breathing technique can help reduce stress, promote relaxation, improve focus, and help with sleep. Breathe deeply, hold, and exhale to feel more balanced and centered!',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(30.0),
          child: GestureDetector(
            onTap: isStarting
                ? null
                : (_isPlaying ? _pauseBreathing : _startCountdown), // Button is clickable after countdown starts
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isStarting ? Colors.grey : MyColors.color1, // Prevent clicking during countdown
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Text(
                _buttonText, // Show the current button text
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
