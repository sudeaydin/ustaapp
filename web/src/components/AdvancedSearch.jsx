import React, { useState, useEffect, useRef } from 'react';
import { CATEGORIES, getAllSkills } from '../data/categories';

const AdvancedSearch = ({ 
  searchQuery, 
  onSearchChange, 
  onSearch, 
  placeholder = "Usta, hizmet veya kategori ara..." 
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [suggestions, setSuggestions] = useState([]);
  const [recentSearches, setRecentSearches] = useState([]);
  const [popularSearches] = useState([
    'Elektrikçi', 'Tesisatçı', 'Boyacı', 'Temizlik', 'Klima montajı',
    'Ev tadilat', 'Bahçe düzenleme', 'Nakliye', 'Marangoz', 'Cam balkon'
  ]);
  
  const searchRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    // Load recent searches from localStorage
    const saved = localStorage.getItem('ustam_recent_searches');
    if (saved) {
      setRecentSearches(JSON.parse(saved));
    }
  }, []);

  useEffect(() => {
    // Generate suggestions based on search query
    if (searchQuery.length > 0) {
      const allSkills = getAllSkills();
      const categoryNames = CATEGORIES.map(cat => cat.name);
      const skillNames = allSkills.map(skill => skill.name);
      
      const allSuggestions = [
        ...categoryNames,
        ...skillNames,
        ...popularSearches
      ];

      const filtered = allSuggestions
        .filter(item => 
          item.toLowerCase().includes(searchQuery.toLowerCase())
        )
        .slice(0, 8);

      setSuggestions(filtered);
      setIsOpen(true);
    } else {
      setSuggestions([]);
      setIsOpen(false);
    }
  }, [searchQuery, popularSearches]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (searchRef.current && !searchRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleSearch = (query = searchQuery) => {
    if (query.trim()) {
      // Add to recent searches
      const newRecent = [
        query,
        ...recentSearches.filter(item => item !== query)
      ].slice(0, 5);
      
      setRecentSearches(newRecent);
      localStorage.setItem('ustam_recent_searches', JSON.stringify(newRecent));
      
      onSearch(query);
      setIsOpen(false);
    }
  };

  const handleSuggestionClick = (suggestion) => {
    onSearchChange(suggestion);
    handleSearch(suggestion);
  };

  const clearRecentSearches = () => {
    setRecentSearches([]);
    localStorage.removeItem('ustam_recent_searches');
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      handleSearch();
    } else if (e.key === 'Escape') {
      setIsOpen(false);
      inputRef.current?.blur();
    }
  };

  return (
    <div ref={searchRef} className="relative w-full max-w-2xl mx-auto">
      {/* Search Input */}
      <div className="relative">
        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <svg className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </div>
        
        <input
          ref={inputRef}
          type="text"
          value={searchQuery}
          onChange={(e) => onSearchChange(e.target.value)}
          onKeyDown={handleKeyDown}
          onFocus={() => {
            if (searchQuery.length > 0 || recentSearches.length > 0) {
              setIsOpen(true);
            }
          }}
          placeholder={placeholder}
          className="block w-full pl-10 pr-12 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-2 focus:ring-blue-500 focus:border-transparent text-lg"
        />
        
        <div className="absolute inset-y-0 right-0 flex items-center">
          {searchQuery && (
            <button
              onClick={() => {
                onSearchChange('');
                setIsOpen(false);
              }}
              className="p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
            >
              <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          )}
          
          <button
            onClick={() => handleSearch()}
            className="p-2 m-1 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
          >
            <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </button>
        </div>
      </div>

      {/* Search Dropdown */}
      {isOpen && (
        <div className="absolute top-full left-0 right-0 mt-1 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg z-50 max-h-96 overflow-y-auto">
          
          {/* Suggestions */}
          {suggestions.length > 0 && (
            <div className="p-2">
              <div className="text-xs font-medium text-gray-500 dark:text-gray-400 px-3 py-2">
                Öneriler
              </div>
              {suggestions.map((suggestion, index) => (
                <button
                  key={index}
                  onClick={() => handleSuggestionClick(suggestion)}
                  className="w-full text-left px-3 py-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg flex items-center space-x-3"
                >
                  <svg className="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                  </svg>
                  <span className="text-gray-900 dark:text-white">{suggestion}</span>
                </button>
              ))}
            </div>
          )}

          {/* Recent Searches */}
          {recentSearches.length > 0 && suggestions.length === 0 && (
            <div className="p-2">
              <div className="flex items-center justify-between px-3 py-2">
                <div className="text-xs font-medium text-gray-500 dark:text-gray-400">
                  Son Aramalar
                </div>
                <button
                  onClick={clearRecentSearches}
                  className="text-xs text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300"
                >
                  Temizle
                </button>
              </div>
              {recentSearches.map((search, index) => (
                <button
                  key={index}
                  onClick={() => handleSuggestionClick(search)}
                  className="w-full text-left px-3 py-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg flex items-center space-x-3"
                >
                  <svg className="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span className="text-gray-900 dark:text-white">{search}</span>
                </button>
              ))}
            </div>
          )}

          {/* Popular Searches */}
          {suggestions.length === 0 && recentSearches.length === 0 && (
            <div className="p-2">
              <div className="text-xs font-medium text-gray-500 dark:text-gray-400 px-3 py-2">
                Popüler Aramalar
              </div>
              {popularSearches.slice(0, 6).map((search, index) => (
                <button
                  key={index}
                  onClick={() => handleSuggestionClick(search)}
                  className="w-full text-left px-3 py-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg flex items-center space-x-3"
                >
                  <svg className="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                  </svg>
                  <span className="text-gray-900 dark:text-white">{search}</span>
                </button>
              ))}
            </div>
          )}

          {/* Quick Filters */}
          <div className="border-t border-gray-200 dark:border-gray-700 p-2">
            <div className="text-xs font-medium text-gray-500 dark:text-gray-400 px-3 py-2">
              Hızlı Filtreler
            </div>
            <div className="flex flex-wrap gap-2 px-3">
              <button
                onClick={() => handleSuggestionClick('4.5+ puan')}
                className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200 hover:bg-yellow-200 dark:hover:bg-yellow-800"
              >
                ⭐ 4.5+ Puan
              </button>
              <button
                onClick={() => handleSuggestionClick('doğrulanmış')}
                className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 hover:bg-green-200 dark:hover:bg-green-800"
              >
                ✓ Doğrulanmış
              </button>
              <button
                onClick={() => handleSuggestionClick('hızlı yanıt')}
                className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 hover:bg-blue-200 dark:hover:bg-blue-800"
              >
                ⚡ Hızlı Yanıt
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdvancedSearch;