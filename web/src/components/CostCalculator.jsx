import React, { useState } from 'react';
import { useAnalytics } from '../utils/analytics';
import api from '../utils/api';

const CostCalculator = () => {
  const analytics = useAnalytics();
  const [formData, setFormData] = useState({
    category: '',
    area_type: '',
    budget_range: '',
    description: '',
    urgency: 'normal',
    location: '',
  });
  const [estimate, setEstimate] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const categories = [
    'Elektrik',
    'Tesisat',
    'Boyama',
    'Temizlik',
    'Klima',
    'Tamirat',
    'Montaj',
    'Diğer'
  ];

  const areaTypes = [
    'Ev',
    'Ofis',
    'Mağaza',
    'Fabrika',
    'Diğer'
  ];

  const budgetRanges = [
    '0-500',
    '500-1000',
    '1000-2500',
    '2500-5000',
    '5000+'
  ];

  const urgencyLevels = [
    { value: 'low', label: 'Acil Değil', multiplier: 0.9 },
    { value: 'normal', label: 'Normal', multiplier: 1.0 },
    { value: 'high', label: 'Acil', multiplier: 1.3 },
    { value: 'emergency', label: 'Çok Acil', multiplier: 1.6 },
  ];

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const calculateCost = async () => {
    if (!formData.category || !formData.area_type) {
      setError('Lütfen kategori ve alan türünü seçin');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      // Track cost calculation attempt
      analytics.trackBusinessEvent('cost_calculation', {
        category: formData.category,
        area_type: formData.area_type,
        urgency: formData.urgency,
      });

      const response = await api.getCostEstimate(formData);
      
      if (response.success) {
        setEstimate(response.data);
        analytics.trackBusinessEvent('cost_calculation_success', {
          estimated_cost: response.data.estimated_cost,
          category: formData.category,
        });
      } else {
        setError('Maliyet hesaplanamadı');
      }
    } catch (err) {
      console.error('Cost calculation error:', err);
      setError('Bir hata oluştu, lütfen tekrar deneyin');
      analytics.trackError('cost_calculation_failed', err.message);
    } finally {
      setLoading(false);
    }
  };

  const resetCalculator = () => {
    setFormData({
      category: '',
      area_type: '',
      budget_range: '',
      description: '',
      urgency: 'normal',
      location: '',
    });
    setEstimate(null);
    setError(null);
    analytics.trackInteraction('cost_calculator_reset');
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
          💰 Maliyet Hesaplayıcı
        </h3>
        {estimate && (
          <button
            onClick={resetCalculator}
            className="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400"
          >
            Yeniden Hesapla
          </button>
        )}
      </div>

      {!estimate ? (
        <div className="space-y-4">
          {/* Category Selection */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              İş Kategorisi *
            </label>
            <select
              name="category"
              value={formData.category}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500"
              required
            >
              <option value="">Kategori seçin</option>
              {categories.map(category => (
                <option key={category} value={category}>{category}</option>
              ))}
            </select>
          </div>

          {/* Area Type */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Alan Türü *
            </label>
            <select
              name="area_type"
              value={formData.area_type}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500"
              required
            >
              <option value="">Alan türü seçin</option>
              {areaTypes.map(type => (
                <option key={type} value={type}>{type}</option>
              ))}
            </select>
          </div>

          {/* Budget Range */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Bütçe Aralığı
            </label>
            <select
              name="budget_range"
              value={formData.budget_range}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Bütçe aralığı seçin</option>
              {budgetRanges.map(range => (
                <option key={range} value={range}>₺{range}</option>
              ))}
            </select>
          </div>

          {/* Urgency */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Aciliyet Durumu
            </label>
            <select
              name="urgency"
              value={formData.urgency}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500"
            >
              {urgencyLevels.map(level => (
                <option key={level.value} value={level.value}>
                  {level.label}
                </option>
              ))}
            </select>
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              İş Açıklaması
            </label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleInputChange}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500"
              placeholder="İş hakkında detayları yazın..."
            />
          </div>

          {/* Location */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Konum
            </label>
            <input
              type="text"
              name="location"
              value={formData.location}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500"
              placeholder="İl/İlçe"
            />
          </div>

          {error && (
            <div className="p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
              <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
            </div>
          )}

          <button
            onClick={calculateCost}
            disabled={loading || !formData.category || !formData.area_type}
            className="w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white rounded-lg font-medium transition-colors"
          >
            {loading ? 'Hesaplanıyor...' : 'Maliyeti Hesapla'}
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {/* Estimate Results */}
          <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
            <h4 className="font-semibold text-blue-900 dark:text-blue-100 mb-2">
              Tahmini Maliyet
            </h4>
            <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">
              ₺{estimate.estimated_cost?.toLocaleString()}
            </div>
            <p className="text-sm text-blue-700 dark:text-blue-300 mt-1">
              {estimate.min_cost} - {estimate.max_cost} TL arasında değişebilir
            </p>
          </div>

          {/* Breakdown */}
          {estimate.breakdown && (
            <div className="space-y-2">
              <h5 className="font-medium text-gray-900 dark:text-white">Maliyet Dağılımı:</h5>
              {Object.entries(estimate.breakdown).map(([key, value]) => (
                <div key={key} className="flex justify-between text-sm">
                  <span className="text-gray-600 dark:text-gray-400 capitalize">
                    {key.replace('_', ' ')}:
                  </span>
                  <span className="font-medium text-gray-900 dark:text-white">
                    ₺{value}
                  </span>
                </div>
              ))}
            </div>
          )}

          {/* Factors */}
          {estimate.factors && estimate.factors.length > 0 && (
            <div>
              <h5 className="font-medium text-gray-900 dark:text-white mb-2">
                Maliyet Etkileyen Faktörler:
              </h5>
              <ul className="text-sm text-gray-600 dark:text-gray-400 space-y-1">
                {estimate.factors.map((factor, index) => (
                  <li key={index} className="flex items-start">
                    <span className="text-blue-500 mr-2">•</span>
                    {factor}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Recommendations */}
          {estimate.recommendations && estimate.recommendations.length > 0 && (
            <div>
              <h5 className="font-medium text-gray-900 dark:text-white mb-2">
                Öneriler:
              </h5>
              <ul className="text-sm text-gray-600 dark:text-gray-400 space-y-1">
                {estimate.recommendations.map((rec, index) => (
                  <li key={index} className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    {rec}
                  </li>
                ))}
              </ul>
            </div>
          )}

          <div className="pt-4 border-t border-gray-200 dark:border-gray-700">
            <p className="text-xs text-gray-500 dark:text-gray-400 text-center">
              * Bu tahmin ortalama piyasa fiyatlarına dayalıdır. Gerçek fiyatlar değişebilir.
            </p>
          </div>
        </div>
      )}
    </div>
  );
};

export default CostCalculator;