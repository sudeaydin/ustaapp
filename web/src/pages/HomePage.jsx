import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';

export const HomePage = () => {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const [categories, setCategories] = useState([]);
  const [featuredCraftsmen, setFeaturedCraftsmen] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);

  useEffect(() => {
    fetchCategories();
    fetchFeaturedCraftsmen();
    if (user) {
      fetchUnreadCount();
    }
  }, [user]);

  const fetchCategories = async () => {
    try {
      const response = await api.get('/search/categories');
      if (response.success) {
        setCategories(response.data.slice(0, 6)); // Show first 6 categories
      }
    } catch (error) {
      console.error('Categories fetch error:', error);
      // Mock categories
      setCategories([
        { id: 1, name: 'Elektrikçi', icon: '⚡', color: 'bg-yellow-100' },
        { id: 2, name: 'Tesisatçı', icon: '🔧', color: 'bg-blue-100' },
        { id: 3, name: 'Boyacı', icon: '🎨', color: 'bg-green-100' },
        { id: 4, name: 'Temizlik', icon: '🧽', color: 'bg-purple-100' },
        { id: 5, name: 'Marangoz', icon: '🔨', color: 'bg-orange-100' },
        { id: 6, name: 'Bahçıvan', icon: '🌱', color: 'bg-green-100' }
      ]);
    }
  };

  const fetchFeaturedCraftsmen = async () => {
    try {
      const response = await api.get('/search/popular');
      if (response.success) {
        setFeaturedCraftsmen(response.data.top_craftsmen || []);
      }
    } catch (error) {
      console.error('Featured craftsmen fetch error:', error);
      // Mock data
      setFeaturedCraftsmen([
        {
          id: 1,
          name: 'Ahmet Yılmaz',
          business_name: 'Ahmet Usta Elektrik',
          average_rating: 4.9,
          total_reviews: 45,
          city: 'İstanbul'
        }
      ]);
    }
  };

  const fetchUnreadCount = async () => {
    try {
      const token = localStorage.getItem('authToken');
      const response = await fetch('/api/messages/unread-count', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      const data = await response.json();
      if (data.success) {
        setUnreadCount(data.data.unread_count);
      }
    } catch (error) {
      console.error('Unread count fetch error:', error);
    }
  };

  const handleCategoryClick = (categoryId) => {
    navigate(`/craftsmen?category=${categoryId}`);
  };

  const renderStars = (rating) => {
    const stars = [];
    const fullStars = Math.floor(rating);
    
    for (let i = 0; i < fullStars; i++) {
      stars.push(
        <svg key={i} className="w-4 h-4 text-yellow-400 fill-current" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
      );
    }
    
    const emptyStars = 5 - fullStars;
    for (let i = 0; i < emptyStars; i++) {
      stars.push(
        <svg key={`empty-${i}`} className="w-4 h-4 text-gray-300 fill-current" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
      );
    }
    
    return stars;
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                <svg className="w-6 h-6 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                </svg>
              </div>
              <div>
                <h1 className="text-lg font-semibold text-gray-900">
                  Merhaba, {user?.first_name || 'Kullanıcı'}!
                </h1>
                <p className="text-sm text-gray-600">Hangi hizmete ihtiyacınız var?</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-2">
              <button
                onClick={() => navigate('/messages')}
                className="relative p-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-full"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
                {unreadCount > 0 && (
                  <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                    {unreadCount}
                  </span>
                )}
              </button>
              
              <button
                onClick={() => navigate('/profile')}
                className="p-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-full"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Search Bar */}
      <div className="bg-white border-b">
        <div className="max-w-md mx-auto px-4 py-4">
          <button
            onClick={() => navigate('/craftsmen')}
            className="w-full flex items-center px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg text-left text-gray-500 hover:bg-gray-100"
          >
            <svg className="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            Usta ara...
          </button>
        </div>
      </div>

      <div className="max-w-md mx-auto px-4 py-6 space-y-6">
        {/* Quick Actions */}
        <div className="grid grid-cols-2 gap-4">
          <button
            onClick={() => navigate('/craftsmen')}
            className="bg-blue-500 text-white p-4 rounded-lg text-center hover:bg-blue-600 transition-colors"
          >
            <svg className="w-8 h-8 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <span className="font-medium">Usta Ara</span>
          </button>
          
          <button
            onClick={() => navigate('/messages')}
            className="bg-green-500 text-white p-4 rounded-lg text-center hover:bg-green-600 transition-colors relative"
          >
            <svg className="w-8 h-8 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <span className="font-medium">Mesajlarım</span>
            {unreadCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                {unreadCount}
              </span>
            )}
          </button>
        </div>

        {/* Categories */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Kategoriler</h2>
            <button
              onClick={() => navigate('/craftsmen')}
              className="text-sm text-blue-600 hover:text-blue-700"
            >
              Tümü
            </button>
          </div>
          
          <div className="grid grid-cols-3 gap-3">
            {categories.map((category) => (
              <button
                key={category.id}
                onClick={() => handleCategoryClick(category.id)}
                className={`${category.color || 'bg-gray-100'} p-4 rounded-lg text-center hover:opacity-80 transition-opacity`}
              >
                <div className="text-2xl mb-2">{category.icon || '🔧'}</div>
                <span className="text-sm font-medium text-gray-700">{category.name}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Featured Craftsmen */}
        {featuredCraftsmen.length > 0 && (
          <div>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900">Öne Çıkan Ustalar</h2>
              <button
                onClick={() => navigate('/craftsmen')}
                className="text-sm text-blue-600 hover:text-blue-700"
              >
                Tümü
              </button>
            </div>
            
            <div className="space-y-3">
              {featuredCraftsmen.map((craftsman) => (
                <div key={craftsman.id} className="bg-white rounded-lg shadow-sm border p-4">
                  <div className="flex items-center space-x-3">
                    <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                      <svg className="w-6 h-6 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                      </svg>
                    </div>
                    
                    <div className="flex-1">
                      <h3 className="font-semibold text-gray-900">{craftsman.name}</h3>
                      {craftsman.business_name && (
                        <p className="text-sm text-blue-600">{craftsman.business_name}</p>
                      )}
                      
                      <div className="flex items-center mt-1 space-x-2">
                        <div className="flex items-center">
                          {renderStars(craftsman.average_rating)}
                        </div>
                        <span className="text-sm text-gray-600">
                          {craftsman.average_rating?.toFixed(1)} ({craftsman.total_reviews})
                        </span>
                        {craftsman.city && (
                          <span className="text-sm text-gray-500">• {craftsman.city}</span>
                        )}
                      </div>
                    </div>
                    
                    <button
                      onClick={() => navigate(`/messages/${craftsman.id}`)}
                      className="px-3 py-1.5 bg-blue-600 text-white text-sm rounded-md hover:bg-blue-700"
                    >
                      İletişim
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Recent Activity */}
        <div>
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Son Aktiviteler</h2>
          <div className="bg-white rounded-lg shadow-sm border p-4">
            <div className="text-center py-8">
              <svg className="w-12 h-12 mx-auto text-gray-400 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <p className="text-gray-600">Henüz aktivite yok</p>
              <p className="text-sm text-gray-500 mt-1">İlk hizmet talebinizi oluşturun</p>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Navigation */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200">
        <div className="max-w-md mx-auto px-4">
          <div className="flex items-center justify-around py-2">
            <button
              onClick={() => navigate('/home')}
              className="flex flex-col items-center py-2 px-3 text-blue-600"
            >
              <svg className="w-6 h-6 mb-1" fill="currentColor" viewBox="0 0 20 20">
                <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
              </svg>
              <span className="text-xs font-medium">Ana Sayfa</span>
            </button>
            
            <button
              onClick={() => navigate('/craftsmen')}
              className="flex flex-col items-center py-2 px-3 text-gray-600"
            >
              <svg className="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              <span className="text-xs font-medium">Ara</span>
            </button>
            
            <button
              onClick={() => navigate('/messages')}
              className="flex flex-col items-center py-2 px-3 text-gray-600 relative"
            >
              <svg className="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
              </svg>
              <span className="text-xs font-medium">Mesajlar</span>
              {unreadCount > 0 && (
                <span className="absolute top-0 right-1 bg-red-500 text-white text-xs rounded-full h-4 w-4 flex items-center justify-center">
                  {unreadCount > 9 ? '9+' : unreadCount}
                </span>
              )}
            </button>
            
            <button
              onClick={() => navigate('/profile')}
              className="flex flex-col items-center py-2 px-3 text-gray-600"
            >
              <svg className="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
              <span className="text-xs font-medium">Profil</span>
            </button>
          </div>
        </div>
      </div>

      {/* Add bottom padding to account for fixed navigation */}
      <div className="pb-20"></div>
    </div>
  );
};
