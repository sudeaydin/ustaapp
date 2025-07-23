import React, { useState } from "react";

export const Form = ({ 
  className = "", 
  divClassName = "", 
  frameClassName = "",
  text = "", 
  text1 = "",
  text2 = "",
  type = "text", 
  status = "default",
  icon,
  placeholder,
  value,
  onChange,
  ...props 
}) => {
  const [showPassword, setShowPassword] = useState(false);
  const [inputValue, setInputValue] = useState(value || "");

  const handleChange = (e) => {
    setInputValue(e.target.value);
    if (onChange) onChange(e);
  };

  const displayText = text || text1 || text2 || placeholder;
  const inputType = type === "password" && showPassword ? "text" : type;

  return (
    <div className={`relative ${className}`}>
      <input
        type={inputType}
        placeholder={displayText}
        value={inputValue}
        onChange={handleChange}
        className={`
          w-full h-full px-[19.76px] py-[15.81px] 
          rounded-[59.29px] border border-gray-200
          bg-white text-[13.8px] font-medium
          font-['Poppins-Medium',Helvetica] leading-[19.4px]
          focus:outline-none focus:border-[#004cff] focus:ring-1 focus:ring-[#004cff]
          transition-all duration-200
          ${divClassName} ${frameClassName}
        `}
        {...props}
      />
      
      {/* Password toggle icon */}
      {type === "password" && (
        <button
          type="button"
          onClick={() => setShowPassword(!showPassword)}
          className="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
        >
          {showPassword ? (
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z" clipRule="evenodd" />
              <path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z" />
            </svg>
          ) : (
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
              <path fillRule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clipRule="evenodd" />
            </svg>
          )}
        </button>
      )}

      {/* Custom icon */}
      {icon && (
        <div className="absolute right-4 top-1/2 transform -translate-y-1/2">
          {icon}
        </div>
      )}
    </div>
  );
};
