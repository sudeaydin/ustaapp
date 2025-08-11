import React, { createContext, useContext, useState, useEffect } from 'react';

const ThemeContext = createContext();

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};

// Color palette with dark mode variants
const colorPalette = {
  light: {
    poppy: '#E63946',
    'mint-green': '#2D9CDB', 
    'non-photo-blue': '#9ECADD',
    'ucla-blue': '#457B9D',
    'delft-blue': '#1D3557',
    background: '#FFFFFF',
    surface: '#F8F9FA',
    surfaceVariant: '#F1F3F4',
    onBackground: '#1D3557',
    onSurface: '#1D3557',
    primary: '#E63946',
    secondary: '#2D9CDB',
    success: '#38A169',
    warning: '#D69E2E',
    error: '#E53E3E',
    border: '#E2E8F0',
  },
  dark: {
    poppy: '#FF6B7A',
    'mint-green': '#4FC3F7',
    'non-photo-blue': '#B3E5FC', 
    'ucla-blue': '#64B5F6',
    'delft-blue': '#2196F3',
    background: '#0F172A',
    surface: '#1E293B',
    surfaceVariant: '#334155',
    onBackground: '#F1F5F9',
    onSurface: '#F1F5F9',
    primary: '#FF6B7A',
    secondary: '#4FC3F7',
    success: '#4ADE80',
    warning: '#FBBF24',
    error: '#F87171',
    border: '#475569',
  }
};

export const ThemeProvider = ({ children }) => {
  const [isDarkMode, setIsDarkMode] = useState(() => {
    const saved = localStorage.getItem('darkMode');
    if (saved !== null) {
      return JSON.parse(saved);
    }
    return window.matchMedia('(prefers-color-scheme: dark)').matches;
  });

  useEffect(() => {
    localStorage.setItem('darkMode', JSON.stringify(isDarkMode));
    
    // Update document class for Tailwind dark mode
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }

    // Apply CSS custom properties
    const colors = colorPalette[isDarkMode ? 'dark' : 'light'];
    const root = document.documentElement;
    
    Object.entries(colors).forEach(([key, value]) => {
      root.style.setProperty(`--color-${key}`, value);
    });
  }, [isDarkMode]);

  const toggleDarkMode = () => {
    setIsDarkMode(!isDarkMode);
  };

  const value = {
    isDarkMode,
    toggleDarkMode,
    theme: isDarkMode ? 'dark' : 'light',
    colors: colorPalette[isDarkMode ? 'dark' : 'light']
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};