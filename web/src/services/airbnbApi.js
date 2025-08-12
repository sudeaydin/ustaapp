import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api/airbnb';

// Axios instance with auth token
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
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
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired, redirect to login
      localStorage.removeItem('access_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Categories API
export const categoriesApi = {
  getAll: () => api.get('/categories'),
};

// Craftsmen API
export const craftsmenApi = {
  getAll: (params = {}) => api.get('/craftsmen', { params }),
  getById: (id) => api.get(`/craftsmen/${id}`),
};

// Job Requests API
export const jobRequestsApi = {
  create: (data) => api.post('/job-requests', data),
  getMyRequests: (status) => api.get('/my-job-requests', { params: { status } }),
};

// Quotes API
export const quotesApi = {
  create: (data) => api.post('/quotes', data),
  getByJobId: (jobId) => api.get(`/jobs/${jobId}/quotes`),
  accept: (quoteId) => api.post(`/quotes/${quoteId}/accept`),
};

// Messages API
export const messagesApi = {
  send: (data) => api.post('/messages', data),
  getByPartnerId: (partnerId) => api.get(`/messages/${partnerId}`),
  getConversations: () => api.get('/conversations'),
};

// Notifications API
export const notificationsApi = {
  getAll: () => api.get('/notifications'),
  markAsRead: (notificationId) => api.post(`/notifications/${notificationId}/read`),
};

// Auth helper
export const authHelper = {
  isAuthenticated: () => {
    const token = localStorage.getItem('access_token');
    return !!token;
  },
  
  getToken: () => {
    return localStorage.getItem('access_token');
  },
  
  setToken: (token) => {
    localStorage.setItem('access_token', token);
  },
  
  removeToken: () => {
    localStorage.removeItem('access_token');
  },
  
  getUser: () => {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  },
  
  setUser: (user) => {
    localStorage.setItem('user', JSON.stringify(user));
  },
  
  removeUser: () => {
    localStorage.removeItem('user');
  },
};

// Error handler
export const handleApiError = (error) => {
  if (error.response) {
    // Server responded with error
    const message = error.response.data?.message || 'Bir hata oluştu';
    return { success: false, message };
  } else if (error.request) {
    // Network error
    return { success: false, message: 'Bağlantı hatası' };
  } else {
    // Other error
    return { success: false, message: error.message || 'Bilinmeyen hata' };
  }
};

// Success response wrapper
export const handleApiSuccess = (response) => {
  return {
    success: true,
    data: response.data?.data || response.data,
    message: response.data?.message || 'İşlem başarılı',
  };
};

export default api;