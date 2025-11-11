# YouTube Integration - Setup Guide

## Overview
The YouTube Integration feature allows users to search and watch educational videos within the StudyBuddy app using the YouTube Data API v3.

## Features Implemented
✅ Video search with keywords (e.g., "Python tutorial", "Data structures")
✅ Display video thumbnails, titles, channel names, and descriptions
✅ Embedded video player for in-app viewing
✅ Filters: Relevance, Upload Date, View Count, Rating, Duration
✅ Pagination support for loading more results
✅ Related videos suggestions
✅ Loading indicators and error handling
✅ Theme consistent with dashboard (purple gradient)

## Setup Instructions

### Step 1: Get YouTube Data API v3 Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create a new project or select an existing one
3. Enable the **YouTube Data API v3**:
   - Go to "APIs & Services" > "Library"
   - Search for "YouTube Data API v3"
   - Click "Enable"
4. Create credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy the generated API key
5. (Optional) Restrict the API key:
   - Click on the API key to edit it
   - Under "API restrictions", select "Restrict key"
   - Choose "YouTube Data API v3"
   - Save

### Step 2: Add API Key to the App

1. Open `lib/config/youtube_config.dart`
2. Replace `'YOUR_YOUTUBE_API_KEY_HERE'` with your actual API key:

```dart
class YouTubeConfig {
  static const String apiKey = 'AIzaSyC...your-actual-key...';
  // ... rest of the file
}
```

### Step 3: Install Dependencies

Run the following command to install the required packages:

```bash
flutter pub get
```

**Dependencies added:**
- `youtube_player_flutter: ^9.0.3` - For embedded video playback
- `http: ^1.2.0` - For API requests
- `url_launcher: ^6.2.0` - For opening external links

### Step 4: Test the Feature

1. Run the app: `flutter run`
2. Log in to your account
3. On the dashboard, tap the **YouTube** button
4. Try searching for educational content
5. Test filters and pagination
6. Tap a video to watch it in the embedded player

## File Structure

```
lib/
├── config/
│   └── youtube_config.dart          # API configuration
├── models/
│   └── youtube_video_model.dart     # Data models
├── services/
│   └── youtube_service.dart         # API integration
└── screens/
    ├── youtube_screen.dart          # Search UI
    └── video_player_screen.dart     # Video player UI
```

## API Quota Information

**YouTube Data API v3 has a daily quota limit:**
- Default quota: 10,000 units per day
- Search request: ~100 units
- Video details request: ~1 unit per video

**Estimated usage:**
- Each search (with 20 results): ~120 units
- You can perform approximately 80 searches per day with the default quota

**To increase quota:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/api/youtube.googleapis.com/quotas)
2. Request a quota increase if needed

## Error Handling

The app handles the following error scenarios:

1. **Missing API Key**: Displays error message prompting user to configure API key
2. **Quota Exceeded (403)**: Shows "API quota exceeded" error with retry option
3. **Network Errors**: Displays connection error with retry button
4. **No Results**: Shows empty state with suggested searches
5. **Video Load Failure**: Shows placeholder thumbnail with error icon

## Features Available

### YouTube Search Screen (`youtube_screen.dart`)
- **Search Bar**: Type keywords to search for videos
- **Filters**:
  - Order: Relevance, Upload Date, View Count, Rating
  - Duration: Any, Short (<4 min), Medium (4-20 min), Long (>20 min)
- **Video Cards**: Display thumbnail, title, channel, views, duration, upload date
- **Pagination**: Automatically loads more results when scrolling to bottom
- **Suggested Searches**: Shows educational topics in empty state

### Video Player Screen (`video_player_screen.dart`)
- **Embedded Player**: Watch videos without leaving the app
- **Video Details**: Title, channel, views, likes, publish date
- **Description**: Shows video description (first 5 lines)
- **Related Videos**: Suggests similar educational content
- **Controls**: Play/pause, seek, fullscreen, captions

## Troubleshooting

### Issue: "API key not configured" error
**Solution**: Ensure you've added your YouTube API key in `lib/config/youtube_config.dart`

### Issue: "API quota exceeded" error
**Solution**: 
1. Wait for the daily quota to reset (at midnight Pacific Time)
2. Request a quota increase in Google Cloud Console
3. Use quota more efficiently by implementing caching

### Issue: Videos not loading
**Solution**:
1. Check your internet connection
2. Verify API key is correct and not expired
3. Ensure YouTube Data API v3 is enabled in Google Cloud Console

### Issue: Player not working
**Solution**:
1. Check that `youtube_player_flutter` package is properly installed
2. Ensure device/emulator has internet access
3. Try running `flutter clean` and `flutter pub get`

## Customization

### Change default search results count
Edit `lib/config/youtube_config.dart`:
```dart
static const int maxResults = 20; // Change to desired number
```

### Add more educational search suggestions
Edit `lib/config/youtube_config.dart`:
```dart
static const List<String> suggestedSearches = [
  'Your Custom Topic 1',
  'Your Custom Topic 2',
  // Add more...
];
```

### Modify theme colors
Edit the gradient in `youtube_screen.dart` (line ~118):
```dart
gradient: const LinearGradient(
  colors: [Color(0xFF667EEA), Color(0xFF764BA2)], // Change colors
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
```

## Testing Checklist

- [ ] API key is configured correctly
- [ ] Search returns relevant results
- [ ] Filters work correctly (order and duration)
- [ ] Pagination loads more results
- [ ] Video player plays videos
- [ ] Related videos display correctly
- [ ] Error states show proper messages
- [ ] Loading indicators appear during API calls
- [ ] Theme matches dashboard design
- [ ] Navigation back to dashboard works
- [ ] App handles quota exceeded gracefully

## Future Enhancements (Optional)

- **Caching**: Implement local caching to reduce API calls
- **Favorites**: Allow users to save favorite videos
- **Watch History**: Track watched videos
- **Playlists**: Support YouTube playlists
- **Offline Mode**: Download videos for offline viewing
- **Comments**: Display video comments
- **Channels**: Follow educational channels

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review YouTube Data API documentation: https://developers.google.com/youtube/v3
3. Check Flutter youtube_player_flutter documentation: https://pub.dev/packages/youtube_player_flutter

## Credits

- **YouTube Data API v3**: Powered by Google
- **youtube_player_flutter**: Created by Sarbagya Dhaubanjar
- **Icons**: Material Design Icons

---

**Important**: Keep your API key secure! Do not commit it to version control. Consider using environment variables or Flutter's `--dart-define` for production builds.
