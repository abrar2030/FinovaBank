import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { ActivityIndicator, View } from 'react-native';

import LoginScreen from '../screens/LoginScreen';
import RegisterScreen from '../screens/RegisterScreen';
import DashboardScreen from '../screens/DashboardScreen';
import AccountDetailsScreen from '../screens/AccountDetailsScreen';
import TransactionsScreen from '../screens/TransactionsScreen';
import LoansScreen from '../screens/LoansScreen';
import SavingsGoalsScreen from '../screens/SavingsGoalsScreen';

import { useAuth } from '../context/AuthContext'; // Import useAuth hook
import { commonStyles, colors } from '../styles/commonStyles'; // Import common styles for loading indicator

// Define the type for the stack navigator parameters
export type RootStackParamList = {
  Login: undefined;
  Register: undefined;
  Dashboard: undefined;
  AccountDetails: { accountId: string }; // Example: Pass accountId as param
  Transactions: undefined;
  Loans: undefined;
  SavingsGoals: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

const AppNavigator = () => {
  const { userToken, isLoading } = useAuth(); // Get auth state and loading status

  if (isLoading) {
    // Show a loading screen while checking token
    return (
      <View style={[commonStyles.container, { justifyContent: 'center', alignItems: 'center' }]}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator>
        {userToken == null ? (
          // No token found, user isn't signed in
          <>
            <Stack.Screen
              name="Login"
              component={LoginScreen}
              options={{ headerShown: false }} // Hide header for Login
            />
            <Stack.Screen
              name="Register"
              component={RegisterScreen}
              options={{ title: 'Create Account', headerBackTitleVisible: false }} // Customize Register header
            />
          </>
        ) : (
          // User is signed in
          <>
            <Stack.Screen name="Dashboard" component={DashboardScreen} options={{ title: 'Dashboard' }} />
            <Stack.Screen name="AccountDetails" component={AccountDetailsScreen} options={{ title: 'Account Details' }} />
            <Stack.Screen name="Transactions" component={TransactionsScreen} options={{ title: 'Transactions' }} />
            <Stack.Screen name="Loans" component={LoansScreen} options={{ title: 'Loans' }} />
            <Stack.Screen name="SavingsGoals" component={SavingsGoalsScreen} options={{ title: 'Savings Goals' }} />
            {/* Add other authenticated screens here */}
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;

