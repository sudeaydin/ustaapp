import React from 'react';

const AirbnbBottomNavigation = ({ selectedIndex, onItemTapped, items }) => {
  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 p-4">
      <div className="bottom-nav">
        <div className="flex justify-around">
          {items.map((item, index) => (
            <button
              key={index}
              className={`bottom-nav-item ${selectedIndex === index ? 'bottom-nav-item-active' : ''}`}
              onClick={() => onItemTapped(index)}
            >
              <div className={`text-xl mb-1 ${selectedIndex === index ? 'text-airbnb-500' : 'text-airbnb-dark-500 dark:text-airbnb-light-500'}`}>
                {selectedIndex === index ? item.activeIcon : item.icon}
              </div>
              <span className={`text-xs font-medium ${selectedIndex === index ? 'text-airbnb-500' : 'text-airbnb-dark-500 dark:text-airbnb-light-500'}`}>
                {item.label}
              </span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};

export default AirbnbBottomNavigation;