import React from 'react';
import { Link } from 'react-router-dom';
import './HomePage.css';

const HomePage = () => {
  return (
    <div className="homepage">
      <div className="content-wrapper">
        <header className="header">
          <div className="logo">FinovaBank</div>
          <nav className="nav">
            <ul>
              <li><Link to="/account">Account</Link></li>
              <li><Link to="/loans">Loans</Link></li>
              <li><Link to="/transactions">Transactions</Link></li>
              <li><Link to="/savings">Savings Goals</Link></li>
              <li><Link to="/notifications">Notifications</Link></li>
              <li><Link to="/login" className="login-button">Login</Link></li>
              <li><Link to="/register" className="register-button">Register</Link></li>
            </ul>
          </nav>
        </header>

        <section className="hero">
          <div className="hero-content">
            <h1>Welcome to FinovaBank</h1>
            <p>Your digital banking solution for managing accounts, loans, transactions, and more.</p>
            <Link to="/register" className="cta-button">Get Started</Link>
          </div>
        </section>

        <section className="features">
          <div className="feature">
            <h2>Secure Banking</h2>
            <p>Experience top-notch security with our advanced encryption.</p>
          </div>
          <div className="feature">
            <h2>Easy Loans</h2>
            <p>Get quick and easy loans tailored to your needs.</p>
          </div>
          <div className="feature">
            <h2>Smart Savings</h2>
            <p>Set and track your savings goals effortlessly.</p>
          </div>
        </section>
      </div>

      <footer className="footer">
        <p>&copy; 2024 FinovaBank. All rights reserved.</p>
      </footer>
    </div>
  );
};

export default HomePage;
