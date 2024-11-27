import React from 'react';
import LoanDetails from '../components/LoanDetails';
import { Link } from 'react-router-dom';
import './LoanPage.css';

const LoanPage = () => {
  return (
    <div className="loan-page">
      <div className="content-wrapper">
        <header className="header">
          <div className="logo">FinovaBank</div>
          <nav className="nav">
            <ul>
              <li><Link to="/account">Account</Link></li>
              <li><Link to="/loans" className="active">Loans</Link></li>
              <li><Link to="/transactions">Transactions</Link></li>
              <li><Link to="/savings">Savings Goals</Link></li>
              <li><Link to="/notifications">Notifications</Link></li>
              <li><Link to="/logout" className="logout-button">Logout</Link></li>
            </ul>
          </nav>
        </header>

        <main className="main-content">
          <h1>Loan Information</h1>
          <LoanDetails />
        </main>
      </div>

      <footer className="footer">
        <p>&copy; 2024 FinovaBank. All rights reserved.</p>
      </footer>
    </div>
  );
};

export default LoanPage;
