import api from './api';

class CustomerService {
  // Get customer profile
  async getProfile() {
    try {
      const response = await api.get('/customer/profile');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Update customer profile
  async updateProfile(profileData) {
    try {
      const response = await api.put('/customer/profile', profileData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get customer quotes
  async getQuotes(params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/customer/quotes?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Accept quote
  async acceptQuote(quoteId) {
    try {
      const response = await api.post(`/customer/quotes/${quoteId}/accept`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Reject quote
  async rejectQuote(quoteId, reason) {
    try {
      const response = await api.post(`/customer/quotes/${quoteId}/reject`, {
        reason
      });
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get customer reviews
  async getReviews(params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/customer/reviews?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Create review
  async createReview(reviewData) {
    try {
      const response = await api.post('/customer/reviews', reviewData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get favorites
  async getFavorites() {
    try {
      const response = await api.get('/customer/favorites');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get customer statistics
  async getStatistics() {
    try {
      const response = await api.get('/customer/statistics');
      return response;
    } catch (error) {
      throw error;
    }
  }
}

export default new CustomerService();
