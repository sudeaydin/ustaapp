import React, { useState, useEffect } from 'react';
import { CATEGORIES, getAllSkills } from '../data/categories';

const SearchFilters = ({ 
  filters, 
  onFiltersChange, 
  isOpen, 
  onToggle,
  resultsCount = 0 
}) => {
  const [localFilters, setLocalFilters] = useState(filters);
  const [showSkillModal, setShowSkillModal] = useState(false);
  const [skillSearch, setSkillSearch] = useState('');

  const cities = [
    'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana',
    'Konya', 'Gaziantep', 'Kayseri', 'Mersin', 'Eskişehir', 'Diyarbakır'
  ];

  const districts = {
    'İstanbul': ['Kadıköy', 'Beşiktaş', 'Şişli', 'Beyoğlu', 'Fatih', 'Üsküdar', 'Bakırköy', 'Maltepe', 'Sarıyer', 'Pendik'],
    'Ankara': ['Çankaya', 'Keçiören', 'Yenimahalle', 'Mamak', 'Sincan', 'Altındağ'],
    'İzmir': ['Konak', 'Karşıyaka', 'Bornova', 'Buca', 'Çiğli', 'Bayraklı']
  };

  const sortOptions = [
    { value: 'rating', label: 'En Yüksek Puan' },
    { value: 'price_low', label: 'En Düşük Fiyat' },
    { value: 'price_high', label: 'En Yüksek Fiyat' },
    { value: 'experience', label: 'En Deneyimli' },
    { value: 'reviews', label: 'En Çok Değerlendirilen' },
    { value: 'response_time', label: 'En Hızlı Yanıt' }
  ];

  useEffect(() => {
    setLocalFilters(filters);
  }, [filters]);

  const handleFilterChange = (key, value) => {
    const newFilters = { ...localFilters, [key]: value };
    setLocalFilters(newFilters);
    onFiltersChange(newFilters);
  };

  const handleSkillToggle = (skillId) => {
    const currentSkills = localFilters.selectedSkills || [];
    const newSkills = currentSkills.includes(skillId)
      ? currentSkills.filter(id => id !== skillId)
      : [...currentSkills, skillId];
    
    handleFilterChange('selectedSkills', newSkills);
  };

  const clearAllFilters = () => {
    const clearedFilters = {
      searchQuery: '',
      selectedCategory: '',
      selectedSkills: [],
      selectedCity: '',
      selectedDistrict: '',
      priceRange: { min: '', max: '' },
      minRating: '',
      sortBy: 'rating'
    };
    setLocalFilters(clearedFilters);
    onFiltersChange(clearedFilters);
  };

  const getActiveFiltersCount = () => {
    let count = 0;
    if (localFilters.selectedCategory) count++;
    if (localFilters.selectedSkills?.length > 0) count++;
    if (localFilters.selectedCity) count++;
    if (localFilters.selectedDistrict) count++;
    if (localFilters.priceRange?.min || localFilters.priceRange?.max) count++;
    if (localFilters.minRating) count++;
    return count;
  };

  const allSkills = getAllSkills();
  const filteredSkills = skillSearch 
    ? allSkills.filter(skill => 
        skill.name.toLowerCase().includes(skillSearch.toLowerCase())
      )
    : allSkills;

  const getSelectedSkillNames = () => {
    if (!localFilters.selectedSkills?.length) return [];
    return localFilters.selectedSkills.map(skillId => {
      const skill = allSkills.find(s => s.id === skillId);
      return skill ? skill.name : '';
    }).filter(Boolean);
  };

  return (
    <div className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
      {/* Filter Toggle Button */}
      <div className="px-4 py-3 flex items-center justify-between">
        <button
          onClick={onToggle}
          className="flex items-center space-x-2 text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707v4.586a1 1 0 01-.293.707l-2 2A1 1 0 019 21v-6.586a1 1 0 00-.293-.707L2.293 7.293A1 1 0 012 6.586V4z" />
          </svg>
          <span className="font-medium">Filtreler</span>
          {getActiveFiltersCount() > 0 && (
            <span className="bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 text-xs px-2 py-1 rounded-full">
              {getActiveFiltersCount()}
            </span>
          )}
        </button>
        
        <div className="flex items-center space-x-4">
          <span className="text-sm text-gray-600 dark:text-gray-400">
            {resultsCount} sonuç bulundu
          </span>
          {getActiveFiltersCount() > 0 && (
            <button
              onClick={clearAllFilters}
              className="text-sm text-red-600 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300"
            >
              Temizle
            </button>
          )}
        </div>
      </div>

      {/* Filters Panel */}
      {isOpen && (
        <div className="px-4 pb-4 border-t border-gray-200 dark:border-gray-700">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mt-4">
            
            {/* Category Filter */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Kategori
              </label>
              <select
                value={localFilters.selectedCategory || ''}
                onChange={(e) => handleFilterChange('selectedCategory', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Tüm Kategoriler</option>
                {CATEGORIES.map(category => (
                  <option key={category.id} value={category.name}>
                    {category.name}
                  </option>
                ))}
              </select>
            </div>

            {/* City Filter */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Şehir
              </label>
              <select
                value={localFilters.selectedCity || ''}
                onChange={(e) => {
                  handleFilterChange('selectedCity', e.target.value);
                  handleFilterChange('selectedDistrict', ''); // Reset district
                }}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Tüm Şehirler</option>
                {cities.map(city => (
                  <option key={city} value={city}>{city}</option>
                ))}
              </select>
            </div>

            {/* District Filter */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                İlçe
              </label>
              <select
                value={localFilters.selectedDistrict || ''}
                onChange={(e) => handleFilterChange('selectedDistrict', e.target.value)}
                disabled={!localFilters.selectedCity}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100 dark:disabled:bg-gray-600 disabled:cursor-not-allowed"
              >
                <option value="">Tüm İlçeler</option>
                {localFilters.selectedCity && districts[localFilters.selectedCity]?.map(district => (
                  <option key={district} value={district}>{district}</option>
                ))}
              </select>
            </div>

            {/* Sort Filter */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Sıralama
              </label>
              <select
                value={localFilters.sortBy || 'rating'}
                onChange={(e) => handleFilterChange('sortBy', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                {sortOptions.map(option => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Second Row */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mt-4">
            
            {/* Price Range */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Fiyat Aralığı (₺/saat)
              </label>
              <div className="flex space-x-2">
                <input
                  type="number"
                  placeholder="Min"
                  value={localFilters.priceRange?.min || ''}
                  onChange={(e) => handleFilterChange('priceRange', {
                    ...localFilters.priceRange,
                    min: e.target.value
                  })}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
                <input
                  type="number"
                  placeholder="Max"
                  value={localFilters.priceRange?.max || ''}
                  onChange={(e) => handleFilterChange('priceRange', {
                    ...localFilters.priceRange,
                    max: e.target.value
                  })}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
            </div>

            {/* Rating Filter */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Minimum Puan
              </label>
              <select
                value={localFilters.minRating || ''}
                onChange={(e) => handleFilterChange('minRating', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Tüm Puanlar</option>
                <option value="4.5">4.5+ ⭐</option>
                <option value="4.0">4.0+ ⭐</option>
                <option value="3.5">3.5+ ⭐</option>
                <option value="3.0">3.0+ ⭐</option>
              </select>
            </div>

            {/* Skills Filter */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Yetenekler
              </label>
              <div className="flex flex-wrap gap-2">
                {getSelectedSkillNames().map((skillName, index) => (
                  <span
                    key={index}
                    className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200"
                  >
                    {skillName}
                    <button
                      onClick={() => {
                        const skillId = localFilters.selectedSkills[index];
                        handleSkillToggle(skillId);
                      }}
                      className="ml-2 text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-200"
                    >
                      ×
                    </button>
                  </span>
                ))}
                <button
                  onClick={() => setShowSkillModal(true)}
                  className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600"
                >
                  + Yetenek Ekle
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Skills Modal */}
      {showSkillModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 w-full max-w-2xl mx-4 max-h-96 overflow-hidden">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                Yetenekler
              </h3>
              <button
                onClick={() => setShowSkillModal(false)}
                className="text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200"
              >
                ×
              </button>
            </div>
            
            <input
              type="text"
              placeholder="Yetenek ara..."
              value={skillSearch}
              onChange={(e) => setSkillSearch(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg mb-4 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            
            <div className="max-h-64 overflow-y-auto">
              <div className="grid grid-cols-2 gap-2">
                {filteredSkills.map(skill => (
                  <label
                    key={skill.id}
                    className="flex items-center space-x-2 p-2 hover:bg-gray-50 dark:hover:bg-gray-700 rounded cursor-pointer"
                  >
                    <input
                      type="checkbox"
                      checked={localFilters.selectedSkills?.includes(skill.id) || false}
                      onChange={() => handleSkillToggle(skill.id)}
                      className="rounded border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500"
                    />
                    <span className="text-sm text-gray-900 dark:text-white">
                      {skill.name}
                    </span>
                  </label>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default SearchFilters;