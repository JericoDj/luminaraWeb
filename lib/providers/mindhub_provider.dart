import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mindhub_models.dart';

class MindHubProvider extends ChangeNotifier {
  List<Article> _articles = [];
  List<VideoItem> _videos = [];
  Map<String, String> _userArticleChoices = {};
  Map<String, String> _userVideoChoices = {};

  List<Article> get articles => _articles;
  List<VideoItem> get videos => _videos;
  
  String? getUserChoice(String id, bool isVideo) => 
      isVideo ? _userVideoChoices[id] : _userArticleChoices[id];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Rate limiting variables
  final List<DateTime> _refreshTimestamps = [];
  bool _isRateLimited = false;
  bool get isRateLimited => _isRateLimited;

  Future<void> fetchData({bool force = false}) async {
    if (_isLoading) return;
    
    if (force) {
      final now = DateTime.now();
      _refreshTimestamps.removeWhere((t) => now.difference(t).inSeconds > 30);
      
      if (_refreshTimestamps.length >= 3) {
        _isRateLimited = true;
        notifyListeners();
        Future.delayed(const Duration(seconds: 30), () {
          _isRateLimited = false;
          notifyListeners();
        });
        return;
      }
      _refreshTimestamps.add(now);
    } else if (_articles.isNotEmpty || _videos.isNotEmpty) {
      // Don't re-fetch if we already have data and it's not forced
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      // Fetch Articles
      final articlesDoc = await FirebaseFirestore.instance.collection('contents').doc('articles').get();
      if (articlesDoc.exists) {
        final data = articlesDoc.data()!;
        _articles = data.entries.map((e) => Article.fromMap(e.key, e.value as Map<String, dynamic>)).toList();
        _articles.sort((a, b) => a.order.compareTo(b.order));
      }

      // Fetch Videos
      final videosDoc = await FirebaseFirestore.instance.collection('contents').doc('videos').get();
      if (videosDoc.exists) {
        final data = videosDoc.data()!;
        _videos = data.entries.map((e) => VideoItem.fromMap(e.key, e.value as Map<String, dynamic>)).toList();
        _videos.sort((a, b) => a.order.compareTo(b.order));
      }

      // Fetch User Choices
      if (userId != null) {
        final userInteractions = await FirebaseFirestore.instance.collection('user_interactions').doc(userId).get();
        if (userInteractions.exists) {
          final data = userInteractions.data()!;
          _userArticleChoices = Map<String, String>.from(data['articles'] ?? {});
          _userVideoChoices = Map<String, String>.from(data['videos'] ?? {});
        }
      }
    } catch (e) {
      debugPrint('Error fetching MindHub data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInteraction(String id, String choice, bool isVideo) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final oldChoice = isVideo ? _userVideoChoices[id] : _userArticleChoices[id];
    if (oldChoice == choice) return;

    // Local update for immediate feedback
    if (isVideo) {
      _userVideoChoices[id] = choice;
      final index = _videos.indexWhere((v) => v.id == id);
      if (index != -1) {
        final v = _videos[index];
        final newInter = Map<String, int>.from(v.interactions);
        if (oldChoice != null) newInter[oldChoice] = (newInter[oldChoice] ?? 1) - 1;
        newInter[choice] = (newInter[choice] ?? 0) + 1;
        _videos[index] = VideoItem(
          id: v.id, title: v.title, description: v.description,
          thumbnail: v.thumbnail, videoUrl: v.videoUrl,
          isYouTube: v.isYouTube, order: v.order, interactions: newInter,
        );
      }
    } else {
      _userArticleChoices[id] = choice;
      final index = _articles.indexWhere((a) => a.id == id);
      if (index != -1) {
        final a = _articles[index];
        final newInter = Map<String, int>.from(a.interactions);
        if (oldChoice != null) newInter[oldChoice] = (newInter[oldChoice] ?? 1) - 1;
        newInter[choice] = (newInter[choice] ?? 0) + 1;
        _articles[index] = Article(
          id: a.id, title: a.title, imageURL: a.imageURL,
          contents: a.contents, sources: a.sources,
          order: a.order, interactions: newInter,
        );
      }
    }
    notifyListeners();

    // Firestore update
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // Update counts in contents collection
      final contentDoc = FirebaseFirestore.instance.collection('contents').doc(isVideo ? 'videos' : 'articles');
      if (oldChoice != null) {
        batch.update(contentDoc, {'$id.interactions.$oldChoice': FieldValue.increment(-1)});
      }
      batch.update(contentDoc, {'$id.interactions.$choice': FieldValue.increment(1)});

      // Update user choice
      final userDoc = FirebaseFirestore.instance.collection('user_interactions').doc(userId);
      batch.set(userDoc, {
        (isVideo ? 'videos' : 'articles'): {id: choice}
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      debugPrint('Error updating interaction: $e');
      // Optionally revert local state on error
    }
  }
}
