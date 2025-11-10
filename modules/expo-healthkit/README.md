# expo-healthkit

iOS HealthKit integration module for Expo apps.

## Installation

This is a local module. It's already linked in your project via Expo's autolinking.

## Features

- Save workouts to HealthKit
- Query workout history
- Get aggregate statistics (distance, calories)
- Delete workouts
- Full TypeScript support
- Automatic HealthKit permissions configuration

## Usage

```typescript
import * as ExpoHealthKit from 'expo-healthkit';

// Check if HealthKit is available
const available = ExpoHealthKit.isAvailable();

// Request authorization
await ExpoHealthKit.requestAuthorization([], ['Workout']);

// Save a workout
const workoutId = await ExpoHealthKit.saveWorkout({
  startDate: Date.now() / 1000 - 3600,
  endDate: Date.now() / 1000,
  duration: 3600,
  distance: 5000,
  calories: 350,
  activityType: 'running',
});

// Query workouts
const workouts = await ExpoHealthKit.queryWorkouts({
  startDate: new Date('2024-01-01'),
  endDate: new Date(),
  limit: 10,
});

// Get statistics
const totalDistance = await ExpoHealthKit.getTotalDistance(
  new Date('2024-01-01'),
  new Date()
);

const totalCalories = await ExpoHealthKit.getTotalCalories(
  new Date('2024-01-01'),
  new Date()
);

// Delete a workout
await ExpoHealthKit.deleteWorkout(workoutId);
```

## API Reference

### `isAvailable(): boolean`

Check if HealthKit is available on the device.

### `requestAuthorization(readTypes: DataType[], writeTypes: DataType[]): Promise<void>`

Request authorization to access HealthKit data.

**DataType**: `'Workout' | 'Distance' | 'Calories' | 'Steps' | 'HeartRate'`

### `saveWorkout(workout: WorkoutData): Promise<string>`

Save a workout to HealthKit. Returns the UUID of the saved workout.

**WorkoutData**:
```typescript
{
  startDate: number;        // Unix timestamp in seconds
  endDate: number;          // Unix timestamp in seconds
  duration: number;         // Duration in seconds
  distance: number;         // Distance in meters
  calories: number;         // Calories in kilocalories
  activityType?: ActivityType;
  metadata?: Record<string, any>;
}
```

**ActivityType**: `'running' | 'walking' | 'cycling' | 'swimming' | 'hiking' | 'yoga' | 'functionalStrengthTraining' | 'traditionalStrengthTraining' | 'elliptical' | 'rowing' | 'other'`

### `queryWorkouts(options: QueryOptions): Promise<Workout[]>`

Query workouts from HealthKit.

**QueryOptions**:
```typescript
{
  startDate?: Date | number;
  endDate?: Date | number;
  limit?: number;
}
```

### `getTotalDistance(startDate: Date, endDate: Date): Promise<number>`

Get total distance for a date range (in meters).

### `getTotalCalories(startDate: Date, endDate: Date): Promise<number>`

Get total calories for a date range (in kilocalories).

### `deleteWorkout(workoutId: string): Promise<void>`

Delete a workout from HealthKit.

## Requirements

- iOS 13.0+
- Physical iOS device (HealthKit doesn't work on simulator)
- HealthKit capability enabled in your Apple Developer account

## Configuration

The module automatically configures HealthKit permissions via the config plugin. You can customize the permission messages in your app.json:

```json
{
  "plugins": [
    [
      "./modules/expo-healthkit/app.plugin.js",
      {
        "healthShareUsageDescription": "Custom read permission message",
        "healthUpdateUsageDescription": "Custom write permission message"
      }
    ]
  ]
}
```

## License

MIT
