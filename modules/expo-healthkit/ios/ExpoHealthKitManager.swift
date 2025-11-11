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
      try await healthStore.requestAuthorization(toShare: writeDataTypes as! Set<HKSampleType>, read: readDataTypes)
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

  // MARK: - Steps & Activity

  func getSteps(startDate: Date, endDate: Date) async throws -> Double {
    return try await getQuantitySum(
      identifier: .stepCount,
      startDate: startDate,
      endDate: endDate,
      unit: .count()
    )
  }

  func getFlightsClimbed(startDate: Date, endDate: Date) async throws -> Double {
    return try await getQuantitySum(
      identifier: .flightsClimbed,
      startDate: startDate,
      endDate: endDate,
      unit: .count()
    )
  }

  // MARK: - Body Measurements

  func saveHeight(value: Double, date: Date) async throws {
    try await saveQuantitySample(
      identifier: .height,
      value: value,
      unit: .meterUnit(with: .centi),
      date: date
    )
  }

  func saveWeight(value: Double, date: Date) async throws {
    try await saveQuantitySample(
      identifier: .bodyMass,
      value: value,
      unit: .gramUnit(with: .kilo),
      date: date
    )
  }

  func saveBodyFat(value: Double, date: Date) async throws {
    try await saveQuantitySample(
      identifier: .bodyFatPercentage,
      value: value / 100.0, // Convert percentage to decimal
      unit: .percent(),
      date: date
    )
  }

  func getLatestHeight() async throws -> Double? {
    return try await getLatestQuantity(identifier: .height, unit: .meterUnit(with: .centi))
  }

  func getLatestWeight() async throws -> Double? {
    return try await getLatestQuantity(identifier: .bodyMass, unit: .gramUnit(with: .kilo))
  }

  func getLatestBMI() async throws -> Double? {
    return try await getLatestQuantity(identifier: .bodyMassIndex, unit: .count())
  }

  func getLatestBodyFat() async throws -> Double? {
    if let value = try await getLatestQuantity(identifier: .bodyFatPercentage, unit: .percent()) {
      return value * 100.0 // Convert to percentage
    }
    return nil
  }

  // MARK: - Heart Rate & Vitals

  func getHeartRateSamples(startDate: Date, endDate: Date, limit: Int?) async throws -> [[String: Any]] {
    return try await getQuantitySamples(
      identifier: .heartRate,
      startDate: startDate,
      endDate: endDate,
      unit: .count().unitDivided(by: .minute()),
      limit: limit
    )
  }

  func getLatestHeartRate() async throws -> Double? {
    return try await getLatestQuantity(
      identifier: .heartRate,
      unit: .count().unitDivided(by: .minute())
    )
  }

  func getRestingHeartRate(startDate: Date, endDate: Date) async throws -> Double? {
    return try await getLatestQuantity(
      identifier: .restingHeartRate,
      unit: .count().unitDivided(by: .minute())
    )
  }

  func getOxygenSaturation(startDate: Date, endDate: Date, limit: Int?) async throws -> [[String: Any]] {
    return try await getQuantitySamples(
      identifier: .oxygenSaturation,
      startDate: startDate,
      endDate: endDate,
      unit: .percent(),
      limit: limit
    )
  }

  func saveBloodPressure(systolic: Double, diastolic: Double, date: Date) async throws {
    // Save systolic
    try await saveQuantitySample(
      identifier: .bloodPressureSystolic,
      value: systolic,
      unit: .millimeterOfMercury(),
      date: date
    )

    // Save diastolic
    try await saveQuantitySample(
      identifier: .bloodPressureDiastolic,
      value: diastolic,
      unit: .millimeterOfMercury(),
      date: date
    )
  }

  // MARK: - Sleep

  func getSleepSamples(startDate: Date, endDate: Date) async throws -> [[String: Any]] {
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        predicate: predicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: [sortDescriptor]
      ) { _, samples, error in
        if let error = error {
          continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
          return
        }

        guard let sleepSamples = samples as? [HKCategorySample] else {
          continuation.resume(returning: [])
          return
        }

        let sleepData = sleepSamples.map { sample -> [String: Any] in
          var sleepState = "unknown"
          if #available(iOS 16.0, *) {
            switch sample.value {
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
              sleepState = "core"
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
              sleepState = "deep"
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
              sleepState = "rem"
            case HKCategoryValueSleepAnalysis.awake.rawValue:
              sleepState = "awake"
            case HKCategoryValueSleepAnalysis.inBed.rawValue:
              sleepState = "inBed"
            default:
              sleepState = "asleep"
            }
          } else {
            switch sample.value {
            case HKCategoryValueSleepAnalysis.asleep.rawValue:
              sleepState = "asleep"
            case HKCategoryValueSleepAnalysis.awake.rawValue:
              sleepState = "awake"
            case HKCategoryValueSleepAnalysis.inBed.rawValue:
              sleepState = "inBed"
            default:
              sleepState = "unknown"
            }
          }

          return [
            "id": sample.uuid.uuidString,
            "value": sleepState,
            "startDate": sample.startDate.timeIntervalSince1970,
            "endDate": sample.endDate.timeIntervalSince1970,
            "duration": sample.endDate.timeIntervalSince(sample.startDate)
          ]
        }

        continuation.resume(returning: sleepData)
      }

      healthStore.execute(query)
    }
  }

  // MARK: - Nutrition

  func saveWater(milliliters: Double, date: Date) async throws {
    try await saveQuantitySample(
      identifier: .dietaryWater,
      value: milliliters / 1000.0, // Convert mL to L
      unit: .liter(),
      date: date
    )
  }

  func getWaterIntake(startDate: Date, endDate: Date) async throws -> Double {
    let liters = try await getQuantitySum(
      identifier: .dietaryWater,
      startDate: startDate,
      endDate: endDate,
      unit: .liter()
    )
    return liters * 1000.0 // Convert L to mL
  }

  func saveCaffeine(milligrams: Double, date: Date) async throws {
    try await saveQuantitySample(
      identifier: .dietaryCaffeine,
      value: milligrams / 1000.0, // Convert mg to g
      unit: .gram(),
      date: date
    )
  }

  func saveProtein(grams: Double, date: Date) async throws {
    try await saveQuantitySample(
      identifier: .dietaryProtein,
      value: grams,
      unit: .gram(),
      date: date
    )
  }

  func saveCarbs(grams: Double, date: Date) async throws {
    try await saveQuantitySample(
      identifier: .dietaryCarbohydrates,
      value: grams,
      unit: .gram(),
      date: date
    )
  }

  func saveFat(grams: Double, date: Date) async throws {
    try await saveQuantitySample(
      identifier: .dietaryFatTotal,
      value: grams,
      unit: .gram(),
      date: date
    )
  }

  // MARK: - Generic Helper Methods

  private func getQuantitySum(identifier: HKQuantityTypeIdentifier, startDate: Date, endDate: Date, unit: HKUnit) async throws -> Double {
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKStatisticsQuery(
        quantityType: HKQuantityType.quantityType(forIdentifier: identifier)!,
        quantitySamplePredicate: predicate,
        options: .cumulativeSum
      ) { _, result, error in
        if let error = error {
          continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
          return
        }

        let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
        continuation.resume(returning: value)
      }

      healthStore.execute(query)
    }
  }

  private func getLatestQuantity(identifier: HKQuantityTypeIdentifier, unit: HKUnit) async throws -> Double? {
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: HKQuantityType.quantityType(forIdentifier: identifier)!,
        predicate: nil,
        limit: 1,
        sortDescriptors: [sortDescriptor]
      ) { _, samples, error in
        if let error = error {
          continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
          return
        }

        guard let sample = samples?.first as? HKQuantitySample else {
          continuation.resume(returning: nil)
          return
        }

        let value = sample.quantity.doubleValue(for: unit)
        continuation.resume(returning: value)
      }

      healthStore.execute(query)
    }
  }

  private func getQuantitySamples(identifier: HKQuantityTypeIdentifier, startDate: Date, endDate: Date, unit: HKUnit, limit: Int?) async throws -> [[String: Any]] {
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: HKQuantityType.quantityType(forIdentifier: identifier)!,
        predicate: predicate,
        limit: limit ?? HKObjectQueryNoLimit,
        sortDescriptors: [sortDescriptor]
      ) { _, samples, error in
        if let error = error {
          continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
          return
        }

        guard let quantitySamples = samples as? [HKQuantitySample] else {
          continuation.resume(returning: [])
          return
        }

        let data = quantitySamples.map { sample -> [String: Any] in
          return [
            "id": sample.uuid.uuidString,
            "value": sample.quantity.doubleValue(for: unit),
            "startDate": sample.startDate.timeIntervalSince1970,
            "endDate": sample.endDate.timeIntervalSince1970
          ]
        }

        continuation.resume(returning: data)
      }

      healthStore.execute(query)
    }
  }

  private func saveQuantitySample(identifier: HKQuantityTypeIdentifier, value: Double, unit: HKUnit, date: Date) async throws {
    let quantity = HKQuantity(unit: unit, doubleValue: value)
    let sample = HKQuantitySample(
      type: HKQuantityType.quantityType(forIdentifier: identifier)!,
      quantity: quantity,
      start: date,
      end: date
    )

    do {
      try await healthStore.save(sample)
    } catch {
      throw HealthKitError.saveFailed(error.localizedDescription)
    }
  }

  // MARK: - Helper Methods

  private func parseDataType(_ type: String) -> HKObjectType? {
    switch type.lowercased() {
    // Workouts
    case "workout":
      return HKObjectType.workoutType()

    // Activity & Fitness
    case "steps", "stepcount":
      return HKQuantityType.quantityType(forIdentifier: .stepCount)
    case "distance", "distancewalkingrunning":
      return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
    case "distancecycling":
      return HKQuantityType.quantityType(forIdentifier: .distanceCycling)
    case "distanceswimming":
      return HKQuantityType.quantityType(forIdentifier: .distanceSwimming)
    case "flightsclimbed":
      return HKQuantityType.quantityType(forIdentifier: .flightsClimbed)
    case "activeenergy", "calories", "activeenergyburned":
      return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
    case "basalenergy", "basalenergyburned":
      return HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)

    // Body Measurements
    case "height", "bodyheight":
      return HKQuantityType.quantityType(forIdentifier: .height)
    case "weight", "bodymass", "bodyweight":
      return HKQuantityType.quantityType(forIdentifier: .bodyMass)
    case "bodymassindex", "bmi":
      return HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)
    case "bodyfat", "bodyfatpercentage":
      return HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)
    case "leanmass", "leanbodymass":
      return HKQuantityType.quantityType(forIdentifier: .leanBodyMass)

    // Vitals
    case "heartrate":
      return HKQuantityType.quantityType(forIdentifier: .heartRate)
    case "restingheartrate":
      return HKQuantityType.quantityType(forIdentifier: .restingHeartRate)
    case "heartratevariability", "hrv":
      return HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
    case "bloodpressuresystolic":
      return HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)
    case "bloodpressurediastolic":
      return HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)
    case "respiratoryrate":
      return HKQuantityType.quantityType(forIdentifier: .respiratoryRate)
    case "oxygensat", "oxygensaturation", "spo2":
      return HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)
    case "bodytemperature":
      return HKQuantityType.quantityType(forIdentifier: .bodyTemperature)

    // Nutrition
    case "dietaryenergy", "dietarycalories":
      return HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)
    case "protein", "dietaryprotein":
      return HKQuantityType.quantityType(forIdentifier: .dietaryProtein)
    case "carbs", "carbohydrates", "dietarycarbohydrates":
      return HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)
    case "fat", "dietaryfat", "dietaryfattotal":
      return HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal)
    case "fiber", "dietaryfiber":
      return HKQuantityType.quantityType(forIdentifier: .dietaryFiber)
    case "water", "dietarywater":
      return HKQuantityType.quantityType(forIdentifier: .dietaryWater)
    case "caffeine", "dietarycaffeine":
      return HKQuantityType.quantityType(forIdentifier: .dietaryCaffeine)

    // Sleep
    case "sleep", "sleepanalysis":
      return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)

    // Mindfulness
    case "mindfulness", "mindfulminutes":
      return HKObjectType.categoryType(forIdentifier: .mindfulSession)

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
