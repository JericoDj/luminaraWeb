import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:luminarawebsite/utils/constants/colors.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'CommunityController.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  double _getResponsiveWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600 ? width : width * 0.6;
  }

  final GetStorage _storage = GetStorage();
  late TabController _tabController;
  final CommunityController _controller = CommunityController();
  final TextEditingController _postController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPosting = false;
  String? _errorMessage;

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

  void _showCommentsDialog(String postId, List comments) {
    final TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          title: const Text("Comments"),
          content: SizedBox(

            width: _getResponsiveWidth(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Comments List
                Flexible(
                  child: comments.isEmpty
                      ? const Text("No comments yet.")
                      : ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        title: Text(comment['username'] ?? 'Anonymous'),
                        subtitle: Text(comment['comment'] ?? ''),
                      );
                    },
                  ),
                ),
                const Divider(),
                // Input to add new comment
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: "Write a comment...",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: MyColors.color2),
                      onPressed: () async {
                        final text = _commentController.text.trim();
                        if (text.isNotEmpty) {
                          await _controller.addComment(postId, text);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _submitPost() async {
    if (_postController.text.isEmpty) return;

    setState(() {
      _isPosting = true;
      _errorMessage = null;
    });

    final result = await _controller.submitPost(_postController.text);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      _postController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Post submitted for review."),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() => _isPosting = false);
  }

  Widget _buildPostInput() {
    final uid = _storage.read('uid');
    if (uid == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          if (_errorMessage != null)
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          Row(
            children: [
              const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/avatars/Avatar2.jpeg')),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _postController,
                    decoration: const InputDecoration(
                      hintText: "What's new?",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _isPosting ? null : _submitPost,
                icon: _isPosting
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.send, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(DocumentSnapshot doc) {
    final post = doc.data() as Map<String, dynamic>;
    final likes = List<String>.from(post['likes'] ?? []);
    final currentUserId = _storage.read('uid');
    final isLiked = currentUserId != null && likes.contains(currentUserId);
    final commentController = TextEditingController();

    final List<Map<String, dynamic>> latestComments =
    (post['comments'] ?? []).cast<Map<String, dynamic>>().reversed.take(3).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and delete option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/avatars/Avatar2.jpeg'),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['username'] ?? 'Anonymous',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_formatTimestamp(post['time'])),
                      ],
                    ),
                  ],
                ),
                if (post['userId'] == currentUserId)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Post'),
                          content: const Text('Are you sure you want to delete this post?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _controller.deletePost(doc.id);
                      }
                    },
                  ),
              ],
            ),

            // Content
            const SizedBox(height: 8),
            Text(post['content'] ?? ''),

            // Status (Pending)
            if (post['status'] == 'pending')
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text("Pending Approval", style: TextStyle(color: Colors.red)),
              ),

            // Actions
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: () => _controller.likePost(doc.id, likes),
                ),
                Text('${likes.length}'),
                const SizedBox(width: 20),
                IconButton(
                    onPressed: () => _showCommentsDialog(doc.id, post['comments']),
                  icon: Icon(Icons.comment, size: 20)),


                const SizedBox(width: 4),
                Text('${(post['comments'] ?? []).length}'),
                const Spacer(),
                if ((post['comments'] ?? []).length > 3)
                  TextButton(
                    onPressed: () => _showCommentsDialog(doc.id, post['comments']),
                    child: const Text("View all"),
                  ),
              ],
            ),

            // Latest 3 Comments
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: latestComments.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "${c['username'] ?? 'Anonymous'}: ${c['comment'] ?? ''}",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                );
              }).toList(),
            ),

            // Add Comment
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = commentController.text.trim();
                    if (text.isNotEmpty) {
                      _controller.addComment(doc.id, text);
                      commentController.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';
    if (timestamp is Timestamp) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
    }
    if (timestamp is String) return timestamp;
    return timestamp.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            width: _getResponsiveWidth(context),
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              labelColor: MyColors.color2, // color for selected tab label
              unselectedLabelColor: Colors.grey, // color for unselected tabs
              indicatorColor: MyColors.color2, // color of the line below the selected tab
              indicatorWeight: 3, // thickness of the indicator line
              tabs: const [
                Tab(text: "Feed"),
                Tab(text: "My Posts"),
              ],
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          width: _getResponsiveWidth(context),
          child: TabBarView(
            controller: _tabController,
            children: [
              // Feed Tab (Always visible)
              Column(
                children: [
                  _buildPostInput(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('safeSpace')
                          .doc('posts')
                          .collection('userPosts')
                          .where('status', isEqualTo: 'approved')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No posts yet"));
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            return _buildPostCard(doc);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // My Posts Tab (Check for login first)
              Builder(
                builder: (context) {
                  final uid = _storage.read('uid');
                  if (uid == null || uid.toString().isEmpty) {
                    return const Center(child: Text("Please log in to view your posts."));
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('safeSpace')
                        .doc('posts')
                        .collection('userPosts')
                        .where('userId', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("You haven't posted yet"));
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index];
                          return _buildPostCard(doc);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
