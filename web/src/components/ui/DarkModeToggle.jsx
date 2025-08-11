import React from 'react';
import { useTheme } from '../../context/ThemeContext';

const DarkModeToggle = ({ className = '', size = 'medium' }) => {
  const { isDarkMode, toggleDarkMode } = useTheme();

  const sizeClasses = {
    small: 'h-5 w-9',
    medium: 'h-6 w-11', 
    large: 'h-7 w-13'
  };

  const thumbSizeClasses = {
    small: 'h-3 w-3',
    medium: 'h-4 w-4',
    large: 'h-5 w-5'
  };

  const translateClasses = {
    small: isDarkMode ? 'translate-x-5' : 'translate-x-1',
    medium: isDarkMode ? 'translate-x-6' : 'translate-x-1',
    large: isDarkMode ? 'translate-x-7' : 'translate-x-1'
  };

  return (
    <button
      onClick={toggleDarkMode}
      className={`relative inline-flex ${sizeClasses[size]} items-center rounded-full transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800 ${
        isDarkMode 
          ? 'bg-blue-600 hover:bg-blue-700' 
          : 'bg-gray-300 hover:bg-gray-400'
      } ${className}`}
      role="switch"
      aria-checked={isDarkMode}
      aria-label={isDarkMode ? 'Switch to light mode' : 'Switch to dark mode'}
      title={isDarkMode ? 'Switch to light mode' : 'Switch to dark mode'}
    >
      {/* Toggle thumb */}
      <span
        className={`inline-block ${thumbSizeClasses[size]} transform rounded-full bg-white transition-transform duration-200 shadow-sm ${translateClasses[size]}`}
      />
      
      {/* Icons */}
      <div className="absolute inset-0 flex items-center justify-between px-1">
        {/* Sun icon (light mode) */}
        <svg
          className={`w-3 h-3 text-yellow-400 transition-opacity duration-200 ${
            isDarkMode ? 'opacity-0' : 'opacity-100'
          }`}
          fill="currentColor"
          viewBox="0 0 20 20"
        >
          <path
            fillRule="evenodd"
            d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z"
            clipRule="evenodd"
          />
        </svg>
        
        {/* Moon icon (dark mode) */}
        <svg
          className={`w-3 h-3 text-blue-300 transition-opacity duration-200 ${
            isDarkMode ? 'opacity-100' : 'opacity-0'
          }`}
          fill="currentColor"
          viewBox="0 0 20 20"
        >
          <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z" />
        </svg>
      </div>
      
      <span className="sr-only">
        {isDarkMode ? 'Switch to light mode' : 'Switch to dark mode'}
      </span>
    </button>
  );
};

export default DarkModeToggle;