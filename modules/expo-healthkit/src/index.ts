export {
  isAvailable,
  requestAuthorization,
  saveWorkout,
  queryWorkouts,
  getTotalDistance,
  getTotalCalories,
  deleteWorkout,
} from './ExpoHealthKit';

export type {
  ActivityType,
  DataType,
  WorkoutData,
  Workout,
  QueryOptions,
} from './types';
