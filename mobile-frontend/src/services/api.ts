import axios from 'axios';

const API_BASE_URL = 'https://api.finovabank.com/api/v1'; // Production URL

// Create a configurable API client
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 seconds timeout
});

// Add a request interceptor to include auth tokens
apiClient.interceptors.request.use(config => {
  const token = localStorage.getItem('userToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
}, error => {
  return Promise.reject(error);
});

// Add a response interceptor to handle common errors
apiClient.interceptors.response.use(
  response => response,
  error => {
    // Handle specific error cases
    if (error.response) {
      // Server responded with a status code outside of 2xx range
      if (error.response.status === 401) {
        // Unauthorized - clear token and redirect to login
        localStorage.removeItem('userToken');
        // Navigation would be handled by the component
      }
    }
    return Promise.reject(error);
  }
);

// --- Account Management Service ---
export const createAccount = (data: any) => apiClient.post('/accounts', data);
export const getAccountDetails = (accountId: string) => apiClient.get(`/accounts/${accountId}`);
export const updateAccountDetails = (accountId: string, data: any) => apiClient.put(`/accounts/${accountId}`, data);
export const getUserAccounts = () => apiClient.get('/accounts');

// --- Transaction Service ---
export const createTransaction = (data: any) => apiClient.post('/transactions', data);
export const getTransactionDetails = (transactionId: string) => apiClient.get(`/transactions/${transactionId}`);
export const getAccountTransactions = (accountId: string, params?: { 
  startDate?: string, 
  endDate?: string, 
  type?: string,
  limit?: number,
  offset?: number
}) => apiClient.get(`/accounts/${accountId}/transactions`, { params });

// --- Loan Management Service ---
export const applyForLoan = (data: any) => apiClient.post('/loans', data);
export const getLoanDetails = (loanId: string) => apiClient.get(`/loans/${loanId}`);
export const getAccountLoans = (accountId: string) => apiClient.get(`/accounts/${accountId}/loans`);
export const getLoanTypes = () => apiClient.get('/loans/types');
export const calculateLoanPayment = (data: { amount: number, term: number, rate: number }) => 
  apiClient.post('/loans/calculate', data);

// --- Savings Goals Service ---
export const createSavingsGoal = (data: any) => apiClient.post('/savings', data);
export const getAccountSavingsGoals = (accountId: string) => apiClient.get(`/accounts/${accountId}/savings`);
export const updateSavingsGoal = (goalId: string, data: any) => apiClient.put(`/savings/${goalId}`, data);
export const deleteSavingsGoal = (goalId: string) => apiClient.delete(`/savings/${goalId}`);
export const contributeTosavingsGoal = (goalId: string, data: { amount: number }) => 
  apiClient.post(`/savings/${goalId}/contribute`, data);

// --- Authentication ---
export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  confirmPassword: string;
}

export interface AuthResponse {
  token: string;
  user: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
  }
}

export const loginUser = (credentials: LoginCredentials) => 
  apiClient.post<AuthResponse>('/auth/login', credentials);

export const registerUser = (userData: RegisterData) => 
  apiClient.post<AuthResponse>('/auth/register', userData);

export const logoutUser = () => apiClient.post('/auth/logout');
export const resetPassword = (email: string) => apiClient.post('/auth/reset-password', { email });
export const verifyEmail = (token: string) => apiClient.post(`/auth/verify-email/${token}`);

// --- User Profile ---
export const getUserProfile = () => apiClient.get('/users/profile');
export const updateUserProfile = (data: any) => apiClient.put('/users/profile', data);
export const changePassword = (data: { currentPassword: string, newPassword: string }) => 
  apiClient.post('/users/change-password', data);

export default apiClient;
