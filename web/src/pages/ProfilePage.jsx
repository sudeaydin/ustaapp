import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const ProfilePage = () => {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const [loading, setLoading] = useState(false);
  const [profile, setProfile] = useState(null);
  const [editing, setEditing] = useState(false);
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    phone: '',
    address: '',
    business_name: '',
    description: '',
    city: '',
    district: '',
    hourly_rate: '',
    is_available: true
  });
  const [passwordData, setPasswordData] = useState({
    current_password: '',
    new_password: '',
    confirm_password: ''
  });
  const [showPasswordForm, setShowPasswordForm] = useState(false);

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('authToken');
      const response = await fetch('/api/profile/', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      const data = await response.json();
      if (data.success) {
        setProfile(data.data);
        setFormData({
          first_name: data.data.first_name || '',
          last_name: data.data.last_name || '',
          phone: data.data.phone || '',
          address: data.data.profile?.address || '',
          business_name: data.data.profile?.business_name || '',
          description: data.data.profile?.description || '',
          city: data.data.profile?.city || '',
          district: data.data.profile?.district || '',
          hourly_rate: data.data.profile?.hourly_rate || '',
          is_available: data.data.profile?.is_available ?? true
        });
      }
    } catch (error) {
      console.error('Profile fetch error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdate = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('authToken');
      const response = await fetch('/api/profile/', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(formData)
      });
      
      const data = await response.json();
      if (data.success) {
        setEditing(false);
        fetchProfile();
        alert('Profil güncellendi!');
      } else {
        alert(data.message || 'Güncelleme başarısız');
      }
    } catch (error) {
      alert('Bir hata oluştu');
    } finally {
      setLoading(false);
    }
  };

  const handlePasswordChange = async () => {
    if (passwordData.new_password !== passwordData.confirm_password) {
      alert('Yeni şifreler eşleşmiyor');
      return;
    }

    try {
      setLoading(true);
      const token = localStorage.getItem('authToken');
      const response = await fetch('/api/profile/password', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          current_password: passwordData.current_password,
          new_password: passwordData.new_password
        })
      });
      
      const data = await response.json();
      if (data.success) {
        setShowPasswordForm(false);
        setPasswordData({ current_password: '', new_password: '', confirm_password: '' });
        alert('Şifre güncellendi!');
      } else {
        alert(data.message || 'Şifre güncelleme başarısız');
      }
    } catch (error) {
      alert('Bir hata oluştu');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handlePasswordChange_Input = (e) => {
    const { name, value } = e.target;
    setPasswordData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  if (loading && !profile) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <button 
              onClick={() => navigate(-1)}
              className="p-2 hover:bg-gray-100 rounded-full"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h1 className="text-xl font-semibold text-gray-900">Profil</h1>
            <button 
              onClick={() => setEditing(!editing)}
              className="text-blue-600 font-medium"
            >
              {editing ? 'İptal' : 'Düzenle'}
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-md mx-auto px-4 py-6">
        {/* Profile Photo */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-4">
          <div className="flex items-center space-x-4">
            <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center">
              <svg className="w-10 h-10 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
              </svg>
            </div>
            <div className="flex-1">
              <h2 className="text-xl font-semibold text-gray-900">
                {profile?.first_name} {profile?.last_name}
              </h2>
              <p className="text-gray-600">{profile?.email}</p>
              <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium ${
                profile?.user_type === 'craftsman' 
                  ? 'bg-blue-100 text-blue-800' 
                  : 'bg-green-100 text-green-800'
              }`}>
                {profile?.user_type === 'craftsman' ? 'Usta' : 'Müşteri'}
              </span>
            </div>
          </div>
        </div>

        {/* Profile Form */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-4">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Kişisel Bilgiler</h3>
          
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Ad</label>
                <input
                  type="text"
                  name="first_name"
                  value={formData.first_name}
                  onChange={handleChange}
                  disabled={!editing}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Soyad</label>
                <input
                  type="text"
                  name="last_name"
                  value={formData.last_name}
                  onChange={handleChange}
                  disabled={!editing}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Telefon</label>
              <input
                type="tel"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                disabled={!editing}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
              />
            </div>

            {profile?.user_type === 'customer' && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Adres</label>
                <textarea
                  name="address"
                  value={formData.address}
                  onChange={handleChange}
                  disabled={!editing}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
                />
              </div>
            )}

            {profile?.user_type === 'craftsman' && (
              <>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">İşletme Adı</label>
                  <input
                    type="text"
                    name="business_name"
                    value={formData.business_name}
                    onChange={handleChange}
                    disabled={!editing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Açıklama</label>
                  <textarea
                    name="description"
                    value={formData.description}
                    onChange={handleChange}
                    disabled={!editing}
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Şehir</label>
                    <input
                      type="text"
                      name="city"
                      value={formData.city}
                      onChange={handleChange}
                      disabled={!editing}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">İlçe</label>
                    <input
                      type="text"
                      name="district"
                      value={formData.district}
                      onChange={handleChange}
                      disabled={!editing}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Saatlik Ücret (₺)</label>
                  <input
                    type="number"
                    name="hourly_rate"
                    value={formData.hourly_rate}
                    onChange={handleChange}
                    disabled={!editing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
                  />
                </div>

                <div className="flex items-center">
                  <input
                    type="checkbox"
                    name="is_available"
                    checked={formData.is_available}
                    onChange={handleChange}
                    disabled={!editing}
                    className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded disabled:opacity-50"
                  />
                  <label className="ml-2 block text-sm text-gray-900">Müsaitim</label>
                </div>
              </>
            )}

            {editing && (
              <div className="flex space-x-3 pt-4">
                <button
                  onClick={handleUpdate}
                  disabled={loading}
                  className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50"
                >
                  {loading ? 'Güncelleniyor...' : 'Güncelle'}
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Password Change */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Şifre</h3>
            <button
              onClick={() => setShowPasswordForm(!showPasswordForm)}
              className="text-blue-600 font-medium"
            >
              {showPasswordForm ? 'İptal' : 'Şifre Değiştir'}
            </button>
          </div>

          {showPasswordForm && (
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Mevcut Şifre</label>
                <input
                  type="password"
                  name="current_password"
                  value={passwordData.current_password}
                  onChange={handlePasswordChange_Input}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Yeni Şifre</label>
                <input
                  type="password"
                  name="new_password"
                  value={passwordData.new_password}
                  onChange={handlePasswordChange_Input}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Yeni Şifre Tekrar</label>
                <input
                  type="password"
                  name="confirm_password"
                  value={passwordData.confirm_password}
                  onChange={handlePasswordChange_Input}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <button
                onClick={handlePasswordChange}
                disabled={loading}
                className="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:opacity-50"
              >
                {loading ? 'Güncelleniyor...' : 'Şifre Güncelle'}
              </button>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="space-y-3">
            <button
              onClick={() => navigate('/settings')}
              className="w-full text-left px-4 py-3 rounded-md hover:bg-gray-50 flex items-center justify-between"
            >
              <span className="text-gray-900">Ayarlar</span>
              <svg className="w-5 h-5 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
              </svg>
            </button>
            
            <button
              onClick={logout}
              className="w-full text-left px-4 py-3 rounded-md hover:bg-red-50 text-red-600 font-medium"
            >
              Çıkış Yap
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};