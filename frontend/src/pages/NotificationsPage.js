import React from 'react';
import Notification from '../components/Notifications';
import { Link } from 'react-router-dom';
import './NotificationsPage.css';

const NotificationsPage = () => {
  return (
    <div className="notifications-page">
      <div className="content-wrapper">
        <header className="header">
          <div className="logo">FinovaBank</div>
          <nav className="nav">
            <ul>
              <li><Link to="/account">Account</Link></li>
              <li><Link to="/loans">Loans</Link></li>
              <li><Link to="/transactions">Transactions</Link></li>
              <li><Link to="/savings">Savings Goals</Link></li>
              <li><Link to="/notifications" className="active">Notifications</Link></li>
              <li><Link to="/logout" className="logout-button">Logout</Link></li>
            </ul>
          </nav>
        </header>

        <main className="main-content">
          <h1>Notifications</h1>
          <Notification />
        </main>
      </div>

      <footer className="footer">
        <p>&copy; 2024 FinovaBank. All rights reserved.</p>
      </footer>
    </div>
  );
};

export default NotificationsPage;
