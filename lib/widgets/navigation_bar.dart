import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/accessDeniedPage.dart';
import '../screens/account_screen/account.dart';
import '../screens/book_now/booknowscreen.dart';
import '../screens/growth_garden/growth_garden.dart';
import '../screens/homescreen/homescreen.dart';
import '../screens/safe_talks/safe_talks.dart';
import '../utils/constants/colors.dart';
import '../utils/storage/user_storage.dart';
import 'accounts_screen/TIcket_Popup_widget.dart';
import 'curved clipper.dart';
import 'mood_dialog/showMoodDialog.dart';

class NavigationBarMenu extends StatefulWidget {
  final bool dailyCheckIn; // Flag to check if the user just logged in


  const NavigationBarMenu({Key? key, required this.dailyCheckIn}) : super(key: key);



  @override
  _NavigationBarMenuState createState() => _NavigationBarMenuState();
}

class _NavigationBarMenuState extends State<NavigationBarMenu> {




  int _selectedIndex = 0;
  late List<Widget> _pages; // Declare the list as late

  @override
  void initState() {
    super.initState();

    // ✅ Call method to get user and proceed
    _loadUserAndProceed();

    _pages = [
      HomeScreen(),
      GrowthGardenScreen(),
      BookNowScreen(),
      SafeSpaceScreen(
        onBackToHome: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      AccountScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.dailyCheckIn) {
        showMoodDialog(context);
      }
    });


  }

  Future<void> _loadUserAndProceed() async {
    final userStorage = UserStorage();
    final uid = await userStorage.getUid();

    if (kDebugMode) {
      print("🔍 Retrieved UID from storage: $uid");
    }

    if (uid != null) {
     await _doSomethingWithUser(uid); // ✅ safe to call
    } else {
      debugPrint("❌ UID is null. Cannot proceed.");
      // Optional: Navigate to login or error screen
    }
  }



  Future <void> _doSomethingWithUser(String uid) async {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (doc.exists) {
          final data = doc.data();
          final hasAccess = data?['access'] ?? true;

          if (hasAccess == false) {
            print(hasAccess);
            // ❌ Access denied
            await Get.offAll(() => const AccessDeniedPage());
          } else {
            // ✅ Access granted
            debugPrint("✅ Access granted to ${data?['full_name'] ?? 'Unknown'}");
          }
        } else {
          debugPrint("❌ User document not found.");
        }
      } catch (e) {
        debugPrint("🔥 Error checking access: $e");
      }
    }






  void _onItemTapped(int index) {
    final userStorage = UserStorage();

    // 🟢 Check if accessing Safe Community
    if (index == 3) {
      final access = userStorage.getSafeCommunityAccess() ?? false;

      if (!access) {
        // ❌ Not allowed, show dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Access Restricted"),
            content: const Text("Sorry, this feature is not available for your account."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return; // ⛔️ Prevent navigation
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }







  // Handle back button press
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If not on the Home screen, navigate to Home
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Prevent default back behavior
    } else {
      // If on the Home screen, show exit confirmation dialog
      final shouldExit = await showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text("Exit App"),
              content: const Text("Are you sure you want to exit?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cancel
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Exit
                  child: const Text("Exit"),
                ),
              ],
            ),
      );
      return shouldExit ?? false; // Return true to exit, false to stay
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Intercept back button press
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,


            toolbarHeight: 70,
            flexibleSpace: Stack(
              children: [


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
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Image.asset(
                      'assets/images/logo/appbar_title.png',
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.06,
                      fit: BoxFit.contain,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() =>
                          SupportTicketsPage()); // Correct usage of Get.to()
                    },
                    child: Container(


                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                        border: Border.all(color: MyColors.color2, width: 2),
                      ),
                      child: Icon(Icons.support_agent, size: 26,
                          color: MyColors.color2),
                    ),
                  ),
                ],
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: _pages[_selectedIndex],
          ),
          bottomNavigationBar: Stack(
            clipBehavior: Clip.none,
            children: [

              /// Bottom Navigation Bar
              Container(
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  children: [

                    /// Curved Gradient Top Border
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ClipPath(
                        clipper: CurvedBorderClipper(),
                        child: Container(
                          height: 2, // Adjust height to control curvature depth
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green, // Start - Green
                                MyColors.color1, // Stop 2
                                MyColors.color2, // Stop 3
                                Colors.orangeAccent, // Stop 4 - Orange Accent
                              ],
                              stops: const [0.0, 0.5, 0.5, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Navigation Row
                    /// Navigation Row
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5, left: 10, right: 10), // Adjust padding for better alignment
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround, // Ensures even spacing around elements
                          children: [
                            _buildNavItem(Icons.home, "Home", 0),
                            _buildNavItem(Icons.spa, "Growth Garden", 1), // \n for line break
                            const SizedBox(width: 65), // Space for floating button (increased for balance)
                            _buildNavItem(Icons.group, "Safe\nCommunity", 3),
                            _buildNavItem(Icons.person, "Account", 4),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              /// Floating Center Button
              Positioned(
                bottom: 8,
                left: (MediaQuery
                    .of(context)
                    .size
                    .width > 510)
                    ? (MediaQuery.of(context).size.width / 2) -
                    30 // Use fixed width when screen is wider than 500px (desktop web)
                    : (MediaQuery
                    .of(context)
                    .size
                    .width / 2) - 27.5, // Dynamic center for mobile
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _onItemTapped(2),
                      child: Container(
                        width: 55,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo/Logo_No_Background_No_SQUARE.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onItemTapped(2),
                      child: Text(
                        "Book Now",
                        style: TextStyle(
                          letterSpacing: -1,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _selectedIndex == 2 ? MyColors.color1 : Colors
                              .grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? MyColors.color1 : Colors.grey
                .shade600,
          ),
          Text(
            textAlign: TextAlign.center,
            label,
            style: TextStyle(
              letterSpacing: -0.5,
              fontSize: 12,
              color: _selectedIndex == index ? MyColors.color1 : Colors.grey
                  .shade600,
            ),
          ),
        ],
      ),
    );
  }
}