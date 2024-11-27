import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import HomePage from './pages/HomePage';
import AccountPage from './pages/AccountPage';
import TransactionPage from './pages/TransactionPage';
import LoanPage from './pages/LoanPage';
import SavingsPage from './pages/SavingsPage';
import NotificationsPage from './pages/NotificationsPage';
import Login from './components/Auth/Login';
import Register from './components/Auth/Register';
import './App.css';

function App() {
  return (
    <Router>
      <div className="app">
        {/* The header is included in individual pages for consistency */}
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/account" element={<AccountPage />} />
          <Route path="/transactions" element={<TransactionPage />} />
          <Route path="/loans" element={<LoanPage />} />
          <Route path="/savings" element={<SavingsPage />} />
          <Route path="/notifications" element={<NotificationsPage />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
        </Routes>
        {/* The footer is included in individual pages for consistency */}
      </div>
    </Router>
  );
}

export default App;
