import React from "react";

export const Button = ({ className = "", children, onClick, disabled = false, variant = "primary" }) => {
  const baseStyles = "all-[unset] box-border overflow-hidden cursor-pointer transition-all duration-200";
  
  const variants = {
    primary: "bg-[#004cff] hover:bg-[#0040d9] text-[#f3f3f3] rounded-2xl",
    secondary: "bg-gray-200 hover:bg-gray-300 text-gray-800 rounded-2xl",
    circle: "rounded-full bg-white shadow-lg hover:shadow-xl"
  };

  return (
    <button
      className={`${baseStyles} ${variants[variant]} ${disabled ? 'opacity-50 cursor-not-allowed' : ''} ${className}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
};
