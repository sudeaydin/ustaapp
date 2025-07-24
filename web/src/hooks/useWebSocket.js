import { useEffect, useRef, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { io } from 'socket.io-client';

const useWebSocket = () => {
  const { user } = useAuth();
  const socketRef = useRef(null);
  const [isConnected, setIsConnected] = useState(false);
  const [onlineUsers, setOnlineUsers] = useState(new Set());

  useEffect(() => {
    if (user) {
      // Initialize WebSocket connection
      socketRef.current = io(process.env.REACT_APP_API_URL || 'http://localhost:5000', {
        auth: {
          token: localStorage.getItem('token')
        },
        transports: ['websocket', 'polling']
      });

      const socket = socketRef.current;

      // Connection event handlers
      socket.on('connect', () => {
        console.log('WebSocket connected');
        setIsConnected(true);
      });

      socket.on('disconnect', () => {
        console.log('WebSocket disconnected');
        setIsConnected(false);
      });

      socket.on('connect_error', (error) => {
        console.error('WebSocket connection error:', error);
        setIsConnected(false);
      });

      // Real-time message events
      socket.on('new_message', (messageData) => {
        // Dispatch custom event for message components to listen
        window.dispatchEvent(new CustomEvent('newMessage', {
          detail: messageData
        }));
      });

      socket.on('message_read', (data) => {
        window.dispatchEvent(new CustomEvent('messageRead', {
          detail: data
        }));
      });

      // Typing indicators
      socket.on('user_typing', (data) => {
        window.dispatchEvent(new CustomEvent('userTyping', {
          detail: data
        }));
      });

      // Notification events
      socket.on('new_notification', (notificationData) => {
        window.dispatchEvent(new CustomEvent('newNotification', {
          detail: notificationData
        }));
        
        // Show browser notification if permission granted
        if (Notification.permission === 'granted') {
          new Notification(notificationData.title, {
            body: notificationData.message,
            icon: '/icons/icon-192x192.png',
            badge: '/icons/icon-96x96.png'
          });
        }
      });

      socket.on('notification_count', (data) => {
        window.dispatchEvent(new CustomEvent('notificationCount', {
          detail: data
        }));
      });

      // Job update events
      socket.on('job_status_update', (data) => {
        window.dispatchEvent(new CustomEvent('jobStatusUpdate', {
          detail: data
        }));
      });

      socket.on('job_update_broadcast', (data) => {
        window.dispatchEvent(new CustomEvent('jobUpdateBroadcast', {
          detail: data
        }));
      });

      // Online status events
      socket.on('online_status', (statusData) => {
        setOnlineUsers(new Set(Object.keys(statusData).filter(userId => statusData[userId])));
      });

      // Cleanup on unmount
      return () => {
        if (socketRef.current) {
          socketRef.current.disconnect();
          socketRef.current = null;
        }
        setIsConnected(false);
      };
    }
  }, [user]);

  // WebSocket utility functions
  const sendMessage = (receiverId, content) => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('send_message', {
        receiver_id: receiverId,
        content: content
      });
    }
  };

  const markMessageAsRead = (messageId) => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('mark_message_read', {
        message_id: messageId
      });
    }
  };

  const joinConversation = (partnerId) => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('join_conversation', {
        partner_id: partnerId
      });
    }
  };

  const leaveConversation = (partnerId) => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('leave_conversation', {
        partner_id: partnerId
      });
    }
  };

  const startTyping = (partnerId) => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('typing_start', {
        partner_id: partnerId
      });
    }
  };

  const stopTyping = (partnerId) => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('typing_stop', {
        partner_id: partnerId
      });
    }
  };

  const getOnlineStatus = (userIds) => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('get_online_status', {
        user_ids: userIds
      });
    }
  };

  const updateJobStatus = (jobId, status, message = '') => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('job_update', {
        job_id: jobId,
        status: status,
        message: message
      });
    }
  };

  const markNotificationAsRead = (notificationId) => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('notification_read', {
        notification_id: notificationId
      });
    }
  };

  return {
    isConnected,
    onlineUsers,
    sendMessage,
    markMessageAsRead,
    joinConversation,
    leaveConversation,
    startTyping,
    stopTyping,
    getOnlineStatus,
    updateJobStatus,
    markNotificationAsRead
  };
};

export default useWebSocket;