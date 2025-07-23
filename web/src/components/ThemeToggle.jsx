import React from 'react';
import { useTheme } from '../context/ThemeContext';

export const ThemeToggle = ({ className = '' }) => {
  const { isDark, toggleTheme } = useTheme();

  return (
    <button
      onClick={toggleTheme}
      className={`relative inline-flex items-center justify-center w-12 h-12 rounded-full transition-all duration-300 hover:scale-110 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 ${
        isDark 
          ? 'bg-gray-800 text-yellow-400 hover:bg-gray-700' 
          : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
      } ${className}`}
      aria-label={isDark ? 'Switch to light mode' : 'Switch to dark mode'}
    >
      <div className="relative w-6 h-6 overflow-hidden">
        {/* Sun Icon */}
        <div className={`absolute inset-0 transform transition-all duration-300 ${
          isDark ? 'rotate-90 scale-0 opacity-0' : 'rotate-0 scale-100 opacity-100'
        }`}>
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
          </svg>
        </div>
        
        {/* Moon Icon */}
        <div className={`absolute inset-0 transform transition-all duration-300 ${
          isDark ? 'rotate-0 scale-100 opacity-100' : '-rotate-90 scale-0 opacity-0'
        }`}>
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
          </svg>
        </div>
      </div>
    </button>
  );
};

export const ThemeToggleSwitch = ({ className = '' }) => {
  const { isDark, toggleTheme } = useTheme();

  return (
    <div className={`flex items-center space-x-3 ${className}`}>
      <span className={`text-sm font-medium ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>
        🌞
      </span>
      <button
        onClick={toggleTheme}
        className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors duration-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 ${
          isDark ? 'bg-blue-600' : 'bg-gray-200'
        }`}
        aria-label="Toggle dark mode"
      >
        <span
          className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform duration-300 ${
            isDark ? 'translate-x-6' : 'translate-x-1'
          }`}
        />
      </button>
      <span className={`text-sm font-medium ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>
        🌙
      </span>
    </div>
  );
};

export const ThemeToggleButton = ({ className = '', variant = 'icon' }) => {
  const { isDark, toggleTheme } = useTheme();

  if (variant === 'switch') {
    return <ThemeToggleSwitch className={className} />;
  }

  return (
    <button
      onClick={toggleTheme}
      className={`inline-flex items-center space-x-2 px-4 py-2 rounded-lg font-medium transition-all duration-300 ${
        isDark
          ? 'bg-gray-800 text-yellow-400 hover:bg-gray-700'
          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
      } ${className}`}
    >
      <span className="text-lg">
        {isDark ? '🌙' : '☀️'}
      </span>
      <span className="hidden sm:inline">
        {isDark ? 'Dark' : 'Light'}
      </span>
    </button>
  );
};

export default ThemeToggle;