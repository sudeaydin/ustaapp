import React, { useState, useEffect } from 'react';
import { useAuth } from '../../context/AuthContext';
import api from '../../utils/api';
import LoadingSpinner from '../ui/LoadingSpinner';
import ErrorMessage from '../ui/ErrorMessage';
import { formatDate, formatTime } from '../../utils/formatters';

const NotificationCenter = () => {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('preferences');
  const [preferences, setPreferences] = useState(null);
  const [analytics, setAnalytics] = useState(null);
  const [locationShares, setLocationShares] = useState([]);
  const [scheduledNotifications, setScheduledNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [pushSupported, setPushSupported] = useState(false);

  useEffect(() => {
    checkPushSupport();
    loadNotificationData();
  }, [activeTab]);

  const checkPushSupport = () => {
    setPushSupported('Notification' in window && 'serviceWorker' in navigator);
  };

  const loadNotificationData = async () => {
    setLoading(true);
    setError(null);
    
    try {
      switch (activeTab) {
        case 'preferences':
          const prefsResponse = await api.getNotificationPreferences();
          setPreferences(prefsResponse.data);
          break;
        case 'analytics':
          const analyticsResponse = await api.getNotificationAnalytics();
          setAnalytics(analyticsResponse.data);
          break;
        case 'location':
          const locationResponse = await api.getLocationShares();
          setLocationShares(locationResponse.data);
          break;
        case 'scheduled':
          const scheduledResponse = await api.getScheduledNotifications();
          setScheduledNotifications(scheduledResponse.data);
          break;
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const requestPushPermission = async () => {
    if (!pushSupported) {
      alert('Push notifications are not supported in this browser');
      return;
    }

    try {
      const permission = await Notification.requestPermission();
      if (permission === 'granted') {
        // Register service worker and get FCM token
        const registration = await navigator.serviceWorker.register('/sw.js');
        // In a real implementation, you would get the FCM token here
        const token = 'mock-fcm-token-' + Date.now();
        
        await api.registerDeviceToken({
          token,
          device_type: 'web',
          device_info: {
            browser: navigator.userAgent,
            platform: navigator.platform
          }
        });
        
        alert('Push notifications enabled successfully!');
        loadNotificationData();
      }
    } catch (err) {
      setError('Failed to enable push notifications: ' + err.message);
    }
  };

  const updatePreferences = async (newPreferences) => {
    try {
      await api.updateNotificationPreferences(newPreferences);
      setPreferences(newPreferences);
    } catch (err) {
      setError('Failed to update preferences: ' + err.message);
    }
  };

  const startLocationSharing = async () => {
    if (!navigator.geolocation) {
      alert('Geolocation is not supported by this browser');
      return;
    }

    try {
      const position = await new Promise((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(resolve, reject);
      });

      const shareData = {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
        duration_minutes: 60,
        purpose: 'job_tracking',
        allowed_users: []
      };

      await api.createLocationShare(shareData);
      loadNotificationData();
    } catch (err) {
      setError('Failed to start location sharing: ' + err.message);
    }
  };

  const stopLocationSharing = async (shareId) => {
    try {
      await api.stopLocationShare(shareId);
      loadNotificationData();
    } catch (err) {
      setError('Failed to stop location sharing: ' + err.message);
    }
  };

  const createCalendarEvent = async () => {
    try {
      const eventData = {
        title: 'Test Job Reminder',
        description: 'This is a test calendar event',
        start_time: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        end_time: new Date(Date.now() + 25 * 60 * 60 * 1000).toISOString(),
        location: 'Test Location',
        attendees: [user.email]
      };

      const response = await api.createCalendarEvent(eventData);
      if (response.success) {
        // Download the iCal file
        const downloadUrl = `/api/notifications/enhanced/calendar/events/${response.data.event_id}.ics`;
        const link = document.createElement('a');
        link.href = downloadUrl;
        link.download = `${eventData.title}.ics`;
        link.click();
      }
    } catch (err) {
      setError('Failed to create calendar event: ' + err.message);
    }
  };

  const sendTestNotification = async () => {
    try {
      await api.testNotification({
        type: 'info',
        title: 'Test Notification',
        message: 'This is a test notification from the notification center',
        channels: ['push', 'email']
      });
      alert('Test notification sent!');
    } catch (err) {
      setError('Failed to send test notification: ' + err.message);
    }
  };

  const tabs = [
    { id: 'preferences', label: 'Tercihler', icon: '⚙️' },
    { id: 'analytics', label: 'Analitik', icon: '📊' },
    { id: 'location', label: 'Konum Paylaşımı', icon: '📍' },
    { id: 'scheduled', label: 'Zamanlanmış', icon: '⏰' }
  ];

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-indigo-600 text-white p-6">
          <h1 className="text-2xl font-bold mb-2">Bildirim Merkezi</h1>
          <p className="text-blue-100">Bildirim ayarlarınızı yönetin ve analitikleri görüntüleyin</p>
        </div>

        {/* Error Message */}
        {error && (
          <div className="p-4">
            <ErrorMessage message={error} onClose={() => setError(null)} />
          </div>
        )}

        {/* Tabs */}
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`py-4 px-2 border-b-2 font-medium text-sm transition-colors ${
                  activeTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <span className="mr-2">{tab.icon}</span>
                {tab.label}
              </button>
            ))}
          </nav>
        </div>

        {/* Content */}
        <div className="p-6">
          {activeTab === 'preferences' && (
            <div className="space-y-6">
              <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                <div className="flex items-center">
                  <span className="text-yellow-600 text-xl mr-3">🔔</span>
                  <div>
                    <h3 className="font-medium text-yellow-800">Push Bildirimleri</h3>
                    <p className="text-yellow-700 text-sm">
                      {pushSupported 
                        ? 'Tarayıcınız push bildirimlerini destekliyor' 
                        : 'Tarayıcınız push bildirimlerini desteklemiyor'}
                    </p>
                  </div>
                  {pushSupported && (
                    <button
                      onClick={requestPushPermission}
                      className="ml-auto bg-yellow-600 text-white px-4 py-2 rounded-lg hover:bg-yellow-700 transition-colors"
                    >
                      Etkinleştir
                    </button>
                  )}
                </div>
              </div>

              {preferences && (
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold">Bildirim Tercihleri</h3>
                  
                  {/* Notification Types */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {Object.entries(preferences.types || {}).map(([type, enabled]) => (
                      <div key={type} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                        <div>
                          <h4 className="font-medium capitalize">{type.replace('_', ' ')}</h4>
                          <p className="text-gray-600 text-sm">
                            {type === 'quote_updates' && 'Teklif güncellemeleri'}
                            {type === 'job_updates' && 'İş güncellemeleri'}
                            {type === 'messages' && 'Yeni mesajlar'}
                            {type === 'reminders' && 'Hatırlatmalar'}
                            {type === 'emergency' && 'Acil durumlar'}
                          </p>
                        </div>
                        <label className="relative inline-flex items-center cursor-pointer">
                          <input
                            type="checkbox"
                            checked={enabled}
                            onChange={(e) => updatePreferences({
                              ...preferences,
                              types: { ...preferences.types, [type]: e.target.checked }
                            })}
                            className="sr-only peer"
                          />
                          <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                        </label>
                      </div>
                    ))}
                  </div>

                  {/* Quiet Hours */}
                  <div className="border border-gray-200 rounded-lg p-4">
                    <h4 className="font-medium mb-3">Sessiz Saatler</h4>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Başlangıç</label>
                        <input
                          type="time"
                          value={preferences.quiet_hours?.start || '22:00'}
                          onChange={(e) => updatePreferences({
                            ...preferences,
                            quiet_hours: { ...preferences.quiet_hours, start: e.target.value }
                          })}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Bitiş</label>
                        <input
                          type="time"
                          value={preferences.quiet_hours?.end || '08:00'}
                          onChange={(e) => updatePreferences({
                            ...preferences,
                            quiet_hours: { ...preferences.quiet_hours, end: e.target.value }
                          })}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        />
                      </div>
                    </div>
                  </div>

                  {/* Test Notification */}
                  <div className="border border-gray-200 rounded-lg p-4">
                    <h4 className="font-medium mb-3">Test Bildirimi</h4>
                    <button
                      onClick={sendTestNotification}
                      className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                    >
                      Test Bildirimi Gönder
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'analytics' && analytics && (
            <div className="space-y-6">
              <h3 className="text-lg font-semibold">Bildirim Analitikleri</h3>
              
              {/* Metrics Grid */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <div className="text-2xl font-bold text-blue-600">{analytics.total_sent || 0}</div>
                  <div className="text-blue-800 text-sm">Toplam Gönderilen</div>
                </div>
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <div className="text-2xl font-bold text-green-600">{analytics.delivered || 0}</div>
                  <div className="text-green-800 text-sm">Teslim Edilen</div>
                </div>
                <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                  <div className="text-2xl font-bold text-yellow-600">{analytics.opened || 0}</div>
                  <div className="text-yellow-800 text-sm">Açılan</div>
                </div>
                <div className="bg-purple-50 border border-purple-200 rounded-lg p-4">
                  <div className="text-2xl font-bold text-purple-600">
                    {analytics.total_sent > 0 ? Math.round((analytics.opened / analytics.total_sent) * 100) : 0}%
                  </div>
                  <div className="text-purple-800 text-sm">Açılma Oranı</div>
                </div>
              </div>

              {/* Channel Performance */}
              {analytics.by_channel && (
                <div>
                  <h4 className="font-medium mb-3">Kanal Performansı</h4>
                  <div className="space-y-2">
                    {Object.entries(analytics.by_channel).map(([channel, stats]) => (
                      <div key={channel} className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
                        <div className="flex items-center">
                          <span className="text-lg mr-3">
                            {channel === 'push' && '📱'}
                            {channel === 'email' && '📧'}
                            {channel === 'sms' && '💬'}
                          </span>
                          <span className="font-medium capitalize">{channel}</span>
                        </div>
                        <div className="text-right">
                          <div className="text-sm text-gray-600">
                            {stats.delivered}/{stats.sent} teslim edildi
                          </div>
                          <div className="text-xs text-gray-500">
                            %{stats.sent > 0 ? Math.round((stats.delivered / stats.sent) * 100) : 0} başarı
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'location' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold">Konum Paylaşımı</h3>
                <button
                  onClick={startLocationSharing}
                  className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors"
                >
                  Konum Paylaşımını Başlat
                </button>
              </div>

              {locationShares.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <span className="text-4xl mb-4 block">📍</span>
                  <p>Aktif konum paylaşımı yok</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {locationShares.map((share) => (
                    <div key={share.id} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <h4 className="font-medium">{share.purpose}</h4>
                          <p className="text-gray-600 text-sm">
                            Başladı: {formatDate(share.created_at)}
                          </p>
                          <p className="text-gray-600 text-sm">
                            Bitiş: {formatDate(share.expires_at)}
                          </p>
                        </div>
                        <div className="flex items-center space-x-2">
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                            share.is_active 
                              ? 'bg-green-100 text-green-800' 
                              : 'bg-gray-100 text-gray-800'
                          }`}>
                            {share.is_active ? 'Aktif' : 'Pasif'}
                          </span>
                          {share.is_active && (
                            <button
                              onClick={() => stopLocationSharing(share.id)}
                              className="bg-red-600 text-white px-3 py-1 rounded text-xs hover:bg-red-700 transition-colors"
                            >
                              Durdur
                            </button>
                          )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {activeTab === 'scheduled' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold">Zamanlanmış Bildirimler</h3>
                <button
                  onClick={createCalendarEvent}
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Test Takvim Etkinliği Oluştur
                </button>
              </div>

              {scheduledNotifications.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <span className="text-4xl mb-4 block">⏰</span>
                  <p>Zamanlanmış bildirim yok</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {scheduledNotifications.map((notification) => (
                    <div key={notification.id} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <h4 className="font-medium">{notification.title}</h4>
                          <p className="text-gray-600 text-sm">{notification.message}</p>
                          <p className="text-gray-500 text-xs">
                            Gönderilecek: {formatDate(notification.scheduled_for)}
                          </p>
                        </div>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                          notification.status === 'pending'
                            ? 'bg-yellow-100 text-yellow-800'
                            : notification.status === 'sent'
                            ? 'bg-green-100 text-green-800'
                            : 'bg-red-100 text-red-800'
                        }`}>
                          {notification.status === 'pending' && 'Bekliyor'}
                          {notification.status === 'sent' && 'Gönderildi'}
                          {notification.status === 'failed' && 'Başarısız'}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default NotificationCenter;