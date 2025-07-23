import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const LoginPage = () => {
  const navigate = useNavigate();
  const { login } = useAuth();
  
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    userType: 'customer' // customer or craftsman
  });
  
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [showPassword, setShowPassword] = useState(false);

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

  const validateForm = () => {
    const newErrors = {};
    
    // Email validation
    if (!formData.email) {
      newErrors.email = 'E-posta adresi gerekli';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Geçerli bir e-posta adresi girin';
    }
    
    // Password validation
    if (!formData.password) {
      newErrors.password = 'Şifre gerekli';
    } else if (formData.password.length < 6) {
      newErrors.password = 'Şifre en az 6 karakter olmalı';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    try {
      setLoading(true);
      
      // Mock login - in real app, call API
      const mockUsers = {
        'customer@test.com': {
          id: 1,
          name: 'Müşteri Test',
          email: 'customer@test.com',
          user_type: 'customer',
          phone: '+90 555 123 4567',
          city: 'İstanbul',
          district: 'Kadıköy'
        },
        'craftsman@test.com': {
          id: 2,
          name: 'Ahmet Yılmaz',
          email: 'craftsman@test.com',
          user_type: 'craftsman',
          business_name: 'Yılmaz Elektrik',
          phone: '+90 555 987 6543',
          city: 'İstanbul',
          district: 'Üsküdar',
          skills: ['Elektrik', 'LED Aydınlatma'],
          experience_years: 8,
          hourly_rate: 150
        }
      };
      
      const user = mockUsers[formData.email];
      
      if (!user || formData.password !== '123456') {
        setErrors({ general: 'E-posta veya şifre hatalı!' });
        return;
      }
      
      if (user.user_type !== formData.userType) {
        setErrors({ general: `Bu hesap ${user.user_type === 'customer' ? 'müşteri' : 'usta'} hesabıdır!` });
        return;
      }
      
      // Login successful
      await login(user);
      
      // Redirect based on user type
      if (user.user_type === 'customer') {
        navigate('/customer/dashboard');
      } else {
        navigate('/craftsman/dashboard');
      }
      
    } catch (error) {
      console.error('Login error:', error);
      setErrors({ general: 'Giriş sırasında bir hata oluştu!' });
    } finally {
      setLoading(false);
    }
  };

  const handleDemoLogin = (userType) => {
    setFormData({
      email: userType === 'customer' ? 'customer@test.com' : 'craftsman@test.com',
      password: '123456',
      userType: userType
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="w-20 h-20 bg-blue-500 rounded-full flex items-center justify-center mx-auto mb-4">
            <span className="text-3xl font-bold text-white">U</span>
          </div>
          <h1 className="text-3xl font-bold text-gray-900">UstamApp</h1>
          <p className="text-gray-600 mt-2">Hesabınıza giriş yapın</p>
        </div>

        {/* Login Form */}
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* User Type Selection */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-3">
                Hesap Türü
              </label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => setFormData(prev => ({ ...prev, userType: 'customer' }))}
                  className={`p-4 rounded-lg border-2 transition-all ${
                    formData.userType === 'customer'
                      ? 'border-blue-500 bg-blue-50 text-blue-700'
                      : 'border-gray-200 bg-gray-50 text-gray-600 hover:border-gray-300'
                  }`}
                >
                  <div className="text-center">
                    <div className="w-8 h-8 mx-auto mb-2">
                      👤
                    </div>
                    <div className="font-medium">Müşteri</div>
                    <div className="text-xs mt-1">İş arıyorum</div>
                  </div>
                </button>
                
                <button
                  type="button"
                  onClick={() => setFormData(prev => ({ ...prev, userType: 'craftsman' }))}
                  className={`p-4 rounded-lg border-2 transition-all ${
                    formData.userType === 'craftsman'
                      ? 'border-blue-500 bg-blue-50 text-blue-700'
                      : 'border-gray-200 bg-gray-50 text-gray-600 hover:border-gray-300'
                  }`}
                >
                  <div className="text-center">
                    <div className="w-8 h-8 mx-auto mb-2">
                      🔨
                    </div>
                    <div className="font-medium">Usta</div>
                    <div className="text-xs mt-1">İş yapıyorum</div>
                  </div>
                </button>
              </div>
            </div>

            {/* Email */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                E-posta Adresi *
              </label>
              <div className="relative">
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
                <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                  </svg>
                </div>
              </div>
              {errors.email && (
                <p className="text-red-500 text-sm mt-1">{errors.email}</p>
              )}
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
                  placeholder="••••••••"
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
              {errors.password && (
                <p className="text-red-500 text-sm mt-1">{errors.password}</p>
              )}
            </div>

            {/* General Error */}
            {errors.general && (
              <div className="bg-red-50 border border-red-200 rounded-lg p-3">
                <p className="text-red-600 text-sm">{errors.general}</p>
              </div>
            )}

            {/* Submit Button - Fixed positioning */}
            <div className="pt-6">
              <button
                type="submit"
                disabled={loading}
                className="w-full bg-gradient-to-r from-blue-500 to-blue-600 text-white py-4 px-6 rounded-xl hover:from-blue-600 hover:to-blue-700 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 font-semibold text-lg shadow-lg hover:shadow-xl transform hover:scale-[1.02] active:scale-[0.98]"
              >
                {loading ? (
                  <div className="flex items-center justify-center space-x-2">
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                    <span>Giriş yapılıyor...</span>
                  </div>
                ) : (
                  <div className="flex items-center justify-center space-x-2">
                    <span>🚀</span>
                    <span>Giriş Yap</span>
                  </div>
                )}
              </button>
            </div>

            {/* Demo Accounts */}
            <div className="border-t pt-6">
              <p className="text-sm text-gray-600 text-center mb-4">Demo hesaplarla hızlı giriş:</p>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => handleDemoLogin('customer')}
                  className="px-4 py-2 bg-green-100 text-green-700 rounded-lg hover:bg-green-200 transition-colors text-sm font-medium"
                >
                  👤 Demo Müşteri
                </button>
                <button
                  type="button"
                  onClick={() => handleDemoLogin('craftsman')}
                  className="px-4 py-2 bg-orange-100 text-orange-700 rounded-lg hover:bg-orange-200 transition-colors text-sm font-medium"
                >
                  🔨 Demo Usta
                </button>
              </div>
              <p className="text-xs text-gray-500 text-center mt-2">
                E-posta: customer@test.com / craftsman@test.com | Şifre: 123456
              </p>
            </div>

            {/* Links */}
            <div className="text-center space-y-2">
              <Link
                to="/forgot-password"
                className="text-sm text-blue-600 hover:text-blue-800 transition-colors"
              >
                Şifremi Unuttum
              </Link>
              <div className="text-sm text-gray-600">
                Hesabınız yok mu?{' '}
                <Link
                  to="/register"
                  className="text-blue-600 hover:text-blue-800 font-medium transition-colors"
                >
                  Kayıt Olun
                </Link>
              </div>
            </div>
          </form>
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

export default LoginPage;
