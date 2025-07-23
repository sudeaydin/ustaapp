import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const CraftsmanRegisterPage = () => {
  const navigate = useNavigate();
  const { register } = useAuth();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    // Temel bilgiler
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
    password: '',
    confirm_password: '',
    
    // Usta özel bilgileri
    business_name: '',
    category: '',
    description: '',
    city: '',
    district: '',
    hourly_rate: '',
    experience_years: '',
    
    // Şartlar
    terms_accepted: false,
    craftsman_terms_accepted: false
  });
  const [errors, setErrors] = useState({});

  const categories = [
    'Elektrikçi',
    'Tesisatçı', 
    'Boyacı',
    'Marangoz',
    'Tadilat',
    'Temizlik',
    'Klima Teknisyeni',
    'Cam Balkon',
    'Döşemeci',
    'Bahçıvan'
  ];

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
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

    // Temel bilgiler
    if (!formData.first_name.trim()) newErrors.first_name = 'Ad zorunludur';
    if (!formData.last_name.trim()) newErrors.last_name = 'Soyad zorunludur';
    if (!formData.email.trim()) newErrors.email = 'Email zorunludur';
    else if (!/\S+@\S+\.\S+/.test(formData.email)) newErrors.email = 'Geçerli email adresi girin';
    if (!formData.phone.trim()) newErrors.phone = 'Telefon zorunludur';
    if (!formData.password) newErrors.password = 'Şifre zorunludur';
    else if (formData.password.length < 6) newErrors.password = 'Şifre en az 6 karakter olmalı';
    if (formData.password !== formData.confirm_password) newErrors.confirm_password = 'Şifreler eşleşmiyor';

    // Usta özel bilgileri
    if (!formData.business_name.trim()) newErrors.business_name = 'İşletme adı zorunludur';
    if (!formData.category) newErrors.category = 'Kategori seçimi zorunludur';
    if (!formData.description.trim()) newErrors.description = 'Açıklama zorunludur';
    else if (formData.description.length < 20) newErrors.description = 'Açıklama en az 20 karakter olmalı';
    if (!formData.city.trim()) newErrors.city = 'Şehir zorunludur';
    if (!formData.district.trim()) newErrors.district = 'İlçe zorunludur';
    if (formData.hourly_rate && (isNaN(formData.hourly_rate) || formData.hourly_rate < 0)) {
      newErrors.hourly_rate = 'Geçerli bir ücret girin';
    }
    if (formData.experience_years && (isNaN(formData.experience_years) || formData.experience_years < 0)) {
      newErrors.experience_years = 'Geçerli deneyim yılı girin';
    }

    // Şartlar
    if (!formData.terms_accepted) newErrors.terms_accepted = 'Genel şartları kabul etmelisiniz';
    if (!formData.craftsman_terms_accepted) newErrors.craftsman_terms_accepted = 'Usta şartlarını kabul etmelisiniz';

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;

    setLoading(true);
    try {
      const registerData = {
        ...formData,
        user_type: 'craftsman'
      };
      
      const response = await register(registerData);
      
      if (response.success) {
        alert('🎉 Usta kaydınız başarıyla tamamlandı! Hoş geldiniz!');
        navigate('/dashboard/craftsman');
      } else {
        setErrors({ general: response.message || 'Kayıt işlemi başarısız' });
      }
    } catch (error) {
      setErrors({ general: error.message || 'Bir hata oluştu' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-8">
      <div className="max-w-2xl mx-auto px-4">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="w-20 h-20 bg-blue-500 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 7.172V5L8 4z" />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            🔧 Usta Kayıt
          </h1>
          <p className="text-gray-600">
            Ustalar platformuna katılın ve müşterilerinize ulaşın
          </p>
        </div>

        {/* Form */}
        <div className="bg-white rounded-lg shadow-lg p-6">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* General Error */}
            {errors.general && (
              <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg">
                {errors.general}
              </div>
            )}

            {/* Temel Bilgiler */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                👤 Temel Bilgiler
              </h3>
              
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Ad *
                  </label>
                  <input
                    type="text"
                    name="first_name"
                    value={formData.first_name}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.first_name ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="Adınız"
                  />
                  {errors.first_name && <p className="text-red-500 text-sm mt-1">{errors.first_name}</p>}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Soyad *
                  </label>
                  <input
                    type="text"
                    name="last_name"
                    value={formData.last_name}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.last_name ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="Soyadınız"
                  />
                  {errors.last_name && <p className="text-red-500 text-sm mt-1">{errors.last_name}</p>}
                </div>
              </div>

              <div className="grid md:grid-cols-2 gap-4 mt-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Email *
                  </label>
                  <input
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.email ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="email@example.com"
                  />
                  {errors.email && <p className="text-red-500 text-sm mt-1">{errors.email}</p>}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Telefon *
                  </label>
                  <input
                    type="tel"
                    name="phone"
                    value={formData.phone}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.phone ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="+90 555 123 4567"
                  />
                  {errors.phone && <p className="text-red-500 text-sm mt-1">{errors.phone}</p>}
                </div>
              </div>

              <div className="grid md:grid-cols-2 gap-4 mt-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Şifre *
                  </label>
                  <input
                    type="password"
                    name="password"
                    value={formData.password}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.password ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="En az 6 karakter"
                  />
                  {errors.password && <p className="text-red-500 text-sm mt-1">{errors.password}</p>}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Şifre Tekrar *
                  </label>
                  <input
                    type="password"
                    name="confirm_password"
                    value={formData.confirm_password}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.confirm_password ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="Şifrenizi tekrar girin"
                  />
                  {errors.confirm_password && <p className="text-red-500 text-sm mt-1">{errors.confirm_password}</p>}
                </div>
              </div>
            </div>

            {/* Profesyonel Bilgiler */}
            <div className="border-t pt-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                🔧 Profesyonel Bilgiler
              </h3>

              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    İşletme Adı *
                  </label>
                  <input
                    type="text"
                    name="business_name"
                    value={formData.business_name}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.business_name ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="Yılmaz Elektrik"
                  />
                  {errors.business_name && <p className="text-red-500 text-sm mt-1">{errors.business_name}</p>}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Kategori *
                  </label>
                  <select
                    name="category"
                    value={formData.category}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.category ? 'border-red-500' : 'border-gray-300'
                    }`}
                  >
                    <option value="">Kategori seçin</option>
                    {categories.map(category => (
                      <option key={category} value={category}>{category}</option>
                    ))}
                  </select>
                  {errors.category && <p className="text-red-500 text-sm mt-1">{errors.category}</p>}
                </div>
              </div>

              <div className="mt-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Hizmet Açıklaması *
                </label>
                <textarea
                  name="description"
                  value={formData.description}
                  onChange={handleInputChange}
                  rows={4}
                  className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                    errors.description ? 'border-red-500' : 'border-gray-300'
                  }`}
                  placeholder="Sunduğunuz hizmetler ve deneyiminiz hakkında detaylı bilgi verin... (En az 20 karakter)"
                />
                {errors.description && <p className="text-red-500 text-sm mt-1">{errors.description}</p>}
              </div>

              <div className="grid md:grid-cols-2 gap-4 mt-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Şehir *
                  </label>
                  <input
                    type="text"
                    name="city"
                    value={formData.city}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.city ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="İstanbul"
                  />
                  {errors.city && <p className="text-red-500 text-sm mt-1">{errors.city}</p>}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    İlçe *
                  </label>
                  <input
                    type="text"
                    name="district"
                    value={formData.district}
                    onChange={handleInputChange}
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.district ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="Kadıköy"
                  />
                  {errors.district && <p className="text-red-500 text-sm mt-1">{errors.district}</p>}
                </div>
              </div>

              <div className="grid md:grid-cols-2 gap-4 mt-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Saatlik Ücret (₺)
                  </label>
                  <input
                    type="number"
                    name="hourly_rate"
                    value={formData.hourly_rate}
                    onChange={handleInputChange}
                    min="0"
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.hourly_rate ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="150"
                  />
                  {errors.hourly_rate && <p className="text-red-500 text-sm mt-1">{errors.hourly_rate}</p>}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Deneyim (Yıl)
                  </label>
                  <input
                    type="number"
                    name="experience_years"
                    value={formData.experience_years}
                    onChange={handleInputChange}
                    min="0"
                    className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      errors.experience_years ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="5"
                  />
                  {errors.experience_years && <p className="text-red-500 text-sm mt-1">{errors.experience_years}</p>}
                </div>
              </div>
            </div>

            {/* Şartlar */}
            <div className="border-t pt-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                📋 Şartlar ve Koşullar
              </h3>

              <div className="space-y-3">
                <label className="flex items-start space-x-3">
                  <input
                    type="checkbox"
                    name="terms_accepted"
                    checked={formData.terms_accepted}
                    onChange={handleInputChange}
                    className="mt-1 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                  <span className="text-sm text-gray-700">
                    <Link to="/terms" className="text-blue-600 hover:underline">Kullanım Şartları</Link> ve{' '}
                    <Link to="/privacy" className="text-blue-600 hover:underline">Gizlilik Politikası</Link>'nı okudum ve kabul ediyorum *
                  </span>
                </label>
                {errors.terms_accepted && <p className="text-red-500 text-sm">{errors.terms_accepted}</p>}

                <label className="flex items-start space-x-3">
                  <input
                    type="checkbox"
                    name="craftsman_terms_accepted"
                    checked={formData.craftsman_terms_accepted}
                    onChange={handleInputChange}
                    className="mt-1 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                  <span className="text-sm text-gray-700">
                    <Link to="/craftsman-terms" className="text-blue-600 hover:underline">Usta Sözleşmesi</Link>'ni okudum ve kabul ediyorum. Müşterilere kaliteli hizmet sunacağımı taahhüt ediyorum *
                  </span>
                </label>
                {errors.craftsman_terms_accepted && <p className="text-red-500 text-sm">{errors.craftsman_terms_accepted}</p>}
              </div>
            </div>

            {/* Submit Button */}
            <div className="border-t pt-6">
              <button
                type="submit"
                disabled={loading}
                className="w-full bg-blue-500 text-white py-3 px-4 rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
              >
                {loading ? (
                  <div className="flex items-center justify-center">
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                    Kayıt Yapılıyor...
                  </div>
                ) : (
                  '🔧 Usta Olarak Kayıt Ol'
                )}
              </button>
            </div>
          </form>

          {/* Login Link */}
          <div className="text-center mt-6 pt-6 border-t">
            <p className="text-gray-600">
              Zaten hesabınız var mı?{' '}
              <Link to="/login" className="text-blue-600 hover:underline font-medium">
                Giriş Yapın
              </Link>
            </p>
            <p className="text-sm text-gray-500 mt-2">
              Müşteri misiniz?{' '}
              <Link to="/register/customer" className="text-green-600 hover:underline font-medium">
                Müşteri Kaydı
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CraftsmanRegisterPage;