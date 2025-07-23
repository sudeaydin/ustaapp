import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const CraftsmanListPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);
  const [craftsmen, setCraftsmen] = useState([]);
  const [categories, setCategories] = useState([]);
  const [locations, setLocations] = useState({ cities: [], districts: [] });
  const [searchQuery, setSearchQuery] = useState('');
  const [filters, setFilters] = useState({
    category_id: '',
    city: '',
    district: '',
    min_rating: '',
    max_rate: '',
    is_available: true
  });
  const [showFilters, setShowFilters] = useState(false);
  const [pagination, setPagination] = useState({
    page: 1,
    pages: 1,
    total: 0
  });

  useEffect(() => {
    fetchCraftsmen();
    fetchCategories();
    fetchLocations();
  }, []);

  useEffect(() => {
    fetchCraftsmen();
  }, [searchQuery, filters]);

  const fetchCraftsmen = async (page = 1) => {
    try {
      setLoading(true);
      const params = new URLSearchParams({
        page: page.toString(),
        per_page: '10'
      });

      if (searchQuery.trim()) {
        params.append('q', searchQuery.trim());
      }

      Object.entries(filters).forEach(([key, value]) => {
        if (value !== '' && value !== null && value !== undefined) {
          params.append(key, value.toString());
        }
      });

      const response = await fetch(`/api/search/craftsmen?${params}`);
      const data = await response.json();
      
      if (data.success) {
        setCraftsmen(data.data.craftsmen);
        setPagination(data.data.pagination);
      } else {
        // Fallback to basic endpoint
        const basicResponse = await fetch(`/api/craftsmen?page=${page}`);
        const basicData = await basicResponse.json();
        if (basicData.success) {
          setCraftsmen(basicData.data.craftsmen);
          setPagination(basicData.data.pagination);
        }
      }
    } catch (error) {
      console.error('Craftsmen fetch error:', error);
      // Mock data fallback
      setCraftsmen([
        {
          id: 1,
          name: 'Ahmet Yılmaz',
          business_name: 'Ahmet Usta Elektrik',
          description: 'Elektrik işleri, aydınlatma, pano montajı',
          city: 'İstanbul',
          district: 'Kadıköy',
          hourly_rate: '150',
          average_rating: 4.8,
          total_reviews: 25,
          is_available: true,
          user: { phone: '0532 123 4567', email: 'ahmet@example.com' }
        }
      ]);
    } finally {
      setLoading(false);
    }
  };

  const fetchCategories = async () => {
    try {
      const response = await fetch('/api/search/categories');
      const data = await response.json();
      if (data.success) {
        setCategories(data.data);
      }
    } catch (error) {
      console.error('Categories fetch error:', error);
    }
  };

  const fetchLocations = async () => {
    try {
      const response = await fetch('/api/search/locations');
      const data = await response.json();
      if (data.success) {
        setLocations(data.data);
      }
    } catch (error) {
      console.error('Locations fetch error:', error);
    }
  };

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({
      ...prev,
      [key]: value
    }));
  };

  const clearFilters = () => {
    setFilters({
      category_id: '',
      city: '',
      district: '',
      min_rating: '',
      max_rate: '',
      is_available: true
    });
    setSearchQuery('');
  };

  const handleContactCraftsman = (craftsman) => {
    if (user) {
      navigate(`/messages/${craftsman.user.id || craftsman.id}`);
    } else {
      navigate('/login');
    }
  };

  const renderStars = (rating) => {
    const stars = [];
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 !== 0;

    for (let i = 0; i < fullStars; i++) {
      stars.push(
        <svg key={i} className="w-4 h-4 text-yellow-400 fill-current" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
      );
    }

    if (hasHalfStar) {
      stars.push(
        <svg key="half" className="w-4 h-4 text-yellow-400 fill-current" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
      );
    }

    const emptyStars = 5 - Math.ceil(rating);
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
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <button 
              onClick={() => navigate(-1)}
              className="p-2 hover:bg-gray-100 rounded-full"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h1 className="text-xl font-semibold text-gray-900">Ustalar</h1>
            <button 
              onClick={() => setShowFilters(!showFilters)}
              className="p-2 hover:bg-gray-100 rounded-full"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.707A1 1 0 013 7V4z" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Search Bar */}
      <div className="bg-white border-b">
        <div className="max-w-md mx-auto px-4 py-3">
          <div className="relative">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Usta ara (isim, iş türü...)"
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <svg className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
        </div>
      </div>

      {/* Filters */}
      {showFilters && (
        <div className="bg-white border-b">
          <div className="max-w-md mx-auto px-4 py-4">
            <div className="space-y-4">
              {/* Category Filter */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
                <select
                  value={filters.category_id}
                  onChange={(e) => handleFilterChange('category_id', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">Tüm kategoriler</option>
                  {categories.map((category) => (
                    <option key={category.id} value={category.id}>
                      {category.name}
                    </option>
                  ))}
                </select>
              </div>

              {/* Location Filters */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Şehir</label>
                  <select
                    value={filters.city}
                    onChange={(e) => handleFilterChange('city', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="">Tüm şehirler</option>
                    {locations.cities.map((city) => (
                      <option key={city} value={city}>
                        {city}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">İlçe</label>
                  <select
                    value={filters.district}
                    onChange={(e) => handleFilterChange('district', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="">Tüm ilçeler</option>
                    {locations.districts.map((district) => (
                      <option key={district} value={district}>
                        {district}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Rating and Price Filters */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Min. Puan</label>
                  <select
                    value={filters.min_rating}
                    onChange={(e) => handleFilterChange('min_rating', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="">Tüm puanlar</option>
                    <option value="4.5">4.5+ ⭐</option>
                    <option value="4.0">4.0+ ⭐</option>
                    <option value="3.5">3.5+ ⭐</option>
                    <option value="3.0">3.0+ ⭐</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Max. Ücret (₺)</label>
                  <input
                    type="number"
                    value={filters.max_rate}
                    onChange={(e) => handleFilterChange('max_rate', e.target.value)}
                    placeholder="Max ücret"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
              </div>

              {/* Availability Filter */}
              <div className="flex items-center">
                <input
                  type="checkbox"
                  checked={filters.is_available}
                  onChange={(e) => handleFilterChange('is_available', e.target.checked)}
                  className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                />
                <label className="ml-2 block text-sm text-gray-900">Sadece müsait olanlar</label>
              </div>

              {/* Filter Actions */}
              <div className="flex space-x-3 pt-2">
                <button
                  onClick={clearFilters}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
                >
                  Temizle
                </button>
                <button
                  onClick={() => setShowFilters(false)}
                  className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                >
                  Uygula
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Results */}
      <div className="max-w-md mx-auto px-4 py-4">
        {loading ? (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
          </div>
        ) : craftsmen.length === 0 ? (
          <div className="text-center py-12">
            <svg className="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <h3 className="text-lg font-medium text-gray-900 mb-2">Usta bulunamadı</h3>
            <p className="text-gray-600">Arama kriterlerinizi değiştirip tekrar deneyin.</p>
          </div>
        ) : (
          <>
            {/* Results count */}
            <div className="mb-4">
              <p className="text-sm text-gray-600">
                {pagination.total} usta bulundu
              </p>
            </div>

            {/* Craftsmen List */}
            <div className="space-y-4">
              {craftsmen.map((craftsman) => (
                <div key={craftsman.id} className="bg-white rounded-lg shadow-sm border p-4">
                  <div className="flex items-start space-x-3">
                    <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center">
                      <svg className="w-8 h-8 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                      </svg>
                    </div>
                    
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between">
                        <h3 className="text-lg font-semibold text-gray-900 truncate">
                          {craftsman.name}
                        </h3>
                        {craftsman.is_available && (
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            Müsait
                          </span>
                        )}
                      </div>
                      
                      {craftsman.business_name && (
                        <p className="text-sm text-blue-600 font-medium">
                          {craftsman.business_name}
                        </p>
                      )}
                      
                      <p className="text-sm text-gray-600 mt-1 line-clamp-2">
                        {craftsman.description}
                      </p>
                      
                      <div className="flex items-center mt-2 space-x-4">
                        <div className="flex items-center">
                          <div className="flex items-center">
                            {renderStars(craftsman.average_rating || 0)}
                          </div>
                          <span className="ml-1 text-sm text-gray-600">
                            {craftsman.average_rating?.toFixed(1)} ({craftsman.total_reviews || 0})
                          </span>
                        </div>
                        
                        {craftsman.hourly_rate && (
                          <span className="text-sm font-medium text-gray-900">
                            ₺{craftsman.hourly_rate}/saat
                          </span>
                        )}
                      </div>
                      
                      <div className="flex items-center justify-between mt-3">
                        <div className="text-sm text-gray-500">
                          {craftsman.city && craftsman.district && (
                            <span>{craftsman.district}, {craftsman.city}</span>
                          )}
                        </div>
                        
                        <div className="flex space-x-2">
                          <a
                            href={`tel:${craftsman.user?.phone}`}
                            className="inline-flex items-center px-3 py-1.5 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                          >
                            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                            </svg>
                            Ara
                          </a>
                          
                          <button
                            onClick={() => handleContactCraftsman(craftsman)}
                            className="inline-flex items-center px-3 py-1.5 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                          >
                            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                            </svg>
                            Mesaj
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Pagination */}
            {pagination.pages > 1 && (
              <div className="flex items-center justify-between mt-6">
                <button
                  onClick={() => fetchCraftsmen(pagination.page - 1)}
                  disabled={pagination.page <= 1}
                  className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Önceki
                </button>
                
                <span className="text-sm text-gray-600">
                  Sayfa {pagination.page} / {pagination.pages}
                </span>
                
                <button
                  onClick={() => fetchCraftsmen(pagination.page + 1)}
                  disabled={pagination.page >= pagination.pages}
                  className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Sonraki
                </button>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};