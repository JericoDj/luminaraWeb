import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/quiz_data.dart';
import 'QuizScreen.dart';
import '../../../utils/constants/colors.dart';
import 'feature_cards.dart';

class InsightQuestButton extends StatelessWidget {
  const InsightQuestButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FeatureCard(
            title: 'Insight Quest',
            icon: Icons.psychology,
            description: 'Science-backed quizzes for better self-awareness.',
            onTap: () {
              Get.to(() => const InsightQuestScreen());
            },
            width: MediaQuery.of(context).size.width < 510
                ? MediaQuery.of(context).size.width / 2 - 20
                : 500 / 2 - 20,
          ),
        ],
      ),
    );
  }
}

class InsightQuestScreen extends StatelessWidget {
  const InsightQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width < 510
        ? MediaQuery.of(context).size.width / 2 - 30
        : 500 / 2 - 30;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
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
          title: const Text('Insight Quest', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 20),
              _buildCategoryGrid(context),
              const SizedBox(height: 30),
              _buildFeaturedQuizzes(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎭 Hero Section with Improved UI
  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [

          const Text(
            "Welcome to Insight Quest! 🧠",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Take personalized, science-backed quizzes to improve self-awareness and mental well-being.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 🧩 Improved GridView for Quiz Categories
  Widget _buildCategoryGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _quizCategory(context, 'Mindfulness', Icons.spa, MyColors.color1, 'Mindfulness',
              "Discover your present-moment awareness."),
          _quizCategory(context, 'Cognitive Skills', Icons.memory, MyColors.color2, 'Cognitive Skills',
              "Test your problem-solving & focus."),
          _quizCategory(context, 'Emotional Intelligence', Icons.favorite, MyColors.color2, 'Emotional Intelligence',
              "Measure your ability to manage emotions."),
          _quizCategory(context, 'Resilience', Icons.shield, MyColors.color1, 'Resilience',
              "Assess your stress-handling skills."),
        ],
      ),
    );
  }

  /// 🎯 Category Cards with Clear Navigation
  Widget _quizCategory(BuildContext context, String title, IconData icon, Color color, String category, String description) {
    return GestureDetector(
      onTap: () {
        if (category == "Mindfulness" || category == "Resilience") {
          Get.to(() => QuizScreen(category: category,));
        } else {
          Get.to(() => QuizScreen(category: category,));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(2, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🌟 Featured Quizzes with Engaging Colors & Descriptions
  Widget _buildFeaturedQuizzes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "🔥 Featured Quizzes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: PageView(
            scrollDirection: Axis.horizontal,
            children: [
              _featuredQuizCard("Deep Focus", "Train your brain to maintain cation.", Colors.indigo, Icons.visibility),
              _featuredQuizCard("Mental Clarity", "Sharpen your ability to think critically.", Colors.purple, Icons.lightbulb),
              _featuredQuizCard("Positivity Boost", "Develop a more optimistic mindset.", Colors.pinkAccent, Icons.mood),
            ],
          ),
        ),
      ],
    );
  }

  /// 🎭 Featured Quiz Cards with Modern Look
  Widget _featuredQuizCard(String title, String description, Color color, IconData icon) {
    double width;
    if (MediaQueryData.fromView(WidgetsBinding.instance.window).size.width < 510) {
      width = MediaQueryData.fromView(WidgetsBinding.instance.window).size.width / 2 - 30;
    } else {
      width = 500 / 2 - 30;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
      child: Container(
        width: width - 15,
        height: width - 15,
        padding: const EdgeInsets.all(3), // Border thickness
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Colors.green,
              MyColors.color1,
              Colors.orange,
              MyColors.color2,
            ],
            stops: [0.0, 0.5, 0.51, 1.0], // Ensures exact half-split
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white, // ✅ White inner box
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              String selectedCategory = quizData.containsKey(title) ? title : "Mindfulness"; // ✅ Prevent crashes
              Get.to(() => QuizScreen(category: selectedCategory, ));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.grey[800]), // ✅ Icon size same as MindHub
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyColors.color1), // ✅ Text color matches MindHub
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: MyColors.color1.withOpacity(0.8)), // ✅ Slightly lighter shade of MyColors.color1
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}