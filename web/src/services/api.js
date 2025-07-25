import axios from 'axios';

// Base API configuration - Using Vite's import.meta.env instead of process.env
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

const api = axios.create({
    baseURL: API_BASE_URL,
    timeout: 10000,
    headers: {
        'Content-Type': 'application/json',
    },
});

api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('authToken');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

api.interceptors.response.use(
    (response) => {
        return response.data;
    },
    (error) => {
        if (error.response) {
            const { status, data } = error.response;
            if (status === 401) {
                localStorage.removeItem('authToken');
                localStorage.removeItem('user');
                window.location.href = '/login';
            }
            return Promise.reject({
                message: data.message || 'Bir hata oluştu',
                status,
                success: false
            });
        } else if (error.request) {
            return Promise.reject({
                message: 'Sunucu ile bağlantı kurulamadı',
                status: 0,
                success: false
            });
        } else {
            return Promise.reject({
                message: 'Beklenmeyen bir hata oluştu',
                status: 0,
                success: false
            });
        }
    }
);

export default api;