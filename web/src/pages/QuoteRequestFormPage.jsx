import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const QuoteRequestFormPage = () => {
  const navigate = useNavigate();
  const { craftsmanId } = useParams();
  const { user } = useAuth();
  
  const [craftsman, setCraftsman] = useState(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  
  const [formData, setFormData] = useState({
    category: '',
    area_type: '',
    square_meters: '',
    budget_range: '',
    description: '',
    additional_details: ''
  });

  const budgetRanges = [
    { value: '0-1000', label: '0 - 1.000 TL' },
    { value: '1000-2000', label: '1.000 - 2.000 TL' },
    { value: '2000-5000', label: '2.000 - 5.000 TL' },
    { value: '5000-10000', label: '5.000 - 10.000 TL' },
    { value: '10000-20000', label: '10.000 - 20.000 TL' },
    { value: '20000+', label: '20.000+ TL' }
  ];

  const areaTypes = [
    { value: 'salon', label: 'Salon' },
    { value: 'mutfak', label: 'Mutfak' },
    { value: 'yatak_odası', label: 'Yatak Odası' },
    { value: 'banyo', label: 'Banyo' },
    { value: 'balkon', label: 'Balkon' },
    { value: 'bahçe', label: 'Bahçe' },
    { value: 'ofis', label: 'Ofis' },
    { value: 'diger', label: 'Diğer' }
  ];

  const categories = [
    'Elektrikçi',
    'Tesisatçı', 
    'Boyacı',
    'Marangoz',
    'Cam Ustası',
    'Klima Teknisyeni',
    'Temizlik',
    'Taşıma',
    'Diğer'
  ];

  useEffect(() => {
    loadCraftsman();
  }, [craftsmanId]);

  const loadCraftsman = async () => {
    try {
      setLoading(true);
      // Mock craftsman data - in real app, fetch from API
      const mockCraftsman = {
        id: parseInt(craftsmanId),
        name: 'Ahmet Usta',
        business: 'Ahmet Elektrik',
        category: 'Elektrikçi',
        rating: 4.8,
        image: 'https://via.placeholder.com/80x80'
      };
      setCraftsman(mockCraftsman);
    } catch (error) {
      console.error('Usta bilgileri yüklenirken hata:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validation
    if (!formData.category || !formData.area_type || !formData.budget_range || !formData.description) {
      alert('Lütfen zorunlu alanları doldurun');
      return;
    }

    setSubmitting(true);
    
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/quote-requests/request', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          craftsman_id: parseInt(craftsmanId),
          category: formData.category,
          area_type: formData.area_type,
          square_meters: formData.square_meters ? parseInt(formData.square_meters) : null,
          budget_range: formData.budget_range,
          description: formData.description,
          additional_details: formData.additional_details
        })
      });

      const data = await response.json();

      if (data.success) {
        alert('Teklif talebiniz başarıyla gönderildi!');
        navigate('/messages');
      } else {
        alert(data.message || 'Teklif talebi gönderilirken bir hata oluştu');
      }
    } catch (error) {
      console.error('Teklif talebi hatası:', error);
      alert('Teklif talebi gönderilirken bir hata oluştu');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      {/* Header */}
      <div className="bg-white shadow-sm">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <button
              onClick={() => navigate(-1)}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h1 className="text-lg font-semibold text-gray-900">Teklif Talebi</h1>
            <div className="w-10"></div>
          </div>
        </div>
      </div>

      {/* Craftsman Info */}
      <div className="bg-white mx-4 mt-4 rounded-lg shadow-sm p-4">
        <div className="flex items-center gap-3">
          <img
            src={craftsman?.image}
            alt={craftsman?.name}
            className="w-16 h-16 rounded-full object-cover"
          />
          <div>
            <h2 className="font-semibold text-gray-900">{craftsman?.name}</h2>
            <p className="text-gray-600">{craftsman?.business}</p>
            <div className="flex items-center gap-1">
              <span className="text-yellow-400">⭐</span>
              <span className="text-sm text-gray-600">{craftsman?.rating}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Quote Request Form */}
      <div className="mx-4 mt-4">
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Category */}
          <div className="bg-white rounded-lg shadow-sm p-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              İş Kategorisi *
            </label>
            <select
              value={formData.category}
              onChange={(e) => handleInputChange('category', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            >
              <option value="">Kategori seçin</option>
              {categories.map(category => (
                <option key={category} value={category}>{category}</option>
              ))}
            </select>
          </div>

          {/* Area Type */}
          <div className="bg-white rounded-lg shadow-sm p-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Çalışılacak Alan *
            </label>
            <select
              value={formData.area_type}
              onChange={(e) => handleInputChange('area_type', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            >
              <option value="">Alan seçin</option>
              {areaTypes.map(area => (
                <option key={area.value} value={area.value}>{area.label}</option>
              ))}
            </select>
          </div>

          {/* Square Meters */}
          <div className="bg-white rounded-lg shadow-sm p-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Metrekare (Opsiyonel)
            </label>
            <input
              type="number"
              value={formData.square_meters}
              onChange={(e) => handleInputChange('square_meters', e.target.value)}
              placeholder="Örn: 25"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <p className="text-xs text-gray-500 mt-1">
              Çalışılacak alanın metrekare bilgisi (varsa)
            </p>
          </div>

          {/* Budget Range */}
          <div className="bg-white rounded-lg shadow-sm p-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Bütçe Aralığı *
            </label>
            <select
              value={formData.budget_range}
              onChange={(e) => handleInputChange('budget_range', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            >
              <option value="">Bütçe aralığı seçin</option>
              {budgetRanges.map(range => (
                <option key={range.value} value={range.value}>{range.label}</option>
              ))}
            </select>
          </div>

          {/* Description */}
          <div className="bg-white rounded-lg shadow-sm p-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              İş Açıklaması *
            </label>
            <textarea
              value={formData.description}
              onChange={(e) => handleInputChange('description', e.target.value)}
              placeholder="Yapılmasını istediğiniz işi detaylı olarak açıklayın..."
              rows={4}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
              required
            />
          </div>

          {/* Additional Details */}
          <div className="bg-white rounded-lg shadow-sm p-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Ek Detaylar (Opsiyonel)
            </label>
            <textarea
              value={formData.additional_details}
              onChange={(e) => handleInputChange('additional_details', e.target.value)}
              placeholder="Varsa ek bilgiler, özel istekler..."
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
            />
          </div>

          {/* Submit Button */}
          <div className="bg-white rounded-lg shadow-sm p-4">
            <button
              type="submit"
              disabled={submitting}
              className="w-full bg-blue-500 text-white py-3 rounded-lg font-medium hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {submitting ? (
                <div className="flex items-center justify-center">
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                  Gönderiliyor...
                </div>
              ) : (
                '📤 Teklif Talebini Gönder'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default QuoteRequestFormPage;