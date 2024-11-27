import React, { useState, useEffect } from 'react';
import api from '../services/API';

const SavingsGoals = () => {
    const [goals, setGoals] = useState([]);

    useEffect(() => {
        const fetchGoals = async () => {
            try {
                const response = await api.get('/savings-goals');
                setGoals(response.data);
            } catch (error) {
                console.error("Error fetching savings goals:", error);
            }
        };
        fetchGoals();
    }, []);

    return (
        <div className="container">
            <h2>Savings Goals</h2>
            {goals.length > 0 ? (
                <ul>
                    {goals.map((goal) => (
                        <li key={goal.id}>
                            Goal: {goal.name}, Target: ${goal.targetAmount}, Progress: ${goal.progress}
                        </li>
                    ))}
                </ul>
            ) : (
                <p>No savings goals available.</p>
            )}
        </div>
    );
};

export default SavingsGoals;
