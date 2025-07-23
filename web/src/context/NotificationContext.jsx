import React, { createContext, useContext, useState, useEffect } from 'react';
import { useAuth } from './AuthContext';

const NotificationContext = createContext();

export const useNotification = () => {
  const context = useContext(NotificationContext);
  if (!context) {
    throw new Error('useNotification must be used within a NotificationProvider');
  }
  return context;
};

export const NotificationProvider = ({ children }) => {
  const { user } = useAuth();
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [settings, setSettings] = useState({
    email: true,
    push: true,
    sms: false,
    jobUpdates: true,
    messages: true,
    proposals: true,
    reviews: true,
    marketing: false
  });

  // Mock notification data generator
  const generateMockNotifications = (userType) => {
    const baseNotifications = [
      {
        id: 1,
        type: 'message',
        title: 'Yeni Mesaj',
        message: 'Ahmet Yılmaz size mesaj gönderdi',
        timestamp: new Date(Date.now() - 30 * 60 * 1000), // 30 min ago
        read: false,
        actionUrl: '/messages/1',
        avatar: null,
        priority: 'normal'
      },
      {
        id: 2,
        type: 'system',
        title: 'Profil Güncellendi',
        message: 'Profiliniz başarıyla güncellendi',
        timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
        read: true,
        actionUrl: '/profile',
        avatar: null,
        priority: 'low'
      }
    ];

    if (userType === 'craftsman') {
      return [
        ...baseNotifications,
        {
          id: 3,
          type: 'job',
          title: 'Yeni İş Teklifi',
          message: 'Elektrik tesisatı işi için teklif isteği aldınız',
          timestamp: new Date(Date.now() - 15 * 60 * 1000), // 15 min ago
          read: false,
          actionUrl: '/job/123',
          avatar: null,
          priority: 'high'
        },
        {
          id: 4,
          type: 'review',
          title: 'Yeni Değerlendirme',
          message: 'Fatma Hanım size 5 yıldız verdi',
          timestamp: new Date(Date.now() - 4 * 60 * 60 * 1000), // 4 hours ago
          read: false,
          actionUrl: '/reviews',
          avatar: null,
          priority: 'normal'
        },
        {
          id: 5,
          type: 'payment',
          title: 'Ödeme Alındı',
          message: '₺450 ödemeniz hesabınıza yatırıldı',
          timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
          read: true,
          actionUrl: '/analytics',
          avatar: null,
          priority: 'normal'
        }
      ];
    } else {
      return [
        ...baseNotifications,
        {
          id: 3,
          type: 'proposal',
          title: 'Yeni Teklif',
          message: '3 usta klima montajı için teklif gönderdi',
          timestamp: new Date(Date.now() - 45 * 60 * 1000), // 45 min ago
          read: false,
          actionUrl: '/job/456/proposals',
          avatar: null,
          priority: 'high'
        },
        {
          id: 4,
          type: 'job',
          title: 'İş Tamamlandı',
          message: 'Elektrik tesisatı işiniz tamamlandı',
          timestamp: new Date(Date.now() - 3 * 60 * 60 * 1000), // 3 hours ago
          read: false,
          actionUrl: '/job/789/progress',
          avatar: null,
          priority: 'normal'
        },
        {
          id: 5,
          type: 'reminder',
          title: 'Değerlendirme Hatırlatması',
          message: 'Tamamlanan işiniz için değerlendirme yapabilirsiniz',
          timestamp: new Date(Date.now() - 6 * 60 * 60 * 1000), // 6 hours ago
          read: true,
          actionUrl: '/review/789',
          avatar: null,
          priority: 'low'
        }
      ];
    }
  };

  // Load notifications when user changes
  useEffect(() => {
    if (user) {
      const mockNotifications = generateMockNotifications(user.user_type);
      setNotifications(mockNotifications);
      setUnreadCount(mockNotifications.filter(n => !n.read).length);
    } else {
      setNotifications([]);
      setUnreadCount(0);
    }
  }, [user]);

  // Load settings from localStorage
  useEffect(() => {
    const savedSettings = localStorage.getItem('ustam_notification_settings');
    if (savedSettings) {
      setSettings(JSON.parse(savedSettings));
    }
  }, []);

  // Save settings to localStorage
  const updateSettings = (newSettings) => {
    setSettings(newSettings);
    localStorage.setItem('ustam_notification_settings', JSON.stringify(newSettings));
  };

  // Mark notification as read
  const markAsRead = (notificationId) => {
    setNotifications(prev => 
      prev.map(notification => 
        notification.id === notificationId 
          ? { ...notification, read: true }
          : notification
      )
    );
    setUnreadCount(prev => Math.max(0, prev - 1));
  };

  // Mark all notifications as read
  const markAllAsRead = () => {
    setNotifications(prev => 
      prev.map(notification => ({ ...notification, read: true }))
    );
    setUnreadCount(0);
  };

  // Delete notification
  const deleteNotification = (notificationId) => {
    setNotifications(prev => {
      const notification = prev.find(n => n.id === notificationId);
      const newNotifications = prev.filter(n => n.id !== notificationId);
      
      if (notification && !notification.read) {
        setUnreadCount(prevCount => Math.max(0, prevCount - 1));
      }
      
      return newNotifications;
    });
  };

  // Clear all notifications
  const clearAllNotifications = () => {
    setNotifications([]);
    setUnreadCount(0);
  };

  // Add new notification (for real-time updates)
  const addNotification = (notification) => {
    const newNotification = {
      ...notification,
      id: Date.now(),
      timestamp: new Date(),
      read: false
    };
    
    setNotifications(prev => [newNotification, ...prev]);
    setUnreadCount(prev => prev + 1);
    
    // Show browser notification if enabled
    if (settings.push && 'Notification' in window && Notification.permission === 'granted') {
      new Notification(notification.title, {
        body: notification.message,
        icon: '/favicon.ico',
        tag: notification.type
      });
    }
  };

  // Request notification permission
  const requestNotificationPermission = async () => {
    if ('Notification' in window && Notification.permission === 'default') {
      const permission = await Notification.requestPermission();
      return permission === 'granted';
    }
    return Notification.permission === 'granted';
  };

  // Simulate real-time notifications
  useEffect(() => {
    if (!user) return;

    const interval = setInterval(() => {
      // Randomly add new notifications (simulation)
      if (Math.random() < 0.1) { // 10% chance every 30 seconds
        const notificationTypes = user.user_type === 'craftsman' 
          ? ['job', 'message', 'review', 'payment']
          : ['proposal', 'message', 'job', 'reminder'];
        
        const randomType = notificationTypes[Math.floor(Math.random() * notificationTypes.length)];
        
        const mockNotifications = {
          job: {
            type: 'job',
            title: 'Yeni İş Talebi',
            message: 'Size uygun yeni bir iş talebi var',
            priority: 'high',
            actionUrl: '/jobs'
          },
          message: {
            type: 'message',
            title: 'Yeni Mesaj',
            message: 'Yeni bir mesajınız var',
            priority: 'normal',
            actionUrl: '/messages'
          },
          proposal: {
            type: 'proposal',
            title: 'Yeni Teklif',
            message: 'İşiniz için yeni teklif geldi',
            priority: 'high',
            actionUrl: '/proposals'
          },
          review: {
            type: 'review',
            title: 'Yeni Değerlendirme',
            message: 'Yeni bir değerlendirme aldınız',
            priority: 'normal',
            actionUrl: '/reviews'
          },
          payment: {
            type: 'payment',
            title: 'Ödeme Bildirimi',
            message: 'Ödemeniz işleme alındı',
            priority: 'normal',
            actionUrl: '/analytics'
          },
          reminder: {
            type: 'reminder',
            title: 'Hatırlatma',
            message: 'Bekleyen işlemleriniz var',
            priority: 'low',
            actionUrl: '/dashboard'
          }
        };

        addNotification(mockNotifications[randomType]);
      }
    }, 30000); // Check every 30 seconds

    return () => clearInterval(interval);
  }, [user, settings.push]);

  const value = {
    notifications,
    unreadCount,
    settings,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    clearAllNotifications,
    addNotification,
    updateSettings,
    requestNotificationPermission
  };

  return (
    <NotificationContext.Provider value={value}>
      {children}
    </NotificationContext.Provider>
  );
};

export default NotificationProvider;