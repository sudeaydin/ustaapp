import api from './api';

export const uploadService = {
  // Upload profile image
  uploadProfileImage: async (file) => {
    try {
      const formData = new FormData();
      formData.append('file', file);
      
      const response = await api.post('/upload/profile', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Upload project image
  uploadProjectImage: async (file) => {
    try {
      const formData = new FormData();
      formData.append('file', file);
      
      const response = await api.post('/upload/project', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Upload multiple images
  uploadMultipleImages: async (files, type = 'project') => {
    try {
      const formData = new FormData();
      
      // Add all files
      files.forEach((file) => {
        formData.append('files', file);
      });
      
      // Add type
      formData.append('type', type);
      
      const response = await api.post('/upload/multiple', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Validate file before upload
  validateFile: (file, maxSize = 5 * 1024 * 1024) => {
    const allowedTypes = ['image/png', 'image/jpg', 'image/jpeg', 'image/gif', 'image/webp'];
    
    if (!file) {
      return { valid: false, error: 'Dosya seçilmedi' };
    }
    
    if (!allowedTypes.includes(file.type)) {
      return { valid: false, error: 'Geçersiz dosya formatı. PNG, JPG, JPEG, GIF, WEBP desteklenir' };
    }
    
    if (file.size > maxSize) {
      return { valid: false, error: `Dosya boyutu ${maxSize / 1024 / 1024}MB'dan küçük olmalıdır` };
    }
    
    return { valid: true };
  },

  // Get image URL
  getImageUrl: (filename, type = 'project') => {
    if (!filename) return null;
    
    // If already a full URL, return as is
    if (filename.startsWith('http')) return filename;
    
    // If starts with /api, return as is
    if (filename.startsWith('/api')) return `http://localhost:5001${filename}`;
    
    // Otherwise construct URL
    return `http://localhost:5001/api/uploads/${type}s/${filename}`;
  }
};