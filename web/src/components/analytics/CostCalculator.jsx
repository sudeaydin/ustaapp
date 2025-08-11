import React, { useState, useEffect } from 'react';
import { useAuth } from '../../context/AuthContext';
import api from '../../utils/api';
import { formatCurrency } from '../../utils/formatters';
import LoadingSpinner from '../ui/LoadingSpinner';
import ErrorMessage from '../ui/ErrorMessage';

const CostCalculator = ({ constants }) => {
  const { user } = useAuth();
  const [formData, setFormData] = useState({
    category: 'elektrik',
    estimated_hours: 4,
    materials_cost: 0,
    area_type: 'other',
    urgency: 'normal',
    complexity_score: 5,
    location_factor: 1.0,
    craftsman_experience: 1
  });
  
  const [calculation, setCalculation] = useState(null);
  const [marketComparison, setMarketComparison] = useState(null);
  const [pricingRecommendations, setPricingRecommendations] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (formData.category && formData.estimated_hours > 0) {
      calculateCost();
    }
  }, [formData]);

  const calculateCost = async () => {
    setLoading(true);
    setError(null);
    
    try {
      // Calculate cost
      const costResponse = await api.calculateJobCost(formData);
      setCalculation(costResponse.data);

      // Get market comparison
      const marketResponse = await api.getMarketComparison({
        category: formData.category,
        days: 90
      });
      setMarketComparison(marketResponse.data);

      // Get pricing recommendations for craftsmen
      if (user?.user_type === 'craftsman') {
        const recommendationsResponse = await api.getPricingRecommendations(user.id, formData.category);
        setPricingRecommendations(recommendationsResponse.data);
      }
    } catch (err) {
      setError(err.message);
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

  const getConfidenceColor = (score) => {
    if (score >= 90) return 'text-green-600';
    if (score >= 75) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getPricePositionColor = (position) => {
    const colors = {
      'above_market': 'text-red-600',
      'below_market': 'text-green-600',
      'market_aligned': 'text-blue-600'
    };
    return colors[position] || 'text-gray-600';
  };

  const getPricePositionText = (position) => {
    const texts = {
      'above_market': 'Piyasa Üstü',
      'below_market': 'Piyasa Altı',
      'market_aligned': 'Piyasa Uyumlu'
    };
    return texts[position] || position;
  };

  return (
    <div className="space-y-6">
      {error && <ErrorMessage message={error} onClose={() => setError(null)} />}
      
      {/* Input Form */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="space-y-4">
          <h4 className="font-medium text-lg">İş Detayları</h4>
          
          {/* Category */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
            <select
              value={formData.category}
              onChange={(e) => handleInputChange('category', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              {constants?.cost_calculator?.base_rates && Object.keys(constants.cost_calculator.base_rates).map((category) => (
                <option key={category} value={category}>
                  {category.charAt(0).toUpperCase() + category.slice(1)}
                </option>
              ))}
            </select>
          </div>

          {/* Estimated Hours */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Tahmini Süre (saat)</label>
            <input
              type="number"
              value={formData.estimated_hours}
              onChange={(e) => handleInputChange('estimated_hours', parseFloat(e.target.value) || 0)}
              min="0.1"
              max="1000"
              step="0.5"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          {/* Materials Cost */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Malzeme Maliyeti (₺)</label>
            <input
              type="number"
              value={formData.materials_cost}
              onChange={(e) => handleInputChange('materials_cost', parseFloat(e.target.value) || 0)}
              min="0"
              step="10"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          {/* Area Type */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Alan Türü</label>
            <select
              value={formData.area_type}
              onChange={(e) => handleInputChange('area_type', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              {constants?.cost_calculator?.area_factors && Object.keys(constants.cost_calculator.area_factors).map((area) => (
                <option key={area} value={area}>
                  {area === 'kitchen' && 'Mutfak'}
                  {area === 'bathroom' && 'Banyo'}
                  {area === 'living_room' && 'Oturma Odası'}
                  {area === 'bedroom' && 'Yatak Odası'}
                  {area === 'balcony' && 'Balkon'}
                  {area === 'garden' && 'Bahçe'}
                  {area === 'office' && 'Ofis'}
                  {area === 'other' && 'Diğer'}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="space-y-4">
          <h4 className="font-medium text-lg">Ek Faktörler</h4>
          
          {/* Urgency */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Aciliyet</label>
            <select
              value={formData.urgency}
              onChange={(e) => handleInputChange('urgency', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="low">Düşük</option>
              <option value="normal">Normal</option>
              <option value="high">Yüksek</option>
              <option value="urgent">Acil</option>
              <option value="emergency">Acil Durum</option>
            </select>
          </div>

          {/* Complexity Score */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Karmaşıklık Skoru (1-10): {formData.complexity_score}
            </label>
            <input
              type="range"
              value={formData.complexity_score}
              onChange={(e) => handleInputChange('complexity_score', parseInt(e.target.value))}
              min="1"
              max="10"
              className="w-full"
            />
            <div className="flex justify-between text-xs text-gray-500 mt-1">
              <span>Basit</span>
              <span>Orta</span>
              <span>Karmaşık</span>
            </div>
          </div>

          {/* Location Factor */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Konum Faktörü: {formData.location_factor}x
            </label>
            <input
              type="range"
              value={formData.location_factor}
              onChange={(e) => handleInputChange('location_factor', parseFloat(e.target.value))}
              min="0.5"
              max="2.0"
              step="0.1"
              className="w-full"
            />
            <div className="flex justify-between text-xs text-gray-500 mt-1">
              <span>Ucuz Bölge</span>
              <span>Normal</span>
              <span>Pahalı Bölge</span>
            </div>
          </div>

          {/* Craftsman Experience */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Usta Deneyimi (yıl)</label>
            <input
              type="number"
              value={formData.craftsman_experience}
              onChange={(e) => handleInputChange('craftsman_experience', parseInt(e.target.value) || 1)}
              min="0"
              max="50"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>
      </div>

      {loading && (
        <div className="flex justify-center py-8">
          <LoadingSpinner />
        </div>
      )}

      {/* Cost Calculation Results */}
      {calculation && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Cost Breakdown */}
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <h4 className="font-medium text-lg mb-4">Maliyet Dökümü</h4>
            <div className="space-y-3">
              {Object.entries(calculation.breakdown).map(([key, value]) => (
                <div key={key} className="flex justify-between">
                  <span className="text-gray-600">
                    {key === 'labor_cost' && 'İşçilik'}
                    {key === 'materials_cost' && 'Malzeme'}
                    {key === 'travel_cost' && 'Ulaşım'}
                    {key === 'overhead_cost' && 'Genel Giderler'}
                    {key === 'subtotal' && 'Ara Toplam'}
                    {key === 'tax_amount' && 'KDV (%18)'}
                    {key === 'total_cost' && 'Toplam Maliyet'}
                  </span>
                  <span className={`font-medium ${key === 'total_cost' ? 'text-lg text-green-600' : ''}`}>
                    {formatCurrency(value)}
                  </span>
                </div>
              ))}
            </div>

            {/* Price Range */}
            <div className="mt-6 p-4 bg-gray-50 rounded-lg">
              <h5 className="font-medium mb-2">Fiyat Aralığı</h5>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span>Minimum:</span>
                  <span className="font-medium">{formatCurrency(calculation.price_range.min_price)}</span>
                </div>
                <div className="flex justify-between">
                  <span>En Olası:</span>
                  <span className="font-medium text-blue-600">{formatCurrency(calculation.price_range.most_likely)}</span>
                </div>
                <div className="flex justify-between">
                  <span>Maksimum:</span>
                  <span className="font-medium">{formatCurrency(calculation.price_range.max_price)}</span>
                </div>
              </div>
            </div>

            {/* Confidence Score */}
            <div className="mt-4">
              <div className="flex justify-between items-center">
                <span className="text-gray-600">Güven Skoru:</span>
                <span className={`font-medium ${getConfidenceColor(calculation.estimation_quality.confidence_score)}`}>
                  %{calculation.estimation_quality.confidence_score}
                </span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2 mt-2">
                <div 
                  className={`h-2 rounded-full ${
                    calculation.estimation_quality.confidence_score >= 90 ? 'bg-green-500' :
                    calculation.estimation_quality.confidence_score >= 75 ? 'bg-yellow-500' : 'bg-red-500'
                  }`}
                  style={{ width: `${calculation.estimation_quality.confidence_score}%` }}
                ></div>
              </div>
            </div>
          </div>

          {/* Factors and Comparison */}
          <div className="space-y-6">
            {/* Calculation Factors */}
            <div className="bg-white border border-gray-200 rounded-lg p-6">
              <h4 className="font-medium text-lg mb-4">Hesaplama Faktörleri</h4>
              <div className="space-y-2">
                {Object.entries(calculation.factors).map(([key, value]) => (
                  <div key={key} className="flex justify-between text-sm">
                    <span className="text-gray-600">
                      {key === 'base_hourly_rate' && 'Temel Saatlik Ücret'}
                      {key === 'adjusted_hourly_rate' && 'Düzeltilmiş Saatlik Ücret'}
                      {key === 'area_factor' && 'Alan Faktörü'}
                      {key === 'urgency_multiplier' && 'Aciliyet Çarpanı'}
                      {key === 'complexity_factor' && 'Karmaşıklık Faktörü'}
                      {key === 'experience_factor' && 'Deneyim Faktörü'}
                      {key === 'location_factor' && 'Konum Faktörü'}
                      {key === 'materials_markup' && 'Malzeme Kar Marjı'}
                    </span>
                    <span className="font-medium">
                      {key.includes('rate') ? formatCurrency(value) : 
                       key.includes('markup') ? `${((value - 1) * 100).toFixed(0)}%` :
                       `${value}x`}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Market Comparison */}
            {marketComparison && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h4 className="font-medium text-lg mb-4">Piyasa Karşılaştırması</h4>
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span className="text-gray-600">Piyasa Ortalaması:</span>
                    <span className="font-medium">{formatCurrency(marketComparison.avg_price)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Minimum:</span>
                    <span className="font-medium">{formatCurrency(marketComparison.min_price)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Maksimum:</span>
                    <span className="font-medium">{formatCurrency(marketComparison.max_price)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Medyan:</span>
                    <span className="font-medium">{formatCurrency(marketComparison.median_price)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Örnek Sayısı:</span>
                    <span className="font-medium">{marketComparison.sample_size}</span>
                  </div>
                </div>

                {/* Price Comparison */}
                <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                  <div className="text-sm text-gray-600">Hesaplanan fiyat vs piyasa:</div>
                  <div className="text-lg font-bold">
                    {calculation.breakdown.total_cost > marketComparison.avg_price ? (
                      <span className="text-red-600">
                        +{formatCurrency(calculation.breakdown.total_cost - marketComparison.avg_price)} yüksek
                      </span>
                    ) : (
                      <span className="text-green-600">
                        -{formatCurrency(marketComparison.avg_price - calculation.breakdown.total_cost)} düşük
                      </span>
                    )}
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Pricing Recommendations for Craftsmen */}
      {user?.user_type === 'craftsman' && pricingRecommendations && (
        <div className="bg-white border border-gray-200 rounded-lg p-6">
          <h4 className="font-medium text-lg mb-4">Fiyatlandırma Önerileri</h4>
          
          {/* Performance vs Market */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div>
              <h5 className="font-medium mb-2">Sizin Performansınız</h5>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-gray-600">Ortalama Fiyat:</span>
                  <span className="font-medium">{formatCurrency(pricingRecommendations.craftsman_performance.avg_price)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Kabul Oranı:</span>
                  <span className="font-medium">{pricingRecommendations.craftsman_performance.acceptance_rate.toFixed(1)}%</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Toplam Teklif:</span>
                  <span className="font-medium">{pricingRecommendations.craftsman_performance.total_quotes}</span>
                </div>
              </div>
            </div>
            
            <div>
              <h5 className="font-medium mb-2">Piyasa Verileri</h5>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-gray-600">Piyasa Ortalaması:</span>
                  <span className="font-medium">{formatCurrency(pricingRecommendations.market_data.avg_price)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">25. Yüzdelik:</span>
                  <span className="font-medium">{formatCurrency(pricingRecommendations.market_data.q1_price)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">75. Yüzdelik:</span>
                  <span className="font-medium">{formatCurrency(pricingRecommendations.market_data.q3_price)}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Price Position */}
          <div className="mb-4">
            <span className="text-gray-600">Fiyat Konumunuz: </span>
            <span className={`font-medium ${getPricePositionColor(pricingRecommendations.price_position)}`}>
              {getPricePositionText(pricingRecommendations.price_position)}
            </span>
          </div>

          {/* Recommendations */}
          {pricingRecommendations.recommendations.length > 0 && (
            <div className="space-y-3">
              <h5 className="font-medium">Öneriler:</h5>
              {pricingRecommendations.recommendations.map((rec, index) => (
                <div key={index} className={`p-3 rounded-lg border ${
                  rec.type === 'price_increase' ? 'border-green-200 bg-green-50' : 'border-yellow-200 bg-yellow-50'
                }`}>
                  <div className="flex items-center justify-between">
                    <span className="text-sm">{rec.message}</span>
                    <span className="font-medium">{formatCurrency(rec.suggested_price)}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Quick Actions */}
      <div className="bg-gray-50 rounded-lg p-4">
        <div className="flex flex-wrap gap-4">
          <button
            onClick={calculateCost}
            disabled={loading}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
          >
            🔄 Yeniden Hesapla
          </button>
          
          {calculation && (
            <button
              onClick={() => {
                const data = {
                  calculation,
                  marketComparison,
                  formData,
                  timestamp: new Date().toISOString()
                };
                const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `cost-calculation-${formData.category}-${Date.now()}.json`;
                a.click();
              }}
              className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors"
            >
              📥 Hesaplamayı İndir
            </button>
          )}

          <button
            onClick={() => {
              setFormData({
                category: 'elektrik',
                estimated_hours: 4,
                materials_cost: 0,
                area_type: 'other',
                urgency: 'normal',
                complexity_score: 5,
                location_factor: 1.0,
                craftsman_experience: 1
              });
            }}
            className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700 transition-colors"
          >
            🔄 Sıfırla
          </button>
        </div>
      </div>
    </div>
  );
};

export default CostCalculator;