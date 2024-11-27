// src/services/API.js

import axios from 'axios';
import AuthService from './AuthService';
import { API_BASE_URL } from './Config'; // Adjust the import path as needed

const API = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add the auth token to headers
API.interceptors.request.use(
  (config) => {
    const user = AuthService.getCurrentUser();
    if (user && user.token) {
      config.headers['Authorization'] = 'Bearer ' + user.token;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle any response errors globally
API.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API call error:', error);

    // Handle 401 Unauthorized errors by logging out the user
    if (error.response && error.response.status === 401) {
      AuthService.logout();
      // Optionally, redirect to the login page
      window.location.href = '/login';
    }

    return Promise.reject(error);
  }
);

export default API;
