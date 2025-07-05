import 'dart:async';
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  _BoxBreathingScreenState createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _rippleAnimation;

  int _stepIndex = -1; // Start with the welcome message
  bool _isPlaying = false;
  int _countdown = 4;
  bool isStarting = false;
  String _buttonText = "Start";

  final List<String> _breathingSteps = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  final List<int> _stepDurations = [4, 4, 4, 4]; // Duration for each breathing step

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

  void _startCountdown() {
    setState(() {
      _stepIndex = -1;
      _countdown = 4;
      isStarting = true;
      _buttonText = "Starting in $_countdown...";
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
          _buttonText = "Starting in $_countdown...";
        });
      } else {
        timer.cancel();
        setState(() => isStarting = false);
        _startBreathing();
      }
    });
  }

  void _startBreathing() {
    setState(() {
      _isPlaying = true;
      _buttonText = "Stop Meditation";
      _stepIndex = 0;
      _countdown = _stepDurations[_stepIndex];
    });

    _animationController.reset();
    _animationController.duration = Duration(seconds: _stepDurations[_stepIndex]);
    _animationController.forward(from: 0);

    _updateBreathingStep();
  }

  void _updateBreathingStep() {
    // After the countdown finishes, we begin each step's animation for the corresponding duration
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
    // Update the animation duration based on the current step
    _animationController.duration = Duration(seconds: _countdown);

    if (_stepIndex == 0) {
      // Inhale: Expand from 100 to 200
      _animationController.forward(from: 0);
    } else if (_stepIndex == 1) {
      // Hold 1: Hold at size 200
      _animationController.stop();
    } else if (_stepIndex == 2) {
      // Exhale: Shrink from 200 to 100
      _animationController.reverse(from: 1);
    } else if (_stepIndex == 3) {
      // Hold 2: Hold at size 100
      _animationController.stop();
    }
  }

  void _pauseBreathing() {
    setState(() {
      _isPlaying = false;
      _buttonText = "Start Meditation";
      _countdown = 4;
      _stepIndex = -1;
    });
    _animationController.stop();
    if (_timer.isActive) _timer.cancel();
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
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: const Text("Box Breathing Exercise"),
        ),
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
                        ? 'Welcome to Box Breathing\nExercise!'
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
                          width: 250,
                          height: 250,
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
                        scale: 1.0, // We don’t need a ripple effect here, just the size animation
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
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Box breathing is a simple but powerful technique to calm the mind, improve focus, and reduce stress.',
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
                : (_isPlaying ? _pauseBreathing : _startCountdown),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isStarting ? Colors.grey : MyColors.color1,
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Text(
                _buttonText,
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
