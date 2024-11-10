import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import HomePage from './pages/HomePage';
import AccountPage from './pages/AccountPage';
import TransactionPage from './pages/TransactionPage';
import LoanPage from './pages/LoanPage';
import SavingsPage from './pages/SavingsPage';
import NotificationsPage from './pages/NotificationsPage';
import './App.css';

function App() {
    return (
        <Router>
            <div className="app">
                <header className="header">
                    <h1>FinovaBank</h1>
                </header>
                <main className="main-content">
                    <Switch>
                        <Route exact path="/" component={HomePage} />
                        <Route path="/account" component={AccountPage} />
                        <Route path="/transactions" component={TransactionPage} />
                        <Route path="/loans" component={LoanPage} />
                        <Route path="/savings" component={SavingsPage} />
                        <Route path="/notifications" component={NotificationsPage} />
                    </Switch>
                </main>
            </div>
        </Router>
    );
}

export default App;