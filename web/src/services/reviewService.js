import api from './api';

class ReviewService {
  // Get reviews with filtering
  async getReviews(params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/reviews?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get review by ID
  async getReviewById(reviewId) {
    try {
      const response = await api.get(`/reviews/${reviewId}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Create review
  async createReview(reviewData) {
    try {
      const response = await api.post('/reviews', reviewData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Update review
  async updateReview(reviewId, updateData) {
    try {
      const response = await api.put(`/reviews/${reviewId}`, updateData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Delete review
  async deleteReview(reviewId) {
    try {
      const response = await api.delete(`/reviews/${reviewId}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get review statistics for craftsman
  async getReviewStatistics(craftsmanId) {
    try {
      const response = await api.get(`/reviews/statistics/${craftsmanId}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get recent reviews
  async getRecentReviews(params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/reviews/recent?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }
}

export default new ReviewService();
