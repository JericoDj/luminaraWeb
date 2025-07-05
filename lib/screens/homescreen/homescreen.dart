import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/MoodController.dart';
import '../../controllers/achievements_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../controllers/user_progress_controller.dart';
import '../../widgets/homescreen_widgets/safe_talk_button.dart';
import '../../widgets/homescreen_widgets/wellness_tracking/wellness_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserProgressController userProgressController = Get.put(UserProgressController());
  final ProgressController progressController = Get.put(ProgressController());
  final AchievementsController achievementsController = Get.put(AchievementsController());
  final HomeController homeController = Get.put(HomeController());
  final MoodController moodController = Get.put(MoodController());

  late Future<List<Map<String, dynamic>>> _carouselImages;

  @override
  void initState() {
    super.initState();
    moodController.getWeeklyMoods();
    userProgressController.fetchUserCheckIns();
    achievementsController.fetchUserAchievements();

    // Fetch the carousel images from Firestore
    _carouselImages = fetchCarouselImages();
  }

  Future<List<Map<String, dynamic>>> fetchCarouselImages() async {
    try {
      // Fetch the images from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('contents').doc('homescreen').get();
      var data = snapshot.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> allImages = [];

      // Loop through the keys in the document to find all image fields (image3, image4, etc.)
      data.forEach((key, value) {
        if (key.startsWith('image')) {
          // Add the image data to the list if it's an image field
          allImages.add(value);
        }
      });

      // Print the results to the console for debugging
      print("Fetched Carousel Images: $allImages");

      // Return the combined list of all images
      return allImages;
    } catch (e) {
      print("Error fetching carousel images: $e");
      return []; // If error occurs, return empty list
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProgressDashboardCard(),
              const SizedBox(height: 20),
              SafeTalkButton(),
              const SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _carouselImages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final images = snapshot.data ?? [];

                  if (images.isEmpty) {
                    return Text('No images available');
                  }

                  return SizedBox(
                    height: 280,
                    child: CarouselSlider(
                      items: images.map((image) => _buildCarouselItem(image)).toList(),
                      options: CarouselOptions(
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.easeInOut,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: const Duration(seconds: 1),
                        viewportFraction: 0.8,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(Map<String, dynamic> item) {
    String imagePath = item['url']; // Fetch URL from Firestore
    String title = item['title'];

    return SizedBox(
      height: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 2, color: Colors.transparent),
                gradient: LinearGradient(
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
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
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
