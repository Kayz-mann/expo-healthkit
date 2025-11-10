import { requireNativeModule } from 'expo';
import type {
  HealthKitPermission,
  WorkoutData,
  Workout,
  QueryOptions,
} from './types';

// Import the native module
const ExpoHealthKitModule = requireNativeModule('ExpoHealthKit');

/**
 * Check if HealthKit is available on the current device
 * @returns true if HealthKit is available, false otherwise
 */
export function isAvailable(): boolean {
  return ExpoHealthKitModule.isAvailable();
}

/**
 * Request authorization to access HealthKit data
 *
 * @param readTypes - Array of HealthKit data types to read (e.g., ['Workout', 'HeartRate'])
 * @param writeTypes - Array of HealthKit data types to write (e.g., ['Workout'])
 *
 * @example
 * ```typescript
 * await requestAuthorization(['Workout'], ['Workout']);
 * ```
 */
export async function requestAuthorization(
  readTypes: HealthKitPermission[] = [],
  writeTypes: HealthKitPermission[] = ['Workout']
): Promise<void> {
  return await ExpoHealthKitModule.requestAuthorization(readTypes, writeTypes);
}

/**
 * Save a workout to HealthKit
 *
 * This function matches the behavior of the running-club-latest app's
 * HealthManager.addWorkout() function
 *
 * @param workout - Workout data to save
 *
 * @example
 * ```typescript
 * await saveWorkout({
 *   startDate: Date.now() / 1000 - 3600, // 1 hour ago
 *   endDate: Date.now() / 1000,
 *   duration: 3600, // 1 hour in seconds
 *   distance: 5000, // 5km in meters
 *   calories: 350,
 *   activityType: 'running',
 * });
 * ```
 */
export async function saveWorkout(workout: WorkoutData): Promise<void> {
  // Convert Date objects to Unix timestamps if needed
  const workoutData = {
    ...workout,
    startDate: typeof workout.startDate === 'number'
      ? workout.startDate
      : workout.startDate / 1000,
    endDate: typeof workout.endDate === 'number'
      ? workout.endDate
      : workout.endDate / 1000,
  };

  return await ExpoHealthKitModule.saveWorkout(workoutData);
}

/**
 * Query workouts from HealthKit within a date range
 *
 * @param options - Query options including date range and optional limit
 * @returns Array of workout objects
 *
 * @example
 * ```typescript
 * const workouts = await queryWorkouts({
 *   startDate: new Date('2024-01-01'),
 *   endDate: new Date(),
 *   limit: 10,
 * });
 * ```
 */
export async function queryWorkouts(
  options: QueryOptions
): Promise<Workout[]> {
  const { startDate, endDate, limit } = options;

  return await ExpoHealthKitModule.queryWorkouts(
    startDate.getTime() / 1000,
    endDate.getTime() / 1000,
    limit
  );
}

/**
 * Get total distance for all workouts in a date range
 *
 * @param startDate - Start date of the range
 * @param endDate - End date of the range
 * @returns Total distance in meters
 *
 * @example
 * ```typescript
 * const distance = await getTotalDistance(
 *   new Date('2024-01-01'),
 *   new Date()
 * );
 * console.log(`Total distance: ${distance} meters`);
 * ```
 */
export async function getTotalDistance(
  startDate: Date,
  endDate: Date
): Promise<number> {
  return await ExpoHealthKitModule.getTotalDistance(
    startDate.getTime() / 1000,
    endDate.getTime() / 1000
  );
}

/**
 * Get total calories burned for all workouts in a date range
 *
 * @param startDate - Start date of the range
 * @param endDate - End date of the range
 * @returns Total calories in kilocalories
 *
 * @example
 * ```typescript
 * const calories = await getTotalCalories(
 *   new Date('2024-01-01'),
 *   new Date()
 * );
 * console.log(`Total calories: ${calories} kcal`);
 * ```
 */
export async function getTotalCalories(
  startDate: Date,
  endDate: Date
): Promise<number> {
  return await ExpoHealthKitModule.getTotalCalories(
    startDate.getTime() / 1000,
    endDate.getTime() / 1000
  );
}

/**
 * Delete a workout from HealthKit by its ID
 *
 * @param workoutId - The unique identifier of the workout to delete
 *
 * @example
 * ```typescript
 * await deleteWorkout('550e8400-e29b-41d4-a716-446655440000');
 * ```
 */
export async function deleteWorkout(workoutId: string): Promise<void> {
  return await ExpoHealthKitModule.deleteWorkout(workoutId);
}
