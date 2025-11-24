# Duration Tracking Improvement

## Problem
Previously, the trip duration timer would continue counting even when the motorcycle was stopped at traffic lights, gas stations, or rest breaks. This resulted in inaccurate "riding time" metrics.

## Solution
Modified the GPS tracking system to only count duration when the bike is **actually moving** (speed > 1 km/h).

## Changes Made

### File: `GPSTrackingManager.swift`

#### 1. Active Duration Tracking (Lines 185-193)
**Before**:
```swift
private func updateDuration() {
    guard let startTime = tripStartTime else { return }
    tripDuration = Date().timeIntervalSince(startTime)
    if !isPaused {
        activeDuration += 1.0  // ❌ Always counts, even when stopped
    }
}
```

**After**:
```swift
private func updateDuration() {
    guard let startTime = tripStartTime else { return }
    tripDuration = Date().timeIntervalSince(startTime)
    
    // Only count duration when bike is actually moving (speed > 1 km/h)
    if !isPaused && currentSpeed > 1.0 {  // ✅ Only counts when moving
        activeDuration += 1.0
    }
}
```

#### 2. Speed Zone Tracking (Lines 199-223)
**Before**:
```swift
private func updateSpeedZones() {
    guard !isPaused, let lastUpdate = lastSpeedZoneUpdate else { return }
    let elapsed = Date().timeIntervalSince(lastUpdate)
    
    let speed = currentSpeed
    if speed < 30 {
        speedZones["0-30"]! += elapsed  // ❌ Counts stationary time as 0-30 km/h
    }
    // ... rest of zones
}
```

**After**:
```swift
private func updateSpeedZones() {
    guard !isPaused, let lastUpdate = lastSpeedZoneUpdate else { return }
    
    // Only count speed zones when bike is actually moving (speed > 1 km/h)
    guard currentSpeed > 1.0 else {  // ✅ Skip if stopped
        lastSpeedZoneUpdate = Date()
        return
    }
    
    let elapsed = Date().timeIntervalSince(lastUpdate)
    
    let speed = currentSpeed
    if speed < 30 {
        speedZones["0-30"]! += elapsed
    }
    // ... rest of zones
}
```

## How It Works

### Movement Detection
- **Threshold**: 1 km/h (approximately 0.28 m/s)
- **Why 1 km/h?**: 
  - GPS accuracy can show small speed variations when stationary
  - 1 km/h is slow enough to filter out GPS noise
  - Fast enough to catch actual movement immediately

### Duration Types

The system now tracks **two** different duration metrics:

1. **Total Duration** (`tripDuration`)
   - Starts when tracking begins
   - Continues until tracking stops
   - Includes ALL time (stopped at lights, breaks, etc.)
   - Formula: `Current Time - Start Time`

2. **Active Duration** (`activeDuration`)
   - Only counts when `currentSpeed > 1.0 km/h`
   - Represents actual riding time
   - Excludes: traffic stops, gas stations, rest breaks
   - Formula: `Sum of 1-second intervals when moving`

### Usage in Calculations

**Average Speed**:
```swift
averageSpeed = (tripDistance / activeDuration) * 3600 // km/h
```
- Uses `activeDuration` for accurate speed calculation
- Ignores time spent stopped

**Calories**:
```swift
let hoursRidden = activeDuration / 3600.0
calories = hoursRidden * 40.0
```
- Based on actual riding time
- More accurate energy expenditure

**Trip Summary**:
```swift
let summary = TripSummary(
    duration: activeDuration > 0 ? activeDuration : tripDuration,
    // ... other fields
)
```
- Saved trip shows `activeDuration` (moving time)
- Falls back to `tripDuration` if no movement detected

## Benefits

### ✅ Accurate Riding Time
- Shows true time spent riding
- Excludes stops at traffic lights
- Excludes fuel stops
- Excludes rest breaks

### ✅ Better Average Speed
- More realistic speed calculations
- Not diluted by stopped time
- Reflects actual riding pace

### ✅ Fair Comparisons
- Compare rides fairly
- Urban rides (lots of stops) vs highway rides
- Actual riding metrics, not total trip time

### ✅ Proper Analytics
- Speed zone distribution accurate
- Calorie burn more realistic
- Carbon savings calculations improved

## Example Scenarios

### Scenario 1: City Ride with Traffic
**Before Fix**:
```
Distance: 50 km
Total Time: 2 hours (7200 seconds)
Stopped at lights: 30 minutes (1800 seconds)
Average Speed: 50 / 2 = 25 km/h ❌ (too low)
```

**After Fix**:
```
Distance: 50 km
Active Time: 1.5 hours (5400 seconds)
Stopped at lights: 30 minutes (not counted)
Average Speed: 50 / 1.5 = 33.3 km/h ✅ (accurate)
```

### Scenario 2: Highway Ride with Fuel Stop
**Before Fix**:
```
Distance: 300 km
Total Time: 4 hours (14400 seconds)
Fuel stop: 15 minutes (900 seconds)
Average Speed: 300 / 4 = 75 km/h ❌ (too low)
```

**After Fix**:
```
Distance: 300 km
Active Time: 3.75 hours (13500 seconds)
Fuel stop: 15 minutes (not counted)
Average Speed: 300 / 3.75 = 80 km/h ✅ (accurate)
```

### Scenario 3: Scenic Ride with Photo Stops
**Before Fix**:
```
Distance: 200 km
Total Time: 5 hours (18000 seconds)
Photo stops: 1 hour (3600 seconds)
Average Speed: 200 / 5 = 40 km/h ❌ (too low)
```

**After Fix**:
```
Distance: 200 km
Active Time: 4 hours (14400 seconds)
Photo stops: 1 hour (not counted)
Average Speed: 200 / 4 = 50 km/h ✅ (accurate)
```

## User Experience

### What Riders See

**Duration Display**:
- Shows `activeDuration` in ActiveTripView
- Only increments when moving > 1 km/h
- Pauses automatically when stopped

**Speed Display**:
- Current speed updates in real-time
- Average speed based on moving time
- More accurate representation of riding pace

### Auto-Pause Feature

The existing auto-pause system (lines 217-233) works in conjunction:
- Triggers after **30 seconds** at speeds < 2 km/h
- Completely stops tracking (including duration)
- Resumes automatically when speed > 2 km/h

**Now you have two layers of protection**:
1. **Movement detection**: Duration only counts when moving > 1 km/h
2. **Auto-pause**: Full tracking pause after 30 sec at < 2 km/h

## Technical Details

### Speed Source
- Speed comes from `CLLocation.speed` property
- Provided by iOS Core Location framework
- Converted from m/s to km/h: `speed * 3.6`
- Updated every 10 meters or when location changes significantly

### Timer Implementation
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    self?.updateDuration()        // ✅ Now checks movement
    self?.updateCalories()         // Uses activeDuration
    self?.updateSpeedZones()       // ✅ Now checks movement
}
```

### Movement Check
```swift
// In updateDuration():
if !isPaused && currentSpeed > 1.0 {
    activeDuration += 1.0
}

// In updateSpeedZones():
guard currentSpeed > 1.0 else {
    lastSpeedZoneUpdate = Date()
    return
}
```

## Build Status
✅ **Successfully built and tested**

## Related Features

This improvement enhances:
- ✅ Trip duration tracking
- ✅ Average speed calculation
- ✅ Speed zone distribution
- ✅ Calorie burn estimation
- ✅ Fuel consumption accuracy (uses distance, not affected)
- ✅ Trip comparison fairness

## Future Enhancements

Potential improvements:
1. **Adjustable threshold**: Let users set movement threshold (0.5-2 km/h)
2. **Stop detection**: Automatically categorize stops (traffic light vs fuel stop)
3. **Stop statistics**: Show time breakdown (moving vs stopped)
4. **Smart detection**: Use accelerometer + GPS for more accurate detection
5. **Stop history**: Track where and how long each stop was

## Conclusion

The trip duration now accurately reflects **actual riding time**, making metrics more meaningful and comparisons more fair. Urban riders with frequent stops will see their true riding pace, while highway riders won't see inflated duration from brief rest stops. 🏍️⏱️
