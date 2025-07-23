import api from './api';

class MessageService {
  // Get conversations
  async getConversations() {
    try {
      const response = await api.get('/messages/conversations');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get conversation messages
  async getConversationMessages(partnerId, params = {}) {
    try {
      const queryParams = new URLSearchParams(params).toString();
      const response = await api.get(`/messages/conversations/${partnerId}?${queryParams}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Send message
  async sendMessage(messageData) {
    try {
      const response = await api.post('/messages/send', messageData);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Mark message as read
  async markMessageRead(messageId) {
    try {
      const response = await api.put(`/messages/${messageId}/read`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Delete message
  async deleteMessage(messageId) {
    try {
      const response = await api.delete(`/messages/${messageId}`);
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Get unread count
  async getUnreadCount() {
    try {
      const response = await api.get('/messages/unread-count');
      return response;
    } catch (error) {
      throw error;
    }
  }

  // Search messages
  async searchMessages(query) {
    try {
      const response = await api.get(`/messages/search?q=${encodeURIComponent(query)}`);
      return response;
    } catch (error) {
      throw error;
    }
  }
}

export default new MessageService();
