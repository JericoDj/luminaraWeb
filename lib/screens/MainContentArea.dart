import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../Footer.dart';
import 'package:url_launcher/url_launcher.dart';
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
        const SizedBox(height: 20), // smaller gap
        _buildImageCarousel(),

        SafeTalkButton(),
        const SizedBox(height: 10),
        _buildStoreButtons(),
        ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [

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
                      padding: const EdgeInsets.only(top: 100),
                      child: _buildImageCarousel(),
                    ),
                  ),
                  const SizedBox(width: 100),
                ],
              )
            ],
            const SizedBox(height: 60),
            AppFooter(),
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
          height: isSmallScreen ? 80 : 120,
        ),
        SizedBox(height: isSmallScreen ? 10 :30),
        Text(
          "Welcome to Luminara",
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 40,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Professional care for your emotional and mental well-being.",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
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
            aspectRatio: 10 / 8,

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
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
              aspectRatio: 16 / 9, // more compact for mobile
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
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
          onPressed: _launchLuminaraAppOrStore,
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
    return Builder(
      builder: (context) {
        final isSmallScreen = MediaQuery.of(context).size.width < 600;
        final imageHeight = isSmallScreen ? 50.0 : 70.0;

        return GestureDetector(
          onTap: onPressed,
          child: Image.asset(
            imagePath,
            height: imageHeight,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  void _launchLuminaraAppOrStore() async {
    const packageName = 'com.lightlevel.luminara';

    // First try to open the app using Android intent
    final intentUri = Uri.parse("intent://#Intent;package=com.lightlevel.luminara;end");

    if (await canLaunchUrl(intentUri)) {
      await launchUrl(intentUri, mode: LaunchMode.externalApplication);
    } else {
      final storeUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
      if (await canLaunchUrl(storeUri)) {
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the store or app')),
        );
      }
    }
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
