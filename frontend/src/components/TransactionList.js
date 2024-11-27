import React, { useState, useEffect } from 'react';
import api from '../services/API';

const TransactionList = () => {
    const [transactions, setTransactions] = useState([]);

    useEffect(() => {
        const fetchTransactions = async () => {
            try {
                const response = await api.get('/transactions');
                setTransactions(response.data);
            } catch (error) {
                console.error("Error fetching transactions:", error);
            }
        };
        fetchTransactions();
    }, []);

    return (
        <div className="container">
            <h2>Transactions</h2>
            {transactions.length > 0 ? (
                <ul>
                    {transactions.map((transaction) => (
                        <li key={transaction.id}>
                            {transaction.date}: ${transaction.amount} - {transaction.type}
                        </li>
                    ))}
                </ul>
            ) : (
                <p>No transactions available.</p>
            )}
        </div>
    );
};

export default TransactionList;
