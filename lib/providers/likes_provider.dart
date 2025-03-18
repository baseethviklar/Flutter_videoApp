// providers/likes_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_helper.dart';

class LikesProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, bool> _likedVideos = {};
  Map<String, int> _likeCount = {};
  bool _isInitialized = false;

  Map<String, bool> get likedVideos => _likedVideos;
  Map<String, int> get likeCount => _likeCount;

  // Initialize likes from local database and then sync with Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Load likes from local database
    await _loadLikesFromLocalDb();
    
    // Sync with Firebase
    await _syncWithFirestore();
    
    _isInitialized = true;
    notifyListeners();
  }

  // Load likes from local SQLite database
  Future<void> _loadLikesFromLocalDb() async {
    final likes = await _dbHelper.getLikes();
    
    for (var like in likes) {
      _likedVideos[like['video_id']] = true;
    }
  }

  // Sync likes with Firebase Firestore
  Future<void> _syncWithFirestore() async {
    try {
      // First, get likes data from Firestore
      final snapshot = await _firestore.collection('likes').get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final videoId = data['video_id'] as String;
        final count = data['count'] as int;
        
        _likeCount[videoId] = count;
      }
      
      // Then, sync any local likes that aren't in Firestore
      for (var videoId in _likedVideos.keys) {
        if (!_likeCount.containsKey(videoId)) {
          await _firestore.collection('likes').doc(videoId).set({
            'video_id': videoId,
            'count': 1,
          });
          _likeCount[videoId] = 1;
        }
      }
    } catch (e) {
      print('Error syncing with Firestore: $e');
    }
  }

  // Toggle like status for a video
  Future<void> toggleLike(String videoId) async {
    bool isLiked = _likedVideos[videoId] ?? false;
    
    // Update local state
    if (isLiked) {
      _likedVideos.remove(videoId);
      _likeCount[videoId] = (_likeCount[videoId] ?? 1) - 1;
    } else {
      _likedVideos[videoId] = true;
      _likeCount[videoId] = (_likeCount[videoId] ?? 0) + 1;
    }
    
    notifyListeners();
    
    // Update local database
    if (isLiked) {
      await _dbHelper.deleteLike(videoId);
    } else {
      await _dbHelper.insertLike(videoId);
    }
    
    // Update Firestore
    try {
      await _firestore.collection('likes').doc(videoId).set({
        'video_id': videoId,
        'count': _likeCount[videoId],
      });
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  // Check if a video is liked
  bool isVideoLiked(String videoId) {
    return _likedVideos[videoId] ?? false;
  }
  
  // Get like count for a video
  int getLikeCount(String videoId) {
    return _likeCount[videoId] ?? 0;
  }
}
