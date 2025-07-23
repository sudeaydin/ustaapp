import api from './api';

class ServiceService {
  // Get all services with filtering
  async getServices(params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/services?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get service by ID
  async getServiceById(serviceId) {
    try {
      const response = await api.get(`/services/${serviceId}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Search services
  async searchServices(searchQuery, filters = {}) {
    try {
      const params = {
        q: searchQuery,
        ...filters
      };
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/services/search?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get services by category
  async getServicesByCategory(categoryId, params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/services/category/${categoryId}?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get featured services
  async getFeaturedServices() {
    try {
      const response = await api.get('/services/featured');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get service categories
  async getCategories() {
    try {
      const response = await api.get('/services/categories');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get craftsmen by service
  async getCraftsmenByService(serviceId, params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/services/${serviceId}/craftsmen?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }
}

export default new ServiceService();
