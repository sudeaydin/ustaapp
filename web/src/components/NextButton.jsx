import React from "react";

export const NextButton = ({ 
  className = "", 
  divClassName = "", 
  property1 = "default", 
  text = "Devam",
  onClick,
  disabled = false 
}) => {
  const baseStyles = "all-[unset] box-border w-[335px] h-[61px] overflow-hidden cursor-pointer";
  
  const variants = {
    default: "opacity-50 cursor-not-allowed",
    select: "cursor-pointer hover:bg-[#0040d9]",
    active: "cursor-pointer hover:bg-[#0040d9]"
  };

  return (
    <button 
      className={`${baseStyles} ${className} ${disabled ? variants.default : variants[property1]}`}
      onClick={onClick}
      disabled={disabled}
    >
      <div className="relative w-[337px] h-[63px] -top-px -left-px bg-[#004cff] rounded-2xl transition-all duration-200">
        <div className={`
          absolute top-[17px] left-[133px] 
          font-['Nunito_Sans-Light',Helvetica] font-light 
          text-[#f3f3f3] text-[22px] text-center 
          tracking-[0] leading-[31px] whitespace-nowrap
          ${divClassName}
        `}>
          {text}
        </div>
      </div>
    </button>
  );
};
