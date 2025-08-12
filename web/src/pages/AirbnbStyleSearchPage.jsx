import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import AirbnbCategoryCard from '../components/AirbnbCategoryCard';

const Icons = {
  search: '🔍',
  filter: '⚙️',
  location: '📍',
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

const AirbnbStyleSearchPage = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [showFilters, setShowFilters] = useState(false);
  const [priceRange, setPriceRange] = useState([0, 1000]);
  const [rating, setRating] = useState(0);

  const category = searchParams.get('category');

  useEffect(() => {
    if (category) {
      setSelectedCategory(category);
    }
  }, [category]);

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

  // Mock data - gerçek uygulamada API'den gelecek
  const craftsmen = [
    {
      id: 1,
      name: 'Ahmet Usta',
      category: 'Elektrikçi',
      rating: 4.8,
      reviews: 127,
      price: 150,
      location: 'Kadıköy, İstanbul',
      image: '👨‍🔧',
      verified: true,
      available: true
    },
    {
      id: 2,
      name: 'Mehmet Usta',
      category: 'Tesisatçı',
      rating: 4.9,
      reviews: 89,
      price: 200,
      location: 'Beşiktaş, İstanbul',
      image: '👨‍🔧',
      verified: true,
      available: true
    },
    {
      id: 3,
      name: 'Ali Usta',
      category: 'Boya',
      rating: 4.7,
      reviews: 156,
      price: 120,
      location: 'Şişli, İstanbul',
      image: '👨‍🔧',
      verified: false,
      available: false
    },
    {
      id: 4,
      name: 'Veli Usta',
      category: 'Temizlik',
      rating: 4.6,
      reviews: 203,
      price: 80,
      location: 'Bakırköy, İstanbul',
      image: '👨‍🔧',
      verified: true,
      available: true
    }
  ];

  const handleCategorySelect = (categoryId) => {
    setSelectedCategory(categoryId);
    navigate(`/airbnb-style-search?category=${categoryId}`);
  };

  const handleCraftsmanClick = (craftsmanId) => {
    navigate(`/craftsman/${craftsmanId}`);
  };

  const renderStars = (rating) => {
    return '⭐'.repeat(Math.floor(rating)) + '☆'.repeat(5 - Math.floor(rating));
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
            <input
              type="text"
              placeholder="Usta ara..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="search-bar"
            />
          </div>
          <button 
            onClick={() => setShowFilters(!showFilters)}
            className="w-8 h-8 bg-airbnb-light-100 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center"
          >
            {Icons.filter}
          </button>
        </div>
      </div>

      {/* Filters */}
      {showFilters && (
        <div className="bg-white dark:bg-airbnb-dark-800 shadow-airbnb p-4 mb-4">
          <h3 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-4">
            Filtreler
          </h3>
          
          {/* Price Range */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-airbnb-dark-700 dark:text-airbnb-light-300 mb-2">
              Fiyat Aralığı: ₺{priceRange[0]} - ₺{priceRange[1]}
            </label>
            <input
              type="range"
              min="0"
              max="1000"
              value={priceRange[1]}
              onChange={(e) => setPriceRange([priceRange[0], parseInt(e.target.value)])}
              className="w-full"
            />
          </div>

          {/* Rating */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-airbnb-dark-700 dark:text-airbnb-light-300 mb-2">
              Minimum Puan: {rating}
            </label>
            <div className="flex space-x-2">
              {[1, 2, 3, 4, 5].map((star) => (
                <button
                  key={star}
                  onClick={() => setRating(star)}
                  className={`text-2xl ${star <= rating ? 'text-airbnb-500' : 'text-airbnb-light-300'}`}
                >
                  ⭐
                </button>
              ))}
            </div>
          </div>

          {/* Location */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-airbnb-dark-700 dark:text-airbnb-light-300 mb-2">
              Konum
            </label>
            <input
              type="text"
              placeholder="Konum girin..."
              className="input"
            />
          </div>

          <button className="btn btn-primary w-full">
            Filtreleri Uygula
          </button>
        </div>
      )}

      {/* Categories */}
      <div className="p-4">
        <h2 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-4">
          Kategoriler
        </h2>
        <div className="grid grid-cols-4 gap-4 mb-6">
          {categories.map((cat) => (
            <AirbnbCategoryCard
              key={cat.id}
              icon={cat.icon}
              label={cat.label}
              isActive={selectedCategory === cat.id}
              onTap={() => handleCategorySelect(cat.id)}
            />
          ))}
        </div>

        {/* Results */}
        <div className="mb-4">
          <h2 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-4">
            {selectedCategory ? `${categories.find(c => c.id === selectedCategory)?.label} Ustaları` : 'Tüm Ustalar'}
          </h2>
          <p className="text-airbnb-dark-600 dark:text-airbnb-light-400 mb-4">
            {craftsmen.length} usta bulundu
          </p>
        </div>

        {/* Craftsmen List */}
        <div className="space-y-4">
          {craftsmen.map((craftsman) => (
            <div 
              key={craftsman.id} 
              className="listing-card"
              onClick={() => handleCraftsmanClick(craftsman.id)}
            >
              <div className="flex items-center p-4">
                <div className="relative">
                  <div className="w-16 h-16 bg-airbnb-light-200 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center text-2xl mr-4">
                    {craftsman.image}
                  </div>
                  {craftsman.verified && (
                    <div className="absolute -top-1 -right-1 w-6 h-6 bg-airbnb-500 rounded-full flex items-center justify-center text-white text-xs">
                      ✓
                    </div>
                  )}
                </div>
                
                <div className="flex-1">
                  <div className="flex items-center space-x-2 mb-1">
                    <h3 className="listing-title">{craftsman.name}</h3>
                    {!craftsman.available && (
                      <span className="badge badge-secondary">Müsait Değil</span>
                    )}
                  </div>
                  <p className="listing-subtitle">{craftsman.category}</p>
                  <div className="flex items-center space-x-2 mb-1">
                    <span className="text-sm">{renderStars(craftsman.rating)}</span>
                    <span className="text-sm text-airbnb-dark-500 dark:text-airbnb-light-500">
                      ({craftsman.reviews} değerlendirme)
                    </span>
                  </div>
                  <p className="text-sm text-airbnb-dark-600 dark:text-airbnb-light-400">
                    📍 {craftsman.location}
                  </p>
                </div>
                
                <div className="text-right">
                  <p className="text-airbnb-500 font-semibold">₺{craftsman.price}/saat</p>
                  <button className="btn btn-primary btn-sm mt-2">
                    İletişim
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default AirbnbStyleSearchPage;