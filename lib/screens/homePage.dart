import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:luminarawebsite/CommunityScreen.dart';
import 'package:luminarawebsite/screens/account_screen/account.dart';
import 'package:luminarawebsite/screens/book_now/booknowscreen.dart';
import 'package:luminarawebsite/screens/growth_garden/growth_garden.dart';
import 'package:luminarawebsite/screens/safe_talks/safe_talks.dart';
import 'package:luminarawebsite/utils/constants/colors.dart';

import '../widgets/homescreen_widgets/safe_talk_button.dart';
import 'MainContentArea.dart';

enum NavItem {
  home,
  growthGarden,
  bookNow,
  safeCommunity,
  account,

}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  NavItem _currentNavItem = NavItem.home;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 65,
        title:  Image.asset(

          'assets/images/appbar_title.png',
          height: MediaQuery
              .of(context)
              .size
              .height * 0.08,
          fit: BoxFit.contain,
        ),
        elevation: 2,
        flexibleSpace: Stack(
          children: [
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
        actions: isLargeScreen
            ? [
          _buildAppBarButton(Icons.home, 'Home', NavItem.home),
          _buildAppBarButton(Icons.eco, 'Growth Garden', NavItem.growthGarden),
          _buildAppBarButton(Icons.calendar_today, 'Book Now', NavItem.bookNow),
          _buildAppBarButton(Icons.group, 'Community', NavItem.safeCommunity),
          const SizedBox(width: 20),
          _buildAppBarButton(Icons.account_circle, 'Account', NavItem.account),

          const SizedBox(width: 12),
        ]
            : null,
        leading: isLargeScreen
            ? null
            : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: isLargeScreen ? null : _buildNavigationDrawer(),
      body: Align(
            alignment: Alignment.topCenter,
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: _buildMainContent())),
    );
  }

  Widget _buildAppBarButton(IconData icon, String label, NavItem item) {
    final bool isSelected = _currentNavItem == item;

    return TextButton.icon(
      onPressed: () => _selectNavItem(item),
      icon: Icon(
        icon,
        color: isSelected ? MyColors.color2 : Colors.black87,
        size: 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? MyColors.color2 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }


  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 20),
            _buildDrawerHeader(),
            const SizedBox(height: 10),
            ..._buildDrawerItems(),
            const SizedBox(height: 20),
            const Divider(),
            ..._buildSecondaryItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'MAIN NAVIGATION',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return [
      _buildDrawerItem(Icons.home, 'Home', NavItem.home),
      _buildDrawerItem(Icons.eco, 'Growth Garden', NavItem.growthGarden),
      _buildDrawerItem(Icons.calendar_today, 'Book Now', NavItem.bookNow),
      _buildDrawerItem(Icons.group, 'Safe Community', NavItem.safeCommunity),
    ];
  }

  List<Widget> _buildSecondaryItems() {
    return [
      _buildDrawerItem(Icons.account_circle, 'Account', NavItem.account),

    ];
  }

  Widget _buildDrawerItem(IconData icon, String title, NavItem item) {
    final isSelected = _currentNavItem == item;

    return ListTile(
      leading: Icon(icon, size: 22, color: isSelected ? Colors.blue : null),
      title: Text(title, style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.blue : Colors.black,
      )),
      tileColor: isSelected ? Colors.blue[50] : null,
      horizontalTitleGap: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: () {
        _selectNavItem(item);
        Navigator.pop(context); // Close the drawer after selection
      },
    );
  }

  void _selectNavItem(NavItem item) {
    setState(() {
      _currentNavItem = item;
    });
  }

  Widget _buildMainContent() {
    switch (_currentNavItem) {
      case NavItem.home:
        return MainContentArea();
      case NavItem.growthGarden:
        return GrowthGardenScreen();
      case NavItem.bookNow:
        return BookNowScreen();
      case NavItem.safeCommunity:
        return CommunityScreen();
      case NavItem.account:
        return AccountScreen();

    }
  }

  Widget _buildPlaceholder(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class NavigationSidebar extends StatelessWidget {
  final NavItem currentNavItem;
  final Function(NavItem) onSelect;

  const NavigationSidebar({
    super.key,
    required this.currentNavItem,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 20),
          _buildNavHeader(),
          const SizedBox(height: 10),
          ..._buildNavItems(),
          const SizedBox(height: 20),
          const Divider(),
          ..._buildSecondaryItems(),
        ],
      ),
    );
  }

  Widget _buildNavHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'MAIN NAVIGATION',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  List<Widget> _buildNavItems() {
    return [
      _buildNavItem(Icons.home, 'Home', NavItem.home),
      _buildNavItem(Icons.eco, 'Growth Garden', NavItem.growthGarden),
      _buildNavItem(Icons.calendar_today, 'Book Now', NavItem.bookNow),
      _buildNavItem(Icons.group, 'Safe Community', NavItem.safeCommunity),
    ];
  }

  List<Widget> _buildSecondaryItems() {
    return [
      _buildNavItem(Icons.account_circle, 'Account', NavItem.account),

    ];
  }

  Widget _buildNavItem(IconData icon, String title, NavItem item) {
    final isSelected = currentNavItem == item;

    return ListTile(
      leading: Icon(icon, size: 22, color: isSelected ? Colors.blue : null),
      title: Text(title, style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.blue : Colors.black,
      )),
      tileColor: isSelected ? Colors.blue[50] : null,
      horizontalTitleGap: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: () => onSelect(item),
    );
  }
}