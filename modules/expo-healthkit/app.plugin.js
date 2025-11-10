const {
  withInfoPlist,
  withEntitlementsPlist,
  createRunOncePlugin,
} = require('@expo/config-plugins');

/**
 * Config plugin to set up HealthKit permissions and entitlements
 */
const withHealthKit = (config, props = {}) => {
  const {
    healthShareUsageDescription = 'This app needs access to read your health data',
    healthUpdateUsageDescription = 'This app needs access to save workout data to your Health app',
  } = props;

  // Add Info.plist entries
  config = withInfoPlist(config, (config) => {
    config.modResults.NSHealthShareUsageDescription = healthShareUsageDescription;
    config.modResults.NSHealthUpdateUsageDescription = healthUpdateUsageDescription;
    return config;
  });

  // Add entitlements
  config = withEntitlementsPlist(config, (config) => {
    config.modResults['com.apple.developer.healthkit'] = true;
    config.modResults['com.apple.developer.healthkit.access'] = [];
    return config;
  });

  return config;
};

module.exports = createRunOncePlugin(
  withHealthKit,
  'expo-healthkit',
  '1.0.0'
);
