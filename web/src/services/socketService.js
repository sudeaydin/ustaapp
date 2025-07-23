import { io } from 'socket.io-client';

class SocketService {
  constructor() {
    this.socket = null;
    this.isConnected = false;
    this.currentUserId = null;
    this.currentUsername = null;
    this.listeners = new Map();
  }

  // Connect to socket server
  connect(userId, username) {
    if (this.socket && this.isConnected) {
      return this.socket;
    }

    this.socket = io('http://localhost:5001', {
      transports: ['websocket', 'polling'],
      timeout: 20000,
    });

    this.currentUserId = userId;
    this.currentUsername = username;

    this.setupEventListeners();
    
    return this.socket;
  }

  // Disconnect from socket server
  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
      this.isConnected = false;
      this.currentUserId = null;
      this.currentUsername = null;
      this.listeners.clear();
    }
  }

  // Setup basic event listeners
  setupEventListeners() {
    if (!this.socket) return;

    this.socket.on('connect', () => {
      console.log('✅ Connected to chat server');
      this.isConnected = true;
      
      // Join chat with user info
      this.socket.emit('join_chat', {
        user_id: this.currentUserId,
        username: this.currentUsername
      });
    });

    this.socket.on('disconnect', () => {
      console.log('❌ Disconnected from chat server');
      this.isConnected = false;
    });

    this.socket.on('connect_error', (error) => {
      console.error('❌ Connection error:', error);
      this.isConnected = false;
    });

    this.socket.on('error', (error) => {
      console.error('❌ Socket error:', error);
    });

    // Chat-specific events
    this.socket.on('joined_chat', (data) => {
      console.log('✅ Joined chat:', data);
    });

    this.socket.on('user_online', (data) => {
      console.log('🟢 User came online:', data);
      this.emit('user_online', data);
    });

    this.socket.on('user_offline', (data) => {
      console.log('🔴 User went offline:', data);
      this.emit('user_offline', data);
    });
  }

  // Join a conversation room
  joinConversation(partnerId) {
    if (!this.socket || !this.isConnected) {
      console.error('Socket not connected');
      return;
    }

    this.socket.emit('join_conversation', {
      user_id: this.currentUserId,
      partner_id: partnerId
    });
  }

  // Leave current conversation room
  leaveConversation() {
    if (!this.socket || !this.isConnected) {
      return;
    }

    this.socket.emit('leave_conversation', {
      user_id: this.currentUserId
    });
  }

  // Send a message
  sendMessage(partnerId, message) {
    if (!this.socket || !this.isConnected) {
      console.error('Socket not connected');
      return false;
    }

    this.socket.emit('send_message', {
      user_id: this.currentUserId,
      username: this.currentUsername,
      partner_id: partnerId,
      message: message
    });

    return true;
  }

  // Start typing indicator
  startTyping(partnerId) {
    if (!this.socket || !this.isConnected) {
      return;
    }

    this.socket.emit('typing_start', {
      user_id: this.currentUserId,
      username: this.currentUsername,
      partner_id: partnerId
    });
  }

  // Stop typing indicator
  stopTyping(partnerId) {
    if (!this.socket || !this.isConnected) {
      return;
    }

    this.socket.emit('typing_stop', {
      user_id: this.currentUserId,
      username: this.currentUsername,
      partner_id: partnerId
    });
  }

  // Get online users
  getOnlineUsers() {
    if (!this.socket || !this.isConnected) {
      return;
    }

    this.socket.emit('get_online_users');
  }

  // Listen to socket events
  on(event, callback) {
    if (!this.socket) {
      console.error('Socket not connected');
      return;
    }

    this.socket.on(event, callback);
    
    // Store listener for cleanup
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event).push(callback);
  }

  // Remove socket event listener
  off(event, callback) {
    if (!this.socket) {
      return;
    }

    this.socket.off(event, callback);
    
    // Remove from stored listeners
    if (this.listeners.has(event)) {
      const callbacks = this.listeners.get(event);
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  // Emit custom events to listeners
  emit(event, data) {
    if (this.listeners.has(event)) {
      this.listeners.get(event).forEach(callback => {
        try {
          callback(data);
        } catch (error) {
          console.error(`Error in ${event} listener:`, error);
        }
      });
    }
  }

  // Get connection status
  isSocketConnected() {
    return this.isConnected && this.socket && this.socket.connected;
  }

  // Get current user info
  getCurrentUser() {
    return {
      userId: this.currentUserId,
      username: this.currentUsername
    };
  }
}

// Create singleton instance
const socketService = new SocketService();

export default socketService;