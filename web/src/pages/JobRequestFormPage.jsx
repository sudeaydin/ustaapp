import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { CATEGORIES } from '../data/categories';

export const JobRequestFormPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  
  const [submitting, setSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    category: '',
    skills_needed: [],
    budget: '',
    budget_type: 'fixed',
    location: '',
    address: '',
    urgency: 'normal',
    preferred_date: '',
    customer_name: user?.name || '',
    customer_phone: user?.phone || '',
    photos: []
  });

  const [showSkillModal, setShowSkillModal] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState(null);

  const urgencyOptions = [
    { value: 'urgent', label: '🔴 Acil', description: '24-48 saat içinde' },
    { value: 'normal', label: '🟡 Normal', description: 'Bu hafta içinde' },
    { value: 'flexible', label: '🟢 Esnek', description: 'Zaman önemli değil' }
  ];

  const budgetTypes = [
    { value: 'fixed', label: '💰 Sabit Fiyat', description: 'Kesin bütçe' },
    { value: 'hourly', label: '⏰ Saatlik', description: 'Saat başı ücret' },
    { value: 'negotiable', label: '🤝 Pazarlık', description: 'Görüşülür' }
  ];

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSkillToggle = (skillId) => {
    setFormData(prev => ({
      ...prev,
      skills_needed: prev.skills_needed.includes(skillId)
        ? prev.skills_needed.filter(id => id !== skillId)
        : [...prev.skills_needed, skillId]
    }));
  };

  const getSkillName = (skillId) => {
    for (const category of CATEGORIES) {
      const skill = category.skills.find(s => s.id === skillId);
      if (skill) return skill.name;
    }
    return '';
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validation
    if (!formData.title.trim()) {
      alert('Lütfen iş başlığı girin!');
      return;
    }
    
    if (!formData.description.trim() || formData.description.trim().length < 20) {
      alert('İş açıklaması en az 20 karakter olmalıdır!');
      return;
    }
    
    if (!formData.category) {
      alert('Lütfen kategori seçin!');
      return;
    }
    
    if (!formData.budget || formData.budget <= 0) {
      alert('Lütfen geçerli bir bütçe girin!');
      return;
    }
    
    if (!formData.location.trim()) {
      alert('Lütfen konum belirtin!');
      return;
    }

    setSubmitting(true);
    
    try {
      // Calculate expiry date (7 days from now)
      const expiryDate = new Date();
      expiryDate.setDate(expiryDate.getDate() + 7);
      
      const requestData = {
        ...formData,
        customer_id: user?.id || 1,
        budget: parseInt(formData.budget),
        expires_at: expiryDate.toISOString()
      };

      const response = await fetch('http://localhost:5001/api/job-requests', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestData)
      });

      const result = await response.json();

      if (result.success) {
        alert('✅ İş talebiniz başarıyla oluşturuldu!');
        navigate('/customer/jobs');
      } else {
        alert('❌ Hata: ' + result.error);
      }
    } catch (error) {
      console.error('Error creating job request:', error);
      alert('❌ İş talebi oluşturulurken hata oluştu!');
    } finally {
      setSubmitting(false);
    }
  };

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
              <h1 className="text-2xl font-bold text-gray-900">📋 Yeni İş Talebi</h1>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        <div className="bg-white rounded-lg shadow-sm p-6">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Job Title */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                İş Başlığı *
              </label>
              <input
                type="text"
                value={formData.title}
                onChange={(e) => handleInputChange('title', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Örn: Ev LED Aydınlatma Sistemi Kurulumu"
                required
              />
            </div>

            {/* Description */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                İş Açıklaması *
              </label>
              <textarea
                value={formData.description}
                onChange={(e) => handleInputChange('description', e.target.value)}
                rows={5}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="İşin detaylarını açıklayın. Ne yapılması gerekiyor, hangi malzemeler kullanılacak, özel istekleriniz var mı..."
                required
              />
              <p className="text-sm text-gray-500 mt-1">
                {formData.description.length}/1000 karakter (En az 20 karakter gerekli)
              </p>
            </div>

            {/* Category */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Kategori *
              </label>
              <select
                value={formData.category}
                onChange={(e) => handleInputChange('category', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                required
              >
                <option value="">Kategori seçiniz</option>
                {CATEGORIES.map((category) => (
                  <option key={category.id} value={category.name}>
                    {category.icon} {category.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Skills Needed */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                İhtiyaç Duyulan Yetenekler
              </label>
              <div className="flex items-center justify-between p-3 border border-gray-300 rounded-lg">
                <div className="flex-1">
                  {formData.skills_needed.length === 0 ? (
                    <span className="text-gray-500">Yetenek seçin (opsiyonel)</span>
                  ) : (
                    <div className="flex flex-wrap gap-2">
                      {formData.skills_needed.map((skillId) => (
                        <span
                          key={skillId}
                          className="px-2 py-1 bg-blue-100 text-blue-800 text-sm rounded-full"
                        >
                          {getSkillName(skillId)}
                        </span>
                      ))}
                    </div>
                  )}
                </div>
                <button
                  type="button"
                  onClick={() => setShowSkillModal(true)}
                  className="px-3 py-1 text-blue-600 hover:text-blue-800 text-sm font-medium"
                >
                  ⚙️ Seç
                </button>
              </div>
            </div>

            {/* Budget and Type */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Bütçe (₺) *
                </label>
                <input
                  type="number"
                  value={formData.budget}
                  onChange={(e) => handleInputChange('budget', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="1500"
                  min="1"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Bütçe Türü *
                </label>
                <select
                  value={formData.budget_type}
                  onChange={(e) => handleInputChange('budget_type', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  {budgetTypes.map((type) => (
                    <option key={type.value} value={type.value}>
                      {type.label}
                    </option>
                  ))}
                </select>
                <p className="text-xs text-gray-500 mt-1">
                  {budgetTypes.find(t => t.value === formData.budget_type)?.description}
                </p>
              </div>
            </div>

            {/* Location */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Konum *
                </label>
                <input
                  type="text"
                  value={formData.location}
                  onChange={(e) => handleInputChange('location', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Kadıköy, İstanbul"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Adres Detay
                </label>
                <input
                  type="text"
                  value={formData.address}
                  onChange={(e) => handleInputChange('address', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Mahalle/sokak bilgisi"
                />
              </div>
            </div>

            {/* Urgency */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-3">
                Aciliyet Durumu *
              </label>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                {urgencyOptions.map((option) => (
                  <label
                    key={option.value}
                    className={`relative flex items-center p-4 border rounded-lg cursor-pointer transition-colors ${
                      formData.urgency === option.value
                        ? 'border-blue-500 bg-blue-50'
                        : 'border-gray-300 hover:border-gray-400'
                    }`}
                  >
                    <input
                      type="radio"
                      name="urgency"
                      value={option.value}
                      checked={formData.urgency === option.value}
                      onChange={(e) => handleInputChange('urgency', e.target.value)}
                      className="sr-only"
                    />
                    <div className="flex-1">
                      <div className="font-medium text-gray-900">{option.label}</div>
                      <div className="text-sm text-gray-600">{option.description}</div>
                    </div>
                    {formData.urgency === option.value && (
                      <svg className="w-5 h-5 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                      </svg>
                    )}
                  </label>
                ))}
              </div>
            </div>

            {/* Preferred Date */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tercih Edilen Tarih
              </label>
              <input
                type="date"
                value={formData.preferred_date}
                onChange={(e) => handleInputChange('preferred_date', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                min={new Date().toISOString().split('T')[0]}
              />
              <p className="text-sm text-gray-500 mt-1">
                İşin yapılmasını istediğiniz tarih (opsiyonel)
              </p>
            </div>

            {/* Contact Info */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  İletişim Adı *
                </label>
                <input
                  type="text"
                  value={formData.customer_name}
                  onChange={(e) => handleInputChange('customer_name', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Telefon Numarası
                </label>
                <input
                  type="tel"
                  value={formData.customer_phone}
                  onChange={(e) => handleInputChange('customer_phone', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="+90 555 123 4567"
                />
              </div>
            </div>

            {/* Photo Upload */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Fotoğraf Ekle (İsteğe bağlı)
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                <svg className="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <p className="text-gray-600 mb-2">İş ile ilgili fotoğrafları ekleyebilirsiniz</p>
                <button
                  type="button"
                  className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                >
                  📷 Fotoğraf Seç
                </button>
              </div>
            </div>

            {/* Guidelines */}
            <div className="bg-blue-50 rounded-lg p-4">
              <h4 className="text-sm font-medium text-blue-900 mb-2">💡 İş Talebi İpuçları:</h4>
              <ul className="text-sm text-blue-800 space-y-1">
                <li>• İş açıklamasını mümkün olduğunca detaylı yazın</li>
                <li>• Beklentilerinizi net bir şekilde belirtin</li>
                <li>• Fotoğraf eklemek ustalar için çok yardımcı olur</li>
                <li>• Gerçekçi bir bütçe belirleyin</li>
                <li>• İletişim bilgilerinizi doğru girin</li>
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
                    <span>Oluşturuluyor...</span>
                  </div>
                ) : (
                  '📋 İş Talebini Oluştur'
                )}
              </button>
            </div>
          </form>
        </div>
      </div>

      {/* Skill Selection Modal */}
      {showSkillModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-medium text-gray-900">⚙️ Yetenek Seçimi</h3>
                <button
                  onClick={() => setShowSkillModal(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              {/* Categories */}
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                {CATEGORIES.map((category) => (
                  <button
                    key={category.id}
                    onClick={() => setSelectedCategory(selectedCategory === category.id ? null : category.id)}
                    className={`p-4 rounded-lg border-2 transition-colors ${
                      selectedCategory === category.id
                        ? 'border-blue-500 bg-blue-50'
                        : 'border-gray-200 hover:border-gray-300'
                    }`}
                  >
                    <div className="text-2xl mb-2">{category.icon}</div>
                    <div className="font-medium text-sm">{category.name}</div>
                  </button>
                ))}
              </div>

              {/* Skills */}
              {selectedCategory && (
                <div className="border-t pt-6">
                  <h4 className="font-medium text-gray-900 mb-4">
                    {CATEGORIES.find(c => c.id === selectedCategory)?.name} Yetenekleri:
                  </h4>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                    {CATEGORIES.find(c => c.id === selectedCategory)?.skills.map((skill) => (
                      <label
                        key={skill.id}
                        className={`flex items-center p-3 rounded-lg border cursor-pointer transition-colors ${
                          formData.skills_needed.includes(skill.id)
                            ? 'border-blue-500 bg-blue-50'
                            : 'border-gray-200 hover:border-gray-300'
                        }`}
                      >
                        <input
                          type="checkbox"
                          checked={formData.skills_needed.includes(skill.id)}
                          onChange={() => handleSkillToggle(skill.id)}
                          className="sr-only"
                        />
                        <div className="flex-1">
                          <div className="font-medium text-sm">{skill.name}</div>
                          <div className="text-xs text-gray-600">{skill.description}</div>
                        </div>
                        {formData.skills_needed.includes(skill.id) && (
                          <svg className="w-5 h-5 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                          </svg>
                        )}
                      </label>
                    ))}
                  </div>
                </div>
              )}

              <div className="flex justify-end pt-6">
                <button
                  onClick={() => setShowSkillModal(false)}
                  className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                >
                  Tamam
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default JobRequestFormPage;