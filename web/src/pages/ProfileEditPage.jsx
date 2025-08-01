import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

const ProfileEditPage = () => {
  const navigate = useNavigate();
  const { user, updateUser } = useAuth();
  const queryClient = useQueryClient();
  
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    phone: '',
    avatar: '',
    // Customer specific
    address: '',
    city: '',
    district: '',
    // Craftsman specific
    business_name: '',
    description: '',
    hourly_rate: '',
    experience_years: '',
    skills: [],
    certifications: [],
    working_hours: {},
    service_areas: [],
    website: '',
    response_time: '',
    is_available: true
  });
  
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Fetch user profile
  const { data: profileData, isLoading: isLoadingProfile } = useQuery({
    queryKey: ['profile'],
    queryFn: async () => {
      const response = await fetch('http://localhost:5001/api/profile/', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        }
      });
      const data = await response.json();
      return data.success ? data.data : null;
    },
    enabled: !!localStorage.getItem('token')
  });

  // Update profile mutation
  const updateProfileMutation = useMutation({
    mutationFn: async (data) => {
      const response = await fetch('http://localhost:5001/api/profile/', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      });
      return response.json();
    },
    onSuccess: (data) => {
      if (data.success) {
        setSuccess('Profil başarıyla güncellendi');
        queryClient.invalidateQueries(['profile']);
        // Update local user data
        if (updateUser) {
          updateUser({ ...user, ...formData });
        }
        setTimeout(() => {
          navigate('/profile');
        }, 2000);
      } else {
        setError(data.message || 'Profil güncellenirken bir hata oluştu');
      }
    },
    onError: () => {
      setError('Profil güncellenirken bir hata oluştu');
    }
  });

  useEffect(() => {
    if (profileData) {
      setFormData({
        first_name: profileData.first_name || '',
        last_name: profileData.last_name || '',
        phone: profileData.phone || '',
        avatar: profileData.avatar || '',
        // Customer specific
        address: profileData.profile?.address || '',
        city: profileData.profile?.city || '',
        district: profileData.profile?.district || '',
        // Craftsman specific
        business_name: profileData.profile?.business_name || '',
        description: profileData.profile?.description || '',
        hourly_rate: profileData.profile?.hourly_rate || '',
        experience_years: profileData.profile?.experience_years || '',
        skills: profileData.profile?.skills || [],
        certifications: profileData.profile?.certifications || [],
        working_hours: profileData.profile?.working_hours || {},
        service_areas: profileData.profile?.service_areas || [],
        website: profileData.profile?.website || '',
        response_time: profileData.profile?.response_time || '',
        is_available: profileData.profile?.is_available ?? true
      });
    }
  }, [profileData]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    setError('');
    setSuccess('');
  };

  const handleSkillChange = (index, value) => {
    const newSkills = [...formData.skills];
    newSkills[index] = value;
    setFormData(prev => ({ ...prev, skills: newSkills }));
  };

  const addSkill = () => {
    setFormData(prev => ({ ...prev, skills: [...prev.skills, ''] }));
  };

  const removeSkill = (index) => {
    const newSkills = formData.skills.filter((_, i) => i !== index);
    setFormData(prev => ({ ...prev, skills: newSkills }));
  };

  const handleCertificationChange = (index, value) => {
    const newCertifications = [...formData.certifications];
    newCertifications[index] = value;
    setFormData(prev => ({ ...prev, certifications: newCertifications }));
  };

  const addCertification = () => {
    setFormData(prev => ({ ...prev, certifications: [...prev.certifications, ''] }));
  };

  const removeCertification = (index) => {
    const newCertifications = formData.certifications.filter((_, i) => i !== index);
    setFormData(prev => ({ ...prev, certifications: newCertifications }));
  };

  const handleWorkingHoursChange = (day, value) => {
    setFormData(prev => ({
      ...prev,
      working_hours: { ...prev.working_hours, [day]: value }
    }));
  };

  const handleServiceAreaChange = (index, value) => {
    const newServiceAreas = [...formData.service_areas];
    newServiceAreas[index] = value;
    setFormData(prev => ({ ...prev, service_areas: newServiceAreas }));
  };

  const addServiceArea = () => {
    setFormData(prev => ({ ...prev, service_areas: [...prev.service_areas, ''] }));
  };

  const removeServiceArea = (index) => {
    const newServiceAreas = formData.service_areas.filter((_, i) => i !== index);
    setFormData(prev => ({ ...prev, service_areas: newServiceAreas }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');
    setSuccess('');

    try {
      const submitData = {
        first_name: formData.first_name,
        last_name: formData.last_name,
        phone: formData.phone,
        avatar: formData.avatar
      };

      // Add user type specific data
      if (user?.user_type === 'customer') {
        submitData.address = formData.address;
        submitData.city = formData.city;
        submitData.district = formData.district;
      } else if (user?.user_type === 'craftsman') {
        submitData.business_name = formData.business_name;
        submitData.description = formData.description;
        submitData.hourly_rate = formData.hourly_rate;
        submitData.experience_years = formData.experience_years;
        submitData.skills = formData.skills.filter(skill => skill.trim());
        submitData.certifications = formData.certifications.filter(cert => cert.trim());
        submitData.working_hours = formData.working_hours;
        submitData.service_areas = formData.service_areas.filter(area => area.trim());
        submitData.website = formData.website;
        submitData.response_time = formData.response_time;
        submitData.is_available = formData.is_available;
      }

      updateProfileMutation.mutate(submitData);
    } catch (err) {
      setError('Bir hata oluştu');
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoadingProfile) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Profil yükleniyor...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-4xl mx-auto px-4 py-6">
          <div className="flex items-center justify-between">
            <button
              onClick={() => navigate(-1)}
              className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
              Geri
            </button>
            <h1 className="text-2xl font-bold text-gray-900">Profil Düzenle</h1>
            <div className="w-20"></div>
          </div>
        </div>
      </div>

      {/* Form */}
      <div className="max-w-4xl mx-auto px-4 py-8">
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Success/Error Messages */}
          {success && (
            <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl">
              {success}
            </div>
          )}
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl">
              {error}
            </div>
          )}

          {/* Basic Information */}
          <div className="bg-white rounded-2xl p-6 shadow-soft">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Temel Bilgiler</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Ad *
                </label>
                <input
                  type="text"
                  name="first_name"
                  value={formData.first_name}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Soyad *
                </label>
                <input
                  type="text"
                  name="last_name"
                  value={formData.last_name}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Telefon
                </label>
                <input
                  type="tel"
                  name="phone"
                  value={formData.phone}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Avatar URL
                </label>
                <input
                  type="url"
                  name="avatar"
                  value={formData.avatar}
                  onChange={handleChange}
                  placeholder="https://example.com/avatar.jpg"
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
            </div>
          </div>

          {/* Customer Specific Fields */}
          {user?.user_type === 'customer' && (
            <div className="bg-white rounded-2xl p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-gray-900 mb-6">Adres Bilgileri</h2>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Adres
                  </label>
                  <textarea
                    name="address"
                    value={formData.address}
                    onChange={handleChange}
                    rows={3}
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Şehir
                    </label>
                    <input
                      type="text"
                      name="city"
                      value={formData.city}
                      onChange={handleChange}
                      className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
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
                      onChange={handleChange}
                      className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Craftsman Specific Fields */}
          {user?.user_type === 'craftsman' && (
            <>
              <div className="bg-white rounded-2xl p-6 shadow-soft">
                <h2 className="text-xl font-semibold text-gray-900 mb-6">İşletme Bilgileri</h2>
                
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      İşletme Adı *
                    </label>
                    <input
                      type="text"
                      name="business_name"
                      value={formData.business_name}
                      onChange={handleChange}
                      required
                      className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Açıklama
                    </label>
                    <textarea
                      name="description"
                      value={formData.description}
                      onChange={handleChange}
                      rows={4}
                      placeholder="Hizmetleriniz hakkında detaylı bilgi verin..."
                      className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Saatlik Ücret (₺)
                      </label>
                      <input
                        type="number"
                        name="hourly_rate"
                        value={formData.hourly_rate}
                        onChange={handleChange}
                        min="0"
                        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
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
                        onChange={handleChange}
                        min="0"
                        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Yanıt Süresi
                      </label>
                      <input
                        type="text"
                        name="response_time"
                        value={formData.response_time}
                        onChange={handleChange}
                        placeholder="2 saat"
                        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Website
                    </label>
                    <input
                      type="url"
                      name="website"
                      value={formData.website}
                      onChange={handleChange}
                      placeholder="https://example.com"
                      className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>

                  <div className="flex items-center">
                    <input
                      type="checkbox"
                      name="is_available"
                      checked={formData.is_available}
                      onChange={handleChange}
                      className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                    />
                    <label className="ml-2 block text-sm text-gray-700">
                      Müsait
                    </label>
                  </div>
                </div>
              </div>

              {/* Skills */}
              <div className="bg-white rounded-2xl p-6 shadow-soft">
                <h2 className="text-xl font-semibold text-gray-900 mb-6">Yetenekler</h2>
                
                <div className="space-y-4">
                  {formData.skills.map((skill, index) => (
                    <div key={index} className="flex items-center space-x-2">
                      <input
                        type="text"
                        value={skill}
                        onChange={(e) => handleSkillChange(index, e.target.value)}
                        placeholder="Yetenek adı"
                        className="flex-1 px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                      <button
                        type="button"
                        onClick={() => removeSkill(index)}
                        className="px-3 py-3 text-red-600 hover:text-red-800"
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </button>
                    </div>
                  ))}
                  
                  <button
                    type="button"
                    onClick={addSkill}
                    className="w-full px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl text-gray-600 hover:border-gray-400 hover:text-gray-700 transition-colors"
                  >
                    + Yetenek Ekle
                  </button>
                </div>
              </div>

              {/* Certifications */}
              <div className="bg-white rounded-2xl p-6 shadow-soft">
                <h2 className="text-xl font-semibold text-gray-900 mb-6">Sertifikalar</h2>
                
                <div className="space-y-4">
                  {formData.certifications.map((certification, index) => (
                    <div key={index} className="flex items-center space-x-2">
                      <input
                        type="text"
                        value={certification}
                        onChange={(e) => handleCertificationChange(index, e.target.value)}
                        placeholder="Sertifika adı"
                        className="flex-1 px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                      <button
                        type="button"
                        onClick={() => removeCertification(index)}
                        className="px-3 py-3 text-red-600 hover:text-red-800"
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </button>
                    </div>
                  ))}
                  
                  <button
                    type="button"
                    onClick={addCertification}
                    className="w-full px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl text-gray-600 hover:border-gray-400 hover:text-gray-700 transition-colors"
                  >
                    + Sertifika Ekle
                  </button>
                </div>
              </div>

              {/* Service Areas */}
              <div className="bg-white rounded-2xl p-6 shadow-soft">
                <h2 className="text-xl font-semibold text-gray-900 mb-6">Hizmet Bölgeleri</h2>
                
                <div className="space-y-4">
                  {formData.service_areas.map((area, index) => (
                    <div key={index} className="flex items-center space-x-2">
                      <input
                        type="text"
                        value={area}
                        onChange={(e) => handleServiceAreaChange(index, e.target.value)}
                        placeholder="İlçe adı"
                        className="flex-1 px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                      <button
                        type="button"
                        onClick={() => removeServiceArea(index)}
                        className="px-3 py-3 text-red-600 hover:text-red-800"
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </button>
                    </div>
                  ))}
                  
                  <button
                    type="button"
                    onClick={addServiceArea}
                    className="w-full px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl text-gray-600 hover:border-gray-400 hover:text-gray-700 transition-colors"
                  >
                    + Hizmet Bölgesi Ekle
                  </button>
                </div>
              </div>
            </>
          )}

          {/* Submit Button */}
          <div className="flex justify-end space-x-4">
            <button
              type="button"
              onClick={() => navigate(-1)}
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors"
            >
              İptal
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="px-6 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? 'Kaydediliyor...' : 'Kaydet'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default ProfileEditPage;