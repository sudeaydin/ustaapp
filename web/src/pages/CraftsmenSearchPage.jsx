import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { CATEGORIES, getCategoryById, getSkillById, getAllSkills } from '../data/categories';
import { useAuth } from '../context/AuthContext';
import AdvancedSearch from '../components/AdvancedSearch';
import SearchFilters from '../components/SearchFilters';

export const CraftsmenSearchPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [searchParams, setSearchParams] = useSearchParams();
  
  // Filter States
  const [filters, setFilters] = useState({
    searchQuery: searchParams.get('q') || '',
    selectedCategory: searchParams.get('category') || '',
    selectedSkills: searchParams.get('skills')?.split(',').filter(Boolean).map(Number) || [],
    selectedCity: searchParams.get('city') || '',
    selectedDistrict: searchParams.get('district') || '',
    priceRange: {
      min: searchParams.get('min_price') || '',
      max: searchParams.get('max_price') || ''
    },
    minRating: searchParams.get('min_rating') || '',
    sortBy: searchParams.get('sort') || 'rating'
  });
  
  // UI States
  const [craftsmen, setCraftsmen] = useState([]);
  const [filteredCraftsmen, setFilteredCraftsmen] = useState([]);
  const [loading, setLoading] = useState(false);
  const [favorites, setFavorites] = useState(new Set());
  const [showFilters, setShowFilters] = useState(false);

  // Mock Craftsmen Data
  const mockCraftsmen = [
    {
      id: 1,
      name: 'Ahmet Yılmaz',
      business_name: 'Yılmaz Elektrik',
      category: 'Elektrikçi',
      skills: [101, 102, 103, 104],
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
      category: 'Marangoz',
      skills: [401, 402, 406],
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
      category: 'Teknisyen',
      skills: [204, 705],
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
      category: 'Temizlikçi',
      skills: [501, 502, 503],
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
      skills: [201, 202, 203, 205],
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
      skills: [301, 302, 303],
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
    },
    {
      id: 7,
      name: 'Osman Güler',
      business_name: 'Güler Bahçıvanlık',
      category: 'Bahçıvan',
      skills: [601, 602, 603, 605],
      city: 'İstanbul',
      district: 'Sarıyer',
      rating: 4.7,
      review_count: 156,
      hourly_rate: 110,
      experience_years: 9,
      description: 'Bahçe düzenleme, peyzaj tasarımı, çim ekimi ve sulama sistemleri kurulumu.',
      avatar: null,
      is_verified: true,
      response_time: '3 saat',
      completed_jobs: 98,
      tags: ['Deneyimli', 'Güvenilir', 'Yaratıcı']
    },
    {
      id: 8,
      name: 'Kemal Arslan',
      business_name: 'Arslan Nakliyat',
      category: 'Nakliyeci',
      skills: [801, 802, 803],
      city: 'İstanbul',
      district: 'Pendik',
      rating: 4.3,
      review_count: 67,
      hourly_rate: 90,
      experience_years: 5,
      description: 'Ev taşıma, ofis taşıma, eşya nakliye hizmetleri. Güvenli ve hızlı taşıma.',
      avatar: null,
      is_verified: false,
      response_time: '4 saat',
      completed_jobs: 34,
      tags: ['Uygun Fiyat', 'Güvenilir']
    }
  ];

  // Load craftsmen data
  useEffect(() => {
    setLoading(true);
    setTimeout(() => {
      setCraftsmen(mockCraftsmen);
      setLoading(false);
    }, 500);
  }, []);

  // Apply filters and search
  useEffect(() => {
    let filtered = [...craftsmen];

    // Text search
    if (filters.searchQuery) {
      const query = filters.searchQuery.toLowerCase();
      filtered = filtered.filter(craftsman =>
        craftsman.name.toLowerCase().includes(query) ||
        craftsman.business_name.toLowerCase().includes(query) ||
        craftsman.category.toLowerCase().includes(query) ||
        craftsman.description.toLowerCase().includes(query) ||
        craftsman.tags.some(tag => tag.toLowerCase().includes(query))
      );
    }

    // Category filter
    if (filters.selectedCategory) {
      filtered = filtered.filter(craftsman => 
        craftsman.category === filters.selectedCategory
      );
    }

    // Skills filter
    if (filters.selectedSkills.length > 0) {
      filtered = filtered.filter(craftsman =>
        filters.selectedSkills.some(skillId => 
          craftsman.skills.includes(skillId)
        )
      );
    }

    // Location filters
    if (filters.selectedCity) {
      filtered = filtered.filter(craftsman => 
        craftsman.city === filters.selectedCity
      );
    }

    if (filters.selectedDistrict) {
      filtered = filtered.filter(craftsman => 
        craftsman.district === filters.selectedDistrict
      );
    }

    // Price range filter
    if (filters.priceRange.min) {
      filtered = filtered.filter(craftsman => 
        craftsman.hourly_rate >= parseInt(filters.priceRange.min)
      );
    }

    if (filters.priceRange.max) {
      filtered = filtered.filter(craftsman => 
        craftsman.hourly_rate <= parseInt(filters.priceRange.max)
      );
    }

    // Rating filter
    if (filters.minRating) {
      filtered = filtered.filter(craftsman => 
        craftsman.rating >= parseFloat(filters.minRating)
      );
    }

    // Sorting
    filtered.sort((a, b) => {
      switch (filters.sortBy) {
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
        case 'response_time':
          return parseInt(a.response_time) - parseInt(b.response_time);
        default:
          return b.rating - a.rating;
      }
    });

    setFilteredCraftsmen(filtered);
    updateURL(filters);
  }, [filters, craftsmen]);

  const updateURL = (newFilters) => {
    const params = new URLSearchParams();
    
    if (newFilters.searchQuery) params.set('q', newFilters.searchQuery);
    if (newFilters.selectedCategory) params.set('category', newFilters.selectedCategory);
    if (newFilters.selectedSkills.length > 0) params.set('skills', newFilters.selectedSkills.join(','));
    if (newFilters.selectedCity) params.set('city', newFilters.selectedCity);
    if (newFilters.selectedDistrict) params.set('district', newFilters.selectedDistrict);
    if (newFilters.priceRange.min) params.set('min_price', newFilters.priceRange.min);
    if (newFilters.priceRange.max) params.set('max_price', newFilters.priceRange.max);
    if (newFilters.minRating) params.set('min_rating', newFilters.minRating);
    if (newFilters.sortBy !== 'rating') params.set('sort', newFilters.sortBy);

    setSearchParams(params);
  };

  const handleFiltersChange = (newFilters) => {
    setFilters(newFilters);
  };

  const handleSearch = (query) => {
    setFilters(prev => ({ ...prev, searchQuery: query }));
  };

  const handleSearchChange = (query) => {
    setFilters(prev => ({ ...prev, searchQuery: query }));
  };

  const toggleFavorite = (craftsmanId) => {
    setFavorites(prev => {
      const newFavorites = new Set(prev);
      if (newFavorites.has(craftsmanId)) {
        newFavorites.delete(craftsmanId);
      } else {
        newFavorites.add(craftsmanId);
      }
      return newFavorites;
    });
  };

  const handleProposal = (craftsmanId) => {
    if (!user) {
      navigate('/login');
      return;
    }
    navigate(`/proposal/${craftsmanId}`);
  };

  const getSkillNames = (skillIds) => {
    const allSkills = getAllSkills();
    return skillIds.map(id => {
      const skill = allSkills.find(s => s.id === id);
      return skill ? skill.name : '';
    }).filter(Boolean);
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <div className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <div className="mb-6">
            <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
              🔍 Usta Ara
            </h1>
            <p className="text-gray-600 dark:text-gray-400">
              İhtiyacınıza uygun ustayı bulun ve hemen teklif alın
            </p>
          </div>

          {/* Advanced Search */}
          <AdvancedSearch
            searchQuery={filters.searchQuery}
            onSearchChange={handleSearchChange}
            onSearch={handleSearch}
          />
        </div>
      </div>

      {/* Search Filters */}
      <SearchFilters
        filters={filters}
        onFiltersChange={handleFiltersChange}
        isOpen={showFilters}
        onToggle={() => setShowFilters(!showFilters)}
        resultsCount={filteredCraftsmen.length}
      />

      {/* Results */}
      <div className="max-w-7xl mx-auto px-4 py-6">
        {loading ? (
          <div className="flex justify-center items-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>
        ) : filteredCraftsmen.length === 0 ? (
          <div className="text-center py-12">
            <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <h3 className="mt-2 text-sm font-medium text-gray-900 dark:text-white">Sonuç bulunamadı</h3>
            <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
              Arama kriterlerinize uygun usta bulunamadı. Filtreleri değiştirmeyi deneyin.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredCraftsmen.map((craftsman) => (
              <div key={craftsman.id} className="bg-white dark:bg-gray-800 rounded-lg shadow-sm hover:shadow-md transition-shadow">
                <div className="p-6">
                  {/* Header */}
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-center space-x-3">
                      <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center">
                        <span className="text-lg font-semibold text-blue-600 dark:text-blue-400">
                          {craftsman.name.split(' ').map(n => n[0]).join('')}
                        </span>
                      </div>
                      <div>
                        <h3 className="font-semibold text-gray-900 dark:text-white">
                          {craftsman.name}
                        </h3>
                        <p className="text-sm text-gray-600 dark:text-gray-400">
                          {craftsman.business_name}
                        </p>
                      </div>
                    </div>
                    
                    <div className="flex items-center space-x-2">
                      {craftsman.is_verified && (
                        <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200">
                          ✓ Doğrulanmış
                        </span>
                      )}
                      <button
                        onClick={() => toggleFavorite(craftsman.id)}
                        className={`p-2 rounded-full transition-colors ${
                          favorites.has(craftsman.id)
                            ? 'text-red-500 bg-red-50 dark:bg-red-900/20'
                            : 'text-gray-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20'
                        }`}
                      >
                        <svg className="w-5 h-5" fill={favorites.has(craftsman.id) ? 'currentColor' : 'none'} stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                        </svg>
                      </button>
                    </div>
                  </div>

                  {/* Category & Location */}
                  <div className="flex items-center justify-between mb-3">
                    <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200">
                      {craftsman.category}
                    </span>
                    <span className="text-sm text-gray-600 dark:text-gray-400">
                      📍 {craftsman.district}, {craftsman.city}
                    </span>
                  </div>

                  {/* Rating & Stats */}
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center space-x-4">
                      <div className="flex items-center">
                        <span className="text-yellow-400">⭐</span>
                        <span className="ml-1 text-sm font-medium text-gray-900 dark:text-white">
                          {craftsman.rating}
                        </span>
                        <span className="ml-1 text-sm text-gray-600 dark:text-gray-400">
                          ({craftsman.review_count})
                        </span>
                      </div>
                      <span className="text-sm text-gray-600 dark:text-gray-400">
                        {craftsman.experience_years} yıl deneyim
                      </span>
                    </div>
                    <div className="text-right">
                      <div className="text-lg font-semibold text-gray-900 dark:text-white">
                        ₺{craftsman.hourly_rate}
                      </div>
                      <div className="text-xs text-gray-600 dark:text-gray-400">
                        /saat
                      </div>
                    </div>
                  </div>

                  {/* Description */}
                  <p className="text-sm text-gray-600 dark:text-gray-400 mb-4 line-clamp-2">
                    {craftsman.description}
                  </p>

                  {/* Skills */}
                  <div className="mb-4">
                    <div className="flex flex-wrap gap-1">
                      {getSkillNames(craftsman.skills).slice(0, 3).map((skill, index) => (
                        <span key={index} className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200">
                          {skill}
                        </span>
                      ))}
                      {craftsman.skills.length > 3 && (
                        <span className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200">
                          +{craftsman.skills.length - 3} daha
                        </span>
                      )}
                    </div>
                  </div>

                  {/* Tags */}
                  <div className="flex flex-wrap gap-1 mb-4">
                    {craftsman.tags.map((tag, index) => (
                      <span key={index} className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200">
                        {tag}
                      </span>
                    ))}
                  </div>

                  {/* Actions */}
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200 dark:border-gray-700">
                    <div className="text-sm text-gray-600 dark:text-gray-400">
                      ⚡ {craftsman.response_time} içinde yanıt
                    </div>
                    <div className="flex space-x-2">
                      <button
                        onClick={() => navigate(`/craftsman/${craftsman.id}`)}
                        className="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
                      >
                        Profil
                      </button>
                      <button
                        onClick={() => handleProposal(craftsman.id)}
                        className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors"
                      >
                        Teklif Al
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default CraftsmenSearchPage;