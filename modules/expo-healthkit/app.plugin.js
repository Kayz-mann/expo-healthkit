const {
  withInfoPlist,
  withEntitlementsPlist,
  createRunOncePlugin,
} = require('@expo/config-plugins');

const withHealthKit = (config, props = {}) => {
  const {
    healthShareUsageDescription = 'This app needs access to read your health data',
    healthUpdateUsageDescription = 'This app needs access to save workout data to your Health app',
  } = props;

  config = withInfoPlist(config, (config) => {
    config.modResults.NSHealthShareUsageDescription = healthShareUsageDescription;
    config.modResults.NSHealthUpdateUsageDescription = healthUpdateUsageDescription;
    return config;
  });

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
