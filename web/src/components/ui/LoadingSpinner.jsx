import React from 'react';

const LoadingSpinner = ({ 
  size = 'medium', 
  color = '#467599', 
  message = null,
  className = '' 
}) => {
  const sizeClasses = {
    small: 'w-4 h-4',
    medium: 'w-8 h-8',
    large: 'w-12 h-12',
    xlarge: 'w-16 h-16'
  };

  return (
    <div className={`flex flex-col items-center justify-center ${className}`}>
      <div 
        className={`${sizeClasses[size]} border-2 border-gray-200 border-t-current rounded-full animate-spin`}
        style={{ borderTopColor: color }}
      />
      {message && (
        <p className="mt-3 text-sm text-gray-600 text-center">
          {message}
        </p>
      )}
    </div>
  );
};

export const LoadingOverlay = ({ isLoading, children, message }) => {
  return (
    <div className="relative">
      {children}
      {isLoading && (
        <div className="absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center z-50">
          <LoadingSpinner size="large" message={message} />
        </div>
      )}
    </div>
  );
};

export const SkeletonLoader = ({ className = '', width = 'w-full', height = 'h-4' }) => {
  return (
    <div className={`${width} ${height} bg-gray-200 rounded animate-pulse ${className}`} />
  );
};

export const SkeletonCard = () => {
  return (
    <div className="bg-white rounded-lg shadow-md p-6 space-y-4">
      <div className="flex items-center space-x-4">
        <SkeletonLoader width="w-12" height="h-12" className="rounded-full" />
        <div className="flex-1 space-y-2">
          <SkeletonLoader height="h-4" />
          <SkeletonLoader width="w-2/3" height="h-3" />
        </div>
      </div>
      <div className="space-y-2">
        <SkeletonLoader height="h-3" />
        <SkeletonLoader width="w-4/5" height="h-3" />
        <SkeletonLoader width="w-3/5" height="h-3" />
      </div>
    </div>
  );
};

export default LoadingSpinner;