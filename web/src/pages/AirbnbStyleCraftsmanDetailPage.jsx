import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';

const AirbnbStyleCraftsmanDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [selectedTab, setSelectedTab] = useState('overview');

  // Mock data - gerçek uygulamada API'den gelecek
  const craftsman = {
    id: id,
    name: 'Ahmet Usta',
    category: 'Elektrikçi',
    rating: 4.8,
    reviews: 127,
    price: 150,
    location: 'Kadıköy, İstanbul',
    image: '👨‍🔧',
    verified: true,
    available: true,
    experience: '15 yıl',
    languages: ['Türkçe', 'İngilizce'],
    description: '15 yıllık deneyimimle elektrik tesisatı, aydınlatma, priz montajı ve tüm elektrik işlerinizde hizmet veriyorum. Güvenilir, kaliteli ve uygun fiyatlı hizmet garantisi.',
    services: [
      'Elektrik Tesisatı',
      'Aydınlatma Sistemleri',
      'Priz Montajı',
      'Elektrik Arıza Giderme',
      'Güvenlik Sistemleri',
      'Akıllı Ev Sistemleri'
    ],
    photos: [
      'https://via.placeholder.com/300x200/FF5A5F/FFFFFF?text=İş+1',
      'https://via.placeholder.com/300x200/00A699/FFFFFF?text=İş+2',
      'https://via.placeholder.com/300x200/222222/FFFFFF?text=İş+3'
    ],
    reviews: [
      {
        id: 1,
        user: 'Ayşe K.',
        rating: 5,
        date: '2 gün önce',
        comment: 'Çok profesyonel ve hızlı bir şekilde işimi halletti. Kesinlikle tavsiye ederim!'
      },
      {
        id: 2,
        user: 'Mehmet Y.',
        rating: 4,
        date: '1 hafta önce',
        comment: 'İşini iyi yapıyor ama biraz geç geldi. Genel olarak memnunum.'
      },
      {
        id: 3,
        user: 'Fatma S.',
        rating: 5,
        date: '2 hafta önce',
        comment: 'Harika bir iş çıkardı. Fiyatı da çok uygun. Teşekkürler!'
      }
    ]
  };

  const renderStars = (rating) => {
    return '⭐'.repeat(Math.floor(rating)) + '☆'.repeat(5 - Math.floor(rating));
  };

  const tabs = [
    { id: 'overview', label: 'Genel Bakış' },
    { id: 'services', label: 'Hizmetler' },
    { id: 'reviews', label: 'Değerlendirmeler' },
    { id: 'photos', label: 'Fotoğraflar' }
  ];

  const renderTabContent = () => {
    switch (selectedTab) {
      case 'overview':
        return (
          <div className="space-y-4">
            <div className="card">
              <div className="card-body">
                <h3 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-3">
                  Hakkında
                </h3>
                <p className="text-airbnb-dark-700 dark:text-airbnb-light-300">
                  {craftsman.description}
                </p>
              </div>
            </div>

            <div className="card">
              <div className="card-body">
                <h3 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-3">
                  Bilgiler
                </h3>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span className="text-airbnb-dark-600 dark:text-airbnb-light-400">Deneyim:</span>
                    <span className="text-airbnb-dark-900 dark:text-white">{craftsman.experience}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-airbnb-dark-600 dark:text-airbnb-light-400">Diller:</span>
                    <span className="text-airbnb-dark-900 dark:text-white">{craftsman.languages.join(', ')}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-airbnb-dark-600 dark:text-airbnb-light-400">Konum:</span>
                    <span className="text-airbnb-dark-900 dark:text-white">{craftsman.location}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        );

      case 'services':
        return (
          <div className="card">
            <div className="card-body">
              <h3 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-4">
                Hizmetler
              </h3>
              <div className="grid grid-cols-2 gap-3">
                {craftsman.services.map((service, index) => (
                  <div key={index} className="chip">
                    {service}
                  </div>
                ))}
              </div>
            </div>
          </div>
        );

      case 'reviews':
        return (
          <div className="space-y-4">
            {craftsman.reviews.map((review) => (
              <div key={review.id} className="review-card">
                <div className="review-header">
                  <div className="review-avatar bg-airbnb-light-200 dark:bg-airbnb-dark-700 flex items-center justify-center text-lg">
                    {review.user.charAt(0)}
                  </div>
                  <div className="flex-1">
                    <div className="review-author">{review.user}</div>
                    <div className="review-date">{review.date}</div>
                  </div>
                  <div className="review-rating">
                    {renderStars(review.rating)}
                  </div>
                </div>
                <div className="review-text">{review.comment}</div>
              </div>
            ))}
          </div>
        );

      case 'photos':
        return (
          <div className="grid grid-cols-2 gap-4">
            {craftsman.photos.map((photo, index) => (
              <div key={index} className="aspect-square rounded-2xl overflow-hidden">
                <img 
                  src={photo} 
                  alt={`İş ${index + 1}`}
                  className="w-full h-full object-cover"
                />
              </div>
            ))}
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-airbnb-light-50 dark:bg-airbnb-dark-900">
      {/* Header */}
      <div className="bg-white dark:bg-airbnb-dark-800 shadow-airbnb px-4 py-3">
        <div className="flex items-center space-x-3">
          <button 
            onClick={() => navigate(-1)}
            className="w-8 h-8 bg-airbnb-light-100 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center"
          >
            ←
          </button>
          <div className="flex-1">
            <h1 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white">
              Usta Profili
            </h1>
          </div>
          <button className="w-8 h-8 bg-airbnb-light-100 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center">
            ❤️
          </button>
        </div>
      </div>

      {/* Profile Header */}
      <div className="bg-white dark:bg-airbnb-dark-800 p-4">
        <div className="flex items-center space-x-4">
          <div className="relative">
            <div className="w-20 h-20 bg-airbnb-light-200 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center text-3xl">
              {craftsman.image}
            </div>
            {craftsman.verified && (
              <div className="absolute -top-1 -right-1 w-8 h-8 bg-airbnb-500 rounded-full flex items-center justify-center text-white text-sm">
                ✓
              </div>
            )}
          </div>
          
          <div className="flex-1">
            <h2 className="text-xl font-bold text-airbnb-dark-900 dark:text-white">
              {craftsman.name}
            </h2>
            <p className="text-airbnb-dark-600 dark:text-airbnb-light-400">
              {craftsman.category}
            </p>
            <div className="flex items-center space-x-2 mt-1">
              <span className="text-sm">{renderStars(craftsman.rating)}</span>
              <span className="text-sm text-airbnb-dark-500 dark:text-airbnb-light-500">
                ({craftsman.reviews.length} değerlendirme)
              </span>
            </div>
            <p className="text-sm text-airbnb-dark-600 dark:text-airbnb-light-400 mt-1">
              📍 {craftsman.location}
            </p>
          </div>
        </div>

        <div className="mt-4 flex space-x-3">
          <button 
            className="btn btn-primary flex-1"
            onClick={() => navigate(`/job-request/new?craftsman=${craftsman.id}`)}
          >
            İş Talebi Oluştur
          </button>
          <button 
            className="btn btn-outline"
            onClick={() => navigate(`/messages/${craftsman.id}`)}
          >
            Mesaj Gönder
          </button>
        </div>

        <div className="mt-4 p-3 bg-airbnb-light-50 dark:bg-airbnb-dark-700 rounded-xl">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-airbnb-dark-600 dark:text-airbnb-light-400">
                Saatlik Ücret
              </p>
              <p className="text-xl font-bold text-airbnb-500">
                ₺{craftsman.price}
              </p>
            </div>
            <div className="text-right">
              <p className="text-sm text-airbnb-dark-600 dark:text-airbnb-light-400">
                Durum
              </p>
              <p className={`text-sm font-medium ${craftsman.available ? 'text-success-500' : 'text-error-500'}`}>
                {craftsman.available ? 'Müsait' : 'Müsait Değil'}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white dark:bg-airbnb-dark-800 border-t border-airbnb-light-200 dark:border-airbnb-dark-700">
        <div className="tab-nav">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              className={`tab-item ${selectedTab === tab.id ? 'tab-item-active' : ''}`}
              onClick={() => setSelectedTab(tab.id)}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Tab Content */}
      <div className="p-4">
        {renderTabContent()}
      </div>
    </div>
  );
};

export default AirbnbStyleCraftsmanDetailPage;