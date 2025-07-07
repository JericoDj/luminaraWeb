
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
      {"url": "assets/images/CoupleTherapy.jpg", "title": "CoupleTherapy"},
      {"url": "assets/images/Psychotherapy.jpg", "title": "Psychotheraphy"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(
                      height: MediaQuery.of(context).size.width*0.10,
                      "assets/images/Logo_Square.png"),
                  SizedBox(height: 20,),

                  const Text(
                    "Welcome to Light Level Psychological Solutions",
                    style: TextStyle(
                      fontSize: 22,
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
                  const SizedBox(height: 20),
                ],
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
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

                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 2.5,
                    child: CarouselSlider(
                      items: images.map((image) => _buildCarouselItem(image)).toList(),
                      options: CarouselOptions(
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.easeInOut,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: const Duration(seconds: 1),
                        viewportFraction: 1,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),



          const SizedBox(height: 20),
          SafeTalkButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }



  Widget _buildCarouselItem(Map<String, dynamic> item) {
    String imagePath = item['url'];
    String title = item['title'];

    return SizedBox(
      height: 275,
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 2, color: Colors.transparent),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFfcbc1d),
                    Color(0xFFfd9c33),
                    Color(0xFFFFD700),
                    Color(0xFFFFA500)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                  },

                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

