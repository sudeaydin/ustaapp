import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const ProposalFormPage = () => {
  const navigate = useNavigate();
  const { jobId } = useParams();
  const { user } = useAuth();
  
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [job, setJob] = useState(null);
  
  const [formData, setFormData] = useState({
    price: '',
    price_type: 'fixed',
    message: '',
    estimated_duration: '',
    availability: '',
    craftsman_name: user?.name || '',
    craftsman_rating: user?.rating || 4.5
  });

  const priceTypes = [
    { value: 'fixed', label: '💰 Sabit Fiyat', description: 'Toplam iş ücreti' },
    { value: 'hourly', label: '⏰ Saatlik Ücret', description: 'Saat başına ücret' },
    { value: 'negotiable', label: '🤝 Pazarlık', description: 'Müşteri ile görüşülür' }
  ];

  useEffect(() => {
    loadJobDetails();
  }, [jobId]);

  const loadJobDetails = async () => {
    try {
      setLoading(true);
      const response = await fetch(`http://localhost:5001/api/job-requests/${jobId}`);
      const data = await response.json();
      
      if (data.success) {
        if (data.data.status !== 'open') {
          alert('Bu iş artık teklif almıyor!');
          navigate('/jobs');
          return;
        }
        setJob(data.data);
        // Set default price type based on job
        setFormData(prev => ({
          ...prev,
          price_type: data.data.budget_type
        }));
      } else {
        alert('İş bulunamadı!');
        navigate('/jobs');
      }
    } catch (error) {
      console.error('Error loading job:', error);
      alert('İş yüklenirken hata oluştu!');
      navigate('/jobs');
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
    if (!formData.price || formData.price <= 0) {
      alert('Lütfen geçerli bir fiyat girin!');
      return;
    }
    
    if (!formData.message.trim() || formData.message.trim().length < 20) {
      alert('Teklif mesajı en az 20 karakter olmalıdır!');
      return;
    }

    setSubmitting(true);
    
    try {
      const proposalData = {
        ...formData,
        craftsman_id: user?.id || 1,
        price: parseInt(formData.price)
      };

      const response = await fetch(`http://localhost:5001/api/job-requests/${jobId}/proposals`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(proposalData)
      });

      const result = await response.json();

      if (result.success) {
        alert('✅ Teklifiniz başarıyla gönderildi!');
        navigate(`/job/${jobId}`);
      } else {
        alert('❌ Hata: ' + result.error);
      }
    } catch (error) {
      console.error('Error submitting proposal:', error);
      alert('❌ Teklif gönderilirken hata oluştu!');
    } finally {
      setSubmitting(false);
    }
  };

  const getBudgetTypeText = (budgetType) => {
    switch (budgetType) {
      case 'fixed': return 'Sabit Fiyat';
      case 'hourly': return 'Saatlik Ücret';
      case 'negotiable': return 'Pazarlık';
      default: return budgetType;
    }
  };

  const getUrgencyColor = (urgency) => {
    switch (urgency) {
      case 'urgent': return 'bg-red-100 text-red-800';
      case 'normal': return 'bg-yellow-100 text-yellow-800';
      case 'flexible': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getUrgencyIcon = (urgency) => {
    switch (urgency) {
      case 'urgent': return '🔴';
      case 'normal': return '🟡';
      case 'flexible': return '🟢';
      default: return '⚪';
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">İş detayları yükleniyor...</p>
        </div>
      </div>
    );
  }

  if (!job) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">İş Bulunamadı</h2>
          <p className="text-gray-600 mb-6">Aradığınız iş talebi bulunamadı veya artık teklif almıyor.</p>
          <button
            onClick={() => navigate('/jobs')}
            className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            İş Listesine Dön
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => navigate(-1)}
                className="flex items-center space-x-2 text-gray-600 hover:text-gray-900 transition-colors"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
                <span>Geri</span>
              </button>
              <h1 className="text-2xl font-bold text-gray-900">💰 Teklif Ver</h1>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main Form */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow-sm p-6">
              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Price Section */}
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-4">💰 Fiyat Bilgileri</h3>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Teklifiniz (₺) *
                      </label>
                      <input
                        type="number"
                        value={formData.price}
                        onChange={(e) => handleInputChange('price', e.target.value)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        placeholder="2500"
                        min="1"
                        required
                      />
                      <p className="text-xs text-gray-500 mt-1">
                        Müşteri bütçesi: {job.budget.toLocaleString('tr-TR')}₺ ({getBudgetTypeText(job.budget_type)})
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Fiyat Türü *
                      </label>
                      <select
                        value={formData.price_type}
                        onChange={(e) => handleInputChange('price_type', e.target.value)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      >
                        {priceTypes.map((type) => (
                          <option key={type.value} value={type.value}>
                            {type.label}
                          </option>
                        ))}
                      </select>
                      <p className="text-xs text-gray-500 mt-1">
                        {priceTypes.find(t => t.value === formData.price_type)?.description}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Message */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Teklif Mesajınız *
                  </label>
                  <textarea
                    value={formData.message}
                    onChange={(e) => handleInputChange('message', e.target.value)}
                    rows={5}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Merhaba, işiniz için teklif vermek istiyorum. Bu konuda X yıllık deneyimim var. Kaliteli malzeme kullanıyorum ve garanti veriyorum..."
                    required
                  />
                  <p className="text-sm text-gray-500 mt-1">
                    {formData.message.length}/500 karakter (En az 20 karakter gerekli)
                  </p>
                </div>

                {/* Duration & Availability */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Tahmini Süre
                    </label>
                    <input
                      type="text"
                      value={formData.estimated_duration}
                      onChange={(e) => handleInputChange('estimated_duration', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="2-3 gün"
                    />
                    <p className="text-xs text-gray-500 mt-1">
                      İşi ne kadar sürede tamamlarsınız?
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Müsaitlik Durumunuz
                    </label>
                    <input
                      type="text"
                      value={formData.availability}
                      onChange={(e) => handleInputChange('availability', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="Bu hafta uygun"
                    />
                    <p className="text-xs text-gray-500 mt-1">
                      Ne zaman başlayabilirsiniz?
                    </p>
                  </div>
                </div>

                {/* Guidelines */}
                <div className="bg-blue-50 rounded-lg p-4">
                  <h4 className="text-sm font-medium text-blue-900 mb-2">💡 Teklif Verme İpuçları:</h4>
                  <ul className="text-sm text-blue-800 space-y-1">
                    <li>• Deneyiminizi ve uzmanlık alanlarınızı belirtin</li>
                    <li>• Kullanacağınız malzeme kalitesinden bahsedin</li>
                    <li>• Garanti sürenizi ve şartlarınızı açıklayın</li>
                    <li>• Gerçekçi bir fiyat ve süre belirtin</li>
                    <li>• Müşterinin sorularını yanıtlamaya hazır olun</li>
                  </ul>
                </div>

                {/* Submit Buttons */}
                <div className="flex space-x-4 pt-6">
                  <button
                    type="button"
                    onClick={() => navigate(-1)}
                    className="flex-1 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    İptal
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className="flex-1 px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                  >
                    {submitting ? (
                      <div className="flex items-center justify-center space-x-2">
                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                        <span>Gönderiliyor...</span>
                      </div>
                    ) : (
                      '💰 Teklifi Gönder'
                    )}
                  </button>
                </div>
              </form>
            </div>
          </div>

          {/* Job Summary Sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow-sm p-6 sticky top-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">📋 İş Özeti</h3>
              
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold text-gray-900 mb-2">{job.title}</h4>
                  <p className="text-sm text-gray-600 line-clamp-3">{job.description}</p>
                </div>

                <div className="flex items-center justify-between py-2 border-t">
                  <span className="text-sm text-gray-600">Kategori:</span>
                  <span className="text-sm font-medium text-gray-900">{job.category}</span>
                </div>

                <div className="flex items-center justify-between py-2 border-t">
                  <span className="text-sm text-gray-600">Konum:</span>
                  <span className="text-sm font-medium text-gray-900">{job.location}</span>
                </div>

                <div className="flex items-center justify-between py-2 border-t">
                  <span className="text-sm text-gray-600">Bütçe:</span>
                  <div className="text-right">
                    <div className="text-sm font-bold text-green-600">
                      {job.budget.toLocaleString('tr-TR')}₺
                    </div>
                    <div className="text-xs text-gray-500">
                      {getBudgetTypeText(job.budget_type)}
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-between py-2 border-t">
                  <span className="text-sm text-gray-600">Aciliyet:</span>
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${getUrgencyColor(job.urgency)}`}>
                    {getUrgencyIcon(job.urgency)} {job.urgency === 'urgent' ? 'Acil' : job.urgency === 'normal' ? 'Normal' : 'Esnek'}
                  </span>
                </div>

                <div className="flex items-center justify-between py-2 border-t">
                  <span className="text-sm text-gray-600">Müşteri:</span>
                  <span className="text-sm font-medium text-gray-900">{job.customer_name}</span>
                </div>

                {job.preferred_date && (
                  <div className="flex items-center justify-between py-2 border-t">
                    <span className="text-sm text-gray-600">Tercih Tarihi:</span>
                    <span className="text-sm font-medium text-gray-900">
                      {new Date(job.preferred_date).toLocaleDateString('tr-TR')}
                    </span>
                  </div>
                )}

                <div className="pt-4 border-t">
                  <div className="grid grid-cols-2 gap-4 text-center">
                    <div className="bg-blue-50 rounded-lg p-3">
                      <div className="text-lg font-bold text-blue-600">{job.proposal_count}</div>
                      <div className="text-xs text-blue-800">Teklif</div>
                    </div>
                    <div className="bg-green-50 rounded-lg p-3">
                      <div className="text-lg font-bold text-green-600">{job.view_count}</div>
                      <div className="text-xs text-green-800">Görüntüleme</div>
                    </div>
                  </div>
                </div>

                {/* Quick Actions */}
                <div className="pt-4 border-t">
                  <button
                    onClick={() => navigate(`/job/${jobId}`)}
                    className="w-full p-3 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors text-sm font-medium text-gray-700"
                  >
                    📋 Detayları Görüntüle
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProposalFormPage;