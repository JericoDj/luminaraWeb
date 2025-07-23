import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../mindhub/articles_screen.dart';
import '../../mindhub/ebooks_screen.dart';
import '../../mindhub/videos_screen.dart';

class MindHubScreen extends StatefulWidget {
  final String category;
  const MindHubScreen({Key? key, required this.category}) : super(key: key);

  @override
  _MindHubScreenState createState() => _MindHubScreenState();
}

class _MindHubScreenState extends State<MindHubScreen> {
  late String selectedCategory;
  late Widget selectedScreen;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category;
    selectedScreen = _getCategoryScreen(selectedCategory);
  }

  void _changeCategory(String category) {
    setState(() {
      selectedCategory = category;
      selectedScreen = _getCategoryScreen(category);
    });
  }

  Widget _getCategoryScreen(String category) {
    switch (category) {
      case 'Articles':
        return  SafeSpaceHubArticles();
      case 'Videos':
        return const MindHubVideosScreen();
      case 'Ebooks':
        return  MindHubEbooksScreen();
      default:
        return const Center(child: Text('Select a category.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width < 510
        ? MediaQuery.of(context).size.width / 2 - 30
        : 500 / 2 - 30;

    return SafeArea(
      child: Scaffold(

        body: selectedScreen, // Updates dynamically based on selection
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300]!, width: 1), // Adds top border
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _categoryButton('Articles', Icons.article, Colors.blue),
              _categoryButton('Videos', Icons.video_collection, Colors.red),
              _categoryButton('Ebooks', Icons.book, Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryButton(String category, IconData icon, Color color) {
    bool isSelected = category == selectedCategory;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeCategory(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? MyColors.color2 : Colors.grey[400], // Active & Inactive colors
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? MyColors.color2 : Colors.grey).withOpacity(0.4),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20), // Bigger Icon
              const SizedBox(height: 5),
              Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Larger font for better readability
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
