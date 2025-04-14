import axios from 'axios';

// Create axios instance
const api = axios.create({
  baseURL: 'http://localhost:8080/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for adding auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for handling errors
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response && error.response.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Account API
export const accountAPI = {
  getAccounts: () => 
    api.get('/accounts'),
  
  getAccountDetails: (accountId: string | undefined) => 
    api.get(`/accounts/${accountId}`),
  
  createAccount: (data: any) => 
    api.post('/accounts', data),
};

// Transaction API
export const transactionAPI = {
  getTransactions: (params?: any) => 
    api.get('/transactions', { params }),
  
  createTransaction: (data: any) => 
    api.post('/transactions', data),
};

// Auth API
export const authAPI = {
  login: (email: string, password: string) => 
    api.post('/auth/login', { email, password }),
  
  register: (name: string, email: string, password: string) => 
    api.post('/auth/register', { name, email, password }),
};

// Loan API
export const loanAPI = {
  getLoans: () => 
    api.get('/loans'),
  
  getLoanDetails: (loanId: string) => 
    api.get(`/loans/${loanId}`),
  
  applyForLoan: (data: any) => 
    api.post('/loans', data),
};

// Savings API
export const savingsAPI = {
  getSavingsGoals: () => 
    api.get('/savings'),
  
  getSavingsGoalDetails: (goalId: string) => 
    api.get(`/savings/${goalId}`),
  
  createSavingsGoal: (data: any) => 
    api.post('/savings', data),
  
  updateSavingsGoal: (goalId: number, data: any) => 
    api.put(`/savings/${goalId}`, data),
  
  deleteSavingsGoal: (goalId: number) => 
    api.delete(`/savings/${goalId}`),
};

export default api;
