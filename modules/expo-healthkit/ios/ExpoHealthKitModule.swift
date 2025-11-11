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

    // Steps & Activity
    AsyncFunction("getSteps") { (startDate: Double, endDate: Double) async throws -> Double in
      return try await healthManager.getSteps(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate)
      )
    }

    AsyncFunction("getFlightsClimbed") { (startDate: Double, endDate: Double) async throws -> Double in
      return try await healthManager.getFlightsClimbed(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate)
      )
    }

    // Body Measurements
    AsyncFunction("saveHeight") { (heightCm: Double, timestamp: Double?) async throws in
      let date = timestamp != nil ? Date(timeIntervalSince1970: timestamp!) : Date()
      try await healthManager.saveHeight(value: heightCm, date: date)
    }

    AsyncFunction("saveWeight") { (weightKg: Double, timestamp: Double?) async throws in
      let date = timestamp != nil ? Date(timeIntervalSince1970: timestamp!) : Date()
      try await healthManager.saveWeight(value: weightKg, date: date)
    }

    AsyncFunction("saveBodyFat") { (percentage: Double, timestamp: Double?) async throws in
      let date = timestamp != nil ? Date(timeIntervalSince1970: timestamp!) : Date()
      try await healthManager.saveBodyFat(value: percentage, date: date)
    }

    AsyncFunction("getLatestHeight") { () async throws -> Double? in
      return try await healthManager.getLatestHeight()
    }

    AsyncFunction("getLatestWeight") { () async throws -> Double? in
      return try await healthManager.getLatestWeight()
    }

    AsyncFunction("getLatestBMI") { () async throws -> Double? in
      return try await healthManager.getLatestBMI()
    }

    AsyncFunction("getLatestBodyFat") { () async throws -> Double? in
      return try await healthManager.getLatestBodyFat()
    }

    // Heart Rate & Vitals
    AsyncFunction("getHeartRateSamples") { (startDate: Double, endDate: Double, limit: Int?) async throws -> [[String: Any]] in
      return try await healthManager.getHeartRateSamples(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate),
        limit: limit
      )
    }

    AsyncFunction("getLatestHeartRate") { () async throws -> Double? in
      return try await healthManager.getLatestHeartRate()
    }

    AsyncFunction("getRestingHeartRate") { (startDate: Double, endDate: Double) async throws -> Double? in
      return try await healthManager.getRestingHeartRate(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate)
      )
    }

    AsyncFunction("getOxygenSaturation") { (startDate: Double, endDate: Double, limit: Int?) async throws -> [[String: Any]] in
      return try await healthManager.getOxygenSaturation(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate),
        limit: limit
      )
    }

    AsyncFunction("saveBloodPressure") { (systolic: Double, diastolic: Double, timestamp: Double?) async throws in
      let date = timestamp != nil ? Date(timeIntervalSince1970: timestamp!) : Date()
      try await healthManager.saveBloodPressure(systolic: systolic, diastolic: diastolic, date: date)
    }

    // Sleep
    AsyncFunction("getSleepSamples") { (startDate: Double, endDate: Double) async throws -> [[String: Any]] in
      return try await healthManager.getSleepSamples(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate)
      )
    }

    // Nutrition
    AsyncFunction("saveWater") { (milliliters: Double, timestamp: Double?) async throws in
      let date = timestamp != nil ? Date(timeIntervalSince1970: timestamp!) : Date()
      try await healthManager.saveWater(milliliters: milliliters, date: date)
    }

    AsyncFunction("getWaterIntake") { (startDate: Double, endDate: Double) async throws -> Double in
      return try await healthManager.getWaterIntake(
        startDate: Date(timeIntervalSince1970: startDate),
        endDate: Date(timeIntervalSince1970: endDate)
      )
    }

    AsyncFunction("saveCaffeine") { (milligrams: Double, timestamp: Double?) async throws in
      let date = timestamp != nil ? Date(timeIntervalSince1970: timestamp!) : Date()
      try await healthManager.saveCaffeine(milligrams: milligrams, date: date)
    }

    AsyncFunction("saveProtein") { (grams: Double, timestamp: Double?) async throws in
      let date = timestamp != nil ? Date(timeIntervalSince1970: timestamp!) : Date()
      try await healthManager.saveProtein(grams: grams, date: date)
    }

    AsyncFunction("saveCarbs") { (grams: Double, timestamp: Double?) async throws in
      let date = timestamp != nil ? Date(timeIntervalSince1970: timestamp!) : Date()
      try await healthManager.saveCarbs(grams: grams, date: date)
    }

    AsyncFunction("saveFat") { (grams: Double, timestamp: Double?) async throws in
      let date = timestamp != nil ? Date(timeIntervalSince1970: timestamp!) : Date()
      try await healthManager.saveFat(grams: grams, date: date)
    }
  }
}
