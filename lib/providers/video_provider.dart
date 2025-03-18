// providers/video_provider.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/video.dart';

class VideoProvider with ChangeNotifier {
  List<Video> _videos = [];
  bool _isLoading = false;
  String? _error;

  List<Video> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Use Pexels API for fetching videos
  Future<void> fetchVideos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Replace with your actual API key
      const apiKey = 'ELIPwfsOfOHZZQ27fbfX49WSSTA0cdYS5KnRMvDwItHT61bEvrG3pgsw';
      final response = await http.get(
        Uri.parse('https://api.pexels.com/videos/popular?per_page=20'),
        headers: {
          'Authorization': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Video> loadedVideos = [];
        
        for (var video in data['videos']) {
          // Get the smallest thumbnail for preview
          final thumbnail = video['video_pictures'][0]['picture'];
          
          loadedVideos.add(
            Video(
              id: video['id'].toString(),
              title: video['user']['name'],
              thumbnailUrl: thumbnail,
              videoUrl: video['video_files'][0]['link'],
            ),
          );
        }
        
        _videos = loadedVideos;
      } else {
        _error = 'Failed to load videos. Please try again later.';
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
