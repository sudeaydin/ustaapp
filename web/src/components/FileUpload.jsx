import React, { useState, useRef } from 'react';
import { uploadService } from '../services/uploadService';

export const FileUpload = ({ 
  type = 'project', // 'profile' or 'project'
  multiple = false,
  onUploadSuccess,
  onUploadError,
  className = '',
  children
}) => {
  const [uploading, setUploading] = useState(false);
  const [dragOver, setDragOver] = useState(false);
  const fileInputRef = useRef(null);

  const handleFileSelect = (files) => {
    const fileArray = Array.from(files);
    
    // Validate files
    for (const file of fileArray) {
      const validation = uploadService.validateFile(file);
      if (!validation.valid) {
        onUploadError?.(validation.error);
        return;
      }
    }

    uploadFiles(fileArray);
  };

  const uploadFiles = async (files) => {
    setUploading(true);
    
    try {
      let response;
      
      if (multiple && files.length > 1) {
        response = await uploadService.uploadMultipleImages(files, type);
      } else {
        const uploadFunction = type === 'profile' 
          ? uploadService.uploadProfileImage 
          : uploadService.uploadProjectImage;
        response = await uploadFunction(files[0]);
      }
      
      if (response.success) {
        onUploadSuccess?.(response.data);
      } else {
        onUploadError?.(response.message || 'Upload failed');
      }
    } catch (error) {
      onUploadError?.(error.message || 'Upload failed');
    } finally {
      setUploading(false);
    }
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDragLeave = (e) => {
    e.preventDefault();
    setDragOver(false);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setDragOver(false);
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
      handleFileSelect(files);
    }
  };

  const handleInputChange = (e) => {
    const files = e.target.files;
    if (files.length > 0) {
      handleFileSelect(files);
    }
  };

  const openFileDialog = () => {
    fileInputRef.current?.click();
  };

  return (
    <div className={`relative ${className}`}>
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        multiple={multiple}
        onChange={handleInputChange}
        className="hidden"
      />
      
      <div
        onClick={openFileDialog}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        className={`
          border-2 border-dashed rounded-lg p-6 text-center cursor-pointer transition-colors
          ${dragOver 
            ? 'border-blue-500 bg-blue-50' 
            : 'border-gray-300 hover:border-gray-400'
          }
          ${uploading ? 'opacity-50 cursor-not-allowed' : ''}
        `}
      >
        {uploading ? (
          <div className="flex flex-col items-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mb-2"></div>
            <p className="text-sm text-gray-600">Yükleniyor...</p>
          </div>
        ) : (
          children || (
            <div className="flex flex-col items-center">
              <svg className="w-12 h-12 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
              <p className="text-sm text-gray-600 mb-2">
                {multiple ? 'Dosyaları buraya sürükleyin' : 'Dosyayı buraya sürükleyin'}
              </p>
              <p className="text-xs text-gray-500">
                veya <span className="text-blue-500 underline">seçmek için tıklayın</span>
              </p>
              <p className="text-xs text-gray-400 mt-2">
                PNG, JPG, JPEG, GIF, WEBP (Max 5MB)
              </p>
            </div>
          )
        )}
      </div>
    </div>
  );
};

export default FileUpload;