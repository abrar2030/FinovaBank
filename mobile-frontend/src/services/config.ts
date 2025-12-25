/**
 * App Configuration
 * This file contains environment-specific configuration for the mobile app
 */

// Determine if we're in development or production
const __DEV__ =
  typeof __DEV__ !== 'undefined'
    ? __DEV__
    : process.env.NODE_ENV === 'development';

interface AppConfig {
  API_BASE_URL: string;
  API_TIMEOUT: number;
  ENABLE_LOGGING: boolean;
}

// Development configuration
const devConfig: AppConfig = {
  API_BASE_URL: 'http://localhost:8080/api/v1', // Local backend for development
  API_TIMEOUT: 30000,
  ENABLE_LOGGING: true,
};

// Production configuration
const prodConfig: AppConfig = {
  API_BASE_URL: 'https://api.finovabank.com/api/v1',
  API_TIMEOUT: 30000,
  ENABLE_LOGGING: false,
};

// Export the appropriate configuration based on environment
const Config: AppConfig = __DEV__ ? devConfig : prodConfig;

export default Config;
