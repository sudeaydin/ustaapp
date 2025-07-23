import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Form } from "../components/Form";
import { NextButton } from "../components/NextButton";
import { Heart } from "../components/Icons";
import { useAuth } from "../context/AuthContext";

export const LoginPage = () => {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [step, setStep] = useState(1); // 1: email, 2: password
  const [formError, setFormError] = useState(null);

  const handleContinue = async () => {
    if (step === 1) {
      if (email) {
        setStep(2);
      }
    } else {
      try {
        setFormError(null);
        const result = await login(email, password);
        if (result.success) {
          // User type'a göre yönlendirme
          const userData = JSON.parse(localStorage.getItem('authUser'));
          if (userData?.user_type === 'craftsman') {
            navigate('/dashboard/craftsman');
          } else if (userData?.user_type === 'customer') {
            navigate('/dashboard/customer');
          } else {
            navigate('/home'); // fallback
          }
        } else {
          setFormError(result.message || 'Giriş başarısız');
        }
      } catch (err) {
        setFormError(err.message || 'Giriş başarısız');
      }
    }
  };

  const isButtonEnabled = step === 1 ? email.length > 0 : password.length > 0;

  return (
    <div className="bg-white flex flex-row justify-center w-full">
      <div className="bg-white overflow-hidden w-[375px] h-[812px]">
        <div className="relative w-[782px] h-[1113px] top-[-172px] left-[-158px]">
          {/* Background bubbles */}
          <div className="absolute w-[782px] h-[1113px] top-0 left-0">
            <div className="absolute w-[235px] h-[310px] top-[674px] left-[298px] bg-gradient-to-br from-blue-100 to-blue-200 rounded-full opacity-30"></div>
            <div className="absolute w-[68px] h-[137px] top-[433px] left-[465px] bg-gradient-to-br from-purple-100 to-purple-200 rounded-full opacity-30"></div>
            <div className="absolute w-[296px] h-[331px] top-[172px] left-[158px] bg-gradient-to-br from-pink-100 to-pink-200 rounded-full opacity-30">
              <div className="absolute w-[244px] h-[272px] top-0 left-0 bg-gradient-to-br from-orange-100 to-orange-200 rounded-full opacity-50"></div>
            </div>
          </div>

          {/* Home indicator */}
          <div className="absolute w-[134px] h-[5px] top-[970px] left-[279px]">
            <div className="relative w-[136px] h-[7px] -top-px -left-px bg-black rounded-[34px]" />
          </div>

          {/* Subtitle with heart */}
          <div className="absolute top-[674px] left-[178px] font-['Nunito_Sans-Light',Helvetica] font-light text-[#202020] text-[19px] tracking-[0] leading-[35px] whitespace-nowrap flex items-center">
            Evin için hazırız!
            <Heart className="w-4 h-[15px] ml-2 text-red-500" />
          </div>

          {/* Title */}
          <div className="top-[609px] left-[178px] font-['Raleway-Bold',Helvetica] font-bold text-[52px] tracking-[-0.52px] leading-[normal] absolute text-[#202020] whitespace-nowrap">
            Giriş
          </div>

          {/* Cancel button */}
          <button 
            onClick={() => navigate('/')}
            className="top-[890px] left-[331px] opacity-90 font-['Nunito_Sans-Light',Helvetica] font-light text-[15px] text-center tracking-[0] leading-[26px] absolute text-[#202020] whitespace-nowrap cursor-pointer hover:opacity-100 transition-opacity"
          >
            İptal
          </button>

          {/* Status bar */}
          <div className="absolute w-[375px] h-11 top-[172px] left-[158px] overflow-hidden">
            <div className="absolute w-[54px] h-[18px] top-[13px] left-[21px] overflow-hidden">
              <div className="absolute w-[54px] top-px left-0 font-['Nunito_Sans-SemiBold',Helvetica] font-semibold text-black text-sm text-center tracking-[0] leading-[normal] whitespace-nowrap">
                9:41
              </div>
            </div>
            
            {/* Battery, WiFi, Cellular icons */}
            <div className="absolute w-6 h-[11px] top-[17px] left-[336px] bg-gray-800 rounded-sm"></div>
            <div className="absolute w-[15px] h-[11px] top-[17px] left-[316px] bg-gray-800 rounded-sm"></div>
            <div className="absolute w-[17px] h-[11px] top-[18px] left-[294px] bg-gray-800 rounded-sm"></div>
          </div>

          {/* Form fields */}
          {step === 1 ? (
            <Form
              className="!h-[52px] !rounded-[59.12px] !gap-[9.85px] !px-[19.71px] !py-[15.76px] !absolute !left-[179px] !w-[334px] !top-[727px]"
              text="Mail adresi"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          ) : (
            <div className="absolute left-[179px] w-[334px] top-[727px] space-y-4">
              <Form
                className="!h-[52px] !rounded-[59.12px] !gap-[9.85px] !px-[19.71px] !py-[15.76px] !w-full"
                text="Mail adresi"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
              <Form
                className="!h-[52px] !rounded-[59.12px] !gap-[9.85px] !px-[19.71px] !py-[15.76px] !w-full"
                text="Şifre"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
          )}

          {/* Continue/Login button */}
          <NextButton
            className="!absolute !left-[178px] !top-[816px]"
            property1={isButtonEnabled ? "select" : "default"}
            text={step === 1 ? "Devam" : "Giriş Yap"}
            onClick={handleContinue}
            disabled={!isButtonEnabled || isLoading}
          />

          {/* Error message */}
          {(formError || error) && (
            <div className="absolute left-[178px] top-[780px] w-[334px] text-red-600 text-sm text-center">
              {formError || error}
            </div>
          )}

          {/* Register link */}
          {step === 1 && (
            <button
              onClick={() => navigate('/register')}
              className="absolute top-[860px] left-[178px] font-['Nunito_Sans-Light',Helvetica] font-light text-[#004cff] text-[15px] text-center tracking-[0] leading-[26px] whitespace-nowrap cursor-pointer hover:underline"
            >
              Hesabın yok mu? Kayıt ol
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
