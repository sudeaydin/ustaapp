import api from './api';

class QuoteService {
  // Create quote request
  async createQuote(quoteData) {
    try {
      const response = await api.post('/quotes', quoteData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get quote by ID
  async getQuoteById(quoteId) {
    try {
      const response = await api.get(`/quotes/${quoteId}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Update quote
  async updateQuote(quoteId, updateData) {
    try {
      const response = await api.put(`/quotes/${quoteId}`, updateData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Delete quote
  async deleteQuote(quoteId) {
    try {
      const response = await api.delete(`/quotes/${quoteId}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get quotes with filtering
  async getQuotes(params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/quotes?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get quote statistics
  async getQuoteStatistics() {
    try {
      const response = await api.get('/quotes/statistics');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Accept quote (customer)
  async acceptQuote(quoteId) {
    try {
      const response = await api.post(`/quotes/${quoteId}/accept`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Reject quote (customer)
  async rejectQuote(quoteId, reason) {
    try {
      const response = await api.post(`/quotes/${quoteId}/reject`, { reason });
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Mark quote as completed
  async completeQuote(quoteId) {
    try {
      const response = await api.post(`/quotes/${quoteId}/complete`);
      return response;
    } catch (error) {
      throw error;
    }
  }
}

export default new QuoteService();
