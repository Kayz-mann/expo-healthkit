/**
 * HealthKit permission types
 */
export type HealthKitPermission =
  | 'Workout'
  | 'HeartRate'
  | 'Steps'
  | 'Distance'
  | 'Calories';

/**
 * Activity types for workouts
 */
export type ActivityType =
  | 'running'
  | 'walking'
  | 'cycling'
  | 'hiking'
  | 'swimming'
  | 'yoga'
  | 'dance'
  | 'basketball'
  | 'soccer'
  | 'tennis'
  | 'other';

/**
 * Data structure for saving a workout to HealthKit
 */
export interface WorkoutData {
  /** Start time of the workout (Unix timestamp in seconds) */
  startDate: number;

  /** End time of the workout (Unix timestamp in seconds) */
  endDate: number;

  /** Duration of the workout in seconds */
  duration: number;

  /** Total distance covered in meters */
  distance: number;

  /** Total calories burned in kilocalories */
  calories: number;

  /** Type of activity (defaults to 'running') */
  activityType?: ActivityType;

  /** Optional metadata to attach to the workout */
  metadata?: Record<string, any>;
}

/**
 * Workout object returned from HealthKit queries
 */
export interface Workout {
  /** Unique identifier for the workout */
  id: string;

  /** Start time of the workout (Unix timestamp in seconds) */
  startDate: number;

  /** End time of the workout (Unix timestamp in seconds) */
  endDate: number;

  /** Duration of the workout in seconds */
  duration: number;

  /** Total distance covered in meters */
  distance: number;

  /** Total calories burned in kilocalories */
  calories: number;

  /** Type of activity */
  activityType: ActivityType;
}

/**
 * Options for querying workouts
 */
export interface QueryOptions {
  /** Start date for the query range */
  startDate: Date;

  /** End date for the query range */
  endDate: Date;

  /** Optional limit on number of results */
  limit?: number;
}
