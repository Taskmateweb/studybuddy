class PrayerTime {
  final String name;
  final String arabicName;
  final DateTime time;
  final bool isNext;
  final String icon;

  PrayerTime({
    required this.name,
    required this.arabicName,
    required this.time,
    this.isNext = false,
    required this.icon,
  });

  String get formattedTime {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  PrayerTime copyWith({bool? isNext}) {
    return PrayerTime(
      name: name,
      arabicName: arabicName,
      time: time,
      isNext: isNext ?? this.isNext,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arabicName': arabicName,
      'time': time.toIso8601String(),
      'isNext': isNext,
      'icon': icon,
    };
  }

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      name: json['name'],
      arabicName: json['arabicName'],
      time: DateTime.parse(json['time']),
      isNext: json['isNext'] ?? false,
      icon: json['icon'],
    );
  }
}

class DailyPrayerTimes {
  final DateTime date;
  final PrayerTime fajr;
  final PrayerTime sunrise;
  final PrayerTime dhuhr;
  final PrayerTime asr;
  final PrayerTime maghrib;
  final PrayerTime isha;
  final PrayerTime? midnight;
  final String location;

  DailyPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.midnight,
    required this.location,
  });

  List<PrayerTime> get allPrayers => [fajr, dhuhr, asr, maghrib, isha];
  
  List<PrayerTime> get allTimes => [
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
    if (midnight != null) midnight!,
  ];

  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    for (var prayer in allPrayers) {
      if (prayer.time.isAfter(now)) {
        return prayer;
      }
    }
    return null; // All prayers completed for today
  }

  Duration? get timeUntilNextPrayer {
    final next = nextPrayer;
    if (next == null) return null;
    return next.time.difference(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'fajr': fajr.toJson(),
      'sunrise': sunrise.toJson(),
      'dhuhr': dhuhr.toJson(),
      'asr': asr.toJson(),
      'maghrib': maghrib.toJson(),
      'isha': isha.toJson(),
      'midnight': midnight?.toJson(),
      'location': location,
    };
  }

  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) {
    return DailyPrayerTimes(
      date: DateTime.parse(json['date']),
      fajr: PrayerTime.fromJson(json['fajr']),
      sunrise: PrayerTime.fromJson(json['sunrise']),
      dhuhr: PrayerTime.fromJson(json['dhuhr']),
      asr: PrayerTime.fromJson(json['asr']),
      maghrib: PrayerTime.fromJson(json['maghrib']),
      isha: PrayerTime.fromJson(json['isha']),
      midnight: json['midnight'] != null ? PrayerTime.fromJson(json['midnight']) : null,
      location: json['location'],
    );
  }
}

class PrayerNotificationSettings {
  final bool fajrEnabled;
  final bool dhuhrEnabled;
  final bool asrEnabled;
  final bool maghribEnabled;
  final bool ishaEnabled;
  final int reminderMinutes; // Minutes before adhan
  final bool adhanSoundEnabled;
  final bool vibrateEnabled;

  PrayerNotificationSettings({
    this.fajrEnabled = true,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
    this.reminderMinutes = 10,
    this.adhanSoundEnabled = true,
    this.vibrateEnabled = true,
  });

  bool isEnabledFor(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return fajrEnabled;
      case 'dhuhr':
        return dhuhrEnabled;
      case 'asr':
        return asrEnabled;
      case 'maghrib':
        return maghribEnabled;
      case 'isha':
        return ishaEnabled;
      default:
        return false;
    }
  }

  PrayerNotificationSettings copyWith({
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
    int? reminderMinutes,
    bool? adhanSoundEnabled,
    bool? vibrateEnabled,
  }) {
    return PrayerNotificationSettings(
      fajrEnabled: fajrEnabled ?? this.fajrEnabled,
      dhuhrEnabled: dhuhrEnabled ?? this.dhuhrEnabled,
      asrEnabled: asrEnabled ?? this.asrEnabled,
      maghribEnabled: maghribEnabled ?? this.maghribEnabled,
      ishaEnabled: ishaEnabled ?? this.ishaEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      adhanSoundEnabled: adhanSoundEnabled ?? this.adhanSoundEnabled,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajrEnabled': fajrEnabled,
      'dhuhrEnabled': dhuhrEnabled,
      'asrEnabled': asrEnabled,
      'maghribEnabled': maghribEnabled,
      'ishaEnabled': ishaEnabled,
      'reminderMinutes': reminderMinutes,
      'adhanSoundEnabled': adhanSoundEnabled,
      'vibrateEnabled': vibrateEnabled,
    };
  }

  factory PrayerNotificationSettings.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationSettings(
      fajrEnabled: json['fajrEnabled'] ?? true,
      dhuhrEnabled: json['dhuhrEnabled'] ?? true,
      asrEnabled: json['asrEnabled'] ?? true,
      maghribEnabled: json['maghribEnabled'] ?? true,
      ishaEnabled: json['ishaEnabled'] ?? true,
      reminderMinutes: json['reminderMinutes'] ?? 10,
      adhanSoundEnabled: json['adhanSoundEnabled'] ?? true,
      vibrateEnabled: json['vibrateEnabled'] ?? true,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String cityName;
  final String countryName;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.countryName,
  });

  String get displayName => '$cityName, $countryName';

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'countryName': countryName,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'],
      longitude: json['longitude'],
      cityName: json['cityName'],
      countryName: json['countryName'],
    );
  }
}
