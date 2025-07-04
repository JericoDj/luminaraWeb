import 'package:flutter/material.dart';

import '../widgets/homescreen_widgets/safe_talk_button.dart';
import '../widgets/homescreen_widgets/wellness_tracking/wellness_map.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luminara Web App'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.account_circle)),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const NavigationSidebar(),
          ),

          // Main Content Area
          const Expanded(
            flex: 9,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: MainContentArea(),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
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
    final navItems = [
      {'icon': Icons.dashboard, 'title': 'Dashboard'},
      {'icon': Icons.shopping_cart, 'title': 'Orders'},
      {'icon': Icons.people, 'title': 'Customers'},
      {'icon': Icons.analytics, 'title': 'Analytics'},
      {'icon': Icons.inventory, 'title': 'Products'},
      {'icon': Icons.category, 'title': 'Categories'},
    ];

    return navItems.map((item) {
      return ListTile(
        leading: Icon(item['icon'] as IconData, size: 22),
        title: Text(item['title'] as String),
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        onTap: () {},
      );
    }).toList();
  }

  List<Widget> _buildSecondaryItems() {
    final secondaryItems = [
      {'icon': Icons.settings, 'title': 'Settings'},
      {'icon': Icons.help, 'title': 'Help Center'},
      {'icon': Icons.logout, 'title': 'Logout'},
    ];

    return secondaryItems.map((item) {
      return ListTile(
        leading: Icon(item['icon'] as IconData, size: 22),
        title: Text(item['title'] as String),
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        onTap: () {},
      );
    }).toList();
  }
}

class MainContentArea extends StatelessWidget {
  const MainContentArea({super.key});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Sales', '\$24,580', Icons.attach_money, Colors.blue),
        _buildStatCard('New Customers', '1,248', Icons.people_alt, Colors.green),
        _buildStatCard('Order Volume', '845', Icons.shopping_bag, Colors.orange),
        _buildStatCard('Conversion Rate', '24.8%', Icons.trending_up, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Icon(icon, color: color),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '+12.4% from last month',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            DataTable(
              columns: const [
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Order')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                _buildDataRow('John Doe', '#ORD-1234', 'Jul 4, 2023', 'Completed'),
                _buildDataRow('Jane Smith', '#ORD-1235', 'Jul 3, 2023', 'Processing'),
                _buildDataRow('Robert Johnson', '#ORD-1236', 'Jul 2, 2023', 'Shipped'),
                _buildDataRow('Emily Wilson', '#ORD-1237', 'Jul 1, 2023', 'Completed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String customer, String order, String date, String status) {
    return DataRow(cells: [
      DataCell(Text(customer)),
      DataCell(Text(order)),
      DataCell(Text(date)),
      DataCell(
        Chip(
          label: Text(status),
          backgroundColor: status == 'Completed'
              ? Colors.green.shade100
              : Colors.orange.shade100,
        ),
      ),
    ]);
  }
}