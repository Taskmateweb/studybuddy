import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/youtube_video_model.dart';
import '../config/youtube_config.dart';

enum SearchOrder {
  relevance,
  date,
  viewCount,
  rating,
}

enum VideoDuration {
  any,
  short, // < 4 minutes
  medium, // 4-20 minutes
  long, // > 20 minutes
}

class YouTubeService {
  // Search for videos
  Future<YouTubeSearchResponse> searchVideos({
    required String query,
    int maxResults = 20,
    String? pageToken,
    SearchOrder order = SearchOrder.relevance,
    VideoDuration duration = VideoDuration.any,
  }) async {
    try {
      if (!YouTubeConfig.isApiKeyConfigured) {
        throw Exception(
          'YouTube API key not configured. Please add your API key in lib/config/youtube_config.dart'
        );
      }

      // Build query parameters
      final params = {
        'part': YouTubeConfig.part,
        'q': query,
        'type': YouTubeConfig.type,
        'maxResults': maxResults.toString(),
        'key': YouTubeConfig.apiKey,
        'order': _getOrderString(order),
      };

      // Add duration filter if specified
      if (duration != VideoDuration.any) {
        params['videoDuration'] = _getDurationString(duration);
      }

      // Add page token if provided
      if (pageToken != null && pageToken.isNotEmpty) {
        params['pageToken'] = pageToken;
      }

      // Build URL
      final uri = Uri.parse(YouTubeConfig.searchEndpoint).replace(
        queryParameters: params,
      );

      print('🔍 Searching YouTube: $query');
      
      // Make API request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final searchResponse = YouTubeSearchResponse.fromJson(data);
        
        print('✅ Found ${searchResponse.videos.length} videos');
        
        // Fetch additional details for videos (duration, view count, etc.)
        if (searchResponse.videos.isNotEmpty) {
          final videoIds = searchResponse.videos.map((v) => v.id).join(',');
          final detailedVideos = await getVideoDetails(videoIds);
          
          return YouTubeSearchResponse(
            videos: detailedVideos,
            nextPageToken: searchResponse.nextPageToken,
            prevPageToken: searchResponse.prevPageToken,
            totalResults: searchResponse.totalResults,
          );
        }
        
        return searchResponse;
      } else if (response.statusCode == 403) {
        throw Exception(
          'YouTube API quota exceeded or invalid API key. Please check your API key.'
        );
      } else {
        throw Exception(
          'Failed to search videos: ${response.statusCode} - ${response.body}'
        );
      }
    } catch (e) {
      print('❌ YouTube search error: $e');
      rethrow;
    }
  }

  // Get video details (duration, view count, likes, etc.)
  Future<List<YouTubeVideo>> getVideoDetails(String videoIds) async {
    try {
      final params = {
        'part': YouTubeConfig.videoDetailspart,
        'id': videoIds,
        'key': YouTubeConfig.apiKey,
      };

      final uri = Uri.parse(YouTubeConfig.videosEndpoint).replace(
        queryParameters: params,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        
        return items
            .map((item) => YouTubeVideo.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get video details: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get video details error: $e');
      rethrow;
    }
  }

  // Get related videos
  Future<List<YouTubeVideo>> getRelatedVideos(String videoId) async {
    try {
      final params = {
        'part': YouTubeConfig.part,
        'relatedToVideoId': videoId,
        'type': YouTubeConfig.type,
        'maxResults': '10',
        'key': YouTubeConfig.apiKey,
      };

      final uri = Uri.parse(YouTubeConfig.searchEndpoint).replace(
        queryParameters: params,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final searchResponse = YouTubeSearchResponse.fromJson(data);
        
        // Fetch additional details for related videos
        if (searchResponse.videos.isNotEmpty) {
          final videoIds = searchResponse.videos.map((v) => v.id).join(',');
          return await getVideoDetails(videoIds);
        }
        
        return searchResponse.videos;
      } else {
        throw Exception('Failed to get related videos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get related videos error: $e');
      return []; // Return empty list on error for related videos
    }
  }

  // Helper method to convert SearchOrder enum to API string
  String _getOrderString(SearchOrder order) {
    switch (order) {
      case SearchOrder.relevance:
        return 'relevance';
      case SearchOrder.date:
        return 'date';
      case SearchOrder.viewCount:
        return 'viewCount';
      case SearchOrder.rating:
        return 'rating';
    }
  }

  // Helper method to convert VideoDuration enum to API string
  String _getDurationString(VideoDuration duration) {
    switch (duration) {
      case VideoDuration.any:
        return 'any';
      case VideoDuration.short:
        return 'short';
      case VideoDuration.medium:
        return 'medium';
      case VideoDuration.long:
        return 'long';
    }
  }

  // Search suggestions based on educational topics
  List<String> getSearchSuggestions() {
    return YouTubeConfig.suggestedSearches;
  }

  // Build video URL
  String getVideoUrl(String videoId) {
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  // Build channel URL
  String getChannelUrl(String channelId) {
    return 'https://www.youtube.com/channel/$channelId';
  }
}
