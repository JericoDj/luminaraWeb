import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

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
              context.go('/insight-quest');
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
                    colors: [Color(0xFFF8F8F8), Color(0xFFF1F1F1)],
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
              _buildFeaturedQuizzes(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: const [
          Text(
            "Welcome to Insight Quest! 🧠",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Take personalized, science-backed quizzes to improve self-awareness and mental well-being.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 1500;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 400 : 16),
      child: GridView.count(
        crossAxisCount: isLargeScreen ? 4 : 2,
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

  Widget _quizCategory(BuildContext context, String title, IconData icon, Color color, String category, String description) {
    return GestureDetector(
      onTap: () {
        context.go('/quiz/${Uri.encodeComponent(category)}');
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

  Widget _buildFeaturedQuizzes(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 1500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 400: 16),
          child: const Text(
            "🔥 Featured Quizzes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        CarouselSlider(
          options: CarouselOptions(
            height: 200,

            viewportFraction: 0.75,
            enableInfiniteScroll: true,
            enlargeCenterPage: true,
            autoPlay: true,
          ),
          items: [
            _featuredQuizCard(context, "Deep Focus", "Train your brain to maintain focus.", Colors.indigo, Icons.visibility),
            _featuredQuizCard(context, "Mental Clarity", "Sharpen your ability to think critically.", Colors.purple, Icons.lightbulb),
            _featuredQuizCard(context, "Positivity Boost", "Develop a more optimistic mindset.", Colors.pinkAccent, Icons.mood),
          ],
        ),

        const SizedBox(height: 50),
      ],
    );
  }


  Widget _featuredQuizCard(BuildContext context, String title, String description, Color color, IconData icon) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 1100;
    final double width = isLargeScreen
        ? screenWidth * 0.30
        : screenWidth < 510
        ? screenWidth / .80
        : screenWidth / .80;

    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(3),
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
          stops: [0.0, 0.5, 0.51, 1.0],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            String selectedCategory = quizData.containsKey(title) ? title : "Mindfulness";
            context.go('/quiz/${Uri.encodeComponent(selectedCategory)}');
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.grey[800]),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyColors.color1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: MyColors.color1.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
