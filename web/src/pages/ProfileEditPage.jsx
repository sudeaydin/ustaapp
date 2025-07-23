import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { profileService } from '../services/profileService';
import ProfileImageUpload from '../components/ProfileImageUpload';
import { uploadService } from '../services/uploadService';

export const ProfileEditPage = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [profile, setProfile] = useState(null);
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
    address: '',
    city: '',
    district: '',
    user_type: 'customer',
    // Craftsman fields
    business_name: '',
    description: '',
    category: '',
    hourly_rate: '',
    experience_years: '',
    is_available: true,
    skills: [],
    certifications: [],
    work_areas: []
  });
  const [errors, setErrors] = useState({});
  const [activeTab, setActiveTab] = useState('basic');

  // Load profile data
  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    try {
      setLoading(true);
      const response = await profileService.getProfile();
      
      if (response.success) {
        const profileData = response.data;
        setProfile(profileData);
        setFormData({
          first_name: profileData.first_name || '',
          last_name: profileData.last_name || '',
          email: profileData.email || '',
          phone: profileData.phone || '',
          address: profileData.address || '',
          city: profileData.city || '',
          district: profileData.district || '',
          user_type: profileData.user_type || 'customer',
          business_name: profileData.business_name || '',
          description: profileData.description || '',
          category: profileData.category || '',
          hourly_rate: profileData.hourly_rate || '',
          experience_years: profileData.experience_years || '',
          is_available: profileData.is_available !== false,
          skills: profileData.skills || [],
          certifications: profileData.certifications || [],
          work_areas: profileData.work_areas || []
        });
      }
    } catch (error) {
      console.error('Profile load error:', error);
      alert('Profil yüklenirken hata oluştu');
    } finally {
      setLoading(false);
    }
  };

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

  const handleArrayInputChange = (name, value) => {
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleProfileImageUpdate = async (imageData) => {
    try {
      const imageUrl = uploadService.getImageUrl(imageData.filename, 'profile');
      const response = await profileService.updateAvatar(imageUrl);
      
      if (response.success) {
        setProfile(prev => ({
          ...prev,
          profile_image: imageUrl
        }));
        alert('Profil fotoğrafı güncellendi!');
      }
    } catch (error) {
      console.error('Avatar update error:', error);
      alert('Profil fotoğrafı güncellenirken hata oluştu');
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validate form data
    const validation = profileService.validateProfileData(formData);
    if (!validation.isValid) {
      setErrors(validation.errors);
      return;
    }

    setSaving(true);
    try {
      const response = await profileService.updateProfile(formData);
      
      if (response.success) {
        alert('Profil başarıyla güncellendi!');
        navigate('/profile');
      } else {
        alert(response.message || 'Profil güncellenirken hata oluştu');
      }
    } catch (error) {
      console.error('Profile update error:', error);
      alert('Profil güncellenirken hata oluştu');
    } finally {
      setSaving(false);
    }
  };

  const handleSkillAdd = (skill) => {
    if (skill.trim() && !formData.skills.includes(skill.trim())) {
      handleArrayInputChange('skills', [...formData.skills, skill.trim()]);
    }
  };

  const handleSkillRemove = (index) => {
    const newSkills = formData.skills.filter((_, i) => i !== index);
    handleArrayInputChange('skills', newSkills);
  };

  const handleCertificationAdd = (cert) => {
    if (cert.trim() && !formData.certifications.includes(cert.trim())) {
      handleArrayInputChange('certifications', [...formData.certifications, cert.trim()]);
    }
  };

  const handleCertificationRemove = (index) => {
    const newCerts = formData.certifications.filter((_, i) => i !== index);
    handleArrayInputChange('certifications', newCerts);
  };

  const handleWorkAreaAdd = (area) => {
    if (area.trim() && !formData.work_areas.includes(area.trim())) {
      handleArrayInputChange('work_areas', [...formData.work_areas, area.trim()]);
    }
  };

  const handleWorkAreaRemove = (index) => {
    const newAreas = formData.work_areas.filter((_, i) => i !== index);
    handleArrayInputChange('work_areas', newAreas);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Profil yükleniyor...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4">
        {/* Header */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-800">
                👤 Profil Düzenle
              </h1>
              <p className="text-gray-600 mt-1">
                Profil bilgilerinizi güncelleyin
              </p>
            </div>
            
            <button
              onClick={() => navigate('/profile')}
              className="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors"
            >
              ← Geri Dön
            </button>
          </div>
        </div>

        <form onSubmit={handleSubmit}>
          {/* Profile Image */}
          <div className="bg-white rounded-lg shadow-md p-6 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 mb-4">
              📸 Profil Fotoğrafı
            </h2>
            
            <div className="flex justify-center">
              <ProfileImageUpload
                currentImage={profile?.profile_image}
                onImageUpdate={handleProfileImageUpdate}
                size="large"
              />
            </div>
          </div>

          {/* Tabs */}
          <div className="bg-white rounded-lg shadow-md mb-6">
            <div className="border-b border-gray-200">
              <nav className="flex space-x-8 px-6">
                <button
                  type="button"
                  onClick={() => setActiveTab('basic')}
                  className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                    activeTab === 'basic'
                      ? 'border-blue-500 text-blue-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700'
                  }`}
                >
                  Temel Bilgiler
                </button>
                
                {formData.user_type === 'craftsman' && (
                  <button
                    type="button"
                    onClick={() => setActiveTab('professional')}
                    className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                      activeTab === 'professional'
                        ? 'border-blue-500 text-blue-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700'
                    }`}
                  >
                    Profesyonel Bilgiler
                  </button>
                )}
              </nav>
            </div>

            <div className="p-6">
              {activeTab === 'basic' && (
                <BasicInfoTab
                  formData={formData}
                  errors={errors}
                  onChange={handleInputChange}
                />
              )}
              
              {activeTab === 'professional' && formData.user_type === 'craftsman' && (
                <ProfessionalInfoTab
                  formData={formData}
                  errors={errors}
                  onChange={handleInputChange}
                  onSkillAdd={handleSkillAdd}
                  onSkillRemove={handleSkillRemove}
                  onCertificationAdd={handleCertificationAdd}
                  onCertificationRemove={handleCertificationRemove}
                  onWorkAreaAdd={handleWorkAreaAdd}
                  onWorkAreaRemove={handleWorkAreaRemove}
                />
              )}
            </div>
          </div>

          {/* Save Button */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="flex justify-end space-x-4">
              <button
                type="button"
                onClick={() => navigate('/profile')}
                className="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
              >
                İptal
              </button>
              
              <button
                type="submit"
                disabled={saving}
                className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {saving ? 'Kaydediliyor...' : 'Kaydet'}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};

// Basic Info Tab Component
const BasicInfoTab = ({ formData, errors, onChange }) => (
  <div className="space-y-6">
    <div className="grid md:grid-cols-2 gap-6">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Ad *
        </label>
        <input
          type="text"
          name="first_name"
          value={formData.first_name}
          onChange={onChange}
          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
            errors.first_name ? 'border-red-500' : 'border-gray-300'
          }`}
          placeholder="Adınız"
        />
        {errors.first_name && (
          <p className="text-red-500 text-sm mt-1">{errors.first_name}</p>
        )}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Soyad *
        </label>
        <input
          type="text"
          name="last_name"
          value={formData.last_name}
          onChange={onChange}
          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
            errors.last_name ? 'border-red-500' : 'border-gray-300'
          }`}
          placeholder="Soyadınız"
        />
        {errors.last_name && (
          <p className="text-red-500 text-sm mt-1">{errors.last_name}</p>
        )}
      </div>
    </div>

    <div className="grid md:grid-cols-2 gap-6">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Email *
        </label>
        <input
          type="email"
          name="email"
          value={formData.email}
          onChange={onChange}
          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
            errors.email ? 'border-red-500' : 'border-gray-300'
          }`}
          placeholder="email@example.com"
        />
        {errors.email && (
          <p className="text-red-500 text-sm mt-1">{errors.email}</p>
        )}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Telefon *
        </label>
        <input
          type="tel"
          name="phone"
          value={formData.phone}
          onChange={onChange}
          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
            errors.phone ? 'border-red-500' : 'border-gray-300'
          }`}
          placeholder="+90 555 123 4567"
        />
        {errors.phone && (
          <p className="text-red-500 text-sm mt-1">{errors.phone}</p>
        )}
      </div>
    </div>

    <div>
      <label className="block text-sm font-medium text-gray-700 mb-2">
        Adres
      </label>
      <textarea
        name="address"
        value={formData.address}
        onChange={onChange}
        rows={3}
        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        placeholder="Tam adresiniz"
      />
    </div>

    <div className="grid md:grid-cols-2 gap-6">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Şehir
        </label>
        <input
          type="text"
          name="city"
          value={formData.city}
          onChange={onChange}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          placeholder="İstanbul"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          İlçe
        </label>
        <input
          type="text"
          name="district"
          value={formData.district}
          onChange={onChange}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          placeholder="Kadıköy"
        />
      </div>
    </div>

    <div>
      <label className="block text-sm font-medium text-gray-700 mb-2">
        Kullanıcı Tipi
      </label>
      <select
        name="user_type"
        value={formData.user_type}
        onChange={onChange}
        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
      >
        <option value="customer">Müşteri</option>
        <option value="craftsman">Usta</option>
      </select>
    </div>
  </div>
);

// Professional Info Tab Component
const ProfessionalInfoTab = ({ 
  formData, 
  errors, 
  onChange, 
  onSkillAdd, 
  onSkillRemove,
  onCertificationAdd,
  onCertificationRemove,
  onWorkAreaAdd,
  onWorkAreaRemove
}) => {
  const [newSkill, setNewSkill] = useState('');
  const [newCertification, setNewCertification] = useState('');
  const [newWorkArea, setNewWorkArea] = useState('');

  return (
    <div className="space-y-6">
      <div className="grid md:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            İşletme Adı *
          </label>
          <input
            type="text"
            name="business_name"
            value={formData.business_name}
            onChange={onChange}
            className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
              errors.business_name ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="Yılmaz Elektrik"
          />
          {errors.business_name && (
            <p className="text-red-500 text-sm mt-1">{errors.business_name}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Kategori *
          </label>
          <select
            name="category"
            value={formData.category}
            onChange={onChange}
            className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
              errors.category ? 'border-red-500' : 'border-gray-300'
            }`}
          >
            <option value="">Kategori seçin</option>
            <option value="Elektrikçi">Elektrikçi</option>
            <option value="Tesisatçı">Tesisatçı</option>
            <option value="Boyacı">Boyacı</option>
            <option value="Marangoz">Marangoz</option>
            <option value="Tadilat">Tadilat</option>
            <option value="Temizlik">Temizlik</option>
          </select>
          {errors.category && (
            <p className="text-red-500 text-sm mt-1">{errors.category}</p>
          )}
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Açıklama *
        </label>
        <textarea
          name="description"
          value={formData.description}
          onChange={onChange}
          rows={4}
          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
            errors.description ? 'border-red-500' : 'border-gray-300'
          }`}
          placeholder="Hizmetleriniz ve deneyiminiz hakkında bilgi verin..."
        />
        {errors.description && (
          <p className="text-red-500 text-sm mt-1">{errors.description}</p>
        )}
      </div>

      <div className="grid md:grid-cols-3 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Saatlik Ücret (₺)
          </label>
          <input
            type="number"
            name="hourly_rate"
            value={formData.hourly_rate}
            onChange={onChange}
            min="0"
            className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
              errors.hourly_rate ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="150"
          />
          {errors.hourly_rate && (
            <p className="text-red-500 text-sm mt-1">{errors.hourly_rate}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Deneyim (Yıl)
          </label>
          <input
            type="number"
            name="experience_years"
            value={formData.experience_years}
            onChange={onChange}
            min="0"
            className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
              errors.experience_years ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="5"
          />
          {errors.experience_years && (
            <p className="text-red-500 text-sm mt-1">{errors.experience_years}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Müsaitlik Durumu
          </label>
          <div className="flex items-center space-x-3 pt-2">
            <label className="flex items-center">
              <input
                type="checkbox"
                name="is_available"
                checked={formData.is_available}
                onChange={onChange}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">Müsaitim</span>
            </label>
          </div>
        </div>
      </div>

      {/* Skills Section */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Yetenekler
        </label>
        <div className="flex space-x-2 mb-3">
          <input
            type="text"
            value={newSkill}
            onChange={(e) => setNewSkill(e.target.value)}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Yeni yetenek ekle"
            onKeyPress={(e) => {
              if (e.key === 'Enter') {
                e.preventDefault();
                onSkillAdd(newSkill);
                setNewSkill('');
              }
            }}
          />
          <button
            type="button"
            onClick={() => {
              onSkillAdd(newSkill);
              setNewSkill('');
            }}
            className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            Ekle
          </button>
        </div>
        <div className="flex flex-wrap gap-2">
          {formData.skills.map((skill, index) => (
            <span
              key={index}
              className="inline-flex items-center px-3 py-1 rounded-full text-sm bg-blue-100 text-blue-800"
            >
              {skill}
              <button
                type="button"
                onClick={() => onSkillRemove(index)}
                className="ml-2 text-blue-600 hover:text-blue-800"
              >
                ×
              </button>
            </span>
          ))}
        </div>
      </div>

      {/* Certifications Section */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Sertifikalar
        </label>
        <div className="flex space-x-2 mb-3">
          <input
            type="text"
            value={newCertification}
            onChange={(e) => setNewCertification(e.target.value)}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Yeni sertifika ekle"
            onKeyPress={(e) => {
              if (e.key === 'Enter') {
                e.preventDefault();
                onCertificationAdd(newCertification);
                setNewCertification('');
              }
            }}
          />
          <button
            type="button"
            onClick={() => {
              onCertificationAdd(newCertification);
              setNewCertification('');
            }}
            className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
          >
            Ekle
          </button>
        </div>
        <div className="flex flex-wrap gap-2">
          {formData.certifications.map((cert, index) => (
            <span
              key={index}
              className="inline-flex items-center px-3 py-1 rounded-full text-sm bg-green-100 text-green-800"
            >
              {cert}
              <button
                type="button"
                onClick={() => onCertificationRemove(index)}
                className="ml-2 text-green-600 hover:text-green-800"
              >
                ×
              </button>
            </span>
          ))}
        </div>
      </div>

      {/* Work Areas Section */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Çalışma Alanları
        </label>
        <div className="flex space-x-2 mb-3">
          <input
            type="text"
            value={newWorkArea}
            onChange={(e) => setNewWorkArea(e.target.value)}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Yeni çalışma alanı ekle"
            onKeyPress={(e) => {
              if (e.key === 'Enter') {
                e.preventDefault();
                onWorkAreaAdd(newWorkArea);
                setNewWorkArea('');
              }
            }}
          />
          <button
            type="button"
            onClick={() => {
              onWorkAreaAdd(newWorkArea);
              setNewWorkArea('');
            }}
            className="px-4 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 transition-colors"
          >
            Ekle
          </button>
        </div>
        <div className="flex flex-wrap gap-2">
          {formData.work_areas.map((area, index) => (
            <span
              key={index}
              className="inline-flex items-center px-3 py-1 rounded-full text-sm bg-purple-100 text-purple-800"
            >
              {area}
              <button
                type="button"
                onClick={() => onWorkAreaRemove(index)}
                className="ml-2 text-purple-600 hover:text-purple-800"
              >
                ×
              </button>
            </span>
          ))}
        </div>
      </div>
    </div>
  );
};

export default ProfileEditPage;