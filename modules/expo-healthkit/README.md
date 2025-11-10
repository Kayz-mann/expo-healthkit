# expo-healthkit

A native Expo module for integrating HealthKit into your React Native app. Save and query workout data with full TypeScript support.

## Features

- 🏃 Save workouts to HealthKit (running, walking, cycling, etc.)
- 📊 Query workout history
- 📈 Get aggregate stats (total distance, calories)
- 🗑️ Delete workouts
- 💪 Full TypeScript support
- ⚡️ Built with Expo Modules for optimal performance

## Installation

This is a local module. It's already included in your project dependencies.

```bash
npm install
```

## Setup

### 1. Run prebuild to generate native iOS project

```bash
npx expo prebuild --platform ios
```

### 2. Install iOS dependencies

```bash
cd ios && pod install && cd ..
```

## Configuration

The HealthKit permissions are automatically configured via the Expo Config Plugin in `app.json`:

```json
{
  "expo": {
    "plugins": [
      [
        "./modules/expo-healthkit/plugin/src/index.ts",
        {
          "healthShareUsageDescription": "Custom message for reading health data",
          "healthUpdateUsageDescription": "Custom message for writing health data"
        }
      ]
    ]
  }
}
```

## Usage

### Request Authorization

```typescript
import * as ExpoHealthKit from 'expo-healthkit';

// Request permission to write workouts
await ExpoHealthKit.requestAuthorization([], ['Workout']);
```

### Save a Workout

```typescript
// Example: Save a 5km run
await ExpoHealthKit.saveWorkout({
  startDate: Date.now() / 1000 - 3600, // 1 hour ago (Unix timestamp)
  endDate: Date.now() / 1000,           // Now
  duration: 3600,                        // 1 hour in seconds
  distance: 5000,                        // 5km in meters
  calories: 350,                         // kcal burned
  activityType: 'running',
});
```

### Query Workouts

```typescript
const workouts = await ExpoHealthKit.queryWorkouts({
  startDate: new Date('2024-01-01'),
  endDate: new Date(),
  limit: 10, // Optional: limit results
});

console.log(workouts);
// [
//   {
//     id: 'uuid',
//     startDate: 1704067200,
//     endDate: 1704070800,
//     duration: 3600,
//     distance: 5000,
//     calories: 350,
//     activityType: 'running'
//   },
//   ...
// ]
```

### Get Aggregate Stats

```typescript
// Total distance in meters
const totalDistance = await ExpoHealthKit.getTotalDistance(
  new Date('2024-01-01'),
  new Date()
);

// Total calories burned
const totalCalories = await ExpoHealthKit.getTotalCalories(
  new Date('2024-01-01'),
  new Date()
);
```

### Delete a Workout

```typescript
await ExpoHealthKit.deleteWorkout('workout-uuid');
```

## API Reference

### `isAvailable(): boolean`

Check if HealthKit is available on the device.

### `requestAuthorization(readTypes?, writeTypes?): Promise<void>`

Request HealthKit permissions.

- `readTypes`: Array of permission types to read (e.g., `['Workout', 'HeartRate']`)
- `writeTypes`: Array of permission types to write (e.g., `['Workout']`)

### `saveWorkout(workout): Promise<void>`

Save a workout to HealthKit.

**Parameters:**
- `startDate` (number): Unix timestamp in seconds
- `endDate` (number): Unix timestamp in seconds
- `duration` (number): Duration in seconds
- `distance` (number): Distance in meters
- `calories` (number): Calories burned in kcal
- `activityType` (string, optional): Activity type (default: 'running')
- `metadata` (object, optional): Additional metadata

**Supported Activity Types:**
- `running`, `walking`, `cycling`, `hiking`, `swimming`, `yoga`, `dance`, `basketball`, `soccer`, `tennis`

### `queryWorkouts(options): Promise<Workout[]>`

Query workouts from HealthKit.

**Options:**
- `startDate` (Date): Start of date range
- `endDate` (Date): End of date range
- `limit` (number, optional): Maximum number of results

### `getTotalDistance(startDate, endDate): Promise<number>`

Get total distance (in meters) for all workouts in a date range.

### `getTotalCalories(startDate, endDate): Promise<number>`

Get total calories (in kcal) for all workouts in a date range.

### `deleteWorkout(workoutId): Promise<void>`

Delete a workout by its ID.

## Comparison with running-club-latest

This module recreates the HealthKit functionality from your Swift running app:

| running-club-latest | expo-healthkit |
|---------------------|----------------|
| `HealthManager.shared.requestAuthorization()` | `requestAuthorization()` |
| `HealthManager.shared.addWorkout()` | `saveWorkout()` |
| Direct Swift/SwiftUI | React Native via Expo Modules |
| Singleton pattern | Functional API |

## Example: Running Tracker Integration

```typescript
import React, { useEffect, useState } from 'react';
import { View, Button, Text } from 'react-native';
import * as ExpoHealthKit from 'expo-healthkit';

export default function RunTracker() {
  const [isRunning, setIsRunning] = useState(false);
  const [startTime, setStartTime] = useState(0);
  const [distance, setDistance] = useState(0);

  useEffect(() => {
    // Request authorization on mount
    ExpoHealthKit.requestAuthorization([], ['Workout']);
  }, []);

  const startRun = () => {
    setIsRunning(true);
    setStartTime(Date.now() / 1000);
    // Start location tracking...
  };

  const stopRun = async () => {
    setIsRunning(false);

    // Save workout to HealthKit
    await ExpoHealthKit.saveWorkout({
      startDate: startTime,
      endDate: Date.now() / 1000,
      duration: Date.now() / 1000 - startTime,
      distance: distance,
      calories: calculateCalories(distance, duration),
      activityType: 'running',
    });
  };

  return (
    <View>
      <Text>Distance: {distance}m</Text>
      {!isRunning ? (
        <Button title="Start Run" onPress={startRun} />
      ) : (
        <Button title="Stop Run" onPress={stopRun} />
      )}
    </View>
  );
}
```

## Platform Support

- ✅ iOS 13.0+
- ❌ Android (HealthKit is iOS-only)

## License

MIT
