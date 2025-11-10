import ExpoModulesCore
import HealthKit

public class ExpoHealthKitModule: Module {
  private let healthManager = ExpoHealthKitManager()

  public func definition() -> ModuleDefinition {
    // Name of the module (used in JS: requireNativeModule("ExpoHealthKit"))
    Name("ExpoHealthKit")

    // Check if HealthKit is available on this device
    Function("isAvailable") { () -> Bool in
      return HKHealthStore.isHealthDataAvailable()
    }

    // Request HealthKit authorization
    // readTypes and writeTypes are arrays of permission strings like ["Workout", "HeartRate"]
    AsyncFunction("requestAuthorization") { (readTypes: [String], writeTypes: [String]) async throws in
      try await healthManager.requestAuthorization(
        readTypes: readTypes,
        writeTypes: writeTypes
      )
    }

    // Save a workout to HealthKit
    // workoutData contains: startDate, endDate, duration, distance, calories, activityType, metadata
    AsyncFunction("saveWorkout") { (workoutData: [String: Any]) async throws in
      try await healthManager.saveWorkout(data: workoutData)
    }

    // Query workouts from HealthKit
    // Returns array of workout objects
    AsyncFunction("queryWorkouts") { (startDate: Double, endDate: Double, limit: Int?) async throws -> [[String: Any]] in
      return try await healthManager.queryWorkouts(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate),
        limit: limit
      )
    }

    // Get total distance for a date range
    AsyncFunction("getTotalDistance") { (startDate: Double, endDate: Double) async throws -> Double in
      return try await healthManager.getTotalDistance(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate)
      )
    }

    // Get total calories burned for a date range
    AsyncFunction("getTotalCalories") { (startDate: Double, endDate: Double) async throws -> Double in
      return try await healthManager.getTotalCalories(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate)
      )
    }

    // Delete a workout by ID
    AsyncFunction("deleteWorkout") { (workoutId: String) async throws in
      try await healthManager.deleteWorkout(id: workoutId)
    }
  }
}
