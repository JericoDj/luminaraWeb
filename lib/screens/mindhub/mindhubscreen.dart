import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminarawebsite/screens/mindhub/videos_screen.dart';

import '../../utils/constants/colors.dart';
import 'articles_screen.dart';
import 'ebooks_screen.dart';


class MindHubCategoriesScreen extends StatelessWidget {
  const MindHubCategoriesScreen({Key? key}) : super(key: key);

  final List<_CategoryItem> categories = const [
    _CategoryItem(
      label: 'Articles',
      icon: Icons.article,
      color: Colors.blue,
      category: 'Articles',
    ),
    _CategoryItem(
      label: 'Videos',
      icon: Icons.video_collection,
      color: Colors.red,
      category: 'Videos',
    ),
    _CategoryItem(
      label: 'Ebooks',
      icon: Icons.book,
      color: Colors.green,
      category: 'Ebooks',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mind Hub Categories"),
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
                    colors: [Colors.orange, Colors.orangeAccent, Colors.green, Colors.greenAccent],
                    stops: const [0.0, 0.5, 0.5, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = categories[index];
            return CategoryCard(
              title: item.label,
              icon: item.icon,
              color: item.color,
              onTap: () {
                if (item.category == 'Articles') {
                  Get.to(() => SafeSpaceHubArticles());
                } else if (item.category == 'Videos') {
                  Get.to(() => const MindHubVideosScreen());
                } else if (item.category == 'Ebooks') {
                  Get.to(() => MindHubEbooksScreen());
                }
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: MyColors.color1,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: MyColors.color1.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'Mind Hub',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;
  final Color color;
  final String category;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              color,
              MyColors.color1,
              color.withOpacity(0.8),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
