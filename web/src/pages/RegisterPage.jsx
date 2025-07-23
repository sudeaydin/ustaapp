import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const RegisterPage = () => {
  const navigate = useNavigate();
  const { login } = useAuth();
  
  const [step, setStep] = useState(1); // 1: user type, 2: basic info, 3: additional info
  const [formData, setFormData] = useState({
    userType: '',
    // Basic info
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    phone: '',
    city: '',
    district: '',
    // Craftsman specific
    businessName: '',
    description: '',
    experienceYears: '',
    hourlyRate: '',
    skills: [],
    workingHours: {
      monday: '09:00-18:00',
      tuesday: '09:00-18:00',
      wednesday: '09:00-18:00',
      thursday: '09:00-18:00',
      friday: '09:00-18:00',
      saturday: '09:00-15:00',
      sunday: 'Kapalı'
    }
  });
  
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  // Mock skills data
  const availableSkills = [
    { id: 1, name: 'Elektrik Tesisatı', category: 'Elektrik' },
    { id: 2, name: 'LED Aydınlatma', category: 'Elektrik' },
    { id: 3, name: 'Klima Montajı', category: 'Soğutma' },
    { id: 4, name: 'Banyo Tesisatı', category: 'Tesisatçılık' },
    { id: 5, name: 'Mutfak Tesisatı', category: 'Tesisatçılık' },
    { id: 6, name: 'Boyama', category: 'Boyacılık' },
    { id: 7, name: 'Duvar Kağıdı', category: 'Boyacılık' },
    { id: 8, name: 'Parke Döşeme', category: 'Döşemeci' }
  ];

  const cities = [
    'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana', 'Konya', 'Gaziantep'
  ];

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const handleSkillToggle = (skillId) => {
    setFormData(prev => ({
      ...prev,
      skills: prev.skills.includes(skillId)
        ? prev.skills.filter(id => id !== skillId)
        : [...prev.skills, skillId]
    }));
  };

  const validateStep = (stepNumber) => {
    const newErrors = {};
    
    if (stepNumber === 1) {
      if (!formData.userType) {
        newErrors.userType = 'Hesap türü seçin';
      }
    }
    
    if (stepNumber === 2) {
      // Basic info validation
      if (!formData.name.trim()) {
        newErrors.name = 'Ad Soyad gerekli';
      }
      
      if (!formData.email) {
        newErrors.email = 'E-posta adresi gerekli';
      } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
        newErrors.email = 'Geçerli bir e-posta adresi girin';
      }
      
      if (!formData.password) {
        newErrors.password = 'Şifre gerekli';
      } else if (formData.password.length < 6) {
        newErrors.password = 'Şifre en az 6 karakter olmalı';
      }
      
      if (formData.password !== formData.confirmPassword) {
        newErrors.confirmPassword = 'Şifreler eşleşmiyor';
      }
      
      if (!formData.phone.trim()) {
        newErrors.phone = 'Telefon numarası gerekli';
      }
      
      if (!formData.city) {
        newErrors.city = 'Şehir seçin';
      }
      
      if (!formData.district.trim()) {
        newErrors.district = 'İlçe gerekli';
      }
    }
    
    if (stepNumber === 3 && formData.userType === 'craftsman') {
      if (!formData.businessName.trim()) {
        newErrors.businessName = 'İşletme adı gerekli';
      }
      
      if (!formData.description.trim()) {
        newErrors.description = 'Açıklama gerekli';
      }
      
      if (!formData.experienceYears) {
        newErrors.experienceYears = 'Deneyim yılı gerekli';
      }
      
      if (!formData.hourlyRate) {
        newErrors.hourlyRate = 'Saatlik ücret gerekli';
      }
      
      if (formData.skills.length === 0) {
        newErrors.skills = 'En az bir yetenek seçin';
      }
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = () => {
    if (validateStep(step)) {
      if (step < 3) {
        setStep(step + 1);
      } else {
        handleSubmit();
      }
    }
  };

  const handleSubmit = async () => {
    try {
      setLoading(true);
      
      // Mock registration - in real app, call API
      const userData = {
        id: Date.now(),
        name: formData.name,
        email: formData.email,
        user_type: formData.userType,
        phone: formData.phone,
        city: formData.city,
        district: formData.district,
        created_at: new Date().toISOString()
      };
      
      if (formData.userType === 'craftsman') {
        userData.business_name = formData.businessName;
        userData.description = formData.description;
        userData.experience_years = parseInt(formData.experienceYears);
        userData.hourly_rate = parseInt(formData.hourlyRate);
        userData.skills = formData.skills;
        userData.working_hours = formData.workingHours;
      }
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // Auto login after registration
      await login(userData);
      
      // Redirect based on user type
      if (userData.user_type === 'customer') {
        navigate('/customer/dashboard');
      } else {
        navigate('/craftsman/dashboard');
      }
      
    } catch (error) {
      console.error('Registration error:', error);
      setErrors({ general: 'Kayıt sırasında bir hata oluştu!' });
    } finally {
      setLoading(false);
    }
  };

  const renderStep1 = () => (
    <div className="space-y-6">
      <div className="text-center">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Hesap Türünüz</h2>
        <p className="text-gray-600">Hangi tür hesap oluşturmak istiyorsunuz?</p>
      </div>
      
      <div className="grid grid-cols-1 gap-4">
        <button
          type="button"
          onClick={() => setFormData(prev => ({ ...prev, userType: 'customer' }))}
          className={`p-6 rounded-xl border-2 transition-all text-left ${
            formData.userType === 'customer'
              ? 'border-blue-500 bg-blue-50'
              : 'border-gray-200 bg-white hover:border-gray-300'
          }`}
        >
          <div className="flex items-center space-x-4">
            <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">👤</span>
            </div>
            <div className="flex-1">
              <h3 className="font-semibold text-gray-900">Müşteri</h3>
              <p className="text-sm text-gray-600">İş arıyorum ve usta bulup işimi yaptırmak istiyorum</p>
              <div className="flex items-center mt-2 text-xs text-gray-500">
                <span>✓ İş talebi oluştur</span>
                <span className="mx-2">•</span>
                <span>✓ Teklifleri karşılaştır</span>
                <span className="mx-2">•</span>
                <span>✓ Değerlendirme yap</span>
              </div>
            </div>
          </div>
        </button>
        
        <button
          type="button"
          onClick={() => setFormData(prev => ({ ...prev, userType: 'craftsman' }))}
          className={`p-6 rounded-xl border-2 transition-all text-left ${
            formData.userType === 'craftsman'
              ? 'border-blue-500 bg-blue-50'
              : 'border-gray-200 bg-white hover:border-gray-300'
          }`}
        >
          <div className="flex items-center space-x-4">
            <div className="w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">🔨</span>
            </div>
            <div className="flex-1">
              <h3 className="font-semibold text-gray-900">Usta</h3>
              <p className="text-sm text-gray-600">İş yapıyorum ve müşterilerden iş talepleri alıp teklif veriyorum</p>
              <div className="flex items-center mt-2 text-xs text-gray-500">
                <span>✓ Teklif ver</span>
                <span className="mx-2">•</span>
                <span>✓ İş yap</span>
                <span className="mx-2">•</span>
                <span>✓ Gelir elde et</span>
              </div>
            </div>
          </div>
        </button>
      </div>
      
      {errors.userType && (
        <p className="text-red-500 text-sm text-center">{errors.userType}</p>
      )}
    </div>
  );

  const renderStep2 = () => (
    <div className="space-y-6">
      <div className="text-center">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Temel Bilgiler</h2>
        <p className="text-gray-600">Hesabınızı oluşturmak için gerekli bilgileri girin</p>
      </div>
      
      <div className="grid grid-cols-1 gap-4">
        {/* Name */}
        <div>
          <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
            Ad Soyad *
          </label>
          <input
            type="text"
            id="name"
            name="name"
            value={formData.name}
            onChange={handleInputChange}
            className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
              errors.name ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="Adınız ve soyadınız"
          />
          {errors.name && <p className="text-red-500 text-sm mt-1">{errors.name}</p>}
        </div>

        {/* Email */}
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
            E-posta Adresi *
          </label>
          <input
            type="email"
            id="email"
            name="email"
            value={formData.email}
            onChange={handleInputChange}
            className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
              errors.email ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="ornek@email.com"
          />
          {errors.email && <p className="text-red-500 text-sm mt-1">{errors.email}</p>}
        </div>

        {/* Password */}
        <div>
          <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
            Şifre *
          </label>
          <div className="relative">
            <input
              type={showPassword ? 'text' : 'password'}
              id="password"
              name="password"
              value={formData.password}
              onChange={handleInputChange}
              className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                errors.password ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="En az 6 karakter"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute inset-y-0 right-0 pr-3 flex items-center"
            >
              <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                {showPassword ? (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
                ) : (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                )}
              </svg>
            </button>
          </div>
          {errors.password && <p className="text-red-500 text-sm mt-1">{errors.password}</p>}
        </div>

        {/* Confirm Password */}
        <div>
          <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 mb-2">
            Şifre Tekrar *
          </label>
          <div className="relative">
            <input
              type={showConfirmPassword ? 'text' : 'password'}
              id="confirmPassword"
              name="confirmPassword"
              value={formData.confirmPassword}
              onChange={handleInputChange}
              className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                errors.confirmPassword ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="Şifrenizi tekrar girin"
            />
            <button
              type="button"
              onClick={() => setShowConfirmPassword(!showConfirmPassword)}
              className="absolute inset-y-0 right-0 pr-3 flex items-center"
            >
              <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                {showConfirmPassword ? (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
                ) : (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                )}
              </svg>
            </button>
          </div>
          {errors.confirmPassword && <p className="text-red-500 text-sm mt-1">{errors.confirmPassword}</p>}
        </div>

        {/* Phone */}
        <div>
          <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-2">
            Telefon Numarası *
          </label>
          <input
            type="tel"
            id="phone"
            name="phone"
            value={formData.phone}
            onChange={handleInputChange}
            className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
              errors.phone ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="+90 555 123 4567"
          />
          {errors.phone && <p className="text-red-500 text-sm mt-1">{errors.phone}</p>}
        </div>

        {/* Location */}
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label htmlFor="city" className="block text-sm font-medium text-gray-700 mb-2">
              Şehir *
            </label>
            <select
              id="city"
              name="city"
              value={formData.city}
              onChange={handleInputChange}
              className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                errors.city ? 'border-red-500' : 'border-gray-300'
              }`}
            >
              <option value="">Şehir seçin</option>
              {cities.map(city => (
                <option key={city} value={city}>{city}</option>
              ))}
            </select>
            {errors.city && <p className="text-red-500 text-sm mt-1">{errors.city}</p>}
          </div>

          <div>
            <label htmlFor="district" className="block text-sm font-medium text-gray-700 mb-2">
              İlçe *
            </label>
            <input
              type="text"
              id="district"
              name="district"
              value={formData.district}
              onChange={handleInputChange}
              className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                errors.district ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="İlçe adı"
            />
            {errors.district && <p className="text-red-500 text-sm mt-1">{errors.district}</p>}
          </div>
        </div>
      </div>
    </div>
  );

  const renderStep3 = () => {
    if (formData.userType === 'customer') {
      return (
        <div className="space-y-6">
          <div className="text-center">
            <h2 className="text-2xl font-bold text-gray-900 mb-2">Kayıt Tamamlanıyor</h2>
            <p className="text-gray-600">Müşteri hesabınız oluşturuluyor...</p>
          </div>
          
          <div className="bg-green-50 border border-green-200 rounded-lg p-6 text-center">
            <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <h3 className="text-lg font-medium text-green-900 mb-2">Hazırsınız!</h3>
            <p className="text-green-700">Hesabınız oluşturuldu. Şimdi iş aramaya başlayabilirsiniz.</p>
          </div>
        </div>
      );
    }

    return (
      <div className="space-y-6">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Usta Bilgileri</h2>
          <p className="text-gray-600">İşletmeniz hakkında bilgi verin</p>
        </div>
        
        <div className="space-y-4">
          {/* Business Name */}
          <div>
            <label htmlFor="businessName" className="block text-sm font-medium text-gray-700 mb-2">
              İşletme Adı *
            </label>
            <input
              type="text"
              id="businessName"
              name="businessName"
              value={formData.businessName}
              onChange={handleInputChange}
              className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                errors.businessName ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="Örn: Yılmaz Elektrik"
            />
            {errors.businessName && <p className="text-red-500 text-sm mt-1">{errors.businessName}</p>}
          </div>

          {/* Description */}
          <div>
            <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
              Açıklama *
            </label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleInputChange}
              rows={4}
              className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                errors.description ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="Kendiniz ve hizmetleriniz hakkında bilgi verin..."
            />
            {errors.description && <p className="text-red-500 text-sm mt-1">{errors.description}</p>}
          </div>

          {/* Experience & Rate */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="experienceYears" className="block text-sm font-medium text-gray-700 mb-2">
                Deneyim (Yıl) *
              </label>
              <input
                type="number"
                id="experienceYears"
                name="experienceYears"
                value={formData.experienceYears}
                onChange={handleInputChange}
                min="0"
                max="50"
                className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                  errors.experienceYears ? 'border-red-500' : 'border-gray-300'
                }`}
                placeholder="5"
              />
              {errors.experienceYears && <p className="text-red-500 text-sm mt-1">{errors.experienceYears}</p>}
            </div>

            <div>
              <label htmlFor="hourlyRate" className="block text-sm font-medium text-gray-700 mb-2">
                Saatlik Ücret (₺) *
              </label>
              <input
                type="number"
                id="hourlyRate"
                name="hourlyRate"
                value={formData.hourlyRate}
                onChange={handleInputChange}
                min="0"
                className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                  errors.hourlyRate ? 'border-red-500' : 'border-gray-300'
                }`}
                placeholder="150"
              />
              {errors.hourlyRate && <p className="text-red-500 text-sm mt-1">{errors.hourlyRate}</p>}
            </div>
          </div>

          {/* Skills */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Yetenekleriniz * (En az 1 tane seçin)
            </label>
            <div className="grid grid-cols-2 gap-2">
              {availableSkills.map(skill => (
                <button
                  key={skill.id}
                  type="button"
                  onClick={() => handleSkillToggle(skill.id)}
                  className={`p-3 rounded-lg border-2 transition-all text-left ${
                    formData.skills.includes(skill.id)
                      ? 'border-blue-500 bg-blue-50 text-blue-700'
                      : 'border-gray-200 bg-white hover:border-gray-300'
                  }`}
                >
                  <div className="font-medium text-sm">{skill.name}</div>
                  <div className="text-xs text-gray-500">{skill.category}</div>
                </button>
              ))}
            </div>
            {errors.skills && <p className="text-red-500 text-sm mt-1">{errors.skills}</p>}
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="max-w-2xl w-full">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="w-20 h-20 bg-blue-500 rounded-full flex items-center justify-center mx-auto mb-4">
            <span className="text-3xl font-bold text-white">U</span>
          </div>
          <h1 className="text-3xl font-bold text-gray-900">UstamApp</h1>
          <p className="text-gray-600 mt-2">Hesap oluşturun</p>
        </div>

        {/* Progress Steps */}
        <div className="flex items-center justify-center mb-8">
          {[1, 2, 3].map((stepNumber) => (
            <div key={stepNumber} className="flex items-center">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center font-medium text-sm ${
                step >= stepNumber
                  ? 'bg-blue-500 text-white'
                  : 'bg-gray-200 text-gray-600'
              }`}>
                {stepNumber}
              </div>
              {stepNumber < 3 && (
                <div className={`w-12 h-1 mx-2 ${
                  step > stepNumber ? 'bg-blue-500' : 'bg-gray-200'
                }`}></div>
              )}
            </div>
          ))}
        </div>

        {/* Form */}
        <div className="bg-white rounded-2xl shadow-xl p-8">
          {step === 1 && renderStep1()}
          {step === 2 && renderStep2()}
          {step === 3 && renderStep3()}

          {/* General Error */}
          {errors.general && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-3 mt-6">
              <p className="text-red-600 text-sm">{errors.general}</p>
            </div>
          )}

          {/* Navigation Buttons */}
          <div className="flex items-center justify-between mt-8 pt-6 border-t">
            {step > 1 ? (
              <button
                type="button"
                onClick={() => setStep(step - 1)}
                className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
              >
                Geri
              </button>
            ) : (
              <Link
                to="/login"
                className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
              >
                Giriş Yap
              </Link>
            )}

            <button
              type="button"
              onClick={handleNext}
              disabled={loading}
              className="px-8 py-4 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-xl hover:from-blue-600 hover:to-blue-700 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 font-semibold text-lg shadow-lg hover:shadow-xl transform hover:scale-[1.02] active:scale-[0.98]"
            >
              {loading ? (
                <div className="flex items-center justify-center space-x-2">
                  <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  <span>Kaydediliyor...</span>
                </div>
              ) : step === 3 ? (
                <div className="flex items-center justify-center space-x-2">
                  <span>✨</span>
                  <span>Hesap Oluştur</span>
                </div>
              ) : (
                <div className="flex items-center justify-center space-x-2">
                  <span>➡️</span>
                  <span>Devam</span>
                </div>
              )}
            </button>
          </div>

          {/* Login Link */}
          <div className="text-center mt-6">
            <p className="text-sm text-gray-600">
              Zaten hesabınız var mı?{' '}
              <Link
                to="/login"
                className="text-blue-600 hover:text-blue-800 font-medium transition-colors"
              >
                Giriş Yapın
              </Link>
            </p>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center mt-8">
          <p className="text-sm text-gray-500">
            © 2025 UstamApp. Tüm hakları saklıdır.
          </p>
        </div>
      </div>
    </div>
  );
};

export default RegisterPage;
