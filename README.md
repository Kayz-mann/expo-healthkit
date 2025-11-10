# Health Kit RN - HealthKit Integration with Expo

A React Native app with native iOS HealthKit integration using Expo Modules.

## 🎯 What This Project Does

This project demonstrates how to integrate iOS HealthKit into a React Native app using **Expo Modules**. It includes a complete working module that lets you:

- ✅ Save workouts to HealthKit
- ✅ Query workout history
- ✅ Get aggregate statistics
- ✅ Delete workouts
- ✅ Full TypeScript support

## 📁 Project Structure

```
health-kit-rn/
├── modules/expo-healthkit/        # Local Expo HealthKit module
│   ├── ios/                       # Native Swift code
│   │   ├── ExpoHealthKitModule.swift
│   │   └── ExpoHealthKitManager.swift
│   ├── src/                       # TypeScript API
│   └── app.plugin.js              # Auto-configuration
├── app/
│   └── healthkit-demo.tsx         # Working demo
└── ios/                           # Generated native project
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
yarn install
```

### 2. Build and Run on Device

**⚠️ IMPORTANT:** HealthKit requires a physical iOS device (not simulator).

Connect your iPhone and run:

```bash
yarn ios --device
```

Or open in Xcode:

```bash
cd ios && open healthkitrn.xcworkspace
```

Then select your device and press Run (⌘R).

### 3. Test the Demo

Once the app launches, navigate to the **healthkit-demo** screen to test:
- Request HealthKit authorization
- Save sample workouts
- Query workout history
- View statistics

## 💻 Usage Example

```typescript
import * as ExpoHealthKit from 'expo-healthkit';

// Request permission
await ExpoHealthKit.requestAuthorization([], ['Workout']);

// Save a workout
await ExpoHealthKit.saveWorkout({
  startDate: Date.now() / 1000 - 3600,
  endDate: Date.now() / 1000,
  duration: 3600,
  distance: 5000,
  calories: 350,
  activityType: 'running',
});

// Query workouts
const workouts = await ExpoHealthKit.queryWorkouts({
  startDate: new Date('2024-01-01'),
  endDate: new Date(),
});
```

## 🏗️ Architecture

This project shows how to bridge Swift/HealthKit to React Native:

```
JavaScript (TypeScript)
       ↓
requireNativeModule
       ↓
  Expo Bridge
       ↓
  Swift Module
       ↓
  iOS HealthKit
```

**Key Components:**

1. **Swift Module** ([ExpoHealthKitModule.swift](modules/expo-healthkit/ios/ExpoHealthKitModule.swift)) - Defines the native interface
2. **Swift Manager** ([ExpoHealthKitManager.swift](modules/expo-healthkit/ios/ExpoHealthKitManager.swift)) - Implements HealthKit operations
3. **TypeScript API** ([src/ExpoHealthKit.ts](modules/expo-healthkit/src/ExpoHealthKit.ts)) - Type-safe JavaScript wrapper
4. **Config Plugin** ([app.plugin.js](modules/expo-healthkit/app.plugin.js)) - Auto-adds permissions

## 📚 Full Documentation

See [modules/expo-healthkit/README.md](modules/expo-healthkit/README.md) for:
- Complete API reference
- All supported functions
- TypeScript types
- Advanced usage

## ⚠️ Troubleshooting

### "Cannot find native module"

This happens when running `yarn start` without building.

**Solution:** Run `yarn ios --device` to build the native code.

### Module not updating

```bash
rm -rf node_modules/expo-healthkit
yarn install
yarn ios --device
```

## 📖 Learn More

- [Expo Modules Docs](https://docs.expo.dev/modules/overview/)
- [HealthKit Docs](https://developer.apple.com/documentation/healthkit)
- [Reference: expo-ios-popover-tip](https://github.com/rit3zh/expo-ios-popover-tip)

## 🎓 What You'll Learn

This project teaches:
- How to create local Expo modules
- Swift ↔ JavaScript bridging
- HealthKit integration
- Expo config plugins
- Native module architecture
