import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../widgets/homescreen_widgets/safe_talk_button.dart';

class MainContentArea extends StatefulWidget {
  const MainContentArea({super.key});

  @override
  State<MainContentArea> createState() => _MainContentAreaState();
}

class _MainContentAreaState extends State<MainContentArea> {
  late Future<List<Map<String, dynamic>>> _carouselImages;

  @override
  void initState() {
    _carouselImages = fetchCarouselImages();
    super.initState();
  }

  Future<List<Map<String, dynamic>>> fetchCarouselImages() async {
    return [
      {"url": "assets/images/Consultation.jpg", "title": "Consultation"},
      {"url": "assets/images/Counselling.jpg", "title": "Counselling"},
      {"url": "assets/images/CoupleTherapy.jpg", "title": "Couple Therapy"},
      {"url": "assets/images/Psychotherapy.jpg", "title": "Psychotherapy"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1100;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            if (isSmallScreen) ...[
              _buildWelcomeText(),
              const SizedBox(height: 30),
              _buildImageCarousel(),
              const SizedBox(height: 20),
              SafeTalkButton(),
              const SizedBox(height: 16),
              _buildStoreButtons(),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        _buildWelcomeText(),
                        const SizedBox(height: 20),
                        SafeTalkButton(),
                        const SizedBox(height: 16),
                        _buildStoreButtons(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: _buildImageCarousel(),
                    ),
                  ),
                  const SizedBox(width: 100),
                ],
              )
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1100;
    return Column(
      children: [
        Image.asset(
          "assets/images/Logo_Square.png",
          height: isSmallScreen
              ? MediaQuery.of(context).size.height * 0.13
              : MediaQuery.of(context).size.height * 0.15,
        ),
        const Text(
          "Welcome to Luminara",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "Professional care for your emotional and mental well-being.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _carouselImages,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final images = snapshot.data ?? [];
        if (images.isEmpty) {
          return const Text('No images available');
        }

        return CarouselSlider(
          items: images.map((image) => _buildCarouselItem(image)).toList(),
          options: CarouselOptions(
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOut,
            autoPlayAnimationDuration: const Duration(seconds: 1),
            enableInfiniteScroll: true,
            aspectRatio: 16 / 10,
            viewportFraction: 1,
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(Map<String, dynamic> item) {
    final imagePath = item['url'];
    final title = item['title'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFfcbc1d),
                Color(0xFFfd9c33),
                Color(0xFFFFD700),
                Color(0xFFFFA500),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AspectRatio(
              aspectRatio: 15 / 7.5,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _storeButton(
          imagePath: 'assets/images/GooglePlayDL.png',
          onPressed: () => _showComingSoonDialog("Google Play"),
        ),
        const SizedBox(width: 12),
        _storeButton(
          imagePath: 'assets/images/AppStoreDL.png',
          onPressed: () => _showComingSoonDialog("App Store"),
        ),
      ],
    );
  }

  Widget _storeButton({required String imagePath, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(
        imagePath,
        height: 80,
        fit: BoxFit.contain,
      ),
    );
  }

  void _showComingSoonDialog(String storeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$storeName'),
        content: const Text('Coming Soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
