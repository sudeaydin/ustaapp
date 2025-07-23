import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const CraftsmenSearchPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [searchParams, setSearchParams] = useSearchParams();
  
  // Search and Filter States
  const [searchQuery, setSearchQuery] = useState(searchParams.get('q') || '');
  const [selectedCategory, setSelectedCategory] = useState(searchParams.get('category') || '');
  const [selectedCity, setSelectedCity] = useState(searchParams.get('city') || '');
  const [selectedDistrict, setSelectedDistrict] = useState(searchParams.get('district') || '');
  const [priceRange, setPriceRange] = useState({
    min: searchParams.get('min_price') || '',
    max: searchParams.get('max_price') || ''
  });
  const [minRating, setMinRating] = useState(searchParams.get('min_rating') || '');
  const [sortBy, setSortBy] = useState(searchParams.get('sort') || 'rating');
  
  // Data States
  const [craftsmen, setCraftsmen] = useState([]);
  const [loading, setLoading] = useState(false);
  const [favorites, setFavorites] = useState(new Set());
  const [showFilters, setShowFilters] = useState(false);

  // Static Data
  const categories = [
    'Elektrikçi',
    'Tesisatçı', 
    'Boyacı',
    'Marangoz',
    'Tadilat',
    'Temizlik',
    'Klima Teknisyeni',
    'Cam Balkon',
    'Döşemeci',
    'Bahçıvan',
    'Cam Ustası',
    'Seramik Ustası'
  ];

  const cities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Adana'
  ];

  const districts = {
    'İstanbul': ['Kadıköy', 'Beşiktaş', 'Şişli', 'Beyoğlu', 'Fatih', 'Üsküdar', 'Bakırköy', 'Maltepe'],
    'Ankara': ['Çankaya', 'Keçiören', 'Yenimahalle', 'Mamak', 'Sincan'],
    'İzmir': ['Konak', 'Karşıyaka', 'Bornova', 'Buca', 'Çiğli']
  };

  // Mock Craftsmen Data
  const mockCraftsmen = [
    {
      id: 1,
      name: 'Ahmet Yılmaz',
      business_name: 'Yılmaz Elektrik',
      category: 'Elektrikçi',
      city: 'İstanbul',
      district: 'Kadıköy',
      rating: 4.8,
      review_count: 127,
      hourly_rate: 150,
      experience_years: 8,
      description: 'Ev ve işyeri elektrik tesisatı, LED aydınlatma, pano montajı konularında uzmanım.',
      avatar: null,
      is_verified: true,
      response_time: '2 saat',
      completed_jobs: 89,
      tags: ['Hızlı', 'Güvenilir', 'Deneyimli']
    },
    {
      id: 2,
      name: 'Mehmet Kaya',
      business_name: 'Kaya Tadilat',
      category: 'Tadilat',
      city: 'İstanbul',
      district: 'Şişli',
      rating: 4.9,
      review_count: 203,
      hourly_rate: 200,
      experience_years: 12,
      description: 'Kapsamlı tadilat işleri, banyo mutfak yenileme, döşeme ve boyama hizmetleri.',
      avatar: null,
      is_verified: true,
      response_time: '1 saat',
      completed_jobs: 156,
      tags: ['Kaliteli', 'Hızlı', 'Profesyonel']
    },
    {
      id: 3,
      name: 'Ali Demir',
      business_name: 'Demir Klima',
      category: 'Klima Teknisyeni',
      city: 'İstanbul',
      district: 'Beşiktaş',
      rating: 4.7,
      review_count: 95,
      hourly_rate: 120,
      experience_years: 6,
      description: 'Klima montaj, bakım, onarım. Tüm marka ve modellerde hizmet veriyorum.',
      avatar: null,
      is_verified: false,
      response_time: '3 saat',
      completed_jobs: 67,
      tags: ['Uygun Fiyat', 'Deneyimli']
    },
    {
      id: 4,
      name: 'Fatma Öz',
      business_name: 'Öz Temizlik',
      category: 'Temizlik',
      city: 'İstanbul',
      district: 'Kadıköy',
      rating: 4.6,
      review_count: 78,
      hourly_rate: 80,
      experience_years: 4,
      description: 'Ev temizliği, ofis temizliği, cam temizliği ve genel temizlik hizmetleri.',
      avatar: null,
      is_verified: true,
      response_time: '1 saat',
      completed_jobs: 45,
      tags: ['Titiz', 'Güvenilir']
    },
    {
      id: 5,
      name: 'Hasan Çelik',
      business_name: 'Çelik Tesisatçılık',
      category: 'Tesisatçı',
      city: 'İstanbul',
      district: 'Üsküdar',
      rating: 4.5,
      review_count: 112,
      hourly_rate: 130,
      experience_years: 10,
      description: 'Su tesisatı, doğalgaz tesisatı, sıhhi tesisat onarım ve montaj hizmetleri.',
      avatar: null,
      is_verified: true,
      response_time: '2 saat',
      completed_jobs: 78,
      tags: ['Deneyimli', 'Güvenilir']
    },
    {
      id: 6,
      name: 'Ayşe Kara',
      business_name: 'Kara Boyacılık',
      category: 'Boyacı',
      city: 'İstanbul',
      district: 'Bakırköy',
      rating: 4.4,
      review_count: 89,
      hourly_rate: 100,
      experience_years: 7,
      description: 'İç mekan boyama, dış cephe boyama, dekoratif boyama ve duvar kağıdı uygulaması.',
      avatar: null,
      is_verified: false,
      response_time: '4 saat',
      completed_jobs: 56,
      tags: ['Kaliteli', 'Uygun Fiyat']
    }
  ];

  // Filter and Search Logic
  const filterCraftsmen = () => {
    let filtered = [...mockCraftsmen];

    // Search query filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(craftsman => 
        craftsman.name.toLowerCase().includes(query) ||
        craftsman.business_name.toLowerCase().includes(query) ||
        craftsman.category.toLowerCase().includes(query) ||
        craftsman.description.toLowerCase().includes(query)
      );
    }

    // Category filter
    if (selectedCategory) {
      filtered = filtered.filter(craftsman => craftsman.category === selectedCategory);
    }

    // Location filters
    if (selectedCity) {
      filtered = filtered.filter(craftsman => craftsman.city === selectedCity);
    }
    if (selectedDistrict) {
      filtered = filtered.filter(craftsman => craftsman.district === selectedDistrict);
    }

    // Price range filter
    if (priceRange.min) {
      filtered = filtered.filter(craftsman => craftsman.hourly_rate >= parseInt(priceRange.min));
    }
    if (priceRange.max) {
      filtered = filtered.filter(craftsman => craftsman.hourly_rate <= parseInt(priceRange.max));
    }

    // Rating filter
    if (minRating) {
      filtered = filtered.filter(craftsman => craftsman.rating >= parseFloat(minRating));
    }

    // Sorting
    filtered.sort((a, b) => {
      switch (sortBy) {
        case 'rating':
          return b.rating - a.rating;
        case 'price_low':
          return a.hourly_rate - b.hourly_rate;
        case 'price_high':
          return b.hourly_rate - a.hourly_rate;
        case 'experience':
          return b.experience_years - a.experience_years;
        case 'reviews':
          return b.review_count - a.review_count;
        default:
          return b.rating - a.rating;
      }
    });

    return filtered;
  };

  // Update URL params when filters change
  const updateURLParams = () => {
    const params = new URLSearchParams();
    if (searchQuery) params.set('q', searchQuery);
    if (selectedCategory) params.set('category', selectedCategory);
    if (selectedCity) params.set('city', selectedCity);
    if (selectedDistrict) params.set('district', selectedDistrict);
    if (priceRange.min) params.set('min_price', priceRange.min);
    if (priceRange.max) params.set('max_price', priceRange.max);
    if (minRating) params.set('min_rating', minRating);
    if (sortBy !== 'rating') params.set('sort', sortBy);
    
    setSearchParams(params);
  };

  // Effects
  useEffect(() => {
    setCraftsmen(filterCraftsmen());
    updateURLParams();
  }, [searchQuery, selectedCategory, selectedCity, selectedDistrict, priceRange, minRating, sortBy]);

  // Handlers
  const handleSearch = (e) => {
    e.preventDefault();
    setCraftsmen(filterCraftsmen());
  };

  const clearFilters = () => {
    setSearchQuery('');
    setSelectedCategory('');
    setSelectedCity('');
    setSelectedDistrict('');
    setPriceRange({ min: '', max: '' });
    setMinRating('');
    setSortBy('rating');
    setSearchParams(new URLSearchParams());
  };

  const toggleFavorite = (craftsmanId) => {
    const newFavorites = new Set(favorites);
    if (newFavorites.has(craftsmanId)) {
      newFavorites.delete(craftsmanId);
    } else {
      newFavorites.add(craftsmanId);
    }
    setFavorites(newFavorites);
  };

  const renderStars = (rating) => {
    return Array.from({ length: 5 }, (_, i) => (
      <svg
        key={i}
        className={`w-4 h-4 ${i < Math.floor(rating) ? 'text-yellow-400' : 'text-gray-300'}`}
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
      </svg>
    ));
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => navigate(-1)}
                className="p-2 hover:bg-gray-100 rounded-full transition-colors"
              >
                <svg className="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </button>
              <div>
                <h1 className="text-xl font-semibold text-gray-900">
                  🔍 Usta Ara
                </h1>
                <p className="text-sm text-gray-600">
                  {craftsmen.length} usta bulundu
                </p>
              </div>
            </div>

            <button
              onClick={() => setShowFilters(!showFilters)}
              className="lg:hidden flex items-center space-x-2 px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.207A1 1 0 013 6.5V4z" />
              </svg>
              <span>Filtrele</span>
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="grid lg:grid-cols-4 gap-6">
          {/* Filters Sidebar */}
          <div className={`lg:col-span-1 ${showFilters ? 'block' : 'hidden lg:block'}`}>
            <div className="bg-white rounded-lg shadow-sm p-6 sticky top-24">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-medium text-gray-900">
                  🎛️ Filtreler
                </h3>
                <button
                  onClick={clearFilters}
                  className="text-sm text-red-600 hover:text-red-800 font-medium"
                >
                  Temizle
                </button>
              </div>

              <div className="space-y-6">
                {/* Search */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Arama
                  </label>
                  <form onSubmit={handleSearch}>
                    <input
                      type="text"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      placeholder="Usta adı, kategori, açıklama..."
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                    />
                  </form>
                </div>

                {/* Category */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Kategori
                  </label>
                  <select
                    value={selectedCategory}
                    onChange={(e) => setSelectedCategory(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                  >
                    <option value="">Tüm Kategoriler</option>
                    {categories.map(category => (
                      <option key={category} value={category}>{category}</option>
                    ))}
                  </select>
                </div>

                {/* Location */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Şehir
                  </label>
                  <select
                    value={selectedCity}
                    onChange={(e) => {
                      setSelectedCity(e.target.value);
                      setSelectedDistrict(''); // Reset district when city changes
                    }}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                  >
                    <option value="">Tüm Şehirler</option>
                    {cities.map(city => (
                      <option key={city} value={city}>{city}</option>
                    ))}
                  </select>
                </div>

                {selectedCity && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      İlçe
                    </label>
                    <select
                      value={selectedDistrict}
                      onChange={(e) => setSelectedDistrict(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                    >
                      <option value="">Tüm İlçeler</option>
                      {districts[selectedCity]?.map(district => (
                        <option key={district} value={district}>{district}</option>
                      ))}
                    </select>
                  </div>
                )}

                {/* Price Range */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Saatlik Ücret (₺)
                  </label>
                  <div className="grid grid-cols-2 gap-2">
                    <input
                      type="number"
                      value={priceRange.min}
                      onChange={(e) => setPriceRange(prev => ({ ...prev, min: e.target.value }))}
                      placeholder="Min"
                      className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                    />
                    <input
                      type="number"
                      value={priceRange.max}
                      onChange={(e) => setPriceRange(prev => ({ ...prev, max: e.target.value }))}
                      placeholder="Max"
                      className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                    />
                  </div>
                </div>

                {/* Rating */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Minimum Puan
                  </label>
                  <select
                    value={minRating}
                    onChange={(e) => setMinRating(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                  >
                    <option value="">Tüm Puanlar</option>
                    <option value="4.5">4.5+ ⭐</option>
                    <option value="4.0">4.0+ ⭐</option>
                    <option value="3.5">3.5+ ⭐</option>
                    <option value="3.0">3.0+ ⭐</option>
                  </select>
                </div>

                {/* Sort */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Sıralama
                  </label>
                  <select
                    value={sortBy}
                    onChange={(e) => setSortBy(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                  >
                    <option value="rating">Puana Göre</option>
                    <option value="price_low">Fiyat (Düşük-Yüksek)</option>
                    <option value="price_high">Fiyat (Yüksek-Düşük)</option>
                    <option value="experience">Deneyime Göre</option>
                    <option value="reviews">Yorum Sayısına Göre</option>
                  </select>
                </div>
              </div>
            </div>
          </div>

          {/* Results */}
          <div className="lg:col-span-3">
            {loading ? (
              <div className="flex items-center justify-center h-64">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-500"></div>
              </div>
            ) : craftsmen.length === 0 ? (
              <div className="bg-white rounded-lg shadow-sm p-12 text-center">
                <svg className="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <h3 className="text-lg font-medium text-gray-900 mb-2">Usta bulunamadı</h3>
                <p className="text-gray-600 mb-4">
                  Arama kriterlerinize uygun usta bulunamadı. Filtreleri değiştirmeyi deneyin.
                </p>
                <button
                  onClick={clearFilters}
                  className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
                >
                  Filtreleri Temizle
                </button>
              </div>
            ) : (
              <div className="space-y-4">
                {craftsmen.map((craftsman) => (
                  <div key={craftsman.id} className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow">
                    <div className="flex items-start justify-between">
                      <div className="flex items-start space-x-4 flex-1">
                        {/* Avatar */}
                        <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
                          {craftsman.avatar ? (
                            <img src={craftsman.avatar} alt={craftsman.name} className="w-16 h-16 rounded-full object-cover" />
                          ) : (
                            <span className="text-green-600 font-medium text-lg">
                              {craftsman.name.charAt(0)}
                            </span>
                          )}
                        </div>

                        {/* Info */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center space-x-2 mb-1">
                            <h3 className="text-lg font-medium text-gray-900">
                              {craftsman.name}
                            </h3>
                            {craftsman.is_verified && (
                              <svg className="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fillRule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                              </svg>
                            )}
                          </div>
                          
                          <p className="text-sm text-gray-600 mb-1">{craftsman.business_name}</p>
                          <p className="text-sm text-green-600 font-medium mb-2">{craftsman.category}</p>
                          
                          <div className="flex items-center space-x-4 text-sm text-gray-500 mb-2">
                            <span>📍 {craftsman.district}, {craftsman.city}</span>
                            <span>⏱️ {craftsman.response_time} yanıt</span>
                            <span>💼 {craftsman.completed_jobs} iş</span>
                          </div>

                          <div className="flex items-center space-x-4 mb-3">
                            <div className="flex items-center space-x-1">
                              {renderStars(craftsman.rating)}
                              <span className="text-sm font-medium text-gray-900 ml-1">
                                {craftsman.rating}
                              </span>
                              <span className="text-sm text-gray-500">
                                ({craftsman.review_count} değerlendirme)
                              </span>
                            </div>
                            <div className="text-lg font-semibold text-green-600">
                              {craftsman.hourly_rate}₺/saat
                            </div>
                          </div>

                          <p className="text-sm text-gray-600 mb-3 line-clamp-2">
                            {craftsman.description}
                          </p>

                          {/* Tags */}
                          <div className="flex flex-wrap gap-2 mb-4">
                            {craftsman.tags.map((tag, index) => (
                              <span key={index} className="px-2 py-1 bg-green-100 text-green-800 text-xs rounded-full">
                                {tag}
                              </span>
                            ))}
                          </div>

                          {/* Action Buttons */}
                          <div className="flex items-center space-x-3">
                            <button
                              onClick={() => navigate(`/craftsman/${craftsman.id}`)}
                              className="flex-1 px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors font-medium"
                            >
                              Profil Görüntüle
                            </button>
                            <button
                              onClick={() => navigate(`/messages/${craftsman.id}`)}
                              className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                            >
                              Mesaj
                            </button>
                            <button
                              onClick={() => navigate(`/chat/${craftsman.id}`)}
                              className="px-4 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 transition-colors"
                            >
                              Chat
                            </button>
                            <button
                              onClick={() => toggleFavorite(craftsman.id)}
                              className={`p-2 rounded-lg transition-colors ${
                                favorites.has(craftsman.id)
                                  ? 'bg-red-100 text-red-600 hover:bg-red-200'
                                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                              }`}
                            >
                              <svg className="w-5 h-5" fill={favorites.has(craftsman.id) ? 'currentColor' : 'none'} stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                              </svg>
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CraftsmenSearchPage;