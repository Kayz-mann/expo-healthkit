// Export all functions
export {
  isAvailable,
  requestAuthorization,
  saveWorkout,
  queryWorkouts,
  getTotalDistance,
  getTotalCalories,
  deleteWorkout,
} from './ExpoHealthKit';

// Export all types
export type {
  HealthKitPermission,
  ActivityType,
  WorkoutData,
  Workout,
  QueryOptions,
} from './types';
