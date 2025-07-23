import React from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "../components/Button";

export const StartPage = () => {
  const navigate = useNavigate();

  return (
    <div className="bg-white flex flex-row justify-center w-full">
      <div className="bg-white w-[375px] h-[812px] relative">
        {/* Home indicator */}
        <div className="absolute w-[134px] h-[5px] top-[798px] left-[121px]">
          <div className="relative w-[136px] h-[7px] -top-px -left-px bg-black rounded-[34px]" />
        </div>

        {/* App title */}
        <div className="absolute top-[389px] left-[108px] font-['Raleway-Bold',Helvetica] font-bold text-[#202020] text-[52px] text-center tracking-[-0.52px] leading-[normal] whitespace-nowrap">
          Ustam
        </div>

        {/* Subtitle */}
        <p className="w-[249px] top-[468px] left-[63px] text-[19px] text-center leading-[33px] absolute font-['Nunito_Sans-Light',Helvetica] font-light text-[#202020] tracking-[0]">
          Evinizin her ihtiyacı için tek uygulama!
        </p>

        {/* Login link */}
        <div className="absolute w-[213px] h-[30px] top-[713px] left-[81px] overflow-hidden">
          <button 
            onClick={() => navigate('/login')}
            className="top-[5px] left-0 opacity-90 text-[15px] leading-[26px] whitespace-nowrap absolute font-['Nunito_Sans-Light',Helvetica] font-light text-[#202020] tracking-[0] cursor-pointer hover:opacity-100 transition-opacity"
          >
            Hesabım var
          </button>

          <Button 
            className="!absolute !w-[30px] !h-[30px] !top-0 !left-[183px]" 
            variant="circle"
            onClick={() => navigate('/login')}
          >
            <svg className="w-4 h-4 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
            </svg>
          </Button>
        </div>

        {/* Status bar */}
        <div className="absolute w-[375px] h-11 top-0 left-0 overflow-hidden">
          <div className="absolute w-[54px] h-[18px] top-[13px] left-[21px] overflow-hidden">
            <div className="absolute w-[54px] top-px left-0 font-['Nunito_Sans-SemiBold',Helvetica] font-semibold text-black text-sm text-center tracking-[0] leading-[normal] whitespace-nowrap">
              9:41
            </div>
          </div>
          
          {/* Battery, WiFi, Cellular icons placeholders */}
          <div className="absolute w-6 h-[11px] top-[17px] left-[336px] bg-gray-800 rounded-sm"></div>
          <div className="absolute w-[15px] h-[11px] top-[17px] left-[316px] bg-gray-800 rounded-sm"></div>
          <div className="absolute w-[17px] h-[11px] top-[18px] left-[294px] bg-gray-800 rounded-sm"></div>
        </div>

        {/* Logo circle */}
        <div className="absolute w-[150px] h-[150px] top-[227px] left-[113px] bg-gradient-to-br from-blue-400 to-blue-600 rounded-full flex items-center justify-center">
          <div className="w-[81px] h-[92px] bg-white rounded-lg flex items-center justify-center">
            <svg className="w-12 h-12 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
            </svg>
          </div>
        </div>

        {/* Start button */}
        <button 
          onClick={() => navigate('/register')}
          className="all-[unset] box-border absolute w-[335px] h-[61px] top-[634px] left-5 overflow-hidden cursor-pointer"
        >
          <div className="relative w-[337px] h-[63px] -top-px -left-px bg-[#004cff] rounded-2xl hover:bg-[#0040d9] transition-colors duration-200">
            <div className="absolute top-[17px] left-[89px] font-['Nunito_Sans-Light',Helvetica] font-light text-[#f3f3f3] text-[22px] text-center tracking-[0] leading-[31px] whitespace-nowrap">
              Hadi başlayalım!
            </div>
          </div>
        </button>
      </div>
    </div>
  );
};
