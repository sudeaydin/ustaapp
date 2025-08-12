import React from 'react';

const AirbnbCategoryCard = ({ icon, label, onTap, isActive = false }) => {
  return (
    <div 
      className={`category-card ${isActive ? 'ring-2 ring-airbnb-500' : ''}`}
      onClick={onTap}
    >
      <div className="flex flex-col items-center justify-center h-full p-4">
        <div className={`category-card-icon ${isActive ? 'bg-airbnb-500 text-white' : ''}`}>
          {icon}
        </div>
        <span className={`text-sm font-medium mt-2 text-center ${isActive ? 'text-airbnb-500' : 'text-airbnb-dark-700 dark:text-airbnb-light-300'}`}>
          {label}
        </span>
      </div>
    </div>
  );
};

export default AirbnbCategoryCard;