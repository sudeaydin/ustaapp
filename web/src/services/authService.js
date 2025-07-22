import api, { setAuthToken, clearAuth } from './api';

class AuthService {
  // Login
  async login(email, password) {
    try {
      const response = await api.post('/auth/login', {
        email,
        password
      });
      
      if (response.success && response.access_token) {
        setAuthToken(response.access_token);
        localStorage.setItem('user', JSON.stringify(response.user));
        return response;
      }
      
      throw new Error(response.message || 'Giriş başarısız');
    } catch (error) {
      throw error;
    }
  }

  // Register
  async register(userData) {
    try {
      const response = await api.post('/auth/register', userData);
      
      if (response.success && response.access_token) {
        setAuthToken(response.access_token);
        localStorage.setItem('user', JSON.stringify(response.user));
        return response;
      }
      
      throw new Error(response.message || 'Kayıt başarısız');
    } catch (error) {
      throw error;
    }
  }

  // Logout
  async logout() {
    try {
      await api.post('/auth/logout');
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      clearAuth();
    }
  }

  // Get current user
  getCurrentUser() {
    try {
      const user = localStorage.getItem('user');
      return user ? JSON.parse(user) : null;
    } catch (error) {
      console.error('Error parsing user data:', error);
      return null;
    }
  }

  // Check if user is authenticated
  isAuthenticated() {
    const token = localStorage.getItem('authToken');
    const user = this.getCurrentUser();
    return !!(token && user);
  }

  // Refresh token
  async refreshToken() {
    try {
      const response = await api.post('/auth/refresh');
      
      if (response.success && response.access_token) {
        setAuthToken(response.access_token);
        return response.access_token;
      }
      
      throw new Error('Token refresh failed');
    } catch (error) {
      clearAuth();
      throw error;
    }
  }

  // Forgot password
  async forgotPassword(email) {
    try {
      const response = await api.post('/auth/forgot-password', { email });
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Reset password
  async resetPassword(token, newPassword) {
    try {
      const response = await api.post('/auth/reset-password', {
        token,
        password: newPassword
      });
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Verify email
  async verifyEmail(token) {
    try {
      const response = await api.post('/auth/verify-email', { token });
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Change password
  async changePassword(oldPassword, newPassword) {
    try {
      const response = await api.post('/auth/change-password', {
        old_password: oldPassword,
        new_password: newPassword
      });
      return response;
    } catch (error) {
      throw error;
    }
  }
}

export default new AuthService();
