import React from 'react';
import TransactionList from '../components/TransactionList';

const TransactionPage = () => {
    return (
        <div className="container">
            <h1>Transactions</h1>
            <TransactionList />
        </div>
    );
};

export default TransactionPage;
