import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Form } from "../components/Form";
import { EyeSlash, ArrowDown } from "../components/Icons";
import { useAuth } from "../context/AuthContext";

export const RegisterPage = () => {
  const navigate = useNavigate();
  const { register } = useAuth();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    phone: '',
    firstName: '',
    lastName: '',
    userType: 'customer'
  });
  const [formError, setFormError] = useState(null);

  const handleInputChange = (field) => (e) => {
    setFormData(prev => ({
      ...prev,
      [field]: e.target.value
    }));
  };

  const handleSubmit = async () => {
    try {
      setFormError(null);
      // API'ye uygun field isimleriyle gönder
      const payload = {
        email: formData.email,
        password: formData.password,
        confirm_password: formData.password,
        phone: formData.phone,
        first_name: formData.firstName,
        last_name: formData.lastName,
        user_type: formData.userType
      };
      const result = await register(payload);
      if (result.success) {
        navigate('/home');
      } else {
        setFormError(result.message || 'Kayıt başarısız');
      }
    } catch (err) {
      setFormError(err.message || 'Kayıt başarısız');
    }
  };

  return (
    <div className="bg-white flex flex-row justify-center w-full">
      <div className="bg-white overflow-hidden w-[375px] h-[812px] relative">
        {/* Background bubbles */}
        <div className="absolute w-[659px] h-[580px] top-[-206px] left-[-132px]">
          <div className="absolute w-[659px] h-[513px] top-0 left-0">
            {/* Bubble decorations */}
            <div className="absolute w-[228px] h-[212px] top-[206px] left-[132px] bg-gradient-to-br from-blue-100 to-blue-200 rounded-full opacity-30"></div>
            <div className="absolute w-[91px] h-[267px] top-[247px] left-[416px] bg-gradient-to-br from-purple-100 to-purple-200 rounded-full opacity-30"></div>
          </div>

          {/* Back button */}
          <div className="absolute w-[90px] h-[90px] top-[490px] left-[162px] bg-white rounded-full shadow-lg flex items-center justify-center cursor-pointer hover:shadow-xl transition-shadow"
               onClick={() => navigate(-1)}>
            <svg className="w-8 h-8 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clipRule="evenodd" />
            </svg>
          </div>

          {/* Title */}
          <div className="absolute top-[327px] left-[162px] font-['Raleway-Bold',Helvetica] font-bold text-[#202020] text-[50px] tracking-[-0.50px] leading-[54px]">
            Hesap <br />
            Oluştur
          </div>

          {/* Status bar */}
          <div className="absolute w-[375px] h-11 top-[206px] left-[132px] overflow-hidden">
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
        </div>

        {/* Home indicator */}
        <div className="absolute w-[134px] h-[5px] top-[798px] left-[121px]">
          <div className="relative w-[136px] h-[7px] -top-px -left-px bg-black rounded-[34px]" />
        </div>

        {/* Cancel button */}
        <button 
          onClick={() => navigate(-1)}
          className="absolute top-[718px] left-[173px] opacity-90 font-['Nunito_Sans-Light',Helvetica] font-light text-[#202020] text-[15px] text-center tracking-[0] leading-[26px] whitespace-nowrap cursor-pointer hover:opacity-100 transition-opacity"
        >
          İptal
        </button>

        {/* Submit button */}
        <button 
          onClick={handleSubmit}
          className="all-[unset] box-border absolute w-[335px] h-[61px] top-[634px] left-5 overflow-hidden cursor-pointer"
        >
          <div className="relative w-[337px] h-[63px] -top-px -left-px bg-[#004cff] rounded-2xl hover:bg-[#0040d9] transition-colors duration-200">
            <div className="absolute top-[17px] left-[133px] font-['Nunito_Sans-Light',Helvetica] font-light text-[#f3f3f3] text-[22px] text-center tracking-[0] leading-[31px] whitespace-nowrap">
              Tamam
            </div>
          </div>
        </button>

        {/* Error message */}
        {(formError || error) && (
          <div className="absolute left-[50px] top-[750px] w-[275px] text-red-600 text-sm text-center">
            {formError || error}
          </div>
        )}

        {/* Form fields */}
        <div className="absolute w-[335px] h-auto top-[360px] left-5 space-y-3">
          <Form
            className="h-[52.37px] rounded-[59.29px] w-full"
            text="Ad"
            type="text"
            value={formData.firstName}
            onChange={handleInputChange('firstName')}
          />
          
          <Form
            className="h-[52.37px] rounded-[59.29px] w-full"
            text="Soyad"
            type="text"
            value={formData.lastName}
            onChange={handleInputChange('lastName')}
          />
          
          <Form
            className="h-[52.37px] rounded-[59.29px] w-full"
            text="Mail adresi"
            type="email"
            value={formData.email}
            onChange={handleInputChange('email')}
          />
          
          <Form
            className="h-[52.37px] rounded-[59.29px] w-full"
            text="Şifre"
            type="password"
            value={formData.password}
            onChange={handleInputChange('password')}
            icon={<EyeSlash className="w-4 h-4 text-gray-400" />}
          />
          
          <Form
            className="h-[55.34px] rounded-[59.29px] w-full"
            text="Telefon numarası"
            type="tel"
            value={formData.phone}
            onChange={handleInputChange('phone')}
          />

          {/* User type selection */}
          <div className="flex space-x-4 mt-4">
            <label className="flex items-center space-x-2 cursor-pointer">
              <input
                type="radio"
                name="userType"
                value="customer"
                checked={formData.userType === 'customer'}
                onChange={handleInputChange('userType')}
                className="text-[#004cff]"
              />
              <span className="text-[13.8px] font-medium text-gray-700">Müşteri</span>
            </label>
            <label className="flex items-center space-x-2 cursor-pointer">
              <input
                type="radio"
                name="userType"
                value="craftsman"
                checked={formData.userType === 'craftsman'}
                onChange={handleInputChange('userType')}
                className="text-[#004cff]"
              />
              <span className="text-[13.8px] font-medium text-gray-700">Usta</span>
            </label>
          </div>
        </div>
      </div>
    </div>
  );
};
