import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:profanity_filter/profanity_filter.dart';

class CommunityController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ProfanityFilter _profanityFilter = ProfanityFilter();

  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> get posts => _posts;

  CommunityController() {
    _fetchPosts();
  }

  void _fetchPosts() async {
    _firestore
        .collection('safeSpace')
        .doc('posts')
        .collection('userPosts')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .listen((snapshot) {
      _posts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Print each post's details
      for (var post in _posts) {
        print('--- Post ---');
        print('ID: ${post['id']}');
        print('User ID: ${post['userId']}');
        print('Username: ${post['username']}');
        print('Content: ${post['content']}');
        print('Timestamp: ${post['timestamp']}');
        print('Status: ${post['status']}');
        print('Likes: ${post['likes']}');
        print('Comments: ${post['comments']}');
      }
    });
  }


  Future<void> addComment(String postId, String commentText) async {
    final uid = GetStorage().read('uid');
    final username = GetStorage().read('username');

    if (uid == null || username == null) return;

    final comment = {
      'userId': uid,
      'username': username,
      'comment': commentText,
      'timestamp': DateTime.now(), // ✅ Use DateTime instead of FieldValue.serverTimestamp()
    };

    final postRef = FirebaseFirestore.instance
        .collection('safeSpace')
        .doc('posts')
        .collection('userPosts')
        .doc(postId);

    await postRef.update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }


  Future<void> deletePost(String postId) async {
    await _firestore
        .collection('safeSpace')
        .doc('posts')
        .collection('userPosts')
        .doc(postId)
        .delete();
  }



  Future<String?> submitPost(String content) async {
    final box = GetStorage();
    final uid = box.read('uid');
    final username = box.read('username');

    if (uid == null || uid.toString().isEmpty) {
      return 'User not logged in.';
    }

    if (username == null || username.toString().isEmpty) {
      return 'Username missing. Please re-login.';
    }

    if (_profanityFilter.hasProfanity(content)) {
      return 'Post contains inappropriate language';
    }

    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final docRef = await _firestore
          .collection('safeSpace')
          .doc('posts')
          .collection('userPosts')
          .add({
        'userId': uid,
        'username': username,
        'content': content,
        'likes': [],
        'comments': [],
        'status': 'pending',
        'time': now,
      });

      print('Post submitted with ID: ${docRef.id}');
      return null;
    } catch (e) {
      print('Error submitting post: $e');
      return 'Failed to submit post.';
    }
  }





  Future<void> likePost(String postId, List<dynamic> currentLikes) async {
    final uid = GetStorage().read('uid');
    if (uid == null) return;

    final postRef = _firestore
        .collection('safeSpace')
        .doc('posts')
        .collection('userPosts')
        .doc(postId);

    if (currentLikes.contains(uid)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }
}