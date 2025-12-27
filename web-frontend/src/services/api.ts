import axios from "axios";

// Type definitions
interface User {
  id: number;
  name: string;
  email: string;
  role: "USER" | "ADMIN";
  createdAt: string;
}

interface Account {
  accountId: string;
  type: string;
  accountType: string;
  balance: number;
  currency: string;
  createdAt: string;
  name?: string;
  email?: string;
  createdDate?: string;
}

interface Transaction {
  transactionId: string;
  type: "DEPOSIT" | "WITHDRAWAL" | "TRANSFER";
  transactionType: "CREDIT" | "DEBIT";
  amount: number;
  description: string;
  date: string;
  accountId: string;
  category?: string;
  status?: string;
}

interface Loan {
  id: number;
  loanAmount: number;
  loanType: string;
  interestRate: number;
  durationInMonths: number;
  monthlyPayment: number;
  remainingAmount: number;
  status: "PENDING" | "APPROVED" | "REJECTED" | "PAID";
  approvalDate: string;
  nextPaymentDate: string;
}

interface SavingsGoal {
  id: number;
  goalId?: number;
  name: string;
  goalName: string;
  targetAmount: number;
  currentAmount: number;
  targetDate: string;
  createdAt: string;
  createdDate?: string;
  progress?: number;
  category?: string;
}

interface CreateAccountData {
  type: string;
  currency: string;
}

interface CreateTransactionData {
  type: "DEPOSIT" | "WITHDRAWAL" | "TRANSFER";
  amount: number;
  description: string;
  accountId: string;
}

interface CreateLoanData {
  loanAmount: number;
  loanType: string;
  durationInMonths: number;
}

interface CreateSavingsGoalData {
  goalName: string;
  targetAmount: number;
  targetDate: string;
}

// Create axios instance
const api = axios.create({
  baseURL: process.env.REACT_APP_API_BASE_URL || "http://localhost:8080/api",
  headers: {
    "Content-Type": "application/json",
  },
});

// Request interceptor for adding auth token
api.interceptors.request.use(
  (config) => {
    const token = sessionStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  },
);

// Response interceptor for handling errors
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response && error.response.status === 401) {
      // Handle unauthorized access
      sessionStorage.removeItem("token");
      sessionStorage.removeItem("user");
      window.location.href = "/login";
    }
    return Promise.reject(error);
  },
);

// Account API
export const accountAPI = {
  getAccounts: () => api.get<Account[]>("/accounts"),

  getAccountDetails: (accountId: string | undefined) =>
    api.get<Account>(`/accounts/${accountId}`),

  createAccount: (data: CreateAccountData) =>
    api.post<Account>("/accounts", data),
};

// Transaction API
export const transactionAPI = {
  getTransactions: (params?: {
    accountId?: string;
    startDate?: string;
    endDate?: string;
    limit?: number;
  }) => api.get<Transaction[]>("/transactions", { params }),

  createTransaction: (data: CreateTransactionData) =>
    api.post<Transaction>("/transactions", data),
};

// Auth API
export const authAPI = {
  login: (email: string, password: string) =>
    api.post<{ token: string; user: User }>("/auth/login", { email, password }),

  register: (name: string, email: string, password: string) =>
    api.post<{ token: string; user: User }>("/auth/register", {
      name,
      email,
      password,
    }),

  verifyToken: (token: string) =>
    api.post<{ valid: boolean }>("/auth/verify", { token }),
};

// Loan API
export const loanAPI = {
  getLoans: () => api.get<Loan[]>("/loans"),

  getLoanDetails: (loanId: string) => api.get<Loan>(`/loans/${loanId}`),

  applyForLoan: (data: CreateLoanData) => api.post<Loan>("/loans", data),
};

// Savings API
export const savingsAPI = {
  getSavingsGoals: () => api.get<SavingsGoal[]>("/savings"),

  getSavingsGoalDetails: (goalId: string) =>
    api.get<SavingsGoal>(`/savings/${goalId}`),

  createSavingsGoal: (data: CreateSavingsGoalData) =>
    api.post<SavingsGoal>("/savings", data),

  updateSavingsGoal: (goalId: number, data: Partial<CreateSavingsGoalData>) =>
    api.put<SavingsGoal>(`/savings/${goalId}`, data),

  deleteSavingsGoal: (goalId: number) => api.delete<void>(`/savings/${goalId}`),
};

export default api;
