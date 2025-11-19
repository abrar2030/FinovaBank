import axios from 'axios';

// Type definitions
interface User {
  id: number;
  name: string;
  email: string;
  role: 'USER' | 'ADMIN';
  createdAt: string;
}

interface Account {
  id: string;
  type: string;
  balance: number;
  currency: string;
  createdAt: string;
}

interface Transaction {
  id: string;
  type: 'DEPOSIT' | 'WITHDRAWAL' | 'TRANSFER';
  amount: number;
  description: string;
  date: string;
  accountId: string;
}

interface Loan {
  id: string;
  amount: number;
  interestRate: number;
  term: number;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'PAID';
  createdAt: string;
}

interface SavingsGoal {
  id: number;
  name: string;
  targetAmount: number;
  currentAmount: number;
  targetDate: string;
  createdAt: string;
}

interface CreateAccountData {
  type: string;
  currency: string;
}

interface CreateTransactionData {
  type: 'DEPOSIT' | 'WITHDRAWAL' | 'TRANSFER';
  amount: number;
  description: string;
  accountId: string;
}

interface CreateLoanData {
  amount: number;
  term: number;
}

interface CreateSavingsGoalData {
  name: string;
  targetAmount: number;
  targetDate: string;
}

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
    const token = sessionStorage.getItem('token');
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
      sessionStorage.removeItem('token');
      sessionStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Account API
export const accountAPI = {
  getAccounts: () =>
    api.get<Account[]>('/accounts'),

  getAccountDetails: (accountId: string) =>
    api.get<Account>(`/accounts/${accountId}`),

  createAccount: (data: CreateAccountData) =>
    api.post<Account>('/accounts', data),
};

// Transaction API
export const transactionAPI = {
  getTransactions: (params?: { accountId?: string; startDate?: string; endDate?: string }) =>
    api.get<Transaction[]>('/transactions', { params }),

  createTransaction: (data: CreateTransactionData) =>
    api.post<Transaction>('/transactions', data),
};

// Auth API
export const authAPI = {
  login: (email: string, password: string) =>
    api.post<{ token: string; user: User }>('/auth/login', { email, password }),

  register: (name: string, email: string, password: string) =>
    api.post<{ token: string; user: User }>('/auth/register', { name, email, password }),

  verifyToken: (token: string) =>
    api.post<{ valid: boolean }>('/auth/verify', { token }),
};

// Loan API
export const loanAPI = {
  getLoans: () =>
    api.get<Loan[]>('/loans'),

  getLoanDetails: (loanId: string) =>
    api.get<Loan>(`/loans/${loanId}`),

  applyForLoan: (data: CreateLoanData) =>
    api.post<Loan>('/loans', data),
};

// Savings API
export const savingsAPI = {
  getSavingsGoals: () =>
    api.get<SavingsGoal[]>('/savings'),

  getSavingsGoalDetails: (goalId: string) =>
    api.get<SavingsGoal>(`/savings/${goalId}`),

  createSavingsGoal: (data: CreateSavingsGoalData) =>
    api.post<SavingsGoal>('/savings', data),

  updateSavingsGoal: (goalId: number, data: Partial<CreateSavingsGoalData>) =>
    api.put<SavingsGoal>(`/savings/${goalId}`, data),

  deleteSavingsGoal: (goalId: number) =>
    api.delete<void>(`/savings/${goalId}`),
};

export default api;
