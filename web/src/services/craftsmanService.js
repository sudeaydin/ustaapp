import api from './api';

export const craftsmanService = {
  // Get all craftsmen with filters
  getCraftsmen: async (filters = {}) => {
    try {
      const params = new URLSearchParams();
      
      if (filters.page) params.append('page', filters.page);
      if (filters.per_page) params.append('per_page', filters.per_page);
      if (filters.category_id) params.append('category_id', filters.category_id);
      if (filters.city) params.append('city', filters.city);
      if (filters.search) params.append('search', filters.search);
      
      const response = await api.get(`/craftsmen/?${params.toString()}`);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Get craftsman by ID
  getCraftsman: async (id) => {
    try {
      const response = await api.get(`/craftsmen/${id}`);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Get all categories
  getCategories: async () => {
    try {
      const response = await api.get('/craftsmen/categories');
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Search craftsmen
  searchCraftsmen: async (query) => {
    try {
      const response = await api.get(`/craftsmen/?search=${encodeURIComponent(query)}`);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Get craftsmen by category
  getCraftsmenByCategory: async (categoryId) => {
    try {
      const response = await api.get(`/craftsmen/?category_id=${categoryId}`);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Get craftsmen by city
  getCraftsmenByCity: async (city) => {
    try {
      const response = await api.get(`/craftsmen/?city=${encodeURIComponent(city)}`);
      return response;
    } catch (error) {
      throw error;
    }
  }
};