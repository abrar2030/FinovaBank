import React, { createContext, useState, useContext, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage'; // Assuming AsyncStorage is installed or needs to be
import { loginUser, registerUser } from '../services/api'; // Import actual API functions

// Define the shape of the auth context data
interface AuthContextData {
  userToken: string | null;
  isLoading: boolean;
  login: (credentials: any) => Promise<void>; // Adjust 'any' based on login credentials type
  logout: () => Promise<void>;
  register: (userData: any) => Promise<void>; // Adjust 'any' based on registration data type
}

// Create the context with a default value
const AuthContext = createContext<AuthContextData>({} as AuthContextData);

// Define the props for the AuthProvider
interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [userToken, setUserToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Check for stored token on app start
  useEffect(() => {
    const bootstrapAsync = async () => {
      let token: string | null = null;
      try {
        // TODO: Replace 'userToken' with your actual storage key
        token = await AsyncStorage.getItem('userToken');
      } catch (e) {
        // Restoring token failed
        console.error('Restoring token failed', e);
      }
      setUserToken(token);
      setIsLoading(false);
    };

    bootstrapAsync();
  }, []);

  const authContextValue = {
    userToken,
    isLoading,
    login: async (credentials: any) => {
      setIsLoading(true);
      try {
        // Replace with actual API call
        // const response = await loginUser(credentials);
        // const token = response.data.token; // Assuming API returns a token
        const token = 'dummy-auth-token'; // Simulate successful login
        await AsyncStorage.setItem('userToken', token);
        setUserToken(token);
      } catch (error) {
        console.error('Login failed:', error);
        // Rethrow or handle error appropriately (e.g., show message)
        throw error;
      } finally {
        setIsLoading(false);
      }
    },
    logout: async () => {
      setIsLoading(true);
      try {
        await AsyncStorage.removeItem('userToken');
        setUserToken(null);
      } catch (error) {
        console.error('Logout failed:', error);
        throw error;
      } finally {
        setIsLoading(false);
      }
    },
    register: async (userData: any) => {
      setIsLoading(true);
      try {
        // Replace with actual API call
        // await registerUser(userData);
        // Optionally log the user in automatically after registration
        // For now, just simulate success
        console.log('Registration successful (simulated)');
      } catch (error) {
        console.error('Registration failed:', error);
        throw error;
      } finally {
        setIsLoading(false);
      }
    },
  };

  return (
    <AuthContext.Provider value={authContextValue}>
      {children}
    </AuthContext.Provider>
  );
};

// Custom hook to use the auth context
export const useAuth = () => {
  return useContext(AuthContext);
};

