// YouTube Data API v3 Configuration
class YouTubeConfig {
  // YouTube Data API v3 key
  // Get your API key from: https://console.cloud.google.com/apis/credentials
  static const String apiKey = 'AIzaSyAX_eZLsHamr_rTG8IpMmhdmqJDXpgowE8';
  
  static const String baseUrl = 'https://www.googleapis.com/youtube/v3';
  
  // API Endpoints
  static const String searchEndpoint = '$baseUrl/search';
  static const String videosEndpoint = '$baseUrl/videos';
  
  // Default parameters
  static const int maxResults = 20;
  static const String type = 'video';
  static const String part = 'snippet';
  static const String videoDetailspart = 'snippet,contentDetails,statistics';
  
  // Educational content categories
  static const List<String> suggestedSearches = [
    'Programming tutorial',
    'Mathematics lesson',
    'Science explained',
    'History documentary',
    'Language learning',
    'Physics concepts',
    'Chemistry experiments',
    'Biology basics',
    'Computer science',
    'Data structures',
  ];
  
  // Validate API key
  static bool get isApiKeyConfigured {
    return apiKey != 'YOUR_YOUTUBE_API_KEY_HERE' && apiKey.isNotEmpty;
  }
}
