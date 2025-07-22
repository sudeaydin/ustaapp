import axios from 'axios';

// Base API configuration
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
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

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    return response.data;
  },
  (error) => {
    // Handle different error types
    if (error.response) {
      // Server responded with error status
      const { status, data } = error.response;
      
      if (status === 401) {
        // Unauthorized - clear token and redirect to login
        localStorage.removeItem('authToken');
        localStorage.removeItem('user');
        window.location.href = '/login';
      }
      
      // Return error message from server
      return Promise.reject({
        message: data.error || data.message || 'Bir hata oluştu',
        status,
        data
      });
    } else if (error.request) {
      // Network error
      return Promise.reject({
        message: 'Sunucuya bağlanılamıyor. İnternet bağlantınızı kontrol edin.',
        status: 0
      });
    } else {
      // Other error
      return Promise.reject({
        message: error.message || 'Beklenmeyen bir hata oluştu',
        status: 0
      });
    }
  }
);

export default api;

// Helper functions
export const setAuthToken = (token) => {
  if (token) {
    localStorage.setItem('authToken', token);
    api.defaults.headers.Authorization = `Bearer ${token}`;
  } else {
    localStorage.removeItem('authToken');
    delete api.defaults.headers.Authorization;
  }
};

export const getAuthToken = () => {
  return localStorage.getItem('authToken');
};

export const clearAuth = () => {
  localStorage.removeItem('authToken');
  localStorage.removeItem('user');
  delete api.defaults.headers.Authorization;
};
