import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Button, ScrollView, Alert } from 'react-native';
import * as ExpoHealthKit from 'expo-healthkit';
import type { Workout } from 'expo-healthkit';

export default function HealthKitDemo() {
  const [isAvailable, setIsAvailable] = useState(false);
  const [authorized, setAuthorized] = useState(false);
  const [workouts, setWorkouts] = useState<Workout[]>([]);
  const [stats, setStats] = useState({ distance: 0, calories: 0 });

  useEffect(() => {
    // Check if HealthKit is available
    const available = ExpoHealthKit.isAvailable();
    setIsAvailable(available);
  }, []);

  const handleRequestAuth = async () => {
    try {
      await ExpoHealthKit.requestAuthorization(['Workout'], ['Workout']);
      setAuthorized(true);
      Alert.alert('Success', 'HealthKit authorization granted');
    } catch (error) {
      Alert.alert('Error', 'Failed to authorize HealthKit');
      console.error(error);
    }
  };

  const handleSaveWorkout = async () => {
    try {
      const now = Date.now() / 1000;
      const oneHourAgo = now - 3600;

      await ExpoHealthKit.saveWorkout({
        startDate: oneHourAgo,
        endDate: now,
        duration: 3600, // 1 hour
        distance: 5000, // 5km
        calories: 350,
        activityType: 'running',
        metadata: {
          note: 'Morning run',
        },
      });

      Alert.alert('Success', 'Workout saved to HealthKit!');
      await loadWorkouts();
    } catch (error) {
      Alert.alert('Error', 'Failed to save workout');
      console.error(error);
    }
  };

  const loadWorkouts = async () => {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const results = await ExpoHealthKit.queryWorkouts({
        startDate: thirtyDaysAgo,
        endDate: new Date(),
        limit: 10,
      });

      setWorkouts(results);
    } catch (error) {
      Alert.alert('Error', 'Failed to load workouts');
      console.error(error);
    }
  };

  const loadStats = async () => {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const distance = await ExpoHealthKit.getTotalDistance(
        thirtyDaysAgo,
        new Date()
      );

      const calories = await ExpoHealthKit.getTotalCalories(
        thirtyDaysAgo,
        new Date()
      );

      setStats({
        distance: Math.round(distance),
        calories: Math.round(calories),
      });
    } catch (error) {
      Alert.alert('Error', 'Failed to load stats');
      console.error(error);
    }
  };

  const handleDeleteWorkout = async (workoutId: string) => {
    try {
      await ExpoHealthKit.deleteWorkout(workoutId);
      Alert.alert('Success', 'Workout deleted');
      await loadWorkouts();
    } catch (error) {
      Alert.alert('Error', 'Failed to delete workout');
      console.error(error);
    }
  };

  const formatDate = (timestamp: number) => {
    return new Date(timestamp * 1000).toLocaleString();
  };

  const formatDistance = (meters: number) => {
    return (meters / 1000).toFixed(2) + ' km';
  };

  const formatDuration = (seconds: number) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return `${hours}h ${minutes}m`;
  };

  if (!isAvailable) {
    return (
      <View style={styles.container}>
        <Text style={styles.error}>HealthKit is not available on this device</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>HealthKit Demo</Text>

      {!authorized && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Authorization</Text>
          <Button title="Request HealthKit Access" onPress={handleRequestAuth} />
        </View>
      )}

      {authorized && (
        <>
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Actions</Text>
            <View style={styles.buttonGroup}>
              <Button title="Save Sample Workout" onPress={handleSaveWorkout} />
              <Button title="Load Workouts" onPress={loadWorkouts} />
              <Button title="Load Stats" onPress={loadStats} />
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Stats (Last 30 Days)</Text>
            <View style={styles.stats}>
              <View style={styles.stat}>
                <Text style={styles.statValue}>{formatDistance(stats.distance)}</Text>
                <Text style={styles.statLabel}>Distance</Text>
              </View>
              <View style={styles.stat}>
                <Text style={styles.statValue}>{stats.calories}</Text>
                <Text style={styles.statLabel}>Calories</Text>
              </View>
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Recent Workouts</Text>
            {workouts.length === 0 ? (
              <Text style={styles.emptyText}>No workouts found</Text>
            ) : (
              workouts.map((workout) => (
                <View key={workout.id} style={styles.workout}>
                  <View style={styles.workoutHeader}>
                    <Text style={styles.workoutType}>{workout.activityType}</Text>
                    <Button
                      title="Delete"
                      onPress={() => handleDeleteWorkout(workout.id)}
                      color="#ff3b30"
                    />
                  </View>
                  <Text style={styles.workoutDetail}>
                    Distance: {formatDistance(workout.distance)}
                  </Text>
                  <Text style={styles.workoutDetail}>
                    Duration: {formatDuration(workout.duration)}
                  </Text>
                  <Text style={styles.workoutDetail}>
                    Calories: {Math.round(workout.calories)} kcal
                  </Text>
                  <Text style={styles.workoutDetail}>
                    Date: {formatDate(workout.startDate)}
                  </Text>
                </View>
              ))
            )}
          </View>
        </>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  section: {
    backgroundColor: 'white',
    borderRadius: 10,
    padding: 15,
    marginBottom: 15,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 10,
  },
  buttonGroup: {
    gap: 10,
  },
  stats: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  stat: {
    alignItems: 'center',
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#007AFF',
  },
  statLabel: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  workout: {
    backgroundColor: '#f9f9f9',
    padding: 12,
    borderRadius: 8,
    marginBottom: 10,
  },
  workoutHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  workoutType: {
    fontSize: 18,
    fontWeight: '600',
    textTransform: 'capitalize',
  },
  workoutDetail: {
    fontSize: 14,
    color: '#333',
    marginBottom: 4,
  },
  emptyText: {
    textAlign: 'center',
    color: '#999',
    padding: 20,
  },
  error: {
    fontSize: 16,
    color: 'red',
    textAlign: 'center',
    padding: 20,
  },
});
