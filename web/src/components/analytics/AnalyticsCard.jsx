import React from 'react';

const AnalyticsCard = ({ 
  title, 
  value, 
  change, 
  changeType = 'positive', 
  icon, 
  description,
  trend,
  className = '' 
}) => {
  const getChangeColor = () => {
    if (changeType === 'positive') return 'text-green-600 dark:text-green-400';
    if (changeType === 'negative') return 'text-red-600 dark:text-red-400';
    return 'text-gray-600 dark:text-gray-400';
  };

  const getChangeIcon = () => {
    if (changeType === 'positive') {
      return (
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 17l9.2-9.2M17 17V7H7" />
        </svg>
      );
    }
    if (changeType === 'negative') {
      return (
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 7l-9.2 9.2M7 7v10h10" />
        </svg>
      );
    }
    return (
      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6" />
      </svg>
    );
  };

  return (
    <div className={`bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700 ${className}`}>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-3">
          {icon && (
            <div className="w-10 h-10 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
              <span className="text-blue-600 dark:text-blue-400 text-xl">{icon}</span>
            </div>
          )}
          <div>
            <h3 className="text-sm font-medium text-gray-600 dark:text-gray-400 uppercase tracking-wide">
              {title}
            </h3>
            <div className="text-2xl font-bold text-gray-900 dark:text-white mt-1">
              {value}
            </div>
          </div>
        </div>
        
        {change && (
          <div className={`flex items-center space-x-1 ${getChangeColor()}`}>
            {getChangeIcon()}
            <span className="text-sm font-medium">{change}</span>
          </div>
        )}
      </div>

      {description && (
        <p className="text-sm text-gray-600 dark:text-gray-400 mb-3">
          {description}
        </p>
      )}

      {trend && (
        <div className="mt-4">
          <div className="flex items-center justify-between text-xs text-gray-500 dark:text-gray-400 mb-1">
            <span>Trend</span>
            <span>Son 30 gün</span>
          </div>
          <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
            <div 
              className={`h-2 rounded-full ${
                changeType === 'positive' 
                  ? 'bg-green-500' 
                  : changeType === 'negative' 
                    ? 'bg-red-500' 
                    : 'bg-gray-500'
              }`}
              style={{ width: `${Math.abs(trend || 0)}%` }}
            ></div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AnalyticsCard;