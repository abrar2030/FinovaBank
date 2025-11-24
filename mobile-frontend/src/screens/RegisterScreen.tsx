import React, {useState} from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
} from 'react-native';
import {commonStyles, colors} from '../styles/commonStyles';
import {useNavigation} from '@react-navigation/native';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {RootStackParamList} from '../navigation/AppNavigator';
import {useAuth} from '../context/AuthContext';

type RegisterScreenNavigationProp = NativeStackNavigationProp<
  RootStackParamList,
  'Register'
>;

const RegisterScreen = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const {register, isLoading} = useAuth();
  const navigation = useNavigation<RegisterScreenNavigationProp>();

  const handleRegister = async () => {
    setError('');

    if (!name || !email || !password) {
      setError('Please fill in all fields.');
      return;
    }

    // Basic email validation (fixed regex)
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setError('Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      setError('Password must be at least 6 characters long.');
      return;
    }

    try {
      await register({name, email, password});
      Alert.alert('Success', 'Registration successful! Please log in.');
      navigation.navigate('Login');
    } catch (apiError: any) {
      console.error('Registration failed:', apiError);
      const errorMessage =
        apiError.response?.data?.error?.message ||
        apiError.message ||
        'Registration failed. Please try again.';
      setError(errorMessage);
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={commonStyles.container}>
      <View style={styles.innerContainer}>
        <Text style={commonStyles.titleText}>Create Account</Text>
        <Text style={commonStyles.subtitleText}>Join FinovaBank today!</Text>

        {error ? <Text style={commonStyles.errorText}>{error}</Text> : null}

        <TextInput
          style={commonStyles.input}
          placeholder="Full Name"
          value={name}
          onChangeText={setName}
          placeholderTextColor={colors.textSecondary}
          editable={!isLoading}
        />
        <TextInput
          style={commonStyles.input}
          placeholder="Email"
          value={email}
          onChangeText={setEmail}
          keyboardType="email-address"
          autoCapitalize="none"
          placeholderTextColor={colors.textSecondary}
          editable={!isLoading}
        />
        <TextInput
          style={commonStyles.input}
          placeholder="Password (min. 6 characters)"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          placeholderTextColor={colors.textSecondary}
          editable={!isLoading}
        />

        <TouchableOpacity
          style={[commonStyles.button, isLoading && styles.buttonDisabled]}
          onPress={handleRegister}
          disabled={isLoading}>
          {isLoading ? (
            <ActivityIndicator color={colors.background} />
          ) : (
            <Text style={commonStyles.buttonText}>Register</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity
          style={[
            commonStyles.button,
            commonStyles.buttonSecondary,
            styles.loginButton,
            isLoading && styles.buttonDisabled,
          ]}
          onPress={() => navigation.navigate('Login')}
          disabled={isLoading}>
          <Text
            style={[commonStyles.buttonText, commonStyles.buttonTextSecondary]}>
            Already have an account? Login
          </Text>
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  innerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
  },
  loginButton: {
    marginTop: 10,
    borderWidth: 0,
    backgroundColor: 'transparent',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
});

export default RegisterScreen;
