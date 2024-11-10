import React, { useState, useEffect } from 'react';
import api from '../services/api';

const AccountDetails = () => {
    const [account, setAccount] = useState(null);

    useEffect(() => {
        const fetchAccount = async () => {
            try {
                const response = await api.get('/account');
                setAccount(response.data);
            } catch (error) {
                console.error("Error fetching account details:", error);
            }
        };
        fetchAccount();
    }, []);

    return (
        <div className="container">
            <h2>Account Details</h2>
            {account ? (
                <div>
                    <p><strong>Account Number:</strong> {account.number}</p>
                    <p><strong>Balance:</strong> ${account.balance}</p>
                    <p><strong>Account Holder:</strong> {account.holder}</p>
                </div>
            ) : (
                <p>Loading account details...</p>
            )}
        </div>
    );
};

export default AccountDetails;