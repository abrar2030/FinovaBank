import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, FlatList, ActivityIndicator, Alert, TouchableOpacity, TextInput } from 'react-native';
import { commonStyles, responsiveWidth } from '../styles/commonStyles'; // Import common styles
// TODO: Import the actual API function, e.g., getAccountSavingsGoals, createSavingsGoal
// import { getAccountSavingsGoals, createSavingsGoal } from '../services/api';

// Define the structure for savings goal data
interface SavingsGoal {
  id: string;
  name: string;
  targetAmount: number;
  currentAmount: number;
  progress: number; // Percentage of completion (0-100)
  createdDate: string;
}

const SavingsGoalsScreen = () => {
  const [savingsGoals, setSavingsGoals] = useState<SavingsGoal[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newGoalName, setNewGoalName] = useState('');
  const [newGoalAmount, setNewGoalAmount] = useState('');
  
  // TODO: Get accountId from context or route params if needed
  const accountId = '1'; // Placeholder

  useEffect(() => {
    const fetchSavingsGoals = async () => {
      setLoading(true);
      setError(null);
      try {
        // TODO: Replace with actual API call
        // const response = await getAccountSavingsGoals(accountId);
        // setSavingsGoals(response.data);

        // Simulate API call for now
        await new Promise(resolve => setTimeout(resolve, 1000)); // Simulate network delay
        const simulatedData: SavingsGoal[] = [
          { id: 'sg301', name: 'Vacation Fund', targetAmount: 5000, currentAmount: 2500, progress: 50, createdDate: '2025-01-15' },
          { id: 'sg302', name: 'New Car', targetAmount: 20000, currentAmount: 5000, progress: 25, createdDate: '2025-02-10' },
          { id: 'sg303', name: 'Emergency Fund', targetAmount: 10000, currentAmount: 9000, progress: 90, createdDate: '2024-11-05' },
        ];
        setSavingsGoals(simulatedData);

      } catch (err: any) {
        console.error('Failed to fetch savings goals:', err);
        const errorMessage = err.response?.data?.error?.message || err.message || 'Failed to load savings goals.';
        setError(errorMessage);
        Alert.alert('Error', errorMessage);
      } finally {
        setLoading(false);
      }
    };

    fetchSavingsGoals();
  }, [accountId]);

  const handleAddGoal = async () => {
    if (!newGoalName.trim() || !newGoalAmount.trim()) {
      Alert.alert('Error', 'Please enter both goal name and target amount.');
      return;
    }

    const targetAmount = parseFloat(newGoalAmount);
    if (isNaN(targetAmount) || targetAmount <= 0) {
      Alert.alert('Error', 'Please enter a valid target amount.');
      return;
    }

    try {
      // TODO: Replace with actual API call
      // const response = await createSavingsGoal({
      //   accountId,
      //   goalName: newGoalName,
      //   targetAmount
      // });
      // console.log('Savings goal created:', response.data);

      // Simulate API call for now
      Alert.alert('Success', 'Savings goal created successfully (simulated)!');
      
      // Add the new goal to the list (in a real app, you'd use the response data)
      const newGoal: SavingsGoal = {
        id: `sg${Date.now()}`, // Generate a temporary ID
        name: newGoalName,
        targetAmount,
        currentAmount: 0,
        progress: 0,
        createdDate: new Date().toISOString().split('T')[0], // Format as YYYY-MM-DD
      };
      
      setSavingsGoals([...savingsGoals, newGoal]);
      
      // Reset form
      setNewGoalName('');
      setNewGoalAmount('');
      setShowAddForm(false);
      
    } catch (err: any) {
      console.error('Failed to create savings goal:', err);
      const errorMessage = err.response?.data?.error?.message || err.message || 'Failed to create savings goal.';
      Alert.alert('Error', errorMessage);
    }
  };

  const renderSavingsGoalItem = ({ item }: { item: SavingsGoal }) => (
    <View style={styles.goalItem}>
      <Text style={styles.goalName}>{item.name}</Text>
      <View style={styles.goalDetails}>
        <Text style={styles.goalAmount}>
          ${item.currentAmount.toFixed(2)} / ${item.targetAmount.toFixed(2)}
        </Text>
        <Text style={styles.goalDate}>Created: {item.createdDate}</Text>
      </View>
      
      {/* Progress bar */}
      <View style={styles.progressBarContainer}>
        <View style={[styles.progressBar, { width: `${item.progress}%` }]} />
      </View>
      <Text style={styles.progressText}>{item.progress}% Complete</Text>
    </View>
  );

  if (loading) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <ActivityIndicator size="large" color="#007bff" />
        <Text>Loading Savings Goals...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <Text style={styles.errorText}>Error: {error}</Text>
      </View>
    );
  }

  return (
    <View style={commonStyles.container}>
      <Text style={commonStyles.titleText}>Your Savings Goals</Text>
      
      {/* Add Goal Button */}
      {!showAddForm && (
        <TouchableOpacity 
          style={[commonStyles.button, styles.addButton]} 
          onPress={() => setShowAddForm(true)}
        >
          <Text style={commonStyles.buttonText}>Add New Savings Goal</Text>
        </TouchableOpacity>
      )}
      
      {/* Add Goal Form */}
      {showAddForm && (
        <View style={styles.formContainer}>
          <Text style={styles.formTitle}>Create New Savings Goal</Text>
          <TextInput
            style={styles.input}
            placeholder="Goal Name (e.g., Vacation Fund)"
            value={newGoalName}
            onChangeText={setNewGoalName}
          />
          <TextInput
            style={styles.input}
            placeholder="Target Amount ($)"
            value={newGoalAmount}
            onChangeText={setNewGoalAmount}
            keyboardType="numeric"
          />
          <View style={styles.formButtons}>
            <TouchableOpacity 
              style={[commonStyles.button, styles.cancelButton]} 
              onPress={() => {
                setShowAddForm(false);
                setNewGoalName('');
                setNewGoalAmount('');
              }}
            >
              <Text style={commonStyles.buttonText}>Cancel</Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={[commonStyles.button, styles.saveButton]} 
              onPress={handleAddGoal}
            >
              <Text style={commonStyles.buttonText}>Save Goal</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}
      
      {/* Goals List */}
      <FlatList
        data={savingsGoals}
        renderItem={renderSavingsGoalItem}
        keyExtractor={(item) => item.id}
        ListEmptyComponent={<Text style={styles.emptyText}>No savings goals found.</Text>}
        style={styles.listContainer}
      />
    </View>
  );
};

// Add specific styles for SavingsGoalsScreen
const styles = StyleSheet.create({
  centerContent: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    color: 'red',
    fontSize: 16,
    textAlign: 'center',
  },
  emptyText: {
    textAlign: 'center',
    marginTop: 20,
    fontSize: 16,
    color: '#6c757d',
  },
  addButton: {
    marginBottom: 20,
    backgroundColor: '#28a745', // Green color for add button
  },
  listContainer: {
    marginTop: 10,
  },
  goalItem: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: responsiveWidth(4), // Responsive padding
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 1.0,
    elevation: 1,
  },
  goalName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  goalDetails: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  goalAmount: {
    fontSize: 14,
    color: '#555',
  },
  goalDate: {
    fontSize: 12,
    color: '#6c757d',
  },
  progressBarContainer: {
    height: 10,
    backgroundColor: '#e9ecef',
    borderRadius: 5,
    overflow: 'hidden',
    marginBottom: 5,
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#17a2b8', // Teal color for progress
  },
  progressText: {
    fontSize: 12,
    color: '#6c757d',
    textAlign: 'right',
  },
  formContainer: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: responsiveWidth(4),
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
    elevation: 2,
  },
  formTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 15,
    color: '#333',
  },
  input: {
    height: 45,
    borderColor: 'gray',
    borderWidth: 1,
    borderRadius: 8,
    marginBottom: 15,
    paddingHorizontal: 10,
    backgroundColor: '#ffffff',
  },
  formButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  cancelButton: {
    flex: 1,
    marginRight: 10,
    backgroundColor: '#6c757d', // Gray color for cancel
  },
  saveButton: {
    flex: 1,
    backgroundColor: '#28a745', // Green color for save
  },
});

export default SavingsGoalsScreen;
