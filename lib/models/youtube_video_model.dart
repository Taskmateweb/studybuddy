class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final String channelTitle;
  final String channelId;
  final String thumbnailUrl;
  final String publishedAt;
  final String? duration;
  final int? viewCount;
  final int? likeCount;

  YouTubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.channelTitle,
    required this.channelId,
    required this.thumbnailUrl,
    required this.publishedAt,
    this.duration,
    this.viewCount,
    this.likeCount,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};
    final statistics = json['statistics'] as Map<String, dynamic>?;
    final contentDetails = json['contentDetails'] as Map<String, dynamic>?;

    // Handle different ID formats from search and video details
    String videoId;
    if (json['id'] is String) {
      videoId = json['id'] as String;
    } else if (json['id'] is Map) {
      videoId = (json['id'] as Map<String, dynamic>)['videoId'] as String? ?? '';
    } else {
      videoId = '';
    }

    // Get thumbnail URL (prefer high quality)
    String thumbnailUrl = '';
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
    if (thumbnails != null) {
      if (thumbnails.containsKey('high')) {
        thumbnailUrl = thumbnails['high']['url'] as String? ?? '';
      } else if (thumbnails.containsKey('medium')) {
        thumbnailUrl = thumbnails['medium']['url'] as String? ?? '';
      } else if (thumbnails.containsKey('default')) {
        thumbnailUrl = thumbnails['default']['url'] as String? ?? '';
      }
    }

    return YouTubeVideo(
      id: videoId,
      title: snippet['title'] as String? ?? 'No Title',
      description: snippet['description'] as String? ?? '',
      channelTitle: snippet['channelTitle'] as String? ?? 'Unknown Channel',
      channelId: snippet['channelId'] as String? ?? '',
      thumbnailUrl: thumbnailUrl,
      publishedAt: snippet['publishedAt'] as String? ?? '',
      duration: contentDetails?['duration'] as String?,
      viewCount: statistics != null && statistics.containsKey('viewCount')
          ? int.tryParse(statistics['viewCount'].toString())
          : null,
      likeCount: statistics != null && statistics.containsKey('likeCount')
          ? int.tryParse(statistics['likeCount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'channelTitle': channelTitle,
      'channelId': channelId,
      'thumbnailUrl': thumbnailUrl,
      'publishedAt': publishedAt,
      'duration': duration,
      'viewCount': viewCount,
      'likeCount': likeCount,
    };
  }

  // Helper method to format view count
  String get formattedViewCount {
    if (viewCount == null) return '';
    if (viewCount! >= 1000000) {
      return '${(viewCount! / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount! >= 1000) {
      return '${(viewCount! / 1000).toStringAsFixed(1)}K views';
    }
    return '$viewCount views';
  }

  // Helper method to format duration from ISO 8601 format (PT15M30S)
  String get formattedDuration {
    if (duration == null) return '';
    
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration!);
    
    if (match == null) return '';
    
    final hours = match.group(1);
    final minutes = match.group(2);
    final seconds = match.group(3);
    
    String result = '';
    if (hours != null) {
      result += '$hours:';
    }
    if (minutes != null) {
      result += hours != null ? minutes.padLeft(2, '0') : minutes;
      result += ':';
    } else if (hours != null) {
      result += '00:';
    }
    if (seconds != null) {
      result += minutes != null || hours != null 
          ? seconds.padLeft(2, '0') 
          : '0:$seconds';
    } else {
      result += '00';
    }
    
    return result;
  }

  // Helper method to format published date
  String get formattedPublishedDate {
    try {
      final date = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}

class YouTubeSearchResponse {
  final List<YouTubeVideo> videos;
  final String? nextPageToken;
  final String? prevPageToken;
  final int totalResults;

  YouTubeSearchResponse({
    required this.videos,
    this.nextPageToken,
    this.prevPageToken,
    required this.totalResults,
  });

  factory YouTubeSearchResponse.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? [];
    final videos = items
        .map((item) => YouTubeVideo.fromJson(item as Map<String, dynamic>))
        .toList();

    final pageInfo = json['pageInfo'] as Map<String, dynamic>? ?? {};

    return YouTubeSearchResponse(
      videos: videos,
      nextPageToken: json['nextPageToken'] as String?,
      prevPageToken: json['prevPageToken'] as String?,
      totalResults: pageInfo['totalResults'] as int? ?? 0,
    );
  }
}
