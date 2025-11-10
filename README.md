# Health Kit RN - HealthKit Integration with Expo

A complete React Native + Expo application demonstrating iOS HealthKit integration through a custom native module.

## 🎯 About This App

This is a **fully functional iOS fitness tracking app** that demonstrates how to integrate native iOS HealthKit features into a React Native/Expo application. The app allows users to:

- 📱 Track and save workout sessions to Apple Health
- 📊 View workout history from the last 30 days
- 📈 See aggregate statistics (total distance, calories)
- 🗑️ Delete workouts from HealthKit
- ✅ Request and manage HealthKit permissions

The app is built using **Expo Router** for navigation and includes a custom **expo-healthkit** module that bridges Swift/HealthKit to JavaScript.

## 🏃 App Features

### Main Demo Screen ([healthkit-demo.tsx](app/healthkit-demo.tsx))

- **Authorization Flow**: Request read/write access to HealthKit workout data
- **Save Workouts**: Create sample workouts (running, walking, cycling, etc.) with distance, duration, and calories
- **View Statistics**: Display total distance and calories burned over the last 30 days
- **Workout History**: Browse recent workouts with detailed information
- **Delete Workouts**: Remove individual workouts from HealthKit

### Module Capabilities

The **expo-healthkit** module provides:

- ✅ Full HealthKit workout management
- ✅ Multiple activity types (running, cycling, swimming, yoga, etc.)
- ✅ Aggregate statistics queries
- ✅ Type-safe TypeScript API
- ✅ Automatic permission configuration via Expo config plugin

## 📁 Project Structure

```
health-kit-rn/
├── app/                           # Expo Router app directory
│   ├── (tabs)/                    # Tab navigation
│   │   ├── index.tsx             # Home screen
│   │   └── explore.tsx           # Explore screen
│   ├── healthkit-demo.tsx        # HealthKit demo & test screen
│   ├── _layout.tsx               # Root layout
│   └── +not-found.tsx            # 404 screen
│
├── modules/expo-healthkit/        # Custom HealthKit Expo module
│   ├── ios/                       # Native iOS implementation
│   │   ├── ExpoHealthKitModule.swift    # Module interface definition
│   │   └── ExpoHealthKitManager.swift   # HealthKit operations logic
│   ├── src/                       # TypeScript API
│   │   ├── ExpoHealthKit.ts      # Main API wrapper
│   │   ├── types.ts              # TypeScript type definitions
│   │   └── index.ts              # Module exports
│   ├── app.plugin.js             # Expo config plugin (auto-adds permissions)
│   ├── expo-module.config.json   # Module configuration for autolinking
│   ├── package.json              # Module package definition
│   └── README.md                 # Module documentation
│
├── components/                    # React components
│   ├── navigation/               # Navigation components
│   ├── ui/                       # UI components
│   └── ...
│
├── ios/                          # Generated iOS native project (git-ignored)
│   ├── healthkitrn.xcworkspace   # Xcode workspace
│   └── healthkitrn/
│       ├── Info.plist            # Contains HealthKit usage descriptions
│       └── healthkitrn.entitlements  # HealthKit entitlements
│
├── app.json                      # Expo configuration
├── package.json                  # Project dependencies
└── tsconfig.json                 # TypeScript configuration
```

### Key Files

- **[app/healthkit-demo.tsx](app/healthkit-demo.tsx)**: Main demo screen with HealthKit integration UI
- **[modules/expo-healthkit/ios/ExpoHealthKitModule.swift](modules/expo-healthkit/ios/ExpoHealthKitModule.swift)**: Native module interface
- **[modules/expo-healthkit/ios/ExpoHealthKitManager.swift](modules/expo-healthkit/ios/ExpoHealthKitManager.swift)**: HealthKit business logic
- **[modules/expo-healthkit/src/ExpoHealthKit.ts](modules/expo-healthkit/src/ExpoHealthKit.ts)**: JavaScript API wrapper
- **[modules/expo-healthkit/app.plugin.js](modules/expo-healthkit/app.plugin.js)**: Expo config plugin for permissions

## 🚀 Quick Start

### 1. Install Dependencies

```bash
yarn install
```

### 2. Build and Run on Device

**⚠️ CRITICAL:** This app REQUIRES building with Xcode or `yarn ios --device`. You **CANNOT** use `yarn start` alone because:
- The native Swift module needs to be compiled
- HealthKit requires a physical iOS device (not simulator)
- Metro bundler only handles JavaScript, not native code

**Option A: Build with Xcode (Recommended for first build)**

1. Open the workspace:
   ```bash
   cd ios && open healthkitrn.xcworkspace
   ```

2. In Xcode:
   - Select the **healthkitrn** project → **healthkitrn** target
   - Go to **Signing & Capabilities** tab
   - ✅ Check "Automatically manage signing"
   - Select your Apple Developer Team from the dropdown

3. Connect your iPhone and select it as the destination

4. Press Run ▶️ (or ⌘R)

**Option B: Build with CLI**

Connect your iPhone and run:
```bash
yarn ios --device
```

**Common Error:** If you see `Error: Cannot find native module 'ExpoHealthKit'`, it means you tried to run with `yarn start` instead of building the app. You must build with Xcode or `yarn ios --device` first.

### 3. Using the App

Once the app launches on your device:

1. Navigate to the **healthkit-demo** screen (you can add it to your navigation or access it directly)
2. Tap **"Request HealthKit Access"** to authorize the app
3. Use the buttons to:
   - **Save Sample Workout**: Creates a 1-hour running workout with 5km distance
   - **Load Workouts**: Fetches your last 10 workouts from the past 30 days
   - **Load Stats**: Shows total distance and calories for the last 30 days
4. View your workout history and tap **Delete** to remove individual workouts

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

### "Cannot find native module 'ExpoHealthKit'"

**Cause:** You're running the Metro bundler (`yarn start`) without building the native code.

**Why this happens:**
- Metro bundler only handles JavaScript files
- Native Swift modules must be compiled with Xcode or `yarn ios`
- The module exists in code but hasn't been built into a binary

**Solution:**
1. Stop Metro bundler (Ctrl+C)
2. Build the app with Xcode or run `yarn ios --device`
3. The module will be compiled and available

### "Signing for 'healthkitrn' requires a development team"

**Solution:** Open Xcode and configure code signing:
1. `open ios/healthkitrn.xcworkspace`
2. Select **healthkitrn** target → **Signing & Capabilities**
3. Check "Automatically manage signing"
4. Select your Apple Developer Team

### "Provisioning profile doesn't support HealthKit capability"

**Cause:** HealthKit requires special App ID configuration in your Apple Developer account.

**Solution:**

1. **Register App ID with HealthKit:**
   - Go to https://developer.apple.com/account
   - Navigate to **Certificates, Identifiers & Profiles** → **Identifiers**
   - Find or create App ID: `com.kayz-mann.health-kit-rn`
   - ✅ Enable **HealthKit** capability
   - Click **Save**

2. **Regenerate Provisioning Profile in Xcode:**
   - Open Xcode → **Signing & Capabilities**
   - **Uncheck** "Automatically manage signing"
   - **Check** it again (forces Xcode to regenerate)
   - Wait for Xcode to download new profile

3. **Build again** - the profile will now include HealthKit entitlements

### Module not updating

```bash
rm -rf node_modules/expo-healthkit
yarn install
cd ios && pod install
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
