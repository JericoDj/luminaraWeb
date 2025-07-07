import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants/colors.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 65,
        title: GestureDetector(
          onTap: () => {
            context.go("/home")
          },
          child: Image.asset(
            'assets/images/appbar_title.png',
            height: MediaQuery.of(context).size.height * 0.08,
            fit: BoxFit.contain,
          ),
        ),
        elevation: 2,
        flexibleSpace: _buildGradientBar(),
        actions: isLargeScreen ? _buildAppBarButtons(context) : null,
        leading: isLargeScreen
            ? null
            : Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: isLargeScreen ? null : _buildDrawer(context),
      body: child,
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

  List<Widget> _buildAppBarButtons(BuildContext context) {
    return [
      _navButton(context, Icons.home, 'Home', '/home'),
      _navButton(context, Icons.eco, 'Growth Garden', '/growth-garden'),
      _navButton(context, Icons.calendar_today, 'Book Now', '/book-now'),
      _navButton(context, Icons.group, 'Community', '/community'),
      const SizedBox(width: 20),
      _navButton(context, Icons.account_circle, 'Account', '/account'),
      const SizedBox(width: 12),
    ];
  }

  Widget _navButton(BuildContext context, IconData icon, String label, String route) {
    final bool selected = GoRouterState.of(context).uri.toString() == route;
    return TextButton.icon(
      onPressed: () => context.go(route),
      icon: Icon(icon, size: 20, color: selected ? MyColors.color2 : Colors.black54),
      label: Text(label,
          style: TextStyle(
              color: selected ? MyColors.color2 : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('MAIN NAVIGATION',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          ),
          _drawerItem(context, Icons.home, 'Home', '/home'),
          _drawerItem(context, Icons.eco, 'Growth Garden', '/growth-garden'),
          _drawerItem(context, Icons.calendar_today, 'Book Now', '/book-now'),
          _drawerItem(context, Icons.group, 'Community', '/community'),
          const Divider(),
          _drawerItem(context, Icons.account_circle, 'Account', '/account'),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route) {
    final bool selected = GoRouterState.of(context).uri.toString() == route;
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.blue : null),
      title: Text(title,
          style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.blue : Colors.black)),
      tileColor: selected ? Colors.blue[50] : null,
      onTap: () {
        context.go(route);
        Navigator.pop(context);
      },
    );
  }
}
