import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../context/ThemeContext';

export const MobileNavigation = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { user } = useAuth();
  const { isDarkMode } = useTheme();

  if (!user) return null; // Don't show nav if not logged in

  const customerNavItems = [
    {
      icon: '🏠',
      label: 'Ana Sayfa',
      path: '/dashboard/customer',
      activeIcon: '🏠'
    },
    {
      icon: '🔍',
      label: 'Usta Bul',
      path: '/craftsmen',
      activeIcon: '🔍'
    },
    {
      icon: '💳',
      label: 'Ödemeler',
      path: '/payment-history',
      activeIcon: '💳'
    },
    {
      icon: '💬',
      label: 'Mesajlar',
      path: '/messages',
      activeIcon: '💬'
    },
    {
      icon: '📋',
      label: 'İşlerim',
      path: '/job-management',
      activeIcon: '📋'
    },
    {
      icon: '👤',
      label: 'Profil',
      path: '/profile',
      activeIcon: '👤'
    },
    {
      icon: '⚖️',
      label: 'Yasal',
      path: '/legal',
      activeIcon: '⚖️'
    }
  ];

  const craftsmanNavItems = [
    {
      icon: '🏠',
      label: 'Ana Sayfa',
      path: '/dashboard/craftsman',
      activeIcon: '🏠'
    },
    {
      icon: '📋',
      label: 'İşlerim',
      path: '/job-management',
      activeIcon: '📋'
    },
    {
      icon: '💬',
      label: 'Mesajlar',
      path: '/messages',
      activeIcon: '💬'
    },
    {
      icon: '📊',
      label: 'Analitik',
      path: '/analytics',
      activeIcon: '📊'
    },
    {
      icon: '👤',
      label: 'Profil',
      path: '/profile',
      activeIcon: '👤'
    },
    {
      icon: '⚖️',
      label: 'Yasal',
      path: '/legal',
      activeIcon: '⚖️'
    }
  ];

  const navItems = user.user_type === 'customer' ? customerNavItems : craftsmanNavItems;

  const isActive = (path) => {
    if (path === '/dashboard/customer' || path === '/dashboard/craftsman') {
      return location.pathname === path;
    }
    return location.pathname.startsWith(path);
  };

  return (
    <div className="md:hidden fixed bottom-0 left-0 right-0 bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 shadow-lg z-50 transition-colors duration-200">
      <div className="flex justify-around items-center py-2">
        {navItems.map((item, index) => (
          <button
            key={index}
            onClick={() => navigate(item.path)}
            className={`flex flex-col items-center justify-center py-2 px-3 rounded-lg transition-all duration-200 min-w-[60px] ${
              isActive(item.path)
                ? 'bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 transform scale-105'
                : 'text-gray-600 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-400 hover:bg-gray-50 dark:hover:bg-gray-800'
            }`}
          >
            <div className={`text-xl mb-1 transition-transform duration-200 ${
              isActive(item.path) ? 'animate-bounce' : ''
            }`}>
              {isActive(item.path) ? item.activeIcon : item.icon}
            </div>
            <span className={`text-xs font-medium transition-colors duration-200 ${
              isActive(item.path) ? 'text-blue-600 dark:text-blue-400' : 'text-gray-600 dark:text-gray-400'
            }`}>
              {item.label}
            </span>
            {isActive(item.path) && (
              <div className="absolute -top-1 left-1/2 transform -translate-x-1/2 w-1 h-1 bg-blue-500 rounded-full"></div>
            )}
          </button>
        ))}
      </div>
      
      {/* Safe area for newer phones */}
      <div className="h-safe-area-inset-bottom bg-white dark:bg-gray-900"></div>
    </div>
  );
};

export default MobileNavigation;