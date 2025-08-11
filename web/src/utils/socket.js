import { io } from 'socket.io-client'

class SocketManager {
  constructor() {
    this.socket = null
    this.isConnected = false
    this.reconnectAttempts = 0
    this.maxReconnectAttempts = 5
    this.listeners = new Map()
    
    this.init()
  }
  
  init() {
    const token = localStorage.getItem('authToken')
    if (!token) {
      console.log('No auth token found, skipping socket connection')
      return
    }
    
    const socketUrl = import.meta.env.VITE_SOCKET_URL || 'http://localhost:5000'
    
    this.socket = io(socketUrl, {
      auth: { token },
      transports: ['websocket', 'polling'],
      timeout: 20000,
      forceNew: true
    })
    
    this.setupEventListeners()
  }
  
  setupEventListeners() {
    if (!this.socket) return
    
    this.socket.on('connect', () => {
      console.log('Socket.IO connected')
      this.isConnected = true
      this.reconnectAttempts = 0
      this.emit('connection_status', { connected: true })
    })
    
    this.socket.on('disconnect', (reason) => {
      console.log('Socket.IO disconnected:', reason)
      this.isConnected = false
      this.emit('connection_status', { connected: false, reason })
    })
    
    this.socket.on('connect_error', (error) => {
      console.error('Socket.IO connection error:', error)
      this.handleReconnect()
    })
    
    // Real-time message events
    this.socket.on('new_message', (data) => {
      console.log('New message received:', data)
      this.emit('new_message', data)
      
      // Show browser notification if page is not visible
      if (document.hidden && 'Notification' in window && Notification.permission === 'granted') {
        new Notification(`Yeni mesaj - ${data.sender.first_name}`, {
          body: data.message.content,
          icon: '/icons/icon-192x192.png',
          tag: 'new-message'
        })
      }
    })
    
    this.socket.on('message_sent', (data) => {
      this.emit('message_sent', data)
    })
    
    this.socket.on('messages_read', (data) => {
      this.emit('messages_read', data)
    })
    
    // Typing indicators
    this.socket.on('user_typing', (data) => {
      this.emit('user_typing', data)
    })
    
    // Quote updates
    this.socket.on('new_quote_request', (data) => {
      console.log('New quote request:', data)
      this.emit('new_quote_request', data)
      
      if (document.hidden && 'Notification' in window && Notification.permission === 'granted') {
        new Notification('Yeni Teklif Talebi!', {
          body: `Yeni bir teklif talebi aldınız`,
          icon: '/icons/icon-192x192.png',
          tag: 'quote-request'
        })
      }
    })
    
    this.socket.on('quote_updated', (data) => {
      console.log('Quote updated:', data)
      this.emit('quote_updated', data)
    })
    
    this.socket.on('quote_broadcast', (data) => {
      this.emit('quote_broadcast', data)
    })
    
    // User status updates
    this.socket.on('user_status_changed', (data) => {
      this.emit('user_status_changed', data)
    })
    
    // Push notifications
    this.socket.on('push_notification', (data) => {
      this.showNotification(data)
    })
    
    // Error handling
    this.socket.on('error', (data) => {
      console.error('Socket.IO error:', data)
      this.emit('socket_error', data)
    })
  }
  
  handleReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++
      const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000)
      
      console.log(`Attempting to reconnect in ${delay}ms (attempt ${this.reconnectAttempts})`)
      
      setTimeout(() => {
        if (this.socket) {
          this.socket.connect()
        }
      }, delay)
    } else {
      console.error('Max reconnection attempts reached')
      this.emit('connection_failed')
    }
  }
  
  // Public methods
  connect() {
    if (!this.socket) {
      this.init()
    } else if (!this.isConnected) {
      this.socket.connect()
    }
  }
  
  disconnect() {
    if (this.socket) {
      this.socket.disconnect()
      this.isConnected = false
    }
  }
  
  // Message methods
  sendMessage(recipientId, content, type = 'text') {
    if (!this.isConnected) {
      throw new Error('Socket not connected')
    }
    
    this.socket.emit('send_message', {
      recipient_id: recipientId,
      content,
      type
    })
  }
  
  markMessagesRead(senderId) {
    if (!this.isConnected) return
    
    this.socket.emit('mark_messages_read', {
      sender_id: senderId
    })
  }
  
  startTyping(recipientId) {
    if (!this.isConnected) return
    
    this.socket.emit('typing_start', {
      recipient_id: recipientId
    })
  }
  
  stopTyping(recipientId) {
    if (!this.isConnected) return
    
    this.socket.emit('typing_stop', {
      recipient_id: recipientId
    })
  }
  
  // Conversation methods
  joinConversation(otherUserId) {
    if (!this.isConnected) return
    
    this.socket.emit('join_conversation', {
      other_user_id: otherUserId
    })
  }
  
  leaveConversation(otherUserId) {
    if (!this.isConnected) return
    
    this.socket.emit('leave_conversation', {
      other_user_id: otherUserId
    })
  }
  
  // Quote methods
  updateQuoteStatus(quoteId, status) {
    if (!this.isConnected) {
      throw new Error('Socket not connected')
    }
    
    this.socket.emit('quote_status_update', {
      quote_id: quoteId,
      status
    })
  }
  
  // Location methods
  updateLocation(latitude, longitude) {
    if (!this.isConnected) return
    
    this.socket.emit('craftsman_location_update', {
      latitude,
      longitude
    })
  }
  
  // Analytics methods
  trackPageView(page) {
    if (!this.isConnected) return
    
    this.socket.emit('page_view', { page })
  }
  
  trackUserAction(action, details = {}) {
    if (!this.isConnected) return
    
    this.socket.emit('user_action', {
      action,
      details
    })
  }
  
  // Event listener management
  on(event, callback) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set())
    }
    this.listeners.get(event).add(callback)
  }
  
  off(event, callback) {
    if (this.listeners.has(event)) {
      this.listeners.get(event).delete(callback)
    }
  }
  
  emit(event, data) {
    if (this.listeners.has(event)) {
      this.listeners.get(event).forEach(callback => {
        try {
          callback(data)
        } catch (error) {
          console.error(`Error in ${event} listener:`, error)
        }
      })
    }
  }
  
  // Notification methods
  async requestNotificationPermission() {
    if (!('Notification' in window)) {
      console.log('This browser does not support notifications')
      return false
    }
    
    if (Notification.permission === 'granted') {
      return true
    }
    
    if (Notification.permission === 'denied') {
      return false
    }
    
    const permission = await Notification.requestPermission()
    return permission === 'granted'
  }
  
  showNotification(data) {
    if ('Notification' in window && Notification.permission === 'granted') {
      const notification = new Notification(data.title, {
        body: data.body,
        icon: data.icon || '/icons/icon-192x192.png',
        badge: '/icons/badge-72x72.png',
        tag: data.tag || 'ustamapp',
        data: data.data,
        requireInteraction: data.requireInteraction || false
      })
      
      notification.onclick = () => {
        window.focus()
        if (data.data && data.data.url) {
          window.location.href = data.data.url
        }
        notification.close()
      }
      
      // Auto close after 5 seconds
      setTimeout(() => notification.close(), 5000)
    }
  }
  
  // Connection status
  getConnectionStatus() {
    return {
      connected: this.isConnected,
      reconnectAttempts: this.reconnectAttempts,
      socketId: this.socket?.id
    }
  }
}

// Create singleton instance
const socketManager = new SocketManager()

// React hook for using socket
export const useSocket = () => {
  const [connectionStatus, setConnectionStatus] = useState(socketManager.getConnectionStatus())
  const [messages, setMessages] = useState([])
  const [typingUsers, setTypingUsers] = useState(new Set())
  
  useEffect(() => {
    // Connection status listener
    const handleConnectionStatus = (status) => {
      setConnectionStatus(socketManager.getConnectionStatus())
    }
    
    // Message listeners
    const handleNewMessage = (data) => {
      setMessages(prev => [...prev, data.message])
    }
    
    const handleMessageSent = (data) => {
      setMessages(prev => [...prev, data.message])
    }
    
    // Typing listeners
    const handleUserTyping = (data) => {
      setTypingUsers(prev => {
        const newSet = new Set(prev)
        if (data.typing) {
          newSet.add(data.user_id)
        } else {
          newSet.delete(data.user_id)
        }
        return newSet
      })
    }
    
    // Register listeners
    socketManager.on('connection_status', handleConnectionStatus)
    socketManager.on('new_message', handleNewMessage)
    socketManager.on('message_sent', handleMessageSent)
    socketManager.on('user_typing', handleUserTyping)
    
    // Cleanup
    return () => {
      socketManager.off('connection_status', handleConnectionStatus)
      socketManager.off('new_message', handleNewMessage)
      socketManager.off('message_sent', handleMessageSent)
      socketManager.off('user_typing', handleUserTyping)
    }
  }, [])
  
  return {
    ...connectionStatus,
    messages,
    typingUsers,
    sendMessage: (recipientId, content, type) => socketManager.sendMessage(recipientId, content, type),
    markMessagesRead: (senderId) => socketManager.markMessagesRead(senderId),
    startTyping: (recipientId) => socketManager.startTyping(recipientId),
    stopTyping: (recipientId) => socketManager.stopTyping(recipientId),
    joinConversation: (otherUserId) => socketManager.joinConversation(otherUserId),
    leaveConversation: (otherUserId) => socketManager.leaveConversation(otherUserId),
    updateQuoteStatus: (quoteId, status) => socketManager.updateQuoteStatus(quoteId, status),
    trackPageView: (page) => socketManager.trackPageView(page),
    trackUserAction: (action, details) => socketManager.trackUserAction(action, details)
  }
}

// React hook for quotes
export const useQuoteSocket = () => {
  const [quotes, setQuotes] = useState([])
  const [quoteUpdates, setQuoteUpdates] = useState([])
  
  useEffect(() => {
    const handleNewQuoteRequest = (data) => {
      setQuotes(prev => [data.quote, ...prev])
      setQuoteUpdates(prev => [...prev, { type: 'new_request', data: data.quote }])
    }
    
    const handleQuoteUpdated = (data) => {
      setQuotes(prev => prev.map(quote => 
        quote.id === data.quote.id ? data.quote : quote
      ))
      setQuoteUpdates(prev => [...prev, { type: 'updated', data: data.quote }])
    }
    
    const handleQuoteBroadcast = (data) => {
      setQuoteUpdates(prev => [...prev, { type: data.type, data: data.data }])
    }
    
    socketManager.on('new_quote_request', handleNewQuoteRequest)
    socketManager.on('quote_updated', handleQuoteUpdated)
    socketManager.on('quote_broadcast', handleQuoteBroadcast)
    
    return () => {
      socketManager.off('new_quote_request', handleNewQuoteRequest)
      socketManager.off('quote_updated', handleQuoteUpdated)
      socketManager.off('quote_broadcast', handleQuoteBroadcast)
    }
  }, [])
  
  return {
    quotes,
    quoteUpdates,
    clearUpdates: () => setQuoteUpdates([])
  }
}

// React hook for online status
export const useOnlineStatus = () => {
  const [onlineUsers, setOnlineUsers] = useState(new Set())
  
  useEffect(() => {
    const handleUserStatusChanged = (data) => {
      setOnlineUsers(prev => {
        const newSet = new Set(prev)
        if (data.status === 'online') {
          newSet.add(data.user_id)
        } else {
          newSet.delete(data.user_id)
        }
        return newSet
      })
    }
    
    socketManager.on('user_status_changed', handleUserStatusChanged)
    
    return () => {
      socketManager.off('user_status_changed', handleUserStatusChanged)
    }
  }, [])
  
  return {
    onlineUsers,
    isUserOnline: (userId) => onlineUsers.has(userId)
  }
}

// Typing indicator component
export const TypingIndicator = ({ typingUsers, currentUserId }) => {
  const typingUsersList = Array.from(typingUsers).filter(id => id !== currentUserId)
  
  if (typingUsersList.length === 0) {
    return null
  }
  
  return (
    <div className="text-sm text-gray-500 italic p-2">
      {typingUsersList.length === 1 
        ? 'Yazıyor...' 
        : `${typingUsersList.length} kişi yazıyor...`}
    </div>
  )
}

// Connection status indicator
export const ConnectionStatus = () => {
  const { connected } = useSocket()
  
  return (
    <div className={`fixed top-4 right-4 z-50 px-3 py-1 rounded-full text-sm ${
      connected 
        ? 'bg-green-100 text-green-800' 
        : 'bg-red-100 text-red-800'
    }`}>
      <span className={`inline-block w-2 h-2 rounded-full mr-2 ${
        connected ? 'bg-green-500' : 'bg-red-500'
      }`}></span>
      {connected ? 'Çevrimiçi' : 'Bağlantı Yok'}
    </div>
  )
}

// Auto-reconnect when auth token changes
export const setupSocketAuth = () => {
  let lastToken = localStorage.getItem('authToken')
  
  setInterval(() => {
    const currentToken = localStorage.getItem('authToken')
    
    if (currentToken !== lastToken) {
      lastToken = currentToken
      
      if (currentToken) {
        // Reconnect with new token
        socketManager.disconnect()
        setTimeout(() => socketManager.init(), 1000)
      } else {
        // Disconnect if no token
        socketManager.disconnect()
      }
    }
  }, 5000)
}

// Initialize socket auth monitoring
setupSocketAuth()

export default socketManager

// Import React hooks
import { useState, useEffect } from 'react'