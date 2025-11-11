# @kayzmann/expo-healthkit

> Modern iOS HealthKit integration for Expo & React Native with zero native configuration

[![npm version](https://badge.fury.io/js/%40kayzmann%2Fexpo-healthkit.svg)](https://www.npmjs.com/package/@kayzmann/expo-healthkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive HealthKit wrapper built with **Expo Modules API** and **Swift**, providing seamless access to iOS health data with full TypeScript support.

## 💡 Key Advantages

### 🚀 Zero Native Configuration
- **Automatic setup** - No AppDelegate modifications or manual Xcode configuration required
- **Config plugin integration** - Permissions and entitlements configured automatically
- **Works with EAS Build** - Seamless cloud builds without native code editing

### ⚡ Built with Modern Technology
- **100% Swift** - Written in Swift 5.4+ using latest iOS APIs with async/await
- **Expo Modules API** - First-class Expo integration with automatic type generation
- **TypeScript-first** - Comprehensive TypeScript definitions with JSDoc comments
- **iOS 13.4+** - Leverages modern HealthKit capabilities

### 🎯 Developer Experience
- **Simple API** - Intuitive, promise-based API with async/await support
- **Type safety** - Full TypeScript autocomplete and type checking
- **Well documented** - Extensive examples and API reference
- **Active maintenance** - Regular updates and compatibility with latest Expo SDK

## 📦 Installation

```bash
npx expo install @kayzmann/expo-healthkit
```

**Compatible with:**
- Expo SDK 52+
- React Native 0.76+
- iOS 13.4+

## ⚙️ Configuration

Add the plugin to your `app.json` or `app.config.js`:

```json
{
  "expo": {
    "plugins": [
      [
        "@kayzmann/expo-healthkit",
        {
          "healthShareUsageDescription": "Allow $(PRODUCT_NAME) to read your health and workout data",
          "healthUpdateUsageDescription": "Allow $(PRODUCT_NAME) to save your workout data to the Health app"
        }
      ]
    ]
  }
}
```

Then rebuild your app:

```bash
npx expo prebuild --clean
npx expo run:ios
```

**That's it!** No AppDelegate modifications or manual Xcode setup needed.

## 🎯 Comprehensive Feature Set

### 🏃 Workouts & Exercise
- Save workouts with detailed metrics (distance, calories, duration)
- Query workout history with flexible date ranges
- Delete workouts
- Support for 10+ activity types (running, cycling, swimming, etc.)
- Custom metadata support

### 📊 Activity & Fitness
- Step count tracking
- Flights of stairs climbed
- Active and basal energy burned
- Distance tracking (walking, running, cycling, swimming)

### ⚖️ Body Measurements
- Height and weight tracking
- Body fat percentage
- BMI calculations
- Lean body mass

### ❤️ Heart & Vitals
- Heart rate samples with time-series data
- Resting heart rate
- Heart rate variability (HRV)
- Blood pressure (systolic/diastolic)
- Oxygen saturation (SpO2)
- Respiratory rate
- Body temperature

### 😴 Sleep Analysis
- Sleep samples with stages
- iOS 16+ sleep stages support (Core, Deep, REM)
- Time in bed vs actual sleep time

### 🍎 Nutrition & Hydration
- Water intake tracking
- Caffeine consumption
- Macronutrients (protein, carbohydrates, fat)
- Dietary fiber
- Calorie intake

## 📚 Usage Examples

### Quick Start

```typescript
import * as ExpoHealthKit from '@kayzmann/expo-healthkit';

// Check if HealthKit is available
const available = ExpoHealthKit.isAvailable();

// Request permissions - iOS will show native permission dialog
await ExpoHealthKit.requestAuthorization(
  ['Workout', 'Steps', 'HeartRate', 'Sleep'], // Read
  ['Workout', 'Water'] // Write
);
```

### 🔐 Permission Flow

When you call `requestAuthorization()`, iOS automatically displays a native permission dialog:

<div align="center">
  <img src="https://raw.githubusercontent.com/Kayz-mann/health-kit-expo-modules/main/docs/healthkit-permission-dialog.png" alt="HealthKit Permission Dialog" width="300"/>
</div>

> **Note:** The screenshot shows the actual iOS HealthKit permission dialog that appears when requesting access to health data.

**Key Points:**
- ✅ The dialog is native iOS UI - no custom setup needed
- ✅ Users can granularly choose which data types to allow
- ✅ Permissions are requested per data category (Workouts, Activity, Nutrition, etc.)
- ✅ Once granted, permissions persist until user changes them in Settings

**Important:** Each data type you want to access must be explicitly requested in the authorization call. For example:
- **Workouts** are a separate permission from **Steps**, **Heart Rate**, **Sleep**, etc.
- To access body measurements, nutrition, or vitals, request those specific permissions
- The permission dialog will show categories based on what you request

### Track Workouts

```typescript
// Save a workout
const workoutId = await ExpoHealthKit.saveWorkout({
  startDate: Date.now() / 1000 - 3600, // 1 hour ago
  endDate: Date.now() / 1000,
  duration: 3600, // seconds
  distance: 5000, // meters
  calories: 350, // kcal
  activityType: 'running',
  metadata: {
    note: 'Morning run in the park',
    weather: 'sunny'
  }
});

// Query recent workouts
const workouts = await ExpoHealthKit.queryWorkouts({
  startDate: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
  endDate: new Date(),
  limit: 10
});

// Get aggregated stats
const distance = await ExpoHealthKit.getTotalDistance(
  new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
  new Date()
);
```

### Monitor Daily Activity

```typescript
const today = new Date();
today.setHours(0, 0, 0, 0);

// Get today's steps
const steps = await ExpoHealthKit.getSteps(today, new Date());
console.log(`Steps today: ${Math.round(steps)}`);

// Get flights climbed
const flights = await ExpoHealthKit.getFlightsClimbed(today, new Date());
console.log(`Flights: ${Math.round(flights)}`);
```

### Track Body Measurements

```typescript
// Save measurements
await ExpoHealthKit.saveWeight(75.5); // kg
await ExpoHealthKit.saveHeight(180); // cm
await ExpoHealthKit.saveBodyFat(15.2); // percentage

// Retrieve latest
const weight = await ExpoHealthKit.getLatestWeight();
const bmi = await ExpoHealthKit.getLatestBMI();

console.log(`Weight: ${weight}kg, BMI: ${bmi?.toFixed(1)}`);
```

### Monitor Heart Health

```typescript
// Get heart rate samples
const heartRates = await ExpoHealthKit.getHeartRateSamples(
  new Date(Date.now() - 24 * 60 * 60 * 1000),
  new Date(),
  50 // limit
);

// Get latest reading
const currentHR = await ExpoHealthKit.getLatestHeartRate();
console.log(`Current HR: ${currentHR} bpm`);

// Save blood pressure
await ExpoHealthKit.saveBloodPressure(120, 80);
```

### Analyze Sleep

```typescript
const yesterday = new Date();
yesterday.setDate(yesterday.getDate() - 1);
yesterday.setHours(0, 0, 0, 0);

const sleepSamples = await ExpoHealthKit.getSleepSamples(
  yesterday,
  new Date()
);

// Calculate total sleep
const totalSleep = sleepSamples
  .filter(s => ['asleep', 'core', 'deep', 'rem'].includes(s.value))
  .reduce((sum, s) => sum + s.duration, 0);

console.log(`Sleep: ${(totalSleep / 3600).toFixed(1)} hours`);
```

### Track Nutrition

```typescript
// Log water intake
await ExpoHealthKit.saveWater(500); // 500ml

// Get daily water
const water = await ExpoHealthKit.getWaterIntake(
  new Date().setHours(0, 0, 0, 0),
  new Date()
);

// Log macros
await ExpoHealthKit.saveProtein(30); // grams
await ExpoHealthKit.saveCarbs(45);
await ExpoHealthKit.saveFat(15);
```

## 📖 API Reference

### Core Functions

#### `isAvailable(): boolean`
Check if HealthKit is available on the device.

#### `requestAuthorization(readTypes: DataType[], writeTypes: DataType[]): Promise<void>`
Request permission to read/write health data.

### Supported Data Types

The module supports 50+ data types including:

**Activity:** `Steps`, `Distance`, `FlightsClimbed`, `ActiveEnergy`, `BasalEnergy`

**Body:** `Height`, `Weight`, `BMI`, `BodyFat`, `LeanMass`

**Vitals:** `HeartRate`, `RestingHeartRate`, `HRV`, `BloodPressure`, `OxygenSaturation`, `RespiratoryRate`, `BodyTemperature`

**Nutrition:** `Water`, `Caffeine`, `Protein`, `Carbs`, `Fat`, `Fiber`

**Sleep:** `SleepAnalysis` (with iOS 16+ stage support)

**Workouts:** Full workout tracking with 10+ activity types

[Full API documentation available in TypeScript definitions with IntelliSense support]

## 🔧 Requirements

- **iOS:** 13.4 or higher
- **Expo SDK:** 52 or higher
- **React Native:** 0.76 or higher
- **Device:** Physical iOS device (HealthKit doesn't work on simulator)
- **Apple Developer:** HealthKit capability enabled in your provisioning profile

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT © [Kayzmann](https://github.com/Kayz-mann)

## 🙏 Acknowledgments

Built with ❤️ using [Expo Modules API](https://docs.expo.dev/modules/overview/)

---

**Need help?** [Open an issue](https://github.com/Kayz-mann/health-kit-expo-modules/issues)
