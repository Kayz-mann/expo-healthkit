import Foundation
import HealthKit

class ExpoHealthKitManager {
  private let healthStore = HKHealthStore()

  // MARK: - Authorization

  /// Request HealthKit authorization for reading and writing health data
  func requestAuthorization(readTypes: [String], writeTypes: [String]) async throws {
    var readSet = Set<HKObjectType>()
    var writeSet = Set<HKSampleType>()

    // Convert string types to HKObjectType for reading
    for type in readTypes {
      if let hkType = parseHealthKitType(type) {
        readSet.insert(hkType)
      }
    }

    // Convert string types to HKSampleType for writing
    for type in writeTypes {
      if let hkType = parseHealthKitType(type) as? HKSampleType {
        writeSet.insert(hkType)
      }
    }

    try await healthStore.requestAuthorization(toShare: writeSet, read: readSet)
  }

  // MARK: - Save Workout

  /// Save a workout to HealthKit (matches the running-club-latest HealthManager.addWorkout)
  func saveWorkout(data: [String: Any]) async throws {
    // Extract required fields
    guard let startDate = data["startDate"] as? Double,
          let endDate = data["endDate"] as? Double,
          let duration = data["duration"] as? Double,
          let distance = data["distance"] as? Double,
          let calories = data["calories"] as? Double else {
      throw HealthKitError.missingRequiredData("Missing required workout data: startDate, endDate, duration, distance, calories")
    }

    // Parse activity type (default to running)
    let activityTypeString = data["activityType"] as? String ?? "running"
    let activityType = parseActivityType(activityTypeString)

    // Create the workout
    let workout = HKWorkout(
      activityType: activityType,
      start: Date(timeIntervalSince1970: startDate),
      end: Date(timeIntervalSince1970: endDate),
      duration: duration,
      totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
      totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
      device: .local(),
      metadata: data["metadata"] as? [String: Any]
    )

    // Save to HealthKit
    try await healthStore.save(workout)
  }

  // MARK: - Query Workouts

  /// Query workouts from HealthKit within a date range
  func queryWorkouts(startDate: Date, endDate: Date, limit: Int?) async throws -> [[String: Any]] {
    let predicate = HKQuery.predicateForSamples(
      withStart: startDate,
      end: endDate,
      options: .strictStartDate
    )

    let sortDescriptor = NSSortDescriptor(
      key: HKSampleSortIdentifierStartDate,
      ascending: false
    )

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: HKWorkoutType.workoutType(),
        predicate: predicate,
        limit: limit ?? HKObjectQueryNoLimit,
        sortDescriptors: [sortDescriptor]
      ) { _, samples, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let workouts = samples as? [HKWorkout] else {
          continuation.resume(returning: [])
          return
        }

        // Convert HKWorkout objects to dictionaries for JS
        let results = workouts.map { workout -> [String: Any] in
          return [
            "id": workout.uuid.uuidString,
            "startDate": workout.startDate.timeIntervalSince1970,
            "endDate": workout.endDate.timeIntervalSince1970,
            "duration": workout.duration,
            "distance": workout.totalDistance?.doubleValue(for: .meter()) ?? 0,
            "calories": workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
            "activityType": self.activityTypeToString(workout.workoutActivityType)
          ]
        }

        continuation.resume(returning: results)
      }

      healthStore.execute(query)
    }
  }

  // MARK: - Aggregate Queries

  /// Get total distance for workouts in a date range
  func getTotalDistance(startDate: Date, endDate: Date) async throws -> Double {
    let workouts = try await queryWorkouts(startDate: startDate, endDate: endDate, limit: nil)
    return workouts.reduce(0.0) { sum, workout in
      sum + (workout["distance"] as? Double ?? 0)
    }
  }

  /// Get total calories burned for workouts in a date range
  func getTotalCalories(startDate: Date, endDate: Date) async throws -> Double {
    let workouts = try await queryWorkouts(startDate: startDate, endDate: endDate, limit: nil)
    return workouts.reduce(0.0) { sum, workout in
      sum + (workout["calories"] as? Double ?? 0)
    }
  }

  // MARK: - Delete Workout

  /// Delete a workout by its UUID
  func deleteWorkout(id: String) async throws {
    guard let uuid = UUID(uuidString: id) else {
      throw HealthKitError.invalidWorkoutId("Invalid workout ID format")
    }

    return try await withCheckedThrowingContinuation { continuation in
      let predicate = HKQuery.predicateForObject(with: uuid)

      let query = HKSampleQuery(
        sampleType: HKWorkoutType.workoutType(),
        predicate: predicate,
        limit: 1,
        sortDescriptors: nil
      ) { _, samples, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let workout = samples?.first else {
          continuation.resume(throwing: HealthKitError.workoutNotFound("Workout not found"))
          return
        }

        // Delete the workout
        self.healthStore.delete(workout) { success, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else if success {
            continuation.resume()
          } else {
            continuation.resume(throwing: HealthKitError.deleteFailed("Failed to delete workout"))
          }
        }
      }

      healthStore.execute(query)
    }
  }

  // MARK: - Helper Functions

  /// Parse string activity type to HKWorkoutActivityType
  private func parseActivityType(_ type: String) -> HKWorkoutActivityType {
    switch type.lowercased() {
    case "running":
      return .running
    case "walking":
      return .walking
    case "cycling":
      return .cycling
    case "hiking":
      return .hiking
    case "swimming":
      return .swimming
    case "yoga":
      return .yoga
    case "dance":
      return .dance
    case "basketball":
      return .basketball
    case "soccer":
      return .soccer
    case "tennis":
      return .tennis
    default:
      return .running
    }
  }

  /// Convert HKWorkoutActivityType to string
  private func activityTypeToString(_ type: HKWorkoutActivityType) -> String {
    switch type {
    case .running: return "running"
    case .walking: return "walking"
    case .cycling: return "cycling"
    case .hiking: return "hiking"
    case .swimming: return "swimming"
    case .yoga: return "yoga"
    case .dance: return "dance"
    case .basketball: return "basketball"
    case .soccer: return "soccer"
    case .tennis: return "tennis"
    default: return "other"
    }
  }

  /// Parse string permission type to HKObjectType
  private func parseHealthKitType(_ type: String) -> HKObjectType? {
    switch type.lowercased() {
    case "workout":
      return HKWorkoutType.workoutType()
    case "heartrate":
      return HKQuantityType.quantityType(forIdentifier: .heartRate)
    case "steps":
      return HKQuantityType.quantityType(forIdentifier: .stepCount)
    case "distance":
      return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
    case "calories":
      return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
    default:
      return nil
    }
  }
}

// MARK: - Error Types

enum HealthKitError: Error, LocalizedError {
  case missingRequiredData(String)
  case invalidWorkoutId(String)
  case workoutNotFound(String)
  case deleteFailed(String)

  var errorDescription: String? {
    switch self {
    case .missingRequiredData(let message),
         .invalidWorkoutId(let message),
         .workoutNotFound(let message),
         .deleteFailed(let message):
      return message
    }
  }
}
