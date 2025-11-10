import ExpoModulesCore
import HealthKit

public class ExpoHealthKitModule: Module {
  private let healthManager = ExpoHealthKitManager()

  public func definition() -> ModuleDefinition {
    Name("ExpoHealthKit")

    Function("isAvailable") { () -> Bool in
      return HKHealthStore.isHealthDataAvailable()
    }

    AsyncFunction("requestAuthorization") { (readTypes: [String], writeTypes: [String]) async throws in
      try await healthManager.requestAuthorization(readTypes: readTypes, writeTypes: writeTypes)
    }

    AsyncFunction("saveWorkout") { (workoutData: [String: Any]) async throws -> String in
      return try await healthManager.saveWorkout(data: workoutData)
    }

    AsyncFunction("queryWorkouts") { (options: [String: Any]) async throws -> [[String: Any]] in
      let startDate = options["startDate"] as? Double ?? 0
      let endDate = options["endDate"] as? Double ?? Date().timeIntervalSince1970
      let limit = options["limit"] as? Int

      return try await healthManager.queryWorkouts(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate),
        limit: limit
      )
    }

    AsyncFunction("getTotalDistance") { (startDate: Double, endDate: Double) async throws -> Double in
      return try await healthManager.getTotalDistance(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate)
      )
    }

    AsyncFunction("getTotalCalories") { (startDate: Double, endDate: Double) async throws -> Double in
      return try await healthManager.getTotalCalories(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate)
      )
    }

    AsyncFunction("deleteWorkout") { (workoutId: String) async throws in
      try await healthManager.deleteWorkout(id: workoutId)
    }
  }
}
