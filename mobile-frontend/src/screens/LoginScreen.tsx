import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { commonStyles } from '../styles/commonStyles'; // Import common styles
import { loginUser } from '../services/api'; // Import API service
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation/AppNavigator';

type LoginScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Login'>;

const LoginScreen = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigation = useNavigation<LoginScreenNavigationProp>();

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please enter both email and password.');
      return;
    }
    try {
      // TODO: Replace with actual API call and response handling
      // const response = await loginUser({ email, password });
      // console.log('Login successful:', response.data);
      // Assume login is successful for now
      Alert.alert('Success', 'Login successful (simulated)!');
      // Navigate to Dashboard after successful login
      navigation.replace('Dashboard'); // Use replace to prevent going back to Login
    } catch (error: any) { // Specify 'any' or a more specific error type
      console.error('Login failed:', error);
      const errorMessage = error.response?.data?.error?.message || 'Login failed. Please try again.';
      Alert.alert('Login Failed', errorMessage);
    }
  };

  const navigateToRegister = () => {
    navigation.navigate('Register');
  };

  return (
    <View style={commonStyles.container}> // Use common container style
      <Text style={commonStyles.titleText}>Finovabank Login</Text> // Use common title style
      <TextInput
        style={styles.input}
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
      />
      <TextInput
        style={styles.input}
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      <TouchableOpacity style={commonStyles.button} onPress={handleLogin}> // Use common button style
        <Text style={commonStyles.buttonText}>Login</Text> // Use common button text style
      </TouchableOpacity>
      <TouchableOpacity style={[commonStyles.button, styles.registerButton]} onPress={navigateToRegister}> // Use common button style
        <Text style={commonStyles.buttonText}>Register</Text>
      </TouchableOpacity>
    </View>
  );
};

// Add specific styles for LoginScreen if needed
const styles = StyleSheet.create({
  input: {
    height: 45,
    borderColor: 'gray',
    borderWidth: 1,
    borderRadius: 8,
    marginBottom: 15,
    paddingHorizontal: 10,
    backgroundColor: '#ffffff',
    width: '90%', // Example responsive width
  },
  registerButton: {
    backgroundColor: '#6c757d', // Different color for register button
    marginTop: 10,
  },
});

export default LoginScreen;
