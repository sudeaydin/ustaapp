import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Search, Star, User, Home as HomeIcon } from "../components/Icons";

const categories = [
  { id: 1, name: 'Fayans', icon: '🔧', color: '#3498db' },
  { id: 2, name: 'Badana', icon: '🎨', color: '#e74c3c' },
  { id: 3, name: 'Elektrik', icon: '⚡', color: '#f39c12' },
  { id: 4, name: 'Su Tesisatı', icon: '🔧', color: '#2980b9' },
  { id: 5, name: 'Marangozluk', icon: '🔨', color: '#8e44ad' },
  { id: 6, name: 'Temizlik', icon: '🧽', color: '#27ae60' },
];

const featuredCraftsmen = [
  {
    id: 1,
    name: 'Mehmet Usta',
    category: 'Fayans',
    rating: 4.8,
    reviews: 156,
    image: null,
    price: '₺50-100/m²'
  },
  {
    id: 2,
    name: 'Ahmet Usta',
    category: 'Elektrik',
    rating: 4.9,
    reviews: 203,
    image: null,
    price: '₺80-150/saat'
  },
  {
    id: 3,
    name: 'Fatma Hanım',
    category: 'Temizlik',
    rating: 4.7,
    reviews: 89,
    image: null,
    price: '₺40-80/saat'
  }
];

export const HomePage = () => {
  const navigate = useNavigate();
  const [searchText, setSearchText] = useState('');

  return (
    <div className="bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="bg-white shadow-sm">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Merhaba!</h1>
              <p className="text-gray-600">Bugün hangi hizmete ihtiyacın var?</p>
            </div>
            <button 
              onClick={() => navigate('/profile')}
              className="p-2 rounded-full bg-gray-100"
            >
              <User className="w-6 h-6 text-gray-600" />
            </button>
          </div>

          {/* Search bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Hizmet veya usta ara..."
              value={searchText}
              onChange={(e) => setSearchText(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>
      </div>

      {/* Categories */}
      <div className="max-w-md mx-auto px-4 py-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Kategoriler</h2>
        <div className="grid grid-cols-2 gap-4">
          {categories.map((category) => (
            <button
              key={category.id}
              onClick={() => navigate('/craftsmen')}
              className="p-4 bg-white rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow"
            >
              <div 
                className="w-12 h-12 rounded-full flex items-center justify-center text-2xl mb-3 mx-auto"
                style={{ backgroundColor: category.color + '20' }}
              >
                {category.icon}
              </div>
              <h3 className="font-medium text-gray-900 text-center">{category.name}</h3>
            </button>
          ))}
        </div>
      </div>

      {/* Featured Craftsmen */}
      <div className="max-w-md mx-auto px-4 py-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-gray-900">Öne Çıkan Ustalar</h2>
          <button 
            onClick={() => navigate('/craftsmen')}
            className="text-blue-600 font-medium"
          >
            Tümünü Gör
          </button>
        </div>

        <div className="space-y-4">
          {featuredCraftsmen.map((craftsman) => (
            <div
              key={craftsman.id}
              onClick={() => navigate(`/craftsman/${craftsman.id}`)}
              className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 cursor-pointer hover:shadow-md transition-shadow"
            >
              <div className="flex items-center space-x-4">
                <div className="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center">
                  <User className="w-8 h-8 text-gray-400" />
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold text-gray-900">{craftsman.name}</h3>
                  <p className="text-gray-600 text-sm">{craftsman.category}</p>
                  <div className="flex items-center space-x-2 mt-1">
                    <div className="flex items-center">
                      <Star className="w-4 h-4 text-yellow-400" filled />
                      <span className="text-sm font-medium ml-1">{craftsman.rating}</span>
                    </div>
                    <span className="text-gray-400">•</span>
                    <span className="text-sm text-gray-600">{craftsman.reviews} değerlendirme</span>
                  </div>
                  <p className="text-sm font-medium text-blue-600 mt-1">{craftsman.price}</p>
                </div>
                <button className="p-2 rounded-full bg-blue-50 text-blue-600">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
                  </svg>
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Bottom Navigation */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200">
        <div className="max-w-md mx-auto px-4 py-2">
          <div className="flex justify-around">
            <button className="flex flex-col items-center py-2 px-3 text-blue-600">
              <HomeIcon className="w-6 h-6" />
              <span className="text-xs mt-1 font-medium">Ana Sayfa</span>
            </button>
            <button 
              onClick={() => navigate('/craftsmen')}
              className="flex flex-col items-center py-2 px-3 text-gray-400"
            >
              <Search className="w-6 h-6" />
              <span className="text-xs mt-1">Ara</span>
            </button>
            <button 
              onClick={() => navigate('/quotes')}
              className="flex flex-col items-center py-2 px-3 text-gray-400"
            >
              <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                <path d="M2 5a2 2 0 012-2h7a2 2 0 012 2v4a2 2 0 01-2 2H9l-3 3v-3H4a2 2 0 01-2-2V5z" />
              </svg>
              <span className="text-xs mt-1">Teklifler</span>
            </button>
            <button 
              onClick={() => navigate('/profile')}
              className="flex flex-col items-center py-2 px-3 text-gray-400"
            >
              <User className="w-6 h-6" />
              <span className="text-xs mt-1">Profil</span>
            </button>
          </div>
        </div>
      </div>

      {/* Home indicator for mobile */}
      <div className="h-6"></div>
    </div>
  );
};
