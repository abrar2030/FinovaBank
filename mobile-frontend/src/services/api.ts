import axios from 'axios';

// TODO: Replace with the actual base URL of the deployed backend
const API_BASE_URL = 'http://localhost:8080/api/v1'; // Placeholder

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add a request interceptor to include auth tokens if needed (example)
// apiClient.interceptors.request.use(config => {
//   const token = /* Get token from storage or context */;
//   if (token) {
//     config.headers.Authorization = `Bearer ${token}`;
//   }
//   return config;
// });

// --- Account Management Service ---
export const createAccount = (data: any) => apiClient.post('/accounts', data);
export const getAccountDetails = (accountId: string) => apiClient.get(`/accounts/${accountId}`);

// --- Transaction Service ---
export const createTransaction = (data: any) => apiClient.post('/transactions', data);
export const getTransactionDetails = (transactionId: string) => apiClient.get(`/transactions/${transactionId}`);
// TODO: Add endpoint for fetching transactions for an account (likely needed for TransactionsScreen)
// export const getAccountTransactions = (accountId: string) => apiClient.get(`/accounts/${accountId}/transactions`);

// --- Loan Management Service ---
export const applyForLoan = (data: any) => apiClient.post('/loans', data);
export const getLoanDetails = (loanId: string) => apiClient.get(`/loans/${loanId}`);
// TODO: Add endpoint for fetching loans for an account (likely needed for LoansScreen)
// export const getAccountLoans = (accountId: string) => apiClient.get(`/accounts/${accountId}/loans`);

// --- Savings Goals Service ---
export const createSavingsGoal = (data: any) => apiClient.post('/savings', data);
// TODO: Add endpoint for fetching savings goals for an account (likely needed for SavingsGoalsScreen)
// export const getAccountSavingsGoals = (accountId: string) => apiClient.get(`/accounts/${accountId}/savings`);

// --- Authentication (Placeholder) ---
// Assuming auth endpoints exist, e.g., /auth/login, /auth/register
export const loginUser = (credentials: any) => apiClient.post('/auth/login', credentials);
export const registerUser = (userData: any) => apiClient.post('/auth/register', userData);

export default apiClient;

