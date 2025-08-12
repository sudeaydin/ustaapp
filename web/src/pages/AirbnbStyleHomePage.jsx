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
  pest: '🐜',
  quote: '💰',
  cart: '🛒',
  job: '🔨',
  review: '⭐',
  payment: '💳',
  notification: '🔔',
  settings: '⚙️'
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

  // Bottom navigation items - ustam özelliklerine göre
  const bottomNavItems = [
    {
      icon: Icons.search,
      activeIcon: Icons.search,
      label: 'Keşfet'
    },
    {
      icon: Icons.quote,
      activeIcon: Icons.quote,
      label: 'Teklifler'
    },
    {
      icon: Icons.job,
      activeIcon: Icons.job,
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

  // Sayfa içerikleri - ustam özellikleriyle
  const pages = [
    // Keşfet sayfası
    <div key="discover" className="p-4">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-airbnb-dark-900 dark:text-white mb-2">
          Hangi hizmete ihtiyacınız var?
        </h1>
        <p className="text-airbnb-dark-600 dark:text-airbnb-light-400">
          Güvenilir ustaları keşfedin ve teklif alın
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
              onTap={() => navigate(`/airbnb-style-search?category=${category.id}`)}
            />
          ))}
        </div>
      </div>

      {/* Hızlı İş Talebi */}
      <div className="mb-6">
        <div className="card">
          <div className="card-body">
            <h3 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-3">
              Hızlı İş Talebi Oluştur
            </h3>
            <p className="text-airbnb-dark-600 dark:text-airbnb-light-400 mb-4">
              İhtiyacınızı anlatın, ustalar size teklif versin
            </p>
            <button 
              className="btn btn-primary w-full"
              onClick={() => navigate('/airbnb-style-job-request')}
            >
              İş Talebi Oluştur
            </button>
          </div>
        </div>
      </div>

      {/* Öne çıkan ustalar */}
      <div className="mb-6">
        <h2 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-4">
          Öne Çıkan Ustalar
        </h2>
        <div className="space-y-4">
          {[1, 2, 3].map((item) => (
            <div key={item} className="listing-card" onClick={() => navigate('/airbnb-style-craftsman/1')}>
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

    // Teklifler sayfası - ustam özelliği
    <div key="quotes" className="p-4">
      <h1 className="text-2xl font-bold text-airbnb-dark-900 dark:text-white mb-4">
        Tekliflerim
      </h1>
      
      {/* Teklif durumları */}
      <div className="tab-nav mb-6">
        <button className="tab-item tab-item-active">Bekleyen (3)</button>
        <button className="tab-item">Kabul Edilen (2)</button>
        <button className="tab-item">Tamamlanan (8)</button>
      </div>

      <div className="space-y-4">
        {[1, 2, 3].map((item) => (
          <div key={item} className="listing-card">
            <div className="p-4">
              <div className="flex items-center justify-between mb-2">
                <h3 className="listing-title">Elektrik Arızası</h3>
                <span className="badge badge-primary">3 Teklif</span>
              </div>
              <p className="listing-subtitle">2 saat önce oluşturuldu</p>
              <div className="mt-3 space-y-2">
                <div className="flex items-center justify-between p-2 bg-airbnb-light-50 dark:bg-airbnb-dark-700 rounded-lg">
                  <div>
                    <p className="font-medium text-airbnb-dark-900 dark:text-white">Ahmet Usta</p>
                    <p className="text-sm text-airbnb-dark-600 dark:text-airbnb-light-400">4.8 ⭐ (127 değerlendirme)</p>
                  </div>
                  <div className="text-right">
                    <p className="text-airbnb-500 font-semibold">₺300</p>
                    <button className="btn btn-primary btn-sm mt-1">Kabul Et</button>
                  </div>
                </div>
                <div className="flex items-center justify-between p-2 bg-airbnb-light-50 dark:bg-airbnb-dark-700 rounded-lg">
                  <div>
                    <p className="font-medium text-airbnb-dark-900 dark:text-white">Mehmet Usta</p>
                    <p className="text-sm text-airbnb-dark-600 dark:text-airbnb-light-400">4.9 ⭐ (89 değerlendirme)</p>
                  </div>
                  <div className="text-right">
                    <p className="text-airbnb-500 font-semibold">₺350</p>
                    <button className="btn btn-primary btn-sm mt-1">Kabul Et</button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>,

    // İşlerim sayfası - ustam özelliği
    <div key="jobs" className="p-4">
      <h1 className="text-2xl font-bold text-airbnb-dark-900 dark:text-white mb-4">
        İşlerim
      </h1>
      
      {/* İş durumları */}
      <div className="tab-nav mb-6">
        <button className="tab-item tab-item-active">Devam Eden (2)</button>
        <button className="tab-item">Tamamlanan (12)</button>
        <button className="tab-item">İptal Edilen (1)</button>
      </div>

      <div className="space-y-4">
        {[1, 2, 3].map((item) => (
          <div key={item} className="listing-card">
            <div className="p-4">
              <div className="flex items-center justify-between mb-2">
                <h3 className="listing-title">Elektrik Arızası</h3>
                <span className="badge badge-primary">Devam Ediyor</span>
              </div>
              <p className="listing-subtitle">Ahmet Usta • 2 saat önce</p>
              <div className="mt-3">
                <div className="progress mb-2">
                  <div className="progress-bar" style={{width: '75%'}}></div>
                </div>
                <p className="text-sm text-airbnb-dark-600 dark:text-airbnb-light-400">%75 tamamlandı</p>
              </div>
              <p className="text-airbnb-500 font-semibold mt-2">₺300</p>
              <div className="flex space-x-2 mt-3">
                <button className="btn btn-outline btn-sm flex-1">Detaylar</button>
                <button className="btn btn-primary btn-sm flex-1">Mesaj</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>,

    // Mesajlar sayfası - ustam özelliği
    <div key="messages" className="p-4">
      <h1 className="text-2xl font-bold text-airbnb-dark-900 dark:text-white mb-4">
        Mesajlar
      </h1>
      
      {/* Mesaj kategorileri */}
      <div className="tab-nav mb-6">
        <button className="tab-item tab-item-active">Tümü</button>
        <button className="tab-item">Ustalar</button>
        <button className="tab-item">Destek</button>
      </div>

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

    // Profil sayfası - ustam özellikleriyle
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
        
        <div className="settings-item" onClick={() => navigate('/favorites')}>
          <div>
            <div className="settings-label">Favori Ustalar</div>
            <div className="settings-description">Kaydettiğiniz ustaları görüntüleyin</div>
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
        
        <div className="settings-item" onClick={() => navigate('/settings')}>
          <div>
            <div className="settings-label">Ayarlar</div>
            <div className="settings-description">Uygulama ayarlarınızı yönetin</div>
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
            <button 
              className="w-8 h-8 bg-airbnb-light-100 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center relative"
              onClick={() => navigate('/notifications')}
            >
              {Icons.notification}
              <div className="absolute -top-1 -right-1 w-3 h-3 bg-airbnb-500 rounded-full"></div>
            </button>
            <button 
              className="w-8 h-8 bg-airbnb-light-100 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center"
              onClick={() => navigate('/settings')}
            >
              {Icons.settings}
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