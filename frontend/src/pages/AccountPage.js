import React from 'react';
import AccountDetails from '../components/AccountDetails';
import { Link } from 'react-router-dom';
import './AccountPage.css';

const AccountPage = () => {
  return (
    <div className="account-page">
      <div className="content-wrapper">
        <header className="header">
          <div className="logo">FinovaBank</div>
          <nav className="nav">
            <ul>
              <li><Link to="/account" className="active">Account</Link></li>
              <li><Link to="/loans">Loans</Link></li>
              <li><Link to="/transactions">Transactions</Link></li>
              <li><Link to="/savings">Savings Goals</Link></li>
              <li><Link to="/notifications">Notifications</Link></li>
              <li><Link to="/logout" className="logout-button">Logout</Link></li>
            </ul>
          </nav>
        </header>

        <main className="main-content">
          <h1>Account Overview</h1>
          <AccountDetails />
        </main>
      </div>

      <footer className="footer">
        <p>&copy; 2024 FinovaBank. All rights reserved.</p>
      </footer>
    </div>
  );
};

export default AccountPage;
