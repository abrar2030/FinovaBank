import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { commonStyles } from '../styles/commonStyles'; // Import common styles
import { registerUser } from '../services/api'; // Import API service
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation/AppNavigator';

type RegisterScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Register'>;

const RegisterScreen = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigation = useNavigation<RegisterScreenNavigationProp>();

  const handleRegister = async () => {
    if (!name || !email || !password) {
      Alert.alert('Error', 'Please fill in all fields.');
      return;
    }
    try {
      // TODO: Replace with actual API call and response handling
      // const response = await registerUser({ name, email, password });
      // console.log('Registration successful:', response.data);
      Alert.alert('Success', 'Registration successful (simulated)!');
      // Navigate to Login after successful registration
      navigation.navigate('Login');
    } catch (error: any) {
      console.error('Registration failed:', error);
      const errorMessage = error.response?.data?.error?.message || 'Registration failed. Please try again.';
      Alert.alert('Registration Failed', errorMessage);
    }
  };

  return (
    <View style={commonStyles.container}> // Use common container style
      <Text style={commonStyles.titleText}>Register for Finovabank</Text> // Use common title style
      <TextInput
        style={styles.input}
        placeholder="Full Name"
        value={name}
        onChangeText={setName}
      />
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
      <TouchableOpacity style={commonStyles.button} onPress={handleRegister}> // Use common button style
        <Text style={commonStyles.buttonText}>Register</Text> // Use common button text style
      </TouchableOpacity>
    </View>
  );
};

// Add specific styles for RegisterScreen if needed
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
});

export default RegisterScreen;
