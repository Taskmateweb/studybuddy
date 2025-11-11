import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_time_model.dart';

class PrayerService {
  static const String _cacheKey = 'daily_prayer_times';
  static const String _locationKey = 'saved_location';
  static const String _calculationMethodKey = 'calculation_method';

  // Get current location
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // You can use reverse geocoding API here for city/country names
      // For now, using placeholder names
      final location = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: 'Your City', // TODO: Implement reverse geocoding
        countryName: 'Your Country',
      );

      // Save location
      await _saveLocation(location);
      return location;
    } catch (e) {
      print('Error getting location: $e');
      // Try to return cached location
      return await getSavedLocation();
    }
  }

  // Save location to cache
  Future<void> _saveLocation(LocationData location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, jsonEncode(location.toJson()));
  }

  // Get saved location
  Future<LocationData?> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(_locationKey);
      if (locationJson != null) {
        return LocationData.fromJson(jsonDecode(locationJson));
      }
    } catch (e) {
      print('Error loading saved location: $e');
    }
    return null;
  }

  // Calculate prayer times using Adhan package
  Future<DailyPrayerTimes> calculatePrayerTimes(LocationData location, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    
    // Create Coordinates
    final coordinates = Coordinates(location.latitude, location.longitude);
    
    // Get calculation method (you can make this configurable)
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi; // Default to Shafi madhab
    
    // Calculate prayer times
    final prayerTimes = PrayerTimes.today(coordinates, params);
    
    // Create PrayerTime objects
    final fajr = PrayerTime(
      name: 'Fajr',
      arabicName: 'الفجر',
      time: prayerTimes.fajr,
      icon: '🌅',
    );
    
    final sunrise = PrayerTime(
      name: 'Sunrise',
      arabicName: 'الشروق',
      time: prayerTimes.sunrise,
      icon: '☀️',
    );
    
    final dhuhr = PrayerTime(
      name: 'Dhuhr',
      arabicName: 'الظهر',
      time: prayerTimes.dhuhr,
      icon: '🌞',
    );
    
    final asr = PrayerTime(
      name: 'Asr',
      arabicName: 'العصر',
      time: prayerTimes.asr,
      icon: '🌤️',
    );
    
    final maghrib = PrayerTime(
      name: 'Maghrib',
      arabicName: 'المغرب',
      time: prayerTimes.maghrib,
      icon: '🌆',
    );
    
    final isha = PrayerTime(
      name: 'Isha',
      arabicName: 'العشاء',
      time: prayerTimes.isha,
      icon: '🌙',
    );

    final midnight = PrayerTime(
      name: 'Midnight',
      arabicName: 'منتصف الليل',
      time: prayerTimes.isha.add(Duration(
        hours: prayerTimes.fajr.difference(prayerTimes.isha).inHours ~/ 2,
      )),
      icon: '✨',
    );
    
    final dailyTimes = DailyPrayerTimes(
      date: targetDate,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      midnight: midnight,
      location: location.displayName,
    );
    
    // Cache the times
    await _cachePrayerTimes(dailyTimes);
    
    return dailyTimes;
  }

  // Get today's prayer times
  Future<DailyPrayerTimes?> getTodayPrayerTimes() async {
    try {
      // Try to get from cache first
      final cached = await _getCachedPrayerTimes();
      if (cached != null && _isSameDay(cached.date, DateTime.now())) {
        return _markNextPrayer(cached);
      }

      // Get location
      LocationData? location = await getSavedLocation();
      location ??= await getCurrentLocation();

      if (location == null) {
        throw Exception('Unable to get location');
      }

      // Calculate new prayer times
      final times = await calculatePrayerTimes(location);
      return _markNextPrayer(times);
    } catch (e) {
      print('Error getting prayer times: $e');
      // Return cached data if available, even if old
      return await _getCachedPrayerTimes();
    }
  }

  // Mark the next prayer
  DailyPrayerTimes _markNextPrayer(DailyPrayerTimes times) {
    final now = DateTime.now();
    final prayers = times.allPrayers;
    
    // Find next prayer
    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i].time.isAfter(now)) {
        // Mark this prayer as next
        final updatedPrayers = List<PrayerTime>.from(prayers);
        updatedPrayers[i] = prayers[i].copyWith(isNext: true);
        
        return DailyPrayerTimes(
          date: times.date,
          fajr: updatedPrayers[0],
          sunrise: times.sunrise,
          dhuhr: updatedPrayers[1],
          asr: updatedPrayers[2],
          maghrib: updatedPrayers[3],
          isha: updatedPrayers[4],
          midnight: times.midnight,
          location: times.location,
        );
      }
    }
    
    return times; // All prayers passed
  }

  // Cache prayer times
  Future<void> _cachePrayerTimes(DailyPrayerTimes times) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(times.toJson()));
    } catch (e) {
      print('Error caching prayer times: $e');
    }
  }

  // Get cached prayer times
  Future<DailyPrayerTimes?> _getCachedPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timesJson = prefs.getString(_cacheKey);
      if (timesJson != null) {
        return DailyPrayerTimes.fromJson(jsonDecode(timesJson));
      }
    } catch (e) {
      print('Error loading cached prayer times: $e');
    }
    return null;
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get countdown string
  String getCountdownString(Duration? duration) {
    if (duration == null) return 'No upcoming prayers';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Get motivational quotes
  List<String> getMotivationalQuotes() {
    return [
      '"Verily, prayer restrains from shameful and unjust deeds." - Quran 29:45',
      '"The key to Paradise is prayer." - Prophet Muhammad (PBUH)',
      '"When you get up for prayer, perform ablution properly." - Hadith',
      '"Prayer is the pillar of religion." - Prophet Muhammad (PBUH)',
      '"The coolness of my eyes is in prayer." - Prophet Muhammad (PBUH)',
      '"Between a person and disbelief is the abandonment of prayer." - Hadith',
      '"Pray as you have seen me praying." - Prophet Muhammad (PBUH)',
      '"Prayer is a conversation with Allah." - Islamic Wisdom',
    ];
  }

  // Save calculation method preference
  Future<void> saveCalculationMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_calculationMethodKey, method);
  }

  // Get calculation method preference
  Future<String> getCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_calculationMethodKey) ?? 'muslim_world_league';
  }
}
