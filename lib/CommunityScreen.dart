import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedBottomIndex = 3;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildPostInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/avatars/Avatar2.jpeg'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "What's new?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.grey[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/avatars/Avatar2.jpeg'),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("mjericoDj", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("2025-07-05 21:26:48", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text("hello"),
            const SizedBox(height: 4),
            const Text("Pending Approval", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.favorite_border, size: 20),
                SizedBox(width: 4),
                Text("0"),
                SizedBox(width: 20),
                Icon(Icons.comment, size: 20),
                SizedBox(width: 4),
                Text("0"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        _buildPostInput(),
        _buildPostCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(),
              _buildTabContent(),
            ],
          ),
        ),
      ),

    );
  }
}
