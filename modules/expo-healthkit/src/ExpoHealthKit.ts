import { requireNativeModule } from 'expo-modules-core';
import type {
  WorkoutData,
  Workout,
  QueryOptions,
  DataType,
  QuantitySample,
  SleepSample,
  BloodPressure,
} from './types';

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

// ======================
// Steps & Activity
// ======================

/**
 * Get total step count for a date range
 * @param startDate - Start date
 * @param endDate - End date
 * @returns Total steps
 */
export async function getSteps(startDate: Date, endDate: Date): Promise<number> {
  const start = startDate.getTime() / 1000;
  const end = endDate.getTime() / 1000;
  return await ExpoHealthKitModule.getSteps(start, end);
}

/**
 * Get total flights of stairs climbed for a date range
 * @param startDate - Start date
 * @param endDate - End date
 * @returns Total flights climbed
 */
export async function getFlightsClimbed(startDate: Date, endDate: Date): Promise<number> {
  const start = startDate.getTime() / 1000;
  const end = endDate.getTime() / 1000;
  return await ExpoHealthKitModule.getFlightsClimbed(start, end);
}

// ======================
// Body Measurements
// ======================

/**
 * Save height to HealthKit
 * @param heightCm - Height in centimeters
 * @param date - Optional date (defaults to now)
 */
export async function saveHeight(heightCm: number, date?: Date): Promise<void> {
  const timestamp = date ? date.getTime() / 1000 : undefined;
  return await ExpoHealthKitModule.saveHeight(heightCm, timestamp);
}

/**
 * Save weight to HealthKit
 * @param weightKg - Weight in kilograms
 * @param date - Optional date (defaults to now)
 */
export async function saveWeight(weightKg: number, date?: Date): Promise<void> {
  const timestamp = date ? date.getTime() / 1000 : undefined;
  return await ExpoHealthKitModule.saveWeight(weightKg, timestamp);
}

/**
 * Save body fat percentage to HealthKit
 * @param percentage - Body fat percentage (0-100)
 * @param date - Optional date (defaults to now)
 */
export async function saveBodyFat(percentage: number, date?: Date): Promise<void> {
  const timestamp = date ? date.getTime() / 1000 : undefined;
  return await ExpoHealthKitModule.saveBodyFat(percentage, timestamp);
}

/**
 * Get the most recent height measurement
 * @returns Height in centimeters, or null if not available
 */
export async function getLatestHeight(): Promise<number | null> {
  return await ExpoHealthKitModule.getLatestHeight();
}

/**
 * Get the most recent weight measurement
 * @returns Weight in kilograms, or null if not available
 */
export async function getLatestWeight(): Promise<number | null> {
  return await ExpoHealthKitModule.getLatestWeight();
}

/**
 * Get the most recent BMI calculation
 * @returns BMI value, or null if not available
 */
export async function getLatestBMI(): Promise<number | null> {
  return await ExpoHealthKitModule.getLatestBMI();
}

/**
 * Get the most recent body fat percentage
 * @returns Body fat percentage (0-100), or null if not available
 */
export async function getLatestBodyFat(): Promise<number | null> {
  return await ExpoHealthKitModule.getLatestBodyFat();
}

// ======================
// Heart Rate & Vitals
// ======================

/**
 * Get heart rate samples for a date range
 * @param startDate - Start date
 * @param endDate - End date
 * @param limit - Optional limit on number of samples
 * @returns Array of heart rate samples (bpm)
 */
export async function getHeartRateSamples(
  startDate: Date,
  endDate: Date,
  limit?: number
): Promise<QuantitySample[]> {
  const start = startDate.getTime() / 1000;
  const end = endDate.getTime() / 1000;
  return await ExpoHealthKitModule.getHeartRateSamples(start, end, limit);
}

/**
 * Get the most recent heart rate measurement
 * @returns Heart rate in bpm, or null if not available
 */
export async function getLatestHeartRate(): Promise<number | null> {
  return await ExpoHealthKitModule.getLatestHeartRate();
}

/**
 * Get resting heart rate for a date range
 * @param startDate - Start date
 * @param endDate - End date
 * @returns Resting heart rate in bpm, or null if not available
 */
export async function getRestingHeartRate(
  startDate: Date,
  endDate: Date
): Promise<number | null> {
  const start = startDate.getTime() / 1000;
  const end = endDate.getTime() / 1000;
  return await ExpoHealthKitModule.getRestingHeartRate(start, end);
}

/**
 * Get oxygen saturation samples for a date range
 * @param startDate - Start date
 * @param endDate - End date
 * @param limit - Optional limit on number of samples
 * @returns Array of SpO2 samples (percentage)
 */
export async function getOxygenSaturation(
  startDate: Date,
  endDate: Date,
  limit?: number
): Promise<QuantitySample[]> {
  const start = startDate.getTime() / 1000;
  const end = endDate.getTime() / 1000;
  return await ExpoHealthKitModule.getOxygenSaturation(start, end, limit);
}

/**
 * Save blood pressure measurement to HealthKit
 * @param systolic - Systolic pressure in mmHg
 * @param diastolic - Diastolic pressure in mmHg
 * @param date - Optional date (defaults to now)
 */
export async function saveBloodPressure(
  systolic: number,
  diastolic: number,
  date?: Date
): Promise<void> {
  const timestamp = date ? date.getTime() / 1000 : undefined;
  return await ExpoHealthKitModule.saveBloodPressure(systolic, diastolic, timestamp);
}

// ======================
// Sleep
// ======================

/**
 * Get sleep samples for a date range
 * @param startDate - Start date
 * @param endDate - End date
 * @returns Array of sleep samples with state and duration
 */
export async function getSleepSamples(
  startDate: Date,
  endDate: Date
): Promise<SleepSample[]> {
  const start = startDate.getTime() / 1000;
  const end = endDate.getTime() / 1000;
  return await ExpoHealthKitModule.getSleepSamples(start, end);
}

// ======================
// Nutrition
// ======================

/**
 * Save water intake to HealthKit
 * @param milliliters - Amount of water in milliliters
 * @param date - Optional date (defaults to now)
 */
export async function saveWater(milliliters: number, date?: Date): Promise<void> {
  const timestamp = date ? date.getTime() / 1000 : undefined;
  return await ExpoHealthKitModule.saveWater(milliliters, timestamp);
}

/**
 * Get total water intake for a date range
 * @param startDate - Start date
 * @param endDate - End date
 * @returns Total water in milliliters
 */
export async function getWaterIntake(startDate: Date, endDate: Date): Promise<number> {
  const start = startDate.getTime() / 1000;
  const end = endDate.getTime() / 1000;
  return await ExpoHealthKitModule.getWaterIntake(start, end);
}

/**
 * Save caffeine intake to HealthKit
 * @param milligrams - Amount of caffeine in milligrams
 * @param date - Optional date (defaults to now)
 */
export async function saveCaffeine(milligrams: number, date?: Date): Promise<void> {
  const timestamp = date ? date.getTime() / 1000 : undefined;
  return await ExpoHealthKitModule.saveCaffeine(milligrams, timestamp);
}

/**
 * Save protein intake to HealthKit
 * @param grams - Amount of protein in grams
 * @param date - Optional date (defaults to now)
 */
export async function saveProtein(grams: number, date?: Date): Promise<void> {
  const timestamp = date ? date.getTime() / 1000 : undefined;
  return await ExpoHealthKitModule.saveProtein(grams, timestamp);
}

/**
 * Save carbohydrate intake to HealthKit
 * @param grams - Amount of carbs in grams
 * @param date - Optional date (defaults to now)
 */
export async function saveCarbs(grams: number, date?: Date): Promise<void> {
  const timestamp = date ? date.getTime() / 1000 : undefined;
  return await ExpoHealthKitModule.saveCarbs(grams, timestamp);
}

/**
 * Save fat intake to HealthKit
 * @param grams - Amount of fat in grams
 * @param date - Optional date (defaults to now)
 */
export async function saveFat(grams: number, date?: Date): Promise<void> {
  const timestamp = date ? date.getTime() / 1000 : undefined;
  return await ExpoHealthKitModule.saveFat(grams, timestamp);
}
