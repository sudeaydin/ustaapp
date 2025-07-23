import React, { useState } from 'react';
import FileUpload from '../components/FileUpload';
import ProfileImageUpload from '../components/ProfileImageUpload';
import { uploadService } from '../services/uploadService';

export const TestUploadPage = () => {
  const [profileImage, setProfileImage] = useState(null);
  const [projectImages, setProjectImages] = useState([]);
  const [uploadResults, setUploadResults] = useState([]);

  const handleProfileUpload = (data) => {
    console.log('Profile upload success:', data);
    const imageUrl = uploadService.getImageUrl(data.filename, 'profile');
    setProfileImage(imageUrl);
    setUploadResults(prev => [...prev, {
      type: 'Profile Image',
      success: true,
      data: data,
      timestamp: new Date().toLocaleTimeString()
    }]);
  };

  const handleProfileError = (error) => {
    console.error('Profile upload error:', error);
    setUploadResults(prev => [...prev, {
      type: 'Profile Image',
      success: false,
      error: error,
      timestamp: new Date().toLocaleTimeString()
    }]);
  };

  const handleProjectUpload = (data) => {
    console.log('Project upload success:', data);
    
    if (data.uploaded_files) {
      // Multiple files
      const newImages = data.uploaded_files.map(file => 
        uploadService.getImageUrl(file.filename, 'project')
      );
      setProjectImages(prev => [...prev, ...newImages]);
      setUploadResults(prev => [...prev, {
        type: 'Project Images (Multiple)',
        success: true,
        data: data,
        timestamp: new Date().toLocaleTimeString()
      }]);
    } else {
      // Single file
      const imageUrl = uploadService.getImageUrl(data.filename, 'project');
      setProjectImages(prev => [...prev, imageUrl]);
      setUploadResults(prev => [...prev, {
        type: 'Project Image (Single)',
        success: true,
        data: data,
        timestamp: new Date().toLocaleTimeString()
      }]);
    }
  };

  const handleProjectError = (error) => {
    console.error('Project upload error:', error);
    setUploadResults(prev => [...prev, {
      type: 'Project Image',
      success: false,
      error: error,
      timestamp: new Date().toLocaleTimeString()
    }]);
  };

  const clearResults = () => {
    setUploadResults([]);
    setProjectImages([]);
    setProfileImage(null);
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4">
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <h1 className="text-2xl font-bold text-gray-800 mb-6">
            📸 File Upload Test Sayfası
          </h1>
          
          <div className="grid md:grid-cols-2 gap-8">
            {/* Profile Image Upload */}
            <div className="space-y-4">
              <h2 className="text-lg font-semibold text-gray-700">
                Profil Fotoğrafı Upload
              </h2>
              
              <div className="flex justify-center">
                <ProfileImageUpload
                  currentImage={profileImage}
                  onImageUpdate={handleProfileUpload}
                  size="large"
                />
              </div>
              
              <p className="text-sm text-gray-600 text-center">
                Profil fotoğrafınızı değiştirmek için kamera ikonuna tıklayın
              </p>
            </div>

            {/* Project Images Upload */}
            <div className="space-y-4">
              <h2 className="text-lg font-semibold text-gray-700">
                Proje Fotoğrafları Upload
              </h2>
              
              <FileUpload
                type="project"
                multiple={false}
                onUploadSuccess={handleProjectUpload}
                onUploadError={handleProjectError}
                className="mb-4"
              />
              
              <FileUpload
                type="project"
                multiple={true}
                onUploadSuccess={handleProjectUpload}
                onUploadError={handleProjectError}
              >
                <div className="flex flex-col items-center">
                  <svg className="w-12 h-12 text-green-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                  <p className="text-sm text-green-600 mb-2">
                    Çoklu dosya yükleme
                  </p>
                  <p className="text-xs text-gray-500">
                    Birden fazla dosya seçebilirsiniz
                  </p>
                </div>
              </FileUpload>
            </div>
          </div>
        </div>

        {/* Project Images Gallery */}
        {projectImages.length > 0 && (
          <div className="bg-white rounded-lg shadow-md p-6 mb-6">
            <h2 className="text-lg font-semibold text-gray-700 mb-4">
              📁 Yüklenen Proje Fotoğrafları ({projectImages.length})
            </h2>
            
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {projectImages.map((image, index) => (
                <div key={index} className="aspect-square rounded-lg overflow-hidden shadow-md">
                  <img 
                    src={image} 
                    alt={`Project ${index + 1}`}
                    className="w-full h-full object-cover hover:scale-105 transition-transform"
                  />
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Upload Results */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold text-gray-700">
              📊 Upload Sonuçları ({uploadResults.length})
            </h2>
            
            <button
              onClick={clearResults}
              className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
            >
              Temizle
            </button>
          </div>
          
          <div className="space-y-3 max-h-64 overflow-y-auto">
            {uploadResults.length === 0 ? (
              <p className="text-gray-500 text-center py-4">
                Henüz upload işlemi yapılmadı
              </p>
            ) : (
              uploadResults.map((result, index) => (
                <div 
                  key={index}
                  className={`p-3 rounded-lg border-l-4 ${
                    result.success 
                      ? 'bg-green-50 border-green-400' 
                      : 'bg-red-50 border-red-400'
                  }`}
                >
                  <div className="flex justify-between items-start">
                    <div>
                      <p className="font-medium text-gray-800">
                        {result.type}
                      </p>
                      {result.success ? (
                        <p className="text-sm text-green-600">
                          ✅ Başarıyla yüklendi
                        </p>
                      ) : (
                        <p className="text-sm text-red-600">
                          ❌ {result.error}
                        </p>
                      )}
                    </div>
                    <span className="text-xs text-gray-500">
                      {result.timestamp}
                    </span>
                  </div>
                  
                  {result.success && result.data && (
                    <details className="mt-2">
                      <summary className="text-xs text-gray-600 cursor-pointer">
                        Detayları göster
                      </summary>
                      <pre className="text-xs bg-gray-100 p-2 rounded mt-1 overflow-x-auto">
                        {JSON.stringify(result.data, null, 2)}
                      </pre>
                    </details>
                  )}
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default TestUploadPage;