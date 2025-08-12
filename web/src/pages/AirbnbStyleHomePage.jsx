import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import AirbnbCategoryCard from '../components/AirbnbCategoryCard';
import AirbnbBottomNavigation from '../components/AirbnbBottomNavigation';

// Icons (you can replace with your preferred icon library)
const Icons = {
  search: '🔍',
  favorite: '❤️',
  calendar: '📅',
  message: '💬',
  profile: '👤',
  home: '🏠',
  tools: '🔧',
  plumbing: '🚰',
  electrical: '⚡',
  cleaning: '🧹',
  painting: '🎨',
  gardening: '🌱',
  moving: '📦',
  security: '🔒',
  hvac: '❄️',
  roofing: '🏠',
  flooring: '🟫',
  furniture: '🪑',
  appliance: '🔌',
  pest: '🐜'
};

const AirbnbStyleHomePage = () => {
  const navigate = useNavigate();
  const [selectedIndex, setSelectedIndex] = useState(0);

  // Kategori verileri - ustam projesine özgü
  const categories = [
    { icon: Icons.tools, label: 'Genel Ustalar', id: 'general' },
    { icon: Icons.plumbing, label: 'Tesisatçı', id: 'plumbing' },
    { icon: Icons.electrical, label: 'Elektrikçi', id: 'electrical' },
    { icon: Icons.cleaning, label: 'Temizlik', id: 'cleaning' },
    { icon: Icons.painting, label: 'Boya', id: 'painting' },
    { icon: Icons.gardening, label: 'Bahçe', id: 'gardening' },
    { icon: Icons.moving, label: 'Nakliye', id: 'moving' },
    { icon: Icons.security, label: 'Güvenlik', id: 'security' },
    { icon: Icons.hvac, label: 'Klima', id: 'hvac' },
    { icon: Icons.roofing, label: 'Çatı', id: 'roofing' },
    { icon: Icons.flooring, label: 'Zemin', id: 'flooring' },
    { icon: Icons.furniture, label: 'Mobilya', id: 'furniture' },
    { icon: Icons.appliance, label: 'Beyaz Eşya', id: 'appliance' },
    { icon: Icons.pest, label: 'İlaçlama', id: 'pest' }
  ];

  // Bottom navigation items
  const bottomNavItems = [
    {
      icon: Icons.search,
      activeIcon: Icons.search,
      label: 'Keşfet'
    },
    {
      icon: Icons.favorite,
      activeIcon: Icons.favorite,
      label: 'Favoriler'
    },
    {
      icon: Icons.calendar,
      activeIcon: Icons.calendar,
      label: 'İşlerim'
    },
    {
      icon: Icons.message,
      activeIcon: Icons.message,
      label: 'Mesajlar'
    },
    {
      icon: Icons.profile,
      activeIcon: Icons.profile,
      label: 'Profil'
    }
  ];

  // Sayfa içerikleri
  const pages = [
    // Keşfet sayfası
    <div key="discover" className="p-4">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-airbnb-dark-900 dark:text-white mb-2">
          Hangi hizmete ihtiyacınız var?
        </h1>
        <p className="text-airbnb-dark-600 dark:text-airbnb-light-400">
          Güvenilir ustaları keşfedin
        </p>
      </div>
      
      {/* Kategori kartları */}
      <div className="mb-6">
        <h2 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-4">
          Kategoriler
        </h2>
        <div className="grid grid-cols-4 gap-4">
          {categories.map((category, index) => (
            <AirbnbCategoryCard
              key={category.id}
              icon={category.icon}
              label={category.label}
              onTap={() => navigate(`/search?category=${category.id}`)}
            />
          ))}
        </div>
      </div>

      {/* Öne çıkan ustalar */}
      <div className="mb-6">
        <h2 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-4">
          Öne Çıkan Ustalar
        </h2>
        <div className="space-y-4">
          {[1, 2, 3].map((item) => (
            <div key={item} className="listing-card" onClick={() => navigate('/craftsman/1')}>
              <div className="flex items-center p-4">
                <div className="w-16 h-16 bg-airbnb-light-200 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center text-2xl mr-4">
                  👨‍🔧
                </div>
                <div className="flex-1">
                  <h3 className="listing-title">Ahmet Usta</h3>
                  <p className="listing-subtitle">Elektrikçi • 4.8 ⭐</p>
                  <p className="text-airbnb-500 font-semibold">₺150/saat</p>
                </div>
                <div className="text-airbnb-500">
                  →
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>,

    // Favoriler sayfası
    <div key="favorites" className="p-4">
      <h1 className="text-2xl font-bold text-airbnb-dark-900 dark:text-white mb-4">
        Favori Ustalarım
      </h1>
      <div className="space-y-4">
        {[1, 2].map((item) => (
          <div key={item} className="listing-card">
            <div className="flex items-center p-4">
              <div className="w-16 h-16 bg-airbnb-light-200 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center text-2xl mr-4">
                👨‍🔧
              </div>
              <div className="flex-1">
                <h3 className="listing-title">Mehmet Usta</h3>
                <p className="listing-subtitle">Tesisatçı • 4.9 ⭐</p>
                <p className="text-airbnb-500 font-semibold">₺200/saat</p>
              </div>
              <button className="text-airbnb-500 text-2xl">❤️</button>
            </div>
          </div>
        ))}
      </div>
    </div>,

    // İşlerim sayfası
    <div key="jobs" className="p-4">
      <h1 className="text-2xl font-bold text-airbnb-dark-900 dark:text-white mb-4">
        İşlerim
      </h1>
      <div className="space-y-4">
        {[1, 2, 3].map((item) => (
          <div key={item} className="listing-card">
            <div className="p-4">
              <div className="flex items-center justify-between mb-2">
                <h3 className="listing-title">Elektrik Arızası</h3>
                <span className="badge badge-primary">Devam Ediyor</span>
              </div>
              <p className="listing-subtitle">Ahmet Usta • 2 saat önce</p>
              <p className="text-airbnb-500 font-semibold">₺300</p>
            </div>
          </div>
        ))}
      </div>
    </div>,

    // Mesajlar sayfası
    <div key="messages" className="p-4">
      <h1 className="text-2xl font-bold text-airbnb-dark-900 dark:text-white mb-4">
        Mesajlar
      </h1>
      <div className="space-y-4">
        {[1, 2, 3].map((item) => (
          <div key={item} className="listing-card" onClick={() => navigate('/messages/1')}>
            <div className="flex items-center p-4">
              <div className="w-12 h-12 bg-airbnb-light-200 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center text-xl mr-4">
                👨‍🔧
              </div>
              <div className="flex-1">
                <h3 className="listing-title">Ahmet Usta</h3>
                <p className="listing-subtitle">Merhaba, ne zaman gelebilirsiniz?</p>
                <p className="text-xs text-airbnb-dark-500 dark:text-airbnb-light-500">2 saat önce</p>
              </div>
              <div className="w-3 h-3 bg-airbnb-500 rounded-full"></div>
            </div>
          </div>
        ))}
      </div>
    </div>,

    // Profil sayfası
    <div key="profile" className="p-4">
      <div className="profile-header mb-6">
        <div className="flex items-center">
          <div className="profile-avatar bg-airbnb-light-200 dark:bg-airbnb-dark-700 flex items-center justify-center text-2xl mr-4">
            👤
          </div>
          <div>
            <h1 className="text-xl font-bold">Kullanıcı Adı</h1>
            <p className="opacity-90">Müşteri</p>
          </div>
        </div>
        <div className="profile-stats">
          <div className="profile-stat">
            <div className="profile-stat-value">12</div>
            <div className="profile-stat-label">Tamamlanan İş</div>
          </div>
          <div className="profile-stat">
            <div className="profile-stat-value">8</div>
            <div className="profile-stat-label">Favori Usta</div>
          </div>
          <div className="profile-stat">
            <div className="profile-stat-value">4.8</div>
            <div className="profile-stat-label">Puan</div>
          </div>
        </div>
      </div>

      <div className="space-y-4">
        <div className="settings-item" onClick={() => navigate('/profile/edit')}>
          <div>
            <div className="settings-label">Profili Düzenle</div>
            <div className="settings-description">Kişisel bilgilerinizi güncelleyin</div>
          </div>
          <span>→</span>
        </div>
        <div className="settings-item" onClick={() => navigate('/payment-history')}>
          <div>
            <div className="settings-label">Ödeme Geçmişi</div>
            <div className="settings-description">Geçmiş ödemelerinizi görüntüleyin</div>
          </div>
          <span>→</span>
        </div>
        <div className="settings-item" onClick={() => navigate('/notifications')}>
          <div>
            <div className="settings-label">Bildirimler</div>
            <div className="settings-description">Bildirim ayarlarınızı yönetin</div>
          </div>
          <span>→</span>
        </div>
        <div className="settings-item" onClick={() => navigate('/support')}>
          <div>
            <div className="settings-label">Destek</div>
            <div className="settings-description">Yardım ve destek alın</div>
          </div>
          <span>→</span>
        </div>
      </div>
    </div>
  ];

  const handleItemTapped = (index) => {
    setSelectedIndex(index);
  };

  return (
    <div className="min-h-screen bg-airbnb-light-50 dark:bg-airbnb-dark-900">
      {/* Header */}
      <div className="bg-white dark:bg-airbnb-dark-800 shadow-airbnb px-4 py-3">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-bold text-airbnb-dark-900 dark:text-white">
            ustam
          </h1>
          <div className="flex items-center space-x-3">
            <button className="w-8 h-8 bg-airbnb-light-100 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center">
              🔔
            </button>
            <button className="w-8 h-8 bg-airbnb-light-100 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center">
              ⚙️
            </button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="pb-24">
        {pages[selectedIndex]}
      </div>

      {/* Bottom Navigation */}
      <AirbnbBottomNavigation
        selectedIndex={selectedIndex}
        onItemTapped={handleItemTapped}
        items={bottomNavItems}
      />
    </div>
  );
};

export default AirbnbStyleHomePage;