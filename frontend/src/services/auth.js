import api from './api';

export const login = async (username, password) => {
    try {
        const response = await api.post('/auth/login', { username, password });
        localStorage.setItem('token', response.data.token);
        return response.data;
    } catch (error) {
        console.error("Login failed:", error);
        throw error;
    }
};

export const logout = () => {
    localStorage.removeItem('token');
};

export const isAuthenticated = () => {
    return !!localStorage.getItem('token');
};
