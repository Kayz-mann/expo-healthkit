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
  | 'Workout'
  | 'Distance'
  | 'Calories'
  | 'Steps'
  | 'HeartRate';

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
