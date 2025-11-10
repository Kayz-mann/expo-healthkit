import { requireNativeModule } from 'expo-modules-core';
import type { WorkoutData, Workout, QueryOptions, DataType } from './types';

const ExpoHealthKitModule = requireNativeModule('ExpoHealthKit');

/**
 * Check if HealthKit is available on this device
 * @returns true if HealthKit is available, false otherwise
 */
export function isAvailable(): boolean {
  return ExpoHealthKitModule.isAvailable();
}

/**
 * Request authorization to access HealthKit data
 * @param readTypes - Array of data types to request read access for
 * @param writeTypes - Array of data types to request write access for
 */
export async function requestAuthorization(
  readTypes: DataType[] = [],
  writeTypes: DataType[] = []
): Promise<void> {
  return await ExpoHealthKitModule.requestAuthorization(readTypes, writeTypes);
}

/**
 * Save a workout to HealthKit
 * @param workout - The workout data to save
 * @returns The UUID of the saved workout
 */
export async function saveWorkout(workout: WorkoutData): Promise<string> {
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
 * Query workouts from HealthKit
 * @param options - Query options (startDate, endDate, limit)
 * @returns Array of workouts
 */
export async function queryWorkouts(options: QueryOptions = {}): Promise<Workout[]> {
  const queryOptions = {
    startDate:
      options.startDate instanceof Date
        ? options.startDate.getTime() / 1000
        : options.startDate,
    endDate:
      options.endDate instanceof Date
        ? options.endDate.getTime() / 1000
        : options.endDate,
    limit: options.limit,
  };
  return await ExpoHealthKitModule.queryWorkouts(queryOptions);
}

/**
 * Get total distance for a date range
 * @param startDate - Start date
 * @param endDate - End date
 * @returns Total distance in meters
 */
export async function getTotalDistance(
  startDate: Date,
  endDate: Date
): Promise<number> {
  const start = startDate.getTime() / 1000;
  const end = endDate.getTime() / 1000;
  return await ExpoHealthKitModule.getTotalDistance(start, end);
}

/**
 * Get total calories for a date range
 * @param startDate - Start date
 * @param endDate - End date
 * @returns Total calories in kilocalories
 */
export async function getTotalCalories(
  startDate: Date,
  endDate: Date
): Promise<number> {
  const start = startDate.getTime() / 1000;
  const end = endDate.getTime() / 1000;
  return await ExpoHealthKitModule.getTotalCalories(start, end);
}

/**
 * Delete a workout from HealthKit
 * @param workoutId - The UUID of the workout to delete
 */
export async function deleteWorkout(workoutId: string): Promise<void> {
  return await ExpoHealthKitModule.deleteWorkout(workoutId);
}
