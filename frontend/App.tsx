import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { Box } from '@mui/material';
import Dashboard from './src/pages/Dashboard';
import Login from './src/pages/Login';
import Register from './src/pages/Register';
import AccountDetails from './src/pages/AccountDetails';
import Transactions from './src/pages/Transactions';
import Loans from './src/pages/Loans';
import SavingsGoals from './src/pages/SavingsGoals';
import Layout from './src/components/Layout';
import ProtectedRoute from './src/components/ProtectedRoute';
import { AuthProvider } from './src/context/AuthContext';
import NotFound from './src/pages/NotFound';

function App() {
  return (
    <AuthProvider>
      <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
        <Routes>
          {/* Public routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          
          {/* Protected routes */}
          <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
            <Route index element={<Dashboard />} />
            <Route path="accounts">
              <Route path=":accountId" element={<AccountDetails />} />
            </Route>
            <Route path="transactions" element={<Transactions />} />
            <Route path="loans" element={<Loans />} />
            <Route path="savings" element={<SavingsGoals />} />
            
            {/* Catch-all route for 404 */}
            <Route path="404" element={<NotFound />} />
            <Route path="*" element={<Navigate to="/404" replace />} />
          </Route>
        </Routes>
      </Box>
    </AuthProvider>
  );
}

export default App;
