import api from './api';

export const profileService = {
  // Get user profile
  getProfile: async () => {
    try {
      const response = await api.get('/profile');
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Update user profile
  updateProfile: async (profileData) => {
    try {
      const response = await api.put('/profile', profileData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Change password
  changePassword: async (passwordData) => {
    try {
      const response = await api.put('/profile/password', passwordData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Update profile avatar
  updateAvatar: async (imageUrl) => {
    try {
      const response = await api.put('/profile/avatar', {
        profile_image: imageUrl
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Update skills
  updateSkills: async (skills) => {
    try {
      const response = await api.put('/profile/skills', {
        skills: skills
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Update availability status
  updateAvailability: async (isAvailable) => {
    try {
      const response = await api.put('/profile/availability', {
        is_available: isAvailable
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Validate profile data
  validateProfileData: (data) => {
    const errors = {};

    if (!data.first_name || data.first_name.trim().length < 2) {
      errors.first_name = 'Ad en az 2 karakter olmalıdır';
    }

    if (!data.last_name || data.last_name.trim().length < 2) {
      errors.last_name = 'Soyad en az 2 karakter olmalıdır';
    }

    if (!data.email || !/\S+@\S+\.\S+/.test(data.email)) {
      errors.email = 'Geçerli bir email adresi girin';
    }

    if (!data.phone || !/^[\+]?[0-9\s\-\(\)]{10,}$/.test(data.phone)) {
      errors.phone = 'Geçerli bir telefon numarası girin';
    }

    if (data.user_type === 'craftsman') {
      if (!data.business_name || data.business_name.trim().length < 2) {
        errors.business_name = 'İşletme adı en az 2 karakter olmalıdır';
      }

      if (!data.category || data.category.trim().length < 2) {
        errors.category = 'Kategori seçimi zorunludur';
      }

      if (!data.description || data.description.trim().length < 10) {
        errors.description = 'Açıklama en az 10 karakter olmalıdır';
      }

      if (data.hourly_rate && (isNaN(data.hourly_rate) || data.hourly_rate < 0)) {
        errors.hourly_rate = 'Saatlik ücret geçerli bir sayı olmalıdır';
      }

      if (data.experience_years && (isNaN(data.experience_years) || data.experience_years < 0)) {
        errors.experience_years = 'Deneyim yılı geçerli bir sayı olmalıdır';
      }
    }

    return {
      isValid: Object.keys(errors).length === 0,
      errors
    };
  },

  // Validate password data
  validatePasswordData: (data) => {
    const errors = {};

    if (!data.current_password) {
      errors.current_password = 'Mevcut şifre gereklidir';
    }

    if (!data.new_password) {
      errors.new_password = 'Yeni şifre gereklidir';
    } else if (data.new_password.length < 6) {
      errors.new_password = 'Yeni şifre en az 6 karakter olmalıdır';
    }

    if (!data.confirm_password) {
      errors.confirm_password = 'Şifre onayı gereklidir';
    } else if (data.new_password !== data.confirm_password) {
      errors.confirm_password = 'Şifreler eşleşmiyor';
    }

    return {
      isValid: Object.keys(errors).length === 0,
      errors
    };
  },

  // Format profile data for display
  formatProfileData: (profile) => {
    if (!profile) return null;

    return {
      ...profile,
      full_name: `${profile.first_name} ${profile.last_name}`.trim(),
      display_phone: profile.phone || 'Telefon eklenmemiş',
      display_address: profile.address || 'Adres eklenmemiş',
      display_location: [profile.city, profile.district].filter(Boolean).join(', ') || 'Konum eklenmemiş',
      display_rate: profile.hourly_rate ? `${profile.hourly_rate} ₺/saat` : 'Ücret belirtilmemiş',
      display_experience: profile.experience_years ? `${profile.experience_years} yıl` : 'Deneyim belirtilmemiş',
      availability_text: profile.is_available ? 'Müsait' : 'Müsait değil',
      availability_color: profile.is_available ? 'text-green-600' : 'text-red-600',
      skills_count: profile.skills ? profile.skills.length : 0,
      certifications_count: profile.certifications ? profile.certifications.length : 0,
      work_areas_count: profile.work_areas ? profile.work_areas.length : 0
    };
  }
};