# Testing Muslim Pro API Integration

## Quick Test Guide

### Step 1: Check API Connection
1. Open the app
2. Navigate to "Balance Your Life" (Prayer Times)
3. Watch the console logs for:
   ```
   ✅ API call successful
   OR
   ⚠️ Error fetching from API: ...
   ℹ️ Using fallback Adhan calculation
   ```

### Step 2: Verify Prayer Times Display
Expected behavior:
- **Times should display** for all 5 prayers (Fajr, Dhuhr, Asr, Maghrib, Isha)
- **Next prayer highlighted** with countdown timer
- **Location shows**: "Dhaka, Bangladesh"

### Step 3: Test Offline Mode
1. Display the prayer times (with internet)
2. Disable WiFi/Mobile data
3. Force close and reopen the app
4. Prayer times should still display (from cache)

### Step 4: Test Fallback Mechanism
To test if fallback works:
1. Look for console log: "Using fallback Adhan calculation"
2. This happens when API fails
3. Times will be calculated locally using GPS + Adhan package

## What to Look For

### ✅ Success Indicators
- Prayer times display correctly
- Next prayer is highlighted
- Countdown timer updates every second
- No errors in console
- Location shows "Dhaka, Bangladesh"

### ⚠️ Potential Issues

#### Issue 1: API Returns 404 or Error
**Console Shows**: `API Error: 404` or `Error fetching from API`
**What Happens**: App falls back to Adhan calculation
**Action**: This is expected behavior, fallback is working

#### Issue 2: Time Parsing Errors
**Console Shows**: `Error parsing time: [timeValue]`
**What Happens**: Individual prayer time may default to current time
**Action**: Check API response format and update parsing logic

#### Issue 3: Network Timeout
**Console Shows**: `Error fetching from API: TimeoutException`
**What Happens**: App uses fallback calculation
**Action**: Normal behavior, no action needed

## Console Output Examples

### Successful API Call
```
Fetching prayer times from API...
API Response: {data: {Fajr: 04:45, Sunrise: 05:58, ...}}
Parsed Fajr: 2025-11-16 04:45:00
Parsed Dhuhr: 2025-11-16 11:50:00
...
Prayer times cached successfully
Location: Dhaka, Bangladesh
```

### API Failure with Fallback
```
Error fetching from API: SocketException: Failed host lookup
Using fallback Adhan calculation
Calculating for coordinates: 23.8103, 90.4125
Prayer times calculated successfully
Location: Your City, Your Country
```

### Cached Data Used
```
Loading prayer times...
Found cached data for today
Prayer times loaded from cache
Next prayer: Asr at 15:15
```

## API Response Debug

### Check Actual API Response
Add this log in the code to see raw API response:
```dart
print('Raw API Response: ${response.body}');
```

### Expected Response Format
The API should return something like:
```json
{
  "data": {
    "Fajr": "04:45",
    "Sunrise": "05:58", 
    "Dhuhr": "11:50",
    "Asr": "15:15",
    "Maghrib": "17:42",
    "Isha": "18:58"
  }
}
```

## Testing Checklist

- [ ] App opens without crashes
- [ ] Prayer times screen loads
- [ ] 5 main prayers displayed (Fajr, Dhuhr, Asr, Maghrib, Isha)
- [ ] Next prayer is highlighted
- [ ] Countdown timer updates
- [ ] Location shows "Dhaka, Bangladesh"
- [ ] Times are reasonable (check against actual prayer times)
- [ ] Offline mode works (cached data)
- [ ] Fallback works when API fails

## Comparison Test

### Verify Accuracy
Compare app times with official sources:
1. Check [IslamicFinder](https://www.islamicfinder.org/world/bangladesh/dhaka/)
2. Check [MuslimPro app](https://www.muslimpro.com/)
3. Times should match or be very close (±2 minutes acceptable)

### Expected Times for Dhaka (Example)
- **Fajr**: ~4:45 AM
- **Sunrise**: ~5:58 AM
- **Dhuhr**: ~11:50 AM
- **Asr**: ~3:15 PM
- **Maghrib**: ~5:42 PM
- **Isha**: ~6:58 PM

*Note: Times vary by season*

## Performance Test

### Check Loading Speed
- First load (API call): Should be < 3 seconds
- Cached load: Should be instant (< 1 second)
- Fallback calculation: Should be instant (< 1 second)

## Next Steps if Issues

### If API not working:
1. Check internet connection
2. Verify API endpoint is correct
3. Check API response format
4. Confirm fallback is working

### If times are wrong:
1. Verify API is returning correct data
2. Check timezone settings
3. Ensure date parsing is correct
4. Compare with fallback calculation

### If app crashes:
1. Check console for stack trace
2. Verify all imports are correct
3. Check for null values in parsing
4. Ensure error handling is working

## Success Criteria

✅ **API Integration is successful when:**
- Prayer times load from API
- Times are accurate for Dhaka
- Fallback works when API fails
- Caching works for offline access
- No crashes or errors
- UI updates smoothly

🎉 **If all tests pass, the integration is complete!**
