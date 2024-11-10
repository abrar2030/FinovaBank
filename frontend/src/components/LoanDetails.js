import React, { useState, useEffect } from 'react';
import api from '../services/api';

const LoanDetails = () => {
    const [loans, setLoans] = useState([]);

    useEffect(() => {
        const fetchLoans = async () => {
            try {
                const response = await api.get('/loans');
                setLoans(response.data);
            } catch (error) {
                console.error("Error fetching loan details:", error);
            }
        };
        fetchLoans();
    }, []);

    return (
        <div className="container">
            <h2>Loan Details</h2>
            {loans.length > 0 ? (
                <ul>
                    {loans.map((loan) => (
                        <li key={loan.id}>
                            Amount: ${loan.amount}, Status: {loan.status}, Due: {loan.dueDate}
                        </li>
                    ))}
                </ul>
            ) : (
                <p>No loan details available.</p>
            )}
        </div>
    );
};

export default LoanDetails;
