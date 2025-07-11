import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminarawebsite/Footer.dart';
import 'package:luminarawebsite/providers/userProvider.dart';
import 'package:provider/provider.dart';
import '../utils/constants/colors.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLargeScreen = MediaQuery
        .of(context)
        .size
        .width >= 1100;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 65,
        title: GestureDetector(
          onTap: () =>
          {
            context.go("/home")
          },
          child: Row(
            mainAxisAlignment: isLargeScreen
                ? MainAxisAlignment.start
                : MainAxisAlignment.end
            ,
            children: [

              if (isLargeScreen) SizedBox(width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.05),
              Image.asset(

                "assets/images/Logo_Square.png",
                height: (isLargeScreen) ? MediaQuery
                    .of(context)
                    .size
                    .height * 0.06 : MediaQuery
                    .of(context)
                    .size
                    .height * 0.05,
              ),
              Image.asset(
                'assets/images/appbar_title.png',
                height: isLargeScreen ? MediaQuery
                    .of(context)
                    .size
                    .height * 0.07 : MediaQuery
                    .of(context)
                    .size
                    .height * 0.00,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        elevation: 2,
        flexibleSpace: _buildGradientBar(),
        actions: isLargeScreen
            ? [
          Consumer<UserProvider>(
            builder: (_, userProvider, __) {
              return Row(
                children: _buildAppBarButtons(context, userProvider),
              );
            },
          ),
        ]
            : null,
        leading: isLargeScreen
            ? null
            : Builder(
          builder: (context) =>
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: isLargeScreen ? null : _buildDrawer(context),
      body: Container(
        child: Column(
          children: [
            Expanded(child: child), // dynamic page content
            const AppFooter(), // footer at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBar() {
    return Stack(
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
    );
  }

  List<Widget> _buildAppBarButtons(BuildContext context, UserProvider userProvider) {
    final bool isLoggedIn = userProvider.isLoggedIn;

    return [
      _navButton(context, Icons.home, 'Home', '/home'),
      _navButton(context, Icons.eco, 'Growth Garden', '/growth-garden'),
      _navButton(context, Icons.calendar_today, 'Book Now', '/book-now'),
      _navButton(context, Icons.group, 'Community', '/community'),
      const SizedBox(width: 20),
      _navButton(
        context,
        isLoggedIn ? Icons.account_circle : Icons.login,
        isLoggedIn ? (userProvider.fullName ?? 'Account') : 'Login',
        isLoggedIn ? '/account' : '/login',
      ),
      const SizedBox(width: 12),
    ];
  }


  Widget _navButton(BuildContext context, IconData icon, String label,
      String route) {
    final bool selected = GoRouterState
        .of(context)
        .uri
        .toString() == route;
    return TextButton.icon(
      onPressed: () => context.go(route),
      icon: Icon(
          icon, size: 20, color: selected ? MyColors.color2 : Colors.black54),
      label: Text(label,
          style: TextStyle(
              color: selected ? MyColors.color2 : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            width: double.infinity,
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
            child: Row(
              children: [
                Image.asset("assets/images/Logo_Square.png", height: 40),
                const SizedBox(width: 10),
                Text(
                  "Luminara",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyColors.color1,
                  ),
                ),
              ],
            ),
          ),
          // Gradient bottom border
          Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange,
                  Colors.orangeAccent,
                  Colors.green,
                  Colors.greenAccent
                ],
                stops: [0.0, 0.5, 0.5, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'MAIN NAVIGATION',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey.shade600,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _drawerItem(context, Icons.home, 'Home', '/home'),
                _drawerItem(
                    context, Icons.eco, 'Growth Garden', '/growth-garden'),
                _drawerItem(
                    context, Icons.calendar_today, 'Book Now', '/book-now'),
                _drawerItem(context, Icons.group, 'Community', '/community'),
                const Divider(),
                _drawerItem(
                    context, Icons.account_circle, 'Account', '/account'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title,
      String route) {
    final bool selected = GoRouterState
        .of(context)
        .uri
        .toString() == route;
    return ListTile(
      leading: Icon(icon, color: selected ? MyColors.color2 : MyColors.color2.withValues(alpha:0.8), fill: 0.23,),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? MyColors.color1 : Colors.black87,
        ),
      ),
      tileColor: selected ? MyColors.color2.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        context.go(route);
        Navigator.pop(context);
      },
    );
  }
}
