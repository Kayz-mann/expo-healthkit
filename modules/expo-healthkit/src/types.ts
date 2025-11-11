export type ActivityType =
  | 'running'
  | 'walking'
  | 'cycling'
  | 'swimming'
  | 'hiking'
  | 'yoga'
  | 'functionalStrengthTraining'
  | 'traditionalStrengthTraining'
  | 'elliptical'
  | 'rowing'
  | 'other';

export type DataType =
  // Workouts
  | 'Workout'

  // Activity & Fitness
  | 'Steps' | 'StepCount'
  | 'Distance' | 'DistanceWalkingRunning'
  | 'DistanceCycling'
  | 'DistanceSwimming'
  | 'FlightsClimbed'
  | 'ActiveEnergy' | 'Calories' | 'ActiveEnergyBurned'
  | 'BasalEnergy' | 'BasalEnergyBurned'

  // Body Measurements
  | 'Height' | 'BodyHeight'
  | 'Weight' | 'BodyMass' | 'BodyWeight'
  | 'BodyMassIndex' | 'BMI'
  | 'BodyFat' | 'BodyFatPercentage'
  | 'LeanMass' | 'LeanBodyMass'

  // Vitals
  | 'HeartRate'
  | 'RestingHeartRate'
  | 'HeartRateVariability' | 'HRV'
  | 'BloodPressureSystolic'
  | 'BloodPressureDiastolic'
  | 'RespiratoryRate'
  | 'OxygenSat' | 'OxygenSaturation' | 'SpO2'
  | 'BodyTemperature'

  // Nutrition
  | 'DietaryEnergy' | 'DietaryCalories'
  | 'Protein' | 'DietaryProtein'
  | 'Carbs' | 'Carbohydrates' | 'DietaryCarbohydrates'
  | 'Fat' | 'DietaryFat' | 'DietaryFatTotal'
  | 'Fiber' | 'DietaryFiber'
  | 'Water' | 'DietaryWater'
  | 'Caffeine' | 'DietaryCaffeine'

  // Sleep
  | 'Sleep' | 'SleepAnalysis'

  // Mindfulness
  | 'Mindfulness' | 'MindfulMinutes';

export interface WorkoutData {
  startDate: number;
  endDate: number;
  duration: number;
  distance: number;
  calories: number;
  activityType?: ActivityType;
  metadata?: Record<string, any>;
}

export interface Workout {
  id: string;
  activityType: ActivityType;
  startDate: number;
  endDate: number;
  duration: number;
  distance: number;
  calories: number;
}

export interface QueryOptions {
  startDate?: Date | number;
  endDate?: Date | number;
  limit?: number;
}

export interface QuantitySample {
  id: string;
  value: number;
  startDate: number;
  endDate: number;
}

export interface SleepSample {
  id: string;
  value: 'asleep' | 'awake' | 'inBed' | 'core' | 'deep' | 'rem' | 'unknown';
  startDate: number;
  endDate: number;
  duration: number;
}

export interface BloodPressure {
  systolic: number;
  diastolic: number;
  timestamp?: number;
}
