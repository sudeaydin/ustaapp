import React, { useState, useEffect } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import WebHeader from '../components/WebHeader';

const SearchPage = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  
  const [filters, setFilters] = useState({
    query: searchParams.get('query') || '',
    category: searchParams.get('category') || '',
    city: searchParams.get('city') || '',
    district: searchParams.get('district') || '',
    minRating: searchParams.get('minRating') || '',
    maxRate: searchParams.get('maxRate') || '',
    isAvailable: searchParams.get('isAvailable') || ''
  });
  
  const [results, setResults] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showFilters, setShowFilters] = useState(false);

  // Mock data for demonstration
  const mockCraftsmen = [
    {
      id: 1,
      name: 'Ahmet Yılmaz',
      category: 'Elektrikçi',
      rating: 4.8,
      reviewCount: 127,
      hourlyRate: 150,
      location: 'İstanbul, Kadıköy',
      avatar: '⚡',
      isAvailable: true,
      skills: ['Ev elektriği', 'Endüstriyel', 'Aydınlatma'],
      experience: '8 yıl',
      completedJobs: 234
    },
    {
      id: 2,
      name: 'Mehmet Kaya',
      category: 'Tesisatçı',
      rating: 4.9,
      reviewCount: 89,
      hourlyRate: 120,
      location: 'İstanbul, Şişli',
      avatar: '🔧',
      isAvailable: true,
      skills: ['Su tesisatı', 'Doğalgaz', 'Kombi'],
      experience: '12 yıl',
      completedJobs: 156
    },
    {
      id: 3,
      name: 'Ali Demir',
      category: 'Boyacı',
      rating: 4.7,
      reviewCount: 203,
      hourlyRate: 100,
      location: 'İstanbul, Beşiktaş',
      avatar: '🎨',
      isAvailable: false,
      skills: ['İç boyama', 'Dış boyama', 'Dekoratif'],
      experience: '15 yıl',
      completedJobs: 312
    }
  ];

  const mockCategories = [
    { id: 1, name: 'Elektrikçi', icon: '⚡', count: 150 },
    { id: 2, name: 'Tesisatçı', icon: '🔧', count: 120 },
    { id: 3, name: 'Boyacı', icon: '🎨', count: 200 },
    { id: 4, name: 'Marangoz', icon: '🔨', count: 80 },
    { id: 5, name: 'Temizlik', icon: '🧹', count: 300 },
    { id: 6, name: 'Bahçıvan', icon: '🌱', count: 60 }
  ];

  useEffect(() => {
    setCategories(mockCategories);
    performSearch();
  }, []);

  const performSearch = () => {
    setLoading(true);
    // Simulate API call
    setTimeout(() => {
      let filteredResults = mockCraftsmen;
      
      if (filters.query) {
        filteredResults = filteredResults.filter(craftsman =>
          craftsman.name.toLowerCase().includes(filters.query.toLowerCase()) ||
          craftsman.category.toLowerCase().includes(filters.query.toLowerCase())
        );
      }
      
      if (filters.category) {
        filteredResults = filteredResults.filter(craftsman =>
          craftsman.category === filters.category
        );
      }
      
      if (filters.city) {
        filteredResults = filteredResults.filter(craftsman =>
          craftsman.location.includes(filters.city)
        );
      }
      
      if (filters.minRating) {
        filteredResults = filteredResults.filter(craftsman =>
          craftsman.rating >= parseFloat(filters.minRating)
        );
      }
      
      if (filters.isAvailable === 'true') {
        filteredResults = filteredResults.filter(craftsman => craftsman.isAvailable);
      }
      
      setResults(filteredResults);
      setLoading(false);
    }, 1000);
  };

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const handleSearch = () => {
    performSearch();
  };

  const clearFilters = () => {
    setFilters({
      query: '',
      category: '',
      city: '',
      district: '',
      minRating: '',
      maxRate: '',
      isAvailable: ''
    });
    setResults(mockCraftsmen);
  };

  const handleCraftsmanClick = (craftsman) => {
    navigate(`/craftsman/${craftsman.id}`);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <WebHeader />
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Search Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">
            Usta Ara
          </h1>
          <p className="text-gray-600">
            {results.length} usta bulundu
          </p>
        </div>

        <div className="lg:grid lg:grid-cols-4 lg:gap-8">
          {/* Filters Sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow-md p-6 sticky top-24">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-semibold text-gray-900">Filtreler</h2>
                <button
                  onClick={() => setShowFilters(!showFilters)}
                  className="lg:hidden text-blue-600 hover:text-blue-800"
                >
                  {showFilters ? 'Gizle' : 'Göster'}
                </button>
              </div>

              <div className={`space-y-6 ${showFilters ? 'block' : 'hidden lg:block'}`}>
                {/* Search Input */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Arama
                  </label>
                  <input
                    type="text"
                    value={filters.query}
                    onChange={(e) => handleFilterChange('query', e.target.value)}
                    placeholder="Usta adı veya kategori..."
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                {/* Category Filter */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Kategori
                  </label>
                  <select
                    value={filters.category}
                    onChange={(e) => handleFilterChange('category', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="">Tüm Kategoriler</option>
                    {categories.map(category => (
                      <option key={category.id} value={category.name}>
                        {category.icon} {category.name} ({category.count})
                      </option>
                    ))}
                  </select>
                </div>

                {/* Location Filter */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Şehir
                  </label>
                  <input
                    type="text"
                    value={filters.city}
                    onChange={(e) => handleFilterChange('city', e.target.value)}
                    placeholder="İstanbul, Ankara..."
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                {/* Rating Filter */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Minimum Puan
                  </label>
                  <select
                    value={filters.minRating}
                    onChange={(e) => handleFilterChange('minRating', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="">Tüm Puanlar</option>
                    <option value="4.5">4.5+ ⭐</option>
                    <option value="4.0">4.0+ ⭐</option>
                    <option value="3.5">3.5+ ⭐</option>
                    <option value="3.0">3.0+ ⭐</option>
                  </select>
                </div>

                {/* Availability Filter */}
                <div>
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={filters.isAvailable === 'true'}
                      onChange={(e) => handleFilterChange('isAvailable', e.target.checked ? 'true' : '')}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <span className="ml-2 text-sm text-gray-700">Sadece Müsait Olanlar</span>
                  </label>
                </div>

                {/* Action Buttons */}
                <div className="space-y-3">
                  <button
                    onClick={handleSearch}
                    className="w-full bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Ara
                  </button>
                  <button
                    onClick={clearFilters}
                    className="w-full bg-gray-200 text-gray-700 py-2 px-4 rounded-lg hover:bg-gray-300 transition-colors"
                  >
                    Filtreleri Temizle
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Results */}
          <div className="lg:col-span-3 mt-8 lg:mt-0">
            {loading ? (
              <div className="text-center py-12">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
                <p className="mt-4 text-gray-600">Aranıyor...</p>
              </div>
            ) : (
              <div className="space-y-6">
                {results.length === 0 ? (
                  <div className="text-center py-12">
                    <div className="text-6xl mb-4">🔍</div>
                    <h3 className="text-xl font-semibold text-gray-900 mb-2">
                      Sonuç Bulunamadı
                    </h3>
                    <p className="text-gray-600">
                      Arama kriterlerinizi değiştirip tekrar deneyin.
                    </p>
                  </div>
                ) : (
                  results.map(craftsman => (
                    <div
                      key={craftsman.id}
                      onClick={() => handleCraftsmanClick(craftsman)}
                      className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow cursor-pointer"
                    >
                      <div className="flex items-start space-x-4">
                        <div className="flex-shrink-0">
                          <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center text-2xl">
                            {craftsman.avatar}
                          </div>
                        </div>
                        
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between">
                            <h3 className="text-xl font-semibold text-gray-900">
                              {craftsman.name}
                            </h3>
                            <div className="flex items-center space-x-2">
                              {craftsman.isAvailable ? (
                                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                  Müsait
                                </span>
                              ) : (
                                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                  Meşgul
                                </span>
                              )}
                            </div>
                          </div>
                          
                          <p className="text-blue-600 font-medium">{craftsman.category}</p>
                          <p className="text-gray-600 text-sm">{craftsman.location}</p>
                          
                          <div className="flex items-center mt-2">
                            <div className="flex items-center">
                              <span className="text-yellow-400">⭐</span>
                              <span className="ml-1 text-sm font-medium text-gray-900">
                                {craftsman.rating}
                              </span>
                              <span className="ml-1 text-sm text-gray-600">
                                ({craftsman.reviewCount} değerlendirme)
                              </span>
                            </div>
                            <span className="mx-2 text-gray-300">•</span>
                            <span className="text-sm text-gray-600">
                              {craftsman.completedJobs} tamamlanan iş
                            </span>
                          </div>
                          
                          <div className="flex flex-wrap gap-2 mt-3">
                            {craftsman.skills.map((skill, index) => (
                              <span
                                key={index}
                                className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
                              >
                                {skill}
                              </span>
                            ))}
                          </div>
                          
                          <div className="flex items-center justify-between mt-4">
                            <div className="text-lg font-semibold text-gray-900">
                              {craftsman.hourlyRate}₺/saat
                            </div>
                            <div className="flex space-x-3">
                              <button className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
                                💬 Mesaj
                              </button>
                              <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                                📞 İletişim
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default SearchPage;