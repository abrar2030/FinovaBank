import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { commonStyles, responsiveWidth } from '../styles/commonStyles'; // Import common styles
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation/AppNavigator';

// Define the navigation prop type for this screen
type DashboardScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Dashboard'>;

const DashboardScreen = () => {
  const navigation = useNavigation<DashboardScreenNavigationProp>();

  // Placeholder data - replace with actual data fetched from API
  const accountSummary = {
    balance: 5420.50,
    accountNumber: '**** **** **** 1234',
  };

  const quickActions = [
    { label: 'View Transactions', screen: 'Transactions' as keyof RootStackParamList },
    { label: 'Apply for Loan', screen: 'Loans' as keyof RootStackParamList },
    { label: 'Manage Savings', screen: 'SavingsGoals' as keyof RootStackParamList },
    { label: 'Account Details', screen: 'AccountDetails' as keyof RootStackParamList, params: { accountId: '1' } }, // Example accountId
  ];

  return (
    <ScrollView style={commonStyles.container}> // Use ScrollView for potentially long content
      <Text style={commonStyles.titleText}>Welcome Back!</Text>

      {/* Account Summary Section */}
      <View style={styles.sectionContainer}>
        <Text style={styles.sectionTitle}>Account Summary</Text>
        <Text style={styles.balanceText}>Balance: ${accountSummary.balance.toFixed(2)}</Text>
        <Text style={styles.accountNumberText}>Account: {accountSummary.accountNumber}</Text>
      </View>

      {/* Quick Actions Section */}
      <View style={styles.sectionContainer}>
        <Text style={styles.sectionTitle}>Quick Actions</Text>
        {quickActions.map((action, index) => (
          <TouchableOpacity
            key={index}
            style={[commonStyles.button, styles.actionButton]} // Use common button style
            onPress={() => navigation.navigate(action.screen, action.params as any)} // Navigate to the respective screen
          >
            <Text style={commonStyles.buttonText}>{action.label}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Add more sections as needed, e.g., Recent Transactions, Notifications */}

    </ScrollView>
  );
};

// Add specific styles for DashboardScreen
const styles = StyleSheet.create({
  sectionContainer: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: responsiveWidth(4), // Responsive padding
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#333',
  },
  balanceText: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#28a745', // Green color for balance
    marginBottom: 5,
  },
  accountNumberText: {
    fontSize: 14,
    color: '#6c757d',
  },
  actionButton: {
    backgroundColor: '#17a2b8', // Different color for action buttons
    marginBottom: 10, // Add margin between buttons
  },
});

export default DashboardScreen;
