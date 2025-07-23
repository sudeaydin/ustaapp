import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { CATEGORIES, getCategoryById, getSkillById } from '../data/categories';

export const ProfileEditPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState('basic');
  const [showSkillModal, setShowSkillModal] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState(null);
  
  // Form states
  const [formData, setFormData] = useState({
    name: 'Ahmet Yılmaz',
    business_name: 'Yılmaz Elektrik',
    email: 'ahmet@yilmazelektrik.com',
    phone: '+90 555 123 4567',
    city: 'İstanbul',
    district: 'Kadıköy',
    address: 'Kadıköy Merkez, İstanbul',
    description: `8 yıllık deneyimim ile ev ve işyeri elektrik tesisatı, LED aydınlatma sistemleri, akıllı ev otomasyonu ve elektrik panosu montajı konularında profesyonel hizmet veriyorum.

Müşteri memnuniyeti önceliğim olup, işlerimi titizlikle ve zamanında teslim ederim. Tüm işlerim için garanti veriyorum.`,
    hourly_rate: 150,
    experience_years: 8,
    website: 'www.yilmazelektrik.com',
    service_areas: ['Kadıköy', 'Üsküdar', 'Ataşehir', 'Maltepe', 'Kartal'],
    working_hours: {
      monday: '09:00-18:00',
      tuesday: '09:00-18:00',
      wednesday: '09:00-18:00',
      thursday: '09:00-18:00',
      friday: '09:00-18:00',
      saturday: '09:00-15:00',
      sunday: 'Kapalı'
    }
  });

  // Selected skills state
  const [selectedSkills, setSelectedSkills] = useState([
    { id: 101, name: 'Elektrik Tesisatı', categoryId: 1, categoryName: 'Elektrikçi' },
    { id: 102, name: 'LED Aydınlatma', categoryId: 1, categoryName: 'Elektrikçi' },
    { id: 103, name: 'Ev Otomasyonu', categoryId: 1, categoryName: 'Elektrikçi' },
    { id: 104, name: 'Panel Montajı', categoryId: 1, categoryName: 'Elektrikçi' }
  ]);

  const [certifications, setCertifications] = useState([
    'Elektrik Tesisatı Yeterlilik Belgesi',
    'LED Aydınlatma Uzmanı Sertifikası',
    'Akıllı Ev Sistemleri Eğitimi'
  ]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleWorkingHoursChange = (day, value) => {
    setFormData(prev => ({
      ...prev,
      working_hours: {
        ...prev.working_hours,
        [day]: value
      }
    }));
  };

  const handleServiceAreaAdd = () => {
    const newArea = prompt('Yeni hizmet alanı ekleyin:');
    if (newArea && !formData.service_areas.includes(newArea)) {
      setFormData(prev => ({
        ...prev,
        service_areas: [...prev.service_areas, newArea]
      }));
    }
  };

  const handleServiceAreaRemove = (area) => {
    setFormData(prev => ({
      ...prev,
      service_areas: prev.service_areas.filter(a => a !== area)
    }));
  };

  const handleSkillAdd = (skill) => {
    if (!selectedSkills.find(s => s.id === skill.id)) {
      const category = getCategoryById(skill.categoryId);
      setSelectedSkills(prev => [...prev, {
        ...skill,
        categoryName: category.name,
        categoryIcon: category.icon
      }]);
    }
  };

  const handleSkillRemove = (skillId) => {
    setSelectedSkills(prev => prev.filter(s => s.id !== skillId));
  };

  const handleCertificationAdd = () => {
    const newCert = prompt('Yeni sertifika ekleyin:');
    if (newCert && !certifications.includes(newCert)) {
      setCertifications(prev => [...prev, newCert]);
    }
  };

  const handleCertificationRemove = (cert) => {
    setCertifications(prev => prev.filter(c => c !== cert));
  };

  const handleSave = async () => {
    setLoading(true);
    try {
      // API call to save profile
      const profileData = {
        ...formData,
        skills: selectedSkills.map(s => s.id),
        certifications
      };
      
      console.log('Saving profile:', profileData);
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      alert('✅ Profil başarıyla güncellendi!');
      navigate('/craftsman/dashboard');
    } catch (error) {
      console.error('Profile save error:', error);
      alert('❌ Profil güncellenirken hata oluştu!');
    } finally {
      setLoading(false);
    }
  };

  const renderDayName = (day) => {
    const dayNames = {
      monday: 'Pazartesi',
      tuesday: 'Salı',
      wednesday: 'Çarşamba',
      thursday: 'Perşembe',
      friday: 'Cuma',
      saturday: 'Cumartesi',
      sunday: 'Pazar'
    };
    return dayNames[day];
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
              <h1 className="text-2xl font-bold text-gray-900">⚙️ Profil Düzenle</h1>
            </div>
            
            <button
              onClick={handleSave}
              disabled={loading}
              className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? (
                <div className="flex items-center space-x-2">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  <span>Kaydediliyor...</span>
                </div>
              ) : (
                '💾 Kaydet'
              )}
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Tabs */}
        <div className="bg-white rounded-lg shadow-sm mb-6">
          <div className="border-b border-gray-200">
            <nav className="flex space-x-8 px-6">
              <button
                onClick={() => setActiveTab('basic')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'basic'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                👤 Temel Bilgiler
              </button>
              <button
                onClick={() => setActiveTab('skills')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'skills'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                🎯 Yetenekler ({selectedSkills.length})
              </button>
              <button
                onClick={() => setActiveTab('business')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'business'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                💼 İş Bilgileri
              </button>
              <button
                onClick={() => setActiveTab('schedule')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'schedule'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                ⏰ Çalışma Saatleri
              </button>
            </nav>
          </div>

          {/* Tab Content */}
          <div className="p-6">
            {activeTab === 'basic' && (
              <div className="space-y-6">
                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Ad Soyad *
                    </label>
                    <input
                      type="text"
                      name="name"
                      value={formData.name}
                      onChange={handleInputChange}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      İşletme Adı
                    </label>
                    <input
                      type="text"
                      name="business_name"
                      value={formData.business_name}
                      onChange={handleInputChange}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                </div>

                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      E-posta *
                    </label>
                    <input
                      type="email"
                      name="email"
                      value={formData.email}
                      onChange={handleInputChange}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
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
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                </div>

                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Şehir *
                    </label>
                    <input
                      type="text"
                      name="city"
                      value={formData.city}
                      onChange={handleInputChange}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
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
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Adres
                  </label>
                  <input
                    type="text"
                    name="address"
                    value={formData.address}
                    onChange={handleInputChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Hakkımda
                  </label>
                  <textarea
                    name="description"
                    value={formData.description}
                    onChange={handleInputChange}
                    rows={6}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Kendinizi ve hizmetlerinizi tanıtın..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Website
                  </label>
                  <input
                    type="url"
                    name="website"
                    value={formData.website}
                    onChange={handleInputChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="www.ornek.com"
                  />
                </div>
              </div>
            )}

            {activeTab === 'skills' && (
              <div className="space-y-6">
                {/* Selected Skills */}
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-medium text-gray-900">🎯 Seçili Yeteneklerim</h3>
                    <button
                      onClick={() => setShowSkillModal(true)}
                      className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                    >
                      ➕ Yetenek Ekle
                    </button>
                  </div>
                  
                  {selectedSkills.length > 0 ? (
                    <div className="grid md:grid-cols-2 gap-4">
                      {selectedSkills.map((skill) => (
                        <div key={skill.id} className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                          <div className="flex items-start justify-between">
                            <div className="flex-1">
                              <div className="flex items-center space-x-2 mb-2">
                                <span className="text-lg">{skill.categoryIcon || '⭐'}</span>
                                <span className="font-medium text-gray-900">{skill.name}</span>
                              </div>
                              <p className="text-sm text-gray-600 mb-2">{skill.description}</p>
                              <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">
                                {skill.categoryName}
                              </span>
                            </div>
                            <button
                              onClick={() => handleSkillRemove(skill.id)}
                              className="ml-3 p-1 text-red-500 hover:text-red-700 transition-colors"
                            >
                              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                              </svg>
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="text-center py-8 bg-gray-50 rounded-lg">
                      <p className="text-gray-500 mb-4">Henüz yetenek eklenmemiş</p>
                      <button
                        onClick={() => setShowSkillModal(true)}
                        className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                      >
                        İlk Yeteneğini Ekle
                      </button>
                    </div>
                  )}
                </div>

                {/* Certifications */}
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-medium text-gray-900">🏅 Sertifikalarım</h3>
                    <button
                      onClick={handleCertificationAdd}
                      className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
                    >
                      ➕ Sertifika Ekle
                    </button>
                  </div>
                  
                  <div className="space-y-2">
                    {certifications.map((cert, index) => (
                      <div key={index} className="flex items-center justify-between bg-green-50 border border-green-200 rounded-lg p-3">
                        <div className="flex items-center space-x-2">
                          <svg className="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                          </svg>
                          <span className="text-gray-900">{cert}</span>
                        </div>
                        <button
                          onClick={() => handleCertificationRemove(cert)}
                          className="p-1 text-red-500 hover:text-red-700 transition-colors"
                        >
                          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                          </svg>
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'business' && (
              <div className="space-y-6">
                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Saatlik Ücret (₺)
                    </label>
                    <input
                      type="number"
                      name="hourly_rate"
                      value={formData.hourly_rate}
                      onChange={handleInputChange}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      min="0"
                    />
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
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      min="0"
                    />
                  </div>
                </div>

                {/* Service Areas */}
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Hizmet Verdiğim Bölgeler
                    </label>
                    <button
                      onClick={handleServiceAreaAdd}
                      className="px-3 py-1 bg-blue-500 text-white text-sm rounded hover:bg-blue-600 transition-colors"
                    >
                      ➕ Bölge Ekle
                    </button>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {formData.service_areas.map((area, index) => (
                      <span
                        key={index}
                        className="inline-flex items-center px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm"
                      >
                        {area}
                        <button
                          onClick={() => handleServiceAreaRemove(area)}
                          className="ml-2 text-red-500 hover:text-red-700"
                        >
                          ×
                        </button>
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'schedule' && (
              <div className="space-y-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">⏰ Çalışma Saatleri</h3>
                <div className="space-y-4">
                  {Object.entries(formData.working_hours).map(([day, hours]) => (
                    <div key={day} className="flex items-center space-x-4">
                      <div className="w-24 font-medium text-gray-700">
                        {renderDayName(day)}
                      </div>
                      <div className="flex-1">
                        <select
                          value={hours}
                          onChange={(e) => handleWorkingHoursChange(day, e.target.value)}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        >
                          <option value="Kapalı">Kapalı</option>
                          <option value="09:00-18:00">09:00 - 18:00</option>
                          <option value="08:00-17:00">08:00 - 17:00</option>
                          <option value="10:00-19:00">10:00 - 19:00</option>
                          <option value="09:00-15:00">09:00 - 15:00</option>
                          <option value="08:00-12:00">08:00 - 12:00</option>
                          <option value="13:00-18:00">13:00 - 18:00</option>
                          <option value="24 Saat">24 Saat Açık</option>
                        </select>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Skill Selection Modal */}
      {showSkillModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-medium text-gray-900">🎯 Yetenek Seçimi</h3>
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
                    onClick={() => setSelectedCategory(selectedCategory?.id === category.id ? null : category)}
                    className={`p-4 rounded-lg border-2 transition-colors ${
                      selectedCategory?.id === category.id
                        ? 'border-blue-500 bg-blue-50 text-blue-700'
                        : 'border-gray-200 hover:border-gray-300 text-gray-700'
                    }`}
                  >
                    <div className="text-2xl mb-2">{category.icon}</div>
                    <div className="font-medium text-sm">{category.name}</div>
                  </button>
                ))}
              </div>

              {/* Skills for selected category */}
              {selectedCategory && (
                <div>
                  <h4 className="text-lg font-medium text-gray-900 mb-4">
                    {selectedCategory.icon} {selectedCategory.name} Yetenekleri
                  </h4>
                  <div className="grid md:grid-cols-2 gap-4">
                    {selectedCategory.skills.map((skill) => {
                      const isSelected = selectedSkills.find(s => s.id === skill.id);
                      return (
                        <div
                          key={skill.id}
                          className={`p-4 rounded-lg border-2 cursor-pointer transition-colors ${
                            isSelected
                              ? 'border-green-500 bg-green-50'
                              : 'border-gray-200 hover:border-blue-300 hover:bg-blue-50'
                          }`}
                          onClick={() => {
                            if (isSelected) {
                              handleSkillRemove(skill.id);
                            } else {
                              handleSkillAdd({ ...skill, categoryId: selectedCategory.id });
                            }
                          }}
                        >
                          <div className="flex items-start justify-between">
                            <div className="flex-1">
                              <div className="font-medium text-gray-900 mb-2">{skill.name}</div>
                              <p className="text-sm text-gray-600">{skill.description}</p>
                            </div>
                            <div className="ml-3">
                              {isSelected ? (
                                <svg className="w-6 h-6 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                                </svg>
                              ) : (
                                <svg className="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                                </svg>
                              )}
                            </div>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}

              <div className="flex justify-end space-x-3 mt-6 pt-6 border-t">
                <button
                  onClick={() => setShowSkillModal(false)}
                  className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Kapat
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ProfileEditPage;