import api from './api';

export const quoteService = {
  // Create a new quote request
  createQuote: async (quoteData) => {
    try {
      const response = await api.post('/quotes/', quoteData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Get user's quotes
  getQuotes: async () => {
    try {
      const response = await api.get('/quotes/');
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Get quote by ID
  getQuote: async (id) => {
    try {
      const response = await api.get(`/quotes/${id}`);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Update quote status (for craftsmen)
  updateQuoteStatus: async (id, status, data = {}) => {
    try {
      const response = await api.put(`/quotes/${id}/status`, {
        status,
        ...data
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Accept quote (craftsman accepts the job)
  acceptQuote: async (id, message, price, estimatedDuration) => {
    try {
      const response = await api.put(`/quotes/${id}/accept`, {
        craftsman_message: message,
        price,
        estimated_duration: estimatedDuration
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Reject quote
  rejectQuote: async (id, message) => {
    try {
      const response = await api.put(`/quotes/${id}/reject`, {
        craftsman_message: message
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Complete quote
  completeQuote: async (id) => {
    try {
      const response = await api.put(`/quotes/${id}/complete`);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Cancel quote
  cancelQuote: async (id, reason) => {
    try {
      const response = await api.put(`/quotes/${id}/cancel`, {
        cancellation_reason: reason
      });
      return response;
    } catch (error) {
      throw error;
    }
  }
};
