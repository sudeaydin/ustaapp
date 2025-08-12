import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { jobRequestsApi, categoriesApi, handleApiError, handleApiSuccess } from '../services/airbnbApi';

const AirbnbStyleJobRequestPage = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [loading, setLoading] = useState(false);
  const [categories, setCategories] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState('');
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    location: '',
    budget: '',
    urgency: 'normal',
    photos: []
  });

  const craftsmanId = searchParams.get('craftsman');

  useEffect(() => {
    loadCategories();
    if (craftsmanId) {
      // Pre-fill some data if coming from craftsman page
      setFormData(prev => ({
        ...prev,
        location: 'İstanbul' // Default location
      }));
    }
  }, [craftsmanId]);

  const loadCategories = async () => {
    try {
      const response = await categoriesApi.getAll();
      const result = handleApiSuccess(response);
      if (result.success) {
        setCategories(result.data);
      }
    } catch (error) {
      console.error('Kategoriler yüklenemedi:', error);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleCategorySelect = (categoryId) => {
    setSelectedCategory(categoryId);
  };

  const handlePhotoUpload = (e) => {
    const files = Array.from(e.target.files);
    setFormData(prev => ({
      ...prev,
      photos: [...prev.photos, ...files]
    }));
  };

  const removePhoto = (index) => {
    setFormData(prev => ({
      ...prev,
      photos: prev.photos.filter((_, i) => i !== index)
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!selectedCategory) {
      alert('Lütfen bir kategori seçin');
      return;
    }

    if (!formData.title || !formData.description || !formData.location) {
      alert('Lütfen tüm zorunlu alanları doldurun');
      return;
    }

    setLoading(true);

    try {
      const requestData = {
        ...formData,
        category_id: selectedCategory
      };

      const response = await jobRequestsApi.create(requestData);
      const result = handleApiSuccess(response);

      if (result.success) {
        alert('İş talebi başarıyla oluşturuldu!');
        navigate('/airbnb-style');
      }
    } catch (error) {
      const errorResult = handleApiError(error);
      alert(errorResult.message);
    } finally {
      setLoading(false);
    }
  };

  const urgencyOptions = [
    { value: 'low', label: 'Düşük', icon: '🐌' },
    { value: 'normal', label: 'Normal', icon: '⚡' },
    { value: 'high', label: 'Yüksek', icon: '🚨' },
    { value: 'urgent', label: 'Acil', icon: '🔥' }
  ];

  return (
    <div className="min-h-screen bg-airbnb-light-50 dark:bg-airbnb-dark-900">
      {/* Header */}
      <div className="bg-white dark:bg-airbnb-dark-800 shadow-airbnb px-4 py-3">
        <div className="flex items-center space-x-3">
          <button 
            onClick={() => navigate(-1)}
            className="w-8 h-8 bg-airbnb-light-100 dark:bg-airbnb-dark-700 rounded-full flex items-center justify-center"
          >
            ←
          </button>
          <div className="flex-1">
            <h1 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white">
              İş Talebi Oluştur
            </h1>
          </div>
        </div>
      </div>

      {/* Form */}
      <div className="p-4">
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Kategori Seçimi */}
          <div>
            <h2 className="text-lg font-semibold text-airbnb-dark-900 dark:text-white mb-4">
              Hizmet Kategorisi
            </h2>
            <div className="grid grid-cols-2 gap-3">
              {categories.map((category) => (
                <button
                  key={category.id}
                  type="button"
                  onClick={() => handleCategorySelect(category.id)}
                  className={`p-4 rounded-2xl border-2 transition-all duration-200 ${
                    selectedCategory === category.id
                      ? 'border-airbnb-500 bg-airbnb-50 dark:bg-airbnb-900'
                      : 'border-airbnb-light-200 dark:border-airbnb-dark-700 bg-white dark:bg-airbnb-dark-800'
                  }`}
                >
                  <div className="text-2xl mb-2">{category.icon || '🔧'}</div>
                  <div className="text-sm font-medium text-airbnb-dark-900 dark:text-white">
                    {category.name}
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* İş Başlığı */}
          <div>
            <label className="block text-sm font-medium text-airbnb-dark-700 dark:text-airbnb-light-300 mb-2">
              İş Başlığı *
            </label>
            <input
              type="text"
              name="title"
              value={formData.title}
              onChange={handleInputChange}
              placeholder="Örn: Elektrik arızası, Boya işi..."
              className="input"
              required
            />
          </div>

          {/* Açıklama */}
          <div>
            <label className="block text-sm font-medium text-airbnb-dark-700 dark:text-airbnb-light-300 mb-2">
              Detaylı Açıklama *
            </label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleInputChange}
              placeholder="İhtiyacınızı detaylı olarak açıklayın..."
              rows={4}
              className="input resize-none"
              required
            />
          </div>

          {/* Konum */}
          <div>
            <label className="block text-sm font-medium text-airbnb-dark-700 dark:text-airbnb-light-300 mb-2">
              Konum *
            </label>
            <input
              type="text"
              name="location"
              value={formData.location}
              onChange={handleInputChange}
              placeholder="İl, İlçe"
              className="input"
              required
            />
          </div>

          {/* Bütçe */}
          <div>
            <label className="block text-sm font-medium text-airbnb-dark-700 dark:text-airbnb-light-300 mb-2">
              Bütçe (Opsiyonel)
            </label>
            <div className="relative">
              <input
                type="number"
                name="budget"
                value={formData.budget}
                onChange={handleInputChange}
                placeholder="0"
                className="input pr-12"
              />
              <span className="absolute right-4 top-1/2 transform -translate-y-1/2 text-airbnb-dark-500 dark:text-airbnb-light-500">
                ₺
              </span>
            </div>
          </div>

          {/* Aciliyet */}
          <div>
            <label className="block text-sm font-medium text-airbnb-dark-700 dark:text-airbnb-light-300 mb-2">
              Aciliyet Seviyesi
            </label>
            <div className="grid grid-cols-2 gap-3">
              {urgencyOptions.map((option) => (
                <button
                  key={option.value}
                  type="button"
                  onClick={() => setFormData(prev => ({ ...prev, urgency: option.value }))}
                  className={`p-3 rounded-xl border-2 transition-all duration-200 ${
                    formData.urgency === option.value
                      ? 'border-airbnb-500 bg-airbnb-50 dark:bg-airbnb-900'
                      : 'border-airbnb-light-200 dark:border-airbnb-dark-700 bg-white dark:bg-airbnb-dark-800'
                  }`}
                >
                  <div className="text-lg mb-1">{option.icon}</div>
                  <div className="text-sm font-medium text-airbnb-dark-900 dark:text-white">
                    {option.label}
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Fotoğraf Yükleme */}
          <div>
            <label className="block text-sm font-medium text-airbnb-dark-700 dark:text-airbnb-light-300 mb-2">
              Fotoğraflar (Opsiyonel)
            </label>
            <div className="space-y-3">
              <input
                type="file"
                multiple
                accept="image/*"
                onChange={handlePhotoUpload}
                className="hidden"
                id="photo-upload"
              />
              <label
                htmlFor="photo-upload"
                className="block p-4 border-2 border-dashed border-airbnb-light-300 dark:border-airbnb-dark-600 rounded-xl text-center cursor-pointer hover:border-airbnb-500 transition-colors duration-200"
              >
                <div className="text-2xl mb-2">📷</div>
                <div className="text-sm text-airbnb-dark-600 dark:text-airbnb-light-400">
                  Fotoğraf eklemek için tıklayın
                </div>
              </label>

              {/* Uploaded Photos */}
              {formData.photos.length > 0 && (
                <div className="grid grid-cols-3 gap-3">
                  {formData.photos.map((photo, index) => (
                    <div key={index} className="relative">
                      <img
                        src={URL.createObjectURL(photo)}
                        alt={`Photo ${index + 1}`}
                        className="w-full h-24 object-cover rounded-lg"
                      />
                      <button
                        type="button"
                        onClick={() => removePhoto(index)}
                        className="absolute -top-2 -right-2 w-6 h-6 bg-airbnb-500 text-white rounded-full flex items-center justify-center text-sm"
                      >
                        ×
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading}
            className="btn btn-primary w-full py-4 text-lg font-semibold"
          >
            {loading ? 'Gönderiliyor...' : 'İş Talebi Oluştur'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default AirbnbStyleJobRequestPage;