import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { craftsmanService } from '../services/craftsmanService';

const mockCraftsmen = [
  {
    id: 1,
    name: 'Ahmet Usta',
    business: 'Ahmet Elektrik',
    category: 'Elektrikçi',
    rating: 4.8,
    reviewCount: 124,
    hourlyRate: 150,
    image: 'https://via.placeholder.com/80x80',
    distance: '2.3 km',
    isAvailable: true,
    description: '15 yıllık deneyim ile elektrik tesisatı ve onarım hizmetleri'
  },
  {
    id: 2,
    name: 'Mehmet Usta',
    business: 'Mehmet Tesisat',
    category: 'Tesisatçı',
    rating: 4.6,
    reviewCount: 89,
    hourlyRate: 120,
    image: 'https://via.placeholder.com/80x80',
    distance: '1.8 km',
    isAvailable: true,
    description: 'Su tesisatı, doğalgaz tesisatı ve kombi bakım hizmetleri'
  },
  {
    id: 3,
    name: 'Ali Usta',
    business: 'Ali Boyacılık',
    category: 'Boyacı',
    rating: 4.9,
    reviewCount: 156,
    hourlyRate: 100,
    image: 'https://via.placeholder.com/80x80',
    distance: '3.1 km',
    isAvailable: false,
    description: 'İç ve dış cephe boyama, dekoratif duvar kaplamaları'
  },
];

export const CraftsmanListPage = () => {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [craftsmen, setCraftsmen] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const categories = ['all', 'Elektrikçi', 'Tesisatçı', 'Boyacı', 'Marangoz', 'Temizlik'];

  // Load craftsmen from API
  useEffect(() => {
    const loadCraftsmen = async () => {
      try {
        setLoading(true);
        const response = await craftsmanService.getCraftsmen();
        if (response.success) {
          setCraftsmen(response.data.craftsmen || []);
        } else {
          // Fallback to mock data if API fails
          setCraftsmen(mockCraftsmen);
        }
      } catch (error) {
        console.error('Error loading craftsmen:', error);
        // Fallback to mock data
        setCraftsmen(mockCraftsmen);
      } finally {
        setLoading(false);
      }
    };

    loadCraftsmen();
  }, []);

  const filteredCraftsmen = craftsmen.filter(craftsman => {
    const matchesSearch = craftsman.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         craftsman.business_name?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || craftsman.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between mb-4">
            <button 
              onClick={() => navigate(-1)}
              className="p-2 hover:bg-gray-100 rounded-full"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h1 className="text-xl font-semibold text-gray-900">Ustalar</h1>
            <button className="p-2 hover:bg-gray-100 rounded-full">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
              </svg>
            </button>
          </div>

          {/* Search */}
          <div className="relative mb-4">
            <input
              type="text"
              placeholder="Usta veya hizmet ara..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <svg className="absolute left-3 top-3.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>

          {/* Categories */}
          <div className="flex gap-2 overflow-x-auto pb-2">
            {categories.map(category => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
                  selectedCategory === category
                    ? 'bg-blue-500 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {category === 'all' ? 'Tümü' : category}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Craftsmen List */}
      <div className="max-w-md mx-auto px-4 py-4">
        {loading ? (
          <div className="flex justify-center items-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
          </div>
        ) : (
          <div className="space-y-4">
            {filteredCraftsmen.map(craftsman => (
            <div 
              key={craftsman.id}
              onClick={() => navigate(`/craftsman/${craftsman.id}`)}
              className="bg-white rounded-lg shadow-sm border p-4 cursor-pointer hover:shadow-md transition-shadow"
            >
              <div className="flex items-start gap-3">
                <img 
                  src={craftsman.image} 
                  alt={craftsman.name}
                  className="w-16 h-16 rounded-full object-cover"
                />
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="font-semibold text-gray-900">{craftsman.name}</h3>
                      <p className="text-sm text-gray-600">{craftsman.business}</p>
                    </div>
                    <div className="flex items-center gap-1">
                      {craftsman.isAvailable ? (
                        <span className="w-2 h-2 bg-green-500 rounded-full"></span>
                      ) : (
                        <span className="w-2 h-2 bg-red-500 rounded-full"></span>
                      )}
                      <span className={`text-xs ${craftsman.isAvailable ? 'text-green-600' : 'text-red-600'}`}>
                        {craftsman.isAvailable ? 'Müsait' : 'Meşgul'}
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 mt-1">
                    <span className="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full">
                      {craftsman.category}
                    </span>
                    <div className="flex items-center gap-1">
                      <svg className="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                      </svg>
                      <span className="text-sm font-medium">{craftsman.rating}</span>
                      <span className="text-xs text-gray-500">({craftsman.reviewCount})</span>
                    </div>
                  </div>

                  <p className="text-sm text-gray-600 mt-2 line-clamp-2">
                    {craftsman.description}
                  </p>

                  <div className="flex items-center justify-between mt-3">
                    <div className="flex items-center gap-1 text-sm text-gray-500">
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                      {craftsman.distance}
                    </div>
                    <div className="text-right">
                      <span className="text-lg font-semibold text-gray-900">₺{craftsman.hourlyRate}</span>
                      <span className="text-sm text-gray-500">/saat</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {filteredCraftsmen.length === 0 && (
          <div className="text-center py-12">
            <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <h3 className="text-lg font-medium text-gray-900 mb-1">Sonuç bulunamadı</h3>
            <p className="text-gray-500">Arama kriterlerinizi değiştirip tekrar deneyin</p>
          </div>
        )}
        )}
      </div>
    </div>
  );
};