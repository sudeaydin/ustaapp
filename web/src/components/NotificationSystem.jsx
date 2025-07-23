import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';

export const NotificationSystem = () => {
  const { user } = useAuth();
  const [notifications, setNotifications] = useState([]);
  const [showNotifications, setShowNotifications] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);

  // Mock notifications - in real app, fetch from API
  const mockNotifications = [
    {
      id: 1,
      type: 'proposal_received',
      title: 'Yeni Teklif Alındı',
      message: 'LED Aydınlatma işiniz için Ahmet Yılmaz\'dan yeni bir teklif geldi.',
      created_at: '2025-01-21T15:30:00',
      read: false,
      action_url: '/job/1'
    },
    {
      id: 2,
      type: 'proposal_accepted',
      title: 'Teklifiniz Kabul Edildi',
      message: 'Banyo Tesisatı işi için verdiğiniz teklif kabul edildi. İşe başlayabilirsiniz.',
      created_at: '2025-01-21T12:15:00',
      read: false,
      action_url: '/job/2/progress'
    },
    {
      id: 3,
      type: 'job_completed',
      title: 'İş Tamamlandı',
      message: 'Klima Montajı işi tamamlandı. Değerlendirme yapabilirsiniz.',
      created_at: '2025-01-20T18:45:00',
      read: true,
      action_url: '/review/3'
    },
    {
      id: 4,
      type: 'review_received',
      title: 'Yeni Değerlendirme',
      message: 'LED Aydınlatma işiniz için 5 yıldızlı değerlendirme aldınız.',
      created_at: '2025-01-20T14:20:00',
      read: true,
      action_url: '/craftsman/1'
    }
  ];

  useEffect(() => {
    // Load notifications
    setNotifications(mockNotifications);
    setUnreadCount(mockNotifications.filter(n => !n.read).length);

    // Simulate real-time notifications
    const interval = setInterval(() => {
      // In real app, this would be WebSocket or Server-Sent Events
      // For demo, randomly add new notification
      if (Math.random() > 0.95) {
        const newNotification = {
          id: Date.now(),
          type: 'message_received',
          title: 'Yeni Mesaj',
          message: 'Size yeni bir mesaj geldi.',
          created_at: new Date().toISOString(),
          read: false,
          action_url: '/messages'
        };
        
        setNotifications(prev => [newNotification, ...prev]);
        setUnreadCount(prev => prev + 1);
      }
    }, 30000); // Check every 30 seconds

    return () => clearInterval(interval);
  }, []);

  const getNotificationIcon = (type) => {
    switch (type) {
      case 'proposal_received':
        return '💰';
      case 'proposal_accepted':
        return '✅';
      case 'job_completed':
        return '🎉';
      case 'review_received':
        return '⭐';
      case 'message_received':
        return '💬';
      case 'job_progress':
        return '📈';
      default:
        return '🔔';
    }
  };

  const getNotificationColor = (type) => {
    switch (type) {
      case 'proposal_received':
        return 'bg-blue-100 text-blue-800';
      case 'proposal_accepted':
        return 'bg-green-100 text-green-800';
      case 'job_completed':
        return 'bg-purple-100 text-purple-800';
      case 'review_received':
        return 'bg-yellow-100 text-yellow-800';
      case 'message_received':
        return 'bg-indigo-100 text-indigo-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const formatTimeAgo = (dateString) => {
    const now = new Date();
    const date = new Date(dateString);
    const diffInMinutes = Math.floor((now - date) / (1000 * 60));
    
    if (diffInMinutes < 1) return 'Az önce';
    if (diffInMinutes < 60) return `${diffInMinutes} dakika önce`;
    
    const diffInHours = Math.floor(diffInMinutes / 60);
    if (diffInHours < 24) return `${diffInHours} saat önce`;
    
    const diffInDays = Math.floor(diffInHours / 24);
    return `${diffInDays} gün önce`;
  };

  const markAsRead = (notificationId) => {
    setNotifications(prev => 
      prev.map(n => 
        n.id === notificationId ? { ...n, read: true } : n
      )
    );
    
    if (!notifications.find(n => n.id === notificationId)?.read) {
      setUnreadCount(prev => Math.max(0, prev - 1));
    }
  };

  const markAllAsRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
    setUnreadCount(0);
  };

  const handleNotificationClick = (notification) => {
    markAsRead(notification.id);
    setShowNotifications(false);
    
    // Navigate to action URL
    if (notification.action_url) {
      window.location.href = notification.action_url;
    }
  };

  return (
    <div className="relative">
      {/* Notification Bell */}
      <button
        onClick={() => setShowNotifications(!showNotifications)}
        className="relative p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-full transition-colors"
      >
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>
        
        {/* Unread Badge */}
        {unreadCount > 0 && (
          <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center font-medium">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {/* Notification Dropdown */}
      {showNotifications && (
        <div className="absolute right-0 top-12 w-96 bg-white rounded-lg shadow-lg border z-50 max-h-96 overflow-y-auto">
          {/* Header */}
          <div className="p-4 border-b">
            <div className="flex items-center justify-between">
              <h3 className="font-semibold text-gray-900">🔔 Bildirimler</h3>
              {unreadCount > 0 && (
                <button
                  onClick={markAllAsRead}
                  className="text-sm text-blue-600 hover:text-blue-800 font-medium"
                >
                  Tümünü Okundu İşaretle
                </button>
              )}
            </div>
          </div>

          {/* Notifications List */}
          <div className="max-h-80 overflow-y-auto">
            {notifications.length === 0 ? (
              <div className="p-8 text-center">
                <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-3">
                  <svg className="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                  </svg>
                </div>
                <p className="text-gray-600 text-sm">Henüz bildirim yok</p>
              </div>
            ) : (
              notifications.map((notification) => (
                <div
                  key={notification.id}
                  onClick={() => handleNotificationClick(notification)}
                  className={`p-4 border-b hover:bg-gray-50 cursor-pointer transition-colors ${
                    !notification.read ? 'bg-blue-50' : ''
                  }`}
                >
                  <div className="flex items-start space-x-3">
                    {/* Icon */}
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${getNotificationColor(notification.type)}`}>
                      <span className="text-sm">
                        {getNotificationIcon(notification.type)}
                      </span>
                    </div>

                    {/* Content */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between mb-1">
                        <h4 className={`text-sm font-medium ${!notification.read ? 'text-gray-900' : 'text-gray-700'}`}>
                          {notification.title}
                        </h4>
                        {!notification.read && (
                          <div className="w-2 h-2 bg-blue-500 rounded-full flex-shrink-0"></div>
                        )}
                      </div>
                      
                      <p className="text-sm text-gray-600 mb-2 line-clamp-2">
                        {notification.message}
                      </p>
                      
                      <p className="text-xs text-gray-500">
                        {formatTimeAgo(notification.created_at)}
                      </p>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Footer */}
          {notifications.length > 0 && (
            <div className="p-3 border-t bg-gray-50">
              <button
                onClick={() => {
                  setShowNotifications(false);
                  // Navigate to all notifications page
                }}
                className="w-full text-center text-sm text-blue-600 hover:text-blue-800 font-medium"
              >
                Tüm Bildirimleri Görüntüle
              </button>
            </div>
          )}
        </div>
      )}

      {/* Click outside to close */}
      {showNotifications && (
        <div
          className="fixed inset-0 z-40"
          onClick={() => setShowNotifications(false)}
        ></div>
      )}
    </div>
  );
};

export default NotificationSystem;