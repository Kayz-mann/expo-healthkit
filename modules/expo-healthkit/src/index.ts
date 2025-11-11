export {
  // Core
  isAvailable,
  requestAuthorization,

  // Workouts
  saveWorkout,
  queryWorkouts,
  deleteWorkout,
  getTotalDistance,
  getTotalCalories,

  // Steps & Activity
  getSteps,
  getFlightsClimbed,

  // Body Measurements
  saveHeight,
  saveWeight,
  saveBodyFat,
  getLatestHeight,
  getLatestWeight,
  getLatestBMI,
  getLatestBodyFat,

  // Heart Rate & Vitals
  getHeartRateSamples,
  getLatestHeartRate,
  getRestingHeartRate,
  getOxygenSaturation,
  saveBloodPressure,

  // Sleep
  getSleepSamples,

  // Nutrition
  saveWater,
  getWaterIntake,
  saveCaffeine,
  saveProtein,
  saveCarbs,
  saveFat,
} from './ExpoHealthKit';

export type {
  ActivityType,
  DataType,
  WorkoutData,
  Workout,
  QueryOptions,
  QuantitySample,
  SleepSample,
  BloodPressure,
} from './types';
