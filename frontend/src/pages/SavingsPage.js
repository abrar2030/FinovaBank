import React from 'react';
import SavingsGoals from '../components/SavingsGoals';
import { Link } from 'react-router-dom';
import './SavingsPage.css';

const SavingsPage = () => {
  return (
    <div className="savings-page">
      <div className="content-wrapper">
        <header className="header">
          <div className="logo">FinovaBank</div>
          <nav className="nav">
            <ul>
              <li><Link to="/account">Account</Link></li>
              <li><Link to="/loans">Loans</Link></li>
              <li><Link to="/transactions">Transactions</Link></li>
              <li><Link to="/savings" className="active">Savings Goals</Link></li>
              <li><Link to="/notifications">Notifications</Link></li>
              <li><Link to="/logout" className="logout-button">Logout</Link></li>
            </ul>
          </nav>
        </header>

        <main className="main-content">
          <h1>Savings Goals</h1>
          <SavingsGoals />
        </main>
      </div>

      <footer className="footer">
        <p>&copy; 2024 FinovaBank. All rights reserved.</p>
      </footer>
    </div>
  );
};

export default SavingsPage;
