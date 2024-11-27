import React from 'react';
import TransactionList from '../components/TransactionList';
import { Link } from 'react-router-dom';
import './TransactionPage.css';

const TransactionPage = () => {
  return (
    <div className="transaction-page">
      <div className="content-wrapper">
        <header className="header">
          <div className="logo">FinovaBank</div>
          <nav className="nav">
            <ul>
              <li><Link to="/account">Account</Link></li>
              <li><Link to="/loans">Loans</Link></li>
              <li><Link to="/transactions" className="active">Transactions</Link></li>
              <li><Link to="/savings">Savings Goals</Link></li>
              <li><Link to="/notifications">Notifications</Link></li>
              <li><Link to="/logout" className="logout-button">Logout</Link></li>
            </ul>
          </nav>
        </header>

        <main className="main-content">
          <h1>Transactions</h1>
          <TransactionList />
        </main>
      </div>

      <footer className="footer">
        <p>&copy; 2024 FinovaBank. All rights reserved.</p>
      </footer>
    </div>
  );
};

export default TransactionPage;
