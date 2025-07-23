import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import socketService from '../services/socketService';

export const RealTimeChatPage = () => {
  const { partnerId } = useParams();
  const navigate = useNavigate();
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [isConnected, setIsConnected] = useState(false);
  const [isTyping, setIsTyping] = useState(false);
  const [partnerTyping, setPartnerTyping] = useState(false);
  const [onlineUsers, setOnlineUsers] = useState([]);
  const messagesEndRef = useRef(null);
  const typingTimeoutRef = useRef(null);

  // Mock user data (in real app, get from auth context)
  const currentUser = {
    id: 1,
    name: 'Test User'
  };

  const partner = {
    id: parseInt(partnerId),
    name: `Partner ${partnerId}`
  };

  useEffect(() => {
    // Connect to socket
    socketService.connect(currentUser.id, currentUser.name);
    
    // Join conversation
    socketService.joinConversation(partner.id);

    // Setup event listeners
    setupSocketListeners();

    // Get online users
    socketService.getOnlineUsers();

    return () => {
      // Leave conversation and cleanup
      socketService.leaveConversation();
      cleanupSocketListeners();
    };
  }, [partnerId]);

  useEffect(() => {
    // Scroll to bottom when new messages arrive
    scrollToBottom();
  }, [messages]);

  const setupSocketListeners = () => {
    // Connection status
    socketService.on('connect', () => {
      setIsConnected(true);
    });

    socketService.on('disconnect', () => {
      setIsConnected(false);
    });

    // New message received
    socketService.on('new_message', (messageData) => {
      console.log('📨 New message received:', messageData);
      setMessages(prev => [...prev, messageData]);
    });

    // Message notification (when not in room)
    socketService.on('message_notification', (data) => {
      console.log('🔔 Message notification:', data);
      // Could show toast notification here
    });

    // Typing indicators
    socketService.on('user_typing', (data) => {
      if (data.user_id === partner.id) {
        setPartnerTyping(data.typing);
      }
    });

    // Online users
    socketService.on('online_users', (data) => {
      setOnlineUsers(data.users);
    });

    socketService.on('user_online', (data) => {
      setOnlineUsers(prev => [...prev.filter(id => id !== data.user_id), data.user_id]);
    });

    socketService.on('user_offline', (data) => {
      setOnlineUsers(prev => prev.filter(id => id !== data.user_id));
    });

    // Conversation events
    socketService.on('joined_conversation', (data) => {
      console.log('✅ Joined conversation:', data);
    });

    socketService.on('error', (error) => {
      console.error('❌ Socket error:', error);
      alert(error.message || 'Bir hata oluştu');
    });
  };

  const cleanupSocketListeners = () => {
    socketService.off('connect');
    socketService.off('disconnect');
    socketService.off('new_message');
    socketService.off('message_notification');
    socketService.off('user_typing');
    socketService.off('online_users');
    socketService.off('user_online');
    socketService.off('user_offline');
    socketService.off('joined_conversation');
    socketService.off('error');
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const handleSendMessage = (e) => {
    e.preventDefault();
    
    if (!newMessage.trim()) return;
    
    const success = socketService.sendMessage(partner.id, newMessage.trim());
    
    if (success) {
      setNewMessage('');
      // Stop typing indicator
      socketService.stopTyping(partner.id);
      setIsTyping(false);
    } else {
      alert('Mesaj gönderilemedi. Bağlantınızı kontrol edin.');
    }
  };

  const handleTyping = (e) => {
    setNewMessage(e.target.value);
    
    if (!isTyping && e.target.value.trim()) {
      setIsTyping(true);
      socketService.startTyping(partner.id);
    }
    
    // Clear existing timeout
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }
    
    // Set new timeout to stop typing indicator
    typingTimeoutRef.current = setTimeout(() => {
      setIsTyping(false);
      socketService.stopTyping(partner.id);
    }, 1000);
  };

  const formatTime = (timestamp) => {
    return new Date(timestamp).toLocaleTimeString('tr-TR', {
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const isPartnerOnline = onlineUsers.includes(partner.id);

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      {/* Header */}
      <div className="bg-white shadow-sm border-b px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <button
              onClick={() => navigate('/messages')}
              className="p-2 hover:bg-gray-100 rounded-full transition-colors"
            >
              <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            
            <div className="flex items-center space-x-3">
              <div className="relative">
                <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center">
                  <span className="text-white font-medium text-sm">
                    {partner.name.charAt(0)}
                  </span>
                </div>
                {isPartnerOnline && (
                  <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-green-500 border-2 border-white rounded-full"></div>
                )}
              </div>
              
              <div>
                <h1 className="font-semibold text-gray-900">{partner.name}</h1>
                <p className="text-sm text-gray-500">
                  {isPartnerOnline ? '🟢 Çevrimiçi' : '🔴 Çevrimdışı'}
                </p>
              </div>
            </div>
          </div>
          
          <div className="flex items-center space-x-2">
            <div className={`w-3 h-3 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'}`}></div>
            <span className="text-sm text-gray-600">
              {isConnected ? 'Bağlı' : 'Bağlantı yok'}
            </span>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 ? (
          <div className="text-center py-8">
            <div className="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
              </svg>
            </div>
            <p className="text-gray-500">
              {partner.name} ile sohbet başlıyor...
            </p>
            <p className="text-sm text-gray-400 mt-1">
              İlk mesajınızı gönderin! 💬
            </p>
          </div>
        ) : (
          messages.map((message) => (
            <div
              key={message.id}
              className={`flex ${message.sender_id === currentUser.id ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                  message.sender_id === currentUser.id
                    ? 'bg-blue-500 text-white'
                    : 'bg-white text-gray-800 shadow-sm'
                }`}
              >
                <p className="text-sm">{message.message}</p>
                <p className={`text-xs mt-1 ${
                  message.sender_id === currentUser.id ? 'text-blue-100' : 'text-gray-500'
                }`}>
                  {formatTime(message.timestamp)}
                </p>
              </div>
            </div>
          ))
        )}
        
        {/* Typing indicator */}
        {partnerTyping && (
          <div className="flex justify-start">
            <div className="bg-white text-gray-800 shadow-sm px-4 py-2 rounded-lg">
              <div className="flex items-center space-x-1">
                <span className="text-sm text-gray-600">{partner.name} yazıyor</span>
                <div className="flex space-x-1">
                  <div className="w-1 h-1 bg-gray-400 rounded-full animate-bounce"></div>
                  <div className="w-1 h-1 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.1s'}}></div>
                  <div className="w-1 h-1 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.2s'}}></div>
                </div>
              </div>
            </div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>

      {/* Message Input */}
      <div className="bg-white border-t px-4 py-3">
        <form onSubmit={handleSendMessage} className="flex items-center space-x-3">
          <div className="flex-1">
            <input
              type="text"
              value={newMessage}
              onChange={handleTyping}
              placeholder={isConnected ? "Mesajınızı yazın..." : "Bağlantı bekleniyor..."}
              disabled={!isConnected}
              className="w-full px-4 py-2 border border-gray-300 rounded-full focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed"
            />
          </div>
          
          <button
            type="submit"
            disabled={!isConnected || !newMessage.trim()}
            className="p-2 bg-blue-500 text-white rounded-full hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
            </svg>
          </button>
        </form>
        
        {isTyping && (
          <p className="text-xs text-gray-500 mt-1 px-4">Yazıyor...</p>
        )}
      </div>
    </div>
  );
};

export default RealTimeChatPage;