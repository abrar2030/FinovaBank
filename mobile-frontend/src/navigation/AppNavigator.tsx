import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import LoginScreen from '../screens/LoginScreen';
import RegisterScreen from '../screens/RegisterScreen';
import DashboardScreen from '../screens/DashboardScreen';
import AccountDetailsScreen from '../screens/AccountDetailsScreen';
import TransactionsScreen from '../screens/TransactionsScreen';
import LoansScreen from '../screens/LoansScreen';
import SavingsGoalsScreen from '../screens/SavingsGoalsScreen';

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
  // For now, assume user is not logged in and start with Login
  // Later, this initial route can be determined by auth state
  const initialRouteName: keyof RootStackParamList = 'Login';

  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName={initialRouteName}>
        <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
        <Stack.Screen name="Register" component={RegisterScreen} options={{ title: 'Register' }} />
        {/* Screens accessible after login */}
        <Stack.Screen name="Dashboard" component={DashboardScreen} options={{ title: 'Dashboard' }} />
        <Stack.Screen name="AccountDetails" component={AccountDetailsScreen} options={{ title: 'Account Details' }} />
        <Stack.Screen name="Transactions" component={TransactionsScreen} options={{ title: 'Transactions' }} />
        <Stack.Screen name="Loans" component={LoansScreen} options={{ title: 'Loans' }} />
        <Stack.Screen name="SavingsGoals" component={SavingsGoalsScreen} options={{ title: 'Savings Goals' }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
