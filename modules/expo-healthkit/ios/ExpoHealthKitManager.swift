import Foundation
import HealthKit

enum HealthKitError: Error {
  case notAvailable
  case authorizationFailed(String)
  case saveFailed(String)
  case queryFailed(String)
  case missingRequiredData(String)
  case workoutNotFound
}

class ExpoHealthKitManager {
  private let healthStore = HKHealthStore()

  func requestAuthorization(readTypes: [String], writeTypes: [String]) async throws {
    guard HKHealthStore.isHealthDataAvailable() else {
      throw HealthKitError.notAvailable
    }

    let readDataTypes = Set(readTypes.compactMap { parseDataType($0) })
    let writeDataTypes = Set(writeTypes.compactMap { parseDataType($0) })

    do {
      try await healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes)
    } catch {
      throw HealthKitError.authorizationFailed(error.localizedDescription)
    }
  }

  func saveWorkout(data: [String: Any]) async throws -> String {
    guard let startDate = data["startDate"] as? Double,
          let endDate = data["endDate"] as? Double,
          let duration = data["duration"] as? Double,
          let distance = data["distance"] as? Double,
          let calories = data["calories"] as? Double else {
      throw HealthKitError.missingRequiredData("Missing required workout data")
    }

    let activityType = parseActivityType(data["activityType"] as? String ?? "running")

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

    do {
      try await healthStore.save(workout)
      return workout.uuid.uuidString
    } catch {
      throw HealthKitError.saveFailed(error.localizedDescription)
    }
  }

  func queryWorkouts(startDate: Date, endDate: Date, limit: Int?) async throws -> [[String: Any]] {
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: HKObjectType.workoutType(),
        predicate: predicate,
        limit: limit ?? HKObjectQueryNoLimit,
        sortDescriptors: [sortDescriptor]
      ) { _, samples, error in
        if let error = error {
          continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
          return
        }

        guard let workouts = samples as? [HKWorkout] else {
          continuation.resume(returning: [])
          return
        }

        let workoutData = workouts.map { workout -> [String: Any] in
          return [
            "id": workout.uuid.uuidString,
            "activityType": self.formatActivityType(workout.workoutActivityType),
            "startDate": workout.startDate.timeIntervalSince1970,
            "endDate": workout.endDate.timeIntervalSince1970,
            "duration": workout.duration,
            "distance": workout.totalDistance?.doubleValue(for: .meter()) ?? 0,
            "calories": workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
          ]
        }

        continuation.resume(returning: workoutData)
      }

      healthStore.execute(query)
    }
  }

  func getTotalDistance(startDate: Date, endDate: Date) async throws -> Double {
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKStatisticsQuery(
        quantityType: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        quantitySamplePredicate: predicate,
        options: .cumulativeSum
      ) { _, result, error in
        if let error = error {
          continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
          return
        }

        let distance = result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
        continuation.resume(returning: distance)
      }

      healthStore.execute(query)
    }
  }

  func getTotalCalories(startDate: Date, endDate: Date) async throws -> Double {
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKStatisticsQuery(
        quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        quantitySamplePredicate: predicate,
        options: .cumulativeSum
      ) { _, result, error in
        if let error = error {
          continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
          return
        }

        let calories = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
        continuation.resume(returning: calories)
      }

      healthStore.execute(query)
    }
  }

  func deleteWorkout(id: String) async throws {
    guard let uuid = UUID(uuidString: id) else {
      throw HealthKitError.missingRequiredData("Invalid workout ID")
    }

    let predicate = HKQuery.predicateForObject(with: uuid)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: HKObjectType.workoutType(),
        predicate: predicate,
        limit: 1,
        sortDescriptors: nil
      ) { _, samples, error in
        if let error = error {
          continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
          return
        }

        guard let workout = samples?.first else {
          continuation.resume(throwing: HealthKitError.workoutNotFound)
          return
        }

        self.healthStore.delete(workout) { success, error in
          if let error = error {
            continuation.resume(throwing: HealthKitError.saveFailed(error.localizedDescription))
          } else if success {
            continuation.resume(returning: ())
          } else {
            continuation.resume(throwing: HealthKitError.saveFailed("Failed to delete workout"))
          }
        }
      }

      healthStore.execute(query)
    }
  }

  // MARK: - Helper Methods

  private func parseDataType(_ type: String) -> HKObjectType? {
    switch type.lowercased() {
    case "workout":
      return HKObjectType.workoutType()
    case "distance":
      return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
    case "calories":
      return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
    case "steps":
      return HKQuantityType.quantityType(forIdentifier: .stepCount)
    case "heartrate":
      return HKQuantityType.quantityType(forIdentifier: .heartRate)
    default:
      return nil
    }
  }

  private func parseActivityType(_ type: String) -> HKWorkoutActivityType {
    switch type.lowercased() {
    case "running":
      return .running
    case "walking":
      return .walking
    case "cycling":
      return .cycling
    case "swimming":
      return .swimming
    case "hiking":
      return .hiking
    case "yoga":
      return .yoga
    case "functionalstrengthtraining":
      return .functionalStrengthTraining
    case "traditionalstrengthtraining":
      return .traditionalStrengthTraining
    case "elliptical":
      return .elliptical
    case "rowing":
      return .rowing
    default:
      return .other
    }
  }

  private func formatActivityType(_ type: HKWorkoutActivityType) -> String {
    switch type {
    case .running:
      return "running"
    case .walking:
      return "walking"
    case .cycling:
      return "cycling"
    case .swimming:
      return "swimming"
    case .hiking:
      return "hiking"
    case .yoga:
      return "yoga"
    case .functionalStrengthTraining:
      return "functionalStrengthTraining"
    case .traditionalStrengthTraining:
      return "traditionalStrengthTraining"
    case .elliptical:
      return "elliptical"
    case .rowing:
      return "rowing"
    default:
      return "other"
    }
  }
}
