import api from './api';

class CraftsmanService {
  // Get craftsman profile
  async getProfile() {
    try {
      const response = await api.get('/craftsman/profile');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Update craftsman profile
  async updateProfile(profileData) {
    try {
      const response = await api.put('/craftsman/profile', profileData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get craftsman services
  async getServices() {
    try {
      const response = await api.get('/craftsman/services');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Add new service
  async addService(serviceData) {
    try {
      const response = await api.post('/craftsman/services', serviceData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get craftsman quotes
  async getQuotes(params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/craftsman/quotes?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Respond to quote
  async respondToQuote(quoteId, responseData) {
    try {
      const response = await api.post(`/craftsman/quotes/${quoteId}/respond`, responseData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get craftsman reviews
  async getReviews(params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/craftsman/reviews?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get craftsman statistics
  async getStatistics() {
    try {
      const response = await api.get('/craftsman/statistics');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get availability
  async getAvailability() {
    try {
      const response = await api.get('/craftsman/availability');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Update availability
  async updateAvailability(availabilityData) {
    try {
      const response = await api.put('/craftsman/availability', availabilityData);
      return response;
    } catch (error) {
      throw error;
    }
  }
}

export default new CraftsmanService();
