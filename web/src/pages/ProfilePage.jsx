import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import DeleteAccountModal from '../components/DeleteAccountModal';

export const ProfilePage = () => {
  const navigate = useNavigate();
  const { userId } = useParams();
  const { user } = useAuth();
  
  const [profileData, setProfileData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isEditing, setIsEditing] = useState(false);
  const [editForm, setEditForm] = useState({});
  const [activeTab, setActiveTab] = useState('info');
  const [showAvatarUpload, setShowAvatarUpload] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);

  // Determine if viewing own profile or someone else's
  const isOwnProfile = !userId || userId === user?.id?.toString();

  useEffect(() => {
    loadProfile();
  }, [userId]);

  const loadProfile = async () => {
    try {
      setLoading(true);
      
      // Mock profile data - in real app, fetch from API
      const mockProfile = isOwnProfile ? user : {
        id: parseInt(userId),
        name: 'Ahmet Yılmaz',
        email: 'ahmet@yilmazelektrik.com',
        user_type: 'craftsman',
        business_name: 'Yılmaz Elektrik',
        phone: '+90 555 987 6543',
        city: 'İstanbul',
        district: 'Üsküdar',
        description: '8 yıllık deneyimim ile profesyonel elektrik hizmetleri sunuyorum. LED aydınlatma, klima montajı ve tüm elektrik tesisatı işleriniz için güvenilir çözümler.',
        experience_years: 8,
        hourly_rate: 150,
        skills: ['Elektrik Tesisatı', 'LED Aydınlatma', 'Klima Montajı'],
        rating: 4.8,
        total_jobs: 156,
        join_date: '2022-03-15',
        business_logo: null, // No logo yet, pending approval
        business_logo_status: 'pending', // pending, approved, rejected
        working_hours: {
          monday: '09:00-18:00',
          tuesday: '09:00-18:00',
          wednesday: '09:00-18:00',
          thursday: '09:00-18:00',
          friday: '09:00-18:00',
          saturday: '09:00-15:00',
          sunday: 'Kapalı'
        },
        portfolio: [
          {
            id: 1,
            title: 'LED Aydınlatma Projesi',
            description: 'Modern villa LED aydınlatma sistemi kurulumu',
            images: ['project1.jpg', 'project2.jpg'],
            date: '2025-01-15',
            category: 'LED Aydınlatma'
          },
          {
            id: 2,
            title: 'Klima Montajı',
            description: 'Split klima montajı ve bakım hizmeti',
            images: ['project3.jpg'],
            date: '2025-01-10',
            category: 'Klima'
          }
        ],
        certifications: [
          'Elektrik Tesisatı Yeterlilik Belgesi',
          'LED Aydınlatma Uzmanı Sertifikası',
          'Akıllı Ev Sistemleri Eğitimi'
        ]
      };
      
      setProfileData(mockProfile);
      setEditForm(mockProfile);
    } catch (error) {
      console.error('Error loading profile:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleEditToggle = () => {
    if (isEditing) {
      // Save changes
      handleSaveProfile();
    } else {
      setIsEditing(true);
    }
  };

  const handleSaveProfile = async () => {
    try {
      // In real app, send to API
      console.log('Saving profile:', editForm);
      
      setProfileData(editForm);
      setIsEditing(false);
      
      alert('✅ Profil güncellendi!');
    } catch (error) {
      console.error('Error saving profile:', error);
      alert('❌ Profil güncellenirken hata oluştu!');
    }
  };

  const handleInputChange = (field, value) => {
    setEditForm(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleBusinessLogoUpload = async (file) => {
    try {
      // In real app, upload to server and wait for admin approval
      console.log('Uploading business logo:', file);
      
      setEditForm(prev => ({
        ...prev,
        business_logo_status: 'pending'
      }));
      
      alert('📤 İşletme logosu yüklendi! Yönetim onayı bekleniyor.');
      setShowAvatarUpload(false);
    } catch (error) {
      console.error('Error uploading logo:', error);
      alert('❌ Logo yüklenirken hata oluştu!');
    }
  };

  const getInitials = (name) => {
    return name
      .split(' ')
      .map(word => word.charAt(0))
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const getBusinessLogoStatus = () => {
    switch (profileData?.business_logo_status) {
      case 'pending':
        return {
          text: 'Onay Bekliyor',
          color: 'bg-yellow-100 text-yellow-800',
          icon: '⏳'
        };
      case 'approved':
        return {
          text: 'Onaylandı',
          color: 'bg-green-100 text-green-800',
          icon: '✅'
        };
      case 'rejected':
        return {
          text: 'Reddedildi',
          color: 'bg-red-100 text-red-800',
          icon: '❌'
        };
      default:
        return null;
    }
  };

  const renderInfoTab = () => (
    <div className="space-y-6">
      {/* Basic Info */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">👤 Temel Bilgiler</h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Ad Soyad
            </label>
            {isEditing ? (
              <input
                type="text"
                value={editForm.name || ''}
                onChange={(e) => handleInputChange('name', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            ) : (
              <p className="text-gray-900">{profileData?.name}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              E-posta
            </label>
            <p className="text-gray-900">{profileData?.email}</p>
            <p className="text-xs text-gray-500 mt-1">E-posta değiştirilemez</p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Telefon
            </label>
            {isEditing ? (
              <input
                type="tel"
                value={editForm.phone || ''}
                onChange={(e) => handleInputChange('phone', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            ) : (
              <p className="text-gray-900">{profileData?.phone}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Konum
            </label>
            {isEditing ? (
              <div className="grid grid-cols-2 gap-2">
                <input
                  type="text"
                  value={editForm.city || ''}
                  onChange={(e) => handleInputChange('city', e.target.value)}
                  placeholder="Şehir"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
                <input
                  type="text"
                  value={editForm.district || ''}
                  onChange={(e) => handleInputChange('district', e.target.value)}
                  placeholder="İlçe"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            ) : (
              <p className="text-gray-900">{profileData?.city}, {profileData?.district}</p>
            )}
          </div>
        </div>
      </div>

      {/* Business Info (for craftsmen) */}
      {profileData?.user_type === 'craftsman' && (
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">🏢 İşletme Bilgileri</h3>
          
          <div className="space-y-4">
            {/* Business Logo */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                İşletme Logosu
              </label>
              <div className="flex items-center space-x-4">
                <div className="w-16 h-16 bg-gray-200 rounded-lg flex items-center justify-center">
                  {profileData?.business_logo ? (
                    <img
                      src={profileData.business_logo}
                      alt="İşletme Logosu"
                      className="w-full h-full object-cover rounded-lg"
                    />
                  ) : (
                    <span className="text-gray-400 text-xs text-center">Logo Yok</span>
                  )}
                </div>
                
                <div className="flex-1">
                  {isOwnProfile && (
                    <button
                      onClick={() => setShowAvatarUpload(true)}
                      className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
                    >
                      📤 Logo Yükle
                    </button>
                  )}
                  
                  {profileData?.business_logo_status && (
                    <div className="mt-2">
                      <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${getBusinessLogoStatus()?.color}`}>
                        {getBusinessLogoStatus()?.icon} {getBusinessLogoStatus()?.text}
                      </span>
                      {profileData.business_logo_status === 'pending' && (
                        <p className="text-xs text-gray-500 mt-1">
                          Logonuz yönetim onayı bekliyor. Onaylandıktan sonra görünür olacak.
                        </p>
                      )}
                    </div>
                  )}
                </div>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                İşletme Adı
              </label>
              {isEditing ? (
                <input
                  type="text"
                  value={editForm.business_name || ''}
                  onChange={(e) => handleInputChange('business_name', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              ) : (
                <p className="text-gray-900">{profileData?.business_name}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Açıklama
              </label>
              {isEditing ? (
                <textarea
                  value={editForm.description || ''}
                  onChange={(e) => handleInputChange('description', e.target.value)}
                  rows={4}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              ) : (
                <p className="text-gray-700">{profileData?.description}</p>
              )}
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Deneyim (Yıl)
                </label>
                {isEditing ? (
                  <input
                    type="number"
                    value={editForm.experience_years || ''}
                    onChange={(e) => handleInputChange('experience_years', parseInt(e.target.value))}
                    min="0"
                    max="50"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                ) : (
                  <p className="text-gray-900">{profileData?.experience_years} yıl</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Saatlik Ücret
                </label>
                {isEditing ? (
                  <input
                    type="number"
                    value={editForm.hourly_rate || ''}
                    onChange={(e) => handleInputChange('hourly_rate', parseInt(e.target.value))}
                    min="0"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                ) : (
                  <p className="text-gray-900">{profileData?.hourly_rate}₺/saat</p>
                )}
              </div>
            </div>

            {/* Skills */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Yetenekler
              </label>
              <div className="flex flex-wrap gap-2">
                {profileData?.skills?.map((skill, index) => (
                  <span
                    key={index}
                    className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium"
                  >
                    {skill}
                  </span>
                ))}
              </div>
            </div>

            {/* Certifications */}
            {profileData?.certifications && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Sertifikalar
                </label>
                <ul className="space-y-1">
                  {profileData.certifications.map((cert, index) => (
                    <li key={index} className="flex items-center text-sm text-gray-700">
                      <svg className="w-4 h-4 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      {cert}
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );

  const renderPortfolioTab = () => (
    <div className="space-y-6">
      {profileData?.portfolio?.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {profileData.portfolio.map((project) => (
            <div key={project.id} className="bg-white rounded-lg shadow-sm overflow-hidden">
              <div className="aspect-video bg-gray-200 flex items-center justify-center">
                <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              
              <div className="p-4">
                <div className="flex items-center justify-between mb-2">
                  <h4 className="font-medium text-gray-900">{project.title}</h4>
                  <span className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full">
                    {project.category}
                  </span>
                </div>
                <p className="text-sm text-gray-600 mb-3">{project.description}</p>
                <p className="text-xs text-gray-500">
                  {new Date(project.date).toLocaleDateString('tr-TR')}
                </p>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-12">
          <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">Henüz portföy yok</h3>
          <p className="text-gray-600">
            {isOwnProfile 
              ? 'Yaptığınız işlerin fotoğraflarını ekleyerek portföyünüzü oluşturun.'
              : 'Bu kullanıcının henüz portföyü bulunmuyor.'
            }
          </p>
          {isOwnProfile && (
            <button className="mt-4 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors">
              📷 İlk Projeyi Ekle
            </button>
          )}
        </div>
      )}
    </div>
  );

  const renderStatsTab = () => (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div className="bg-white rounded-lg shadow-sm p-6 text-center">
        <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
          </svg>
        </div>
        <h3 className="text-2xl font-bold text-gray-900">{profileData?.total_jobs || 0}</h3>
        <p className="text-gray-600">Tamamlanan İş</p>
      </div>

      <div className="bg-white rounded-lg shadow-sm p-6 text-center">
        <div className="w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <svg className="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
          </svg>
        </div>
        <h3 className="text-2xl font-bold text-gray-900">{profileData?.rating || 0}</h3>
        <p className="text-gray-600">Ortalama Puan</p>
      </div>

      <div className="bg-white rounded-lg shadow-sm p-6 text-center">
        <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
        </div>
        <h3 className="text-2xl font-bold text-gray-900">
          {profileData?.join_date ? 
            Math.floor((new Date() - new Date(profileData.join_date)) / (365.25 * 24 * 60 * 60 * 1000)) 
            : 0
          }
        </h3>
        <p className="text-gray-600">Yıl Deneyim</p>
      </div>
    </div>
  );

  const renderSettingsTab = () => (
    <div className="space-y-6">
      {/* Account Settings */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">🔐 Hesap Ayarları</h3>
        
        <div className="space-y-4">
          <div className="border-b border-gray-200 pb-4">
            <h4 className="font-medium text-gray-700 mb-2">Şifre Değiştir</h4>
            <p className="text-sm text-gray-600 mb-3">Hesabınızın güvenliği için düzenli olarak şifrenizi değiştirin</p>
            <button
              onClick={() => navigate('/profile/change-password')}
              className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
            >
              Şifre Değiştir
            </button>
          </div>
          
          <div className="border-b border-gray-200 pb-4">
            <h4 className="font-medium text-gray-700 mb-2">Bildirim Ayarları</h4>
            <p className="text-sm text-gray-600 mb-3">E-posta ve push bildirim tercihlerinizi yönetin</p>
            <button
              onClick={() => navigate('/profile/notifications')}
              className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
            >
              Bildirim Ayarları
            </button>
          </div>
          
          <div className="border-b border-gray-200 pb-4">
            <h4 className="font-medium text-gray-700 mb-2">Gizlilik Ayarları</h4>
            <p className="text-sm text-gray-600 mb-3">Profil görünürlüğü ve gizlilik tercihlerinizi ayarlayın</p>
            <button
              onClick={() => navigate('/profile/privacy')}
              className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
            >
              Gizlilik Ayarları
            </button>
          </div>
        </div>
      </div>

      {/* Danger Zone */}
      <div className="bg-red-50 border border-red-200 rounded-lg p-6">
        <h3 className="text-lg font-medium text-red-800 mb-4">⚠️ Tehlikeli Bölge</h3>
        
        <div className="space-y-4">
          <div>
            <h4 className="font-medium text-red-700 mb-2">Hesabımı Sil</h4>
            <p className="text-sm text-red-600 mb-4">
              Hesabınızı kalıcı olarak silmek istiyorsanız bu butonu kullanabilirsiniz. 
              <strong> Bu işlem geri alınamaz</strong> ve tüm verileriniz KVKK gereği sistemden tamamen kaldırılacaktır.
            </p>
            <button
              onClick={() => setShowDeleteModal(true)}
              className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors font-medium"
            >
              🗑️ Hesabımı Sil
            </button>
          </div>
        </div>
      </div>
    </div>
  );

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

  if (!profileData) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Profil Bulunamadı</h2>
          <p className="text-gray-600 mb-6">Aradığınız profil bulunamadı.</p>
          <button
            onClick={() => navigate(-1)}
            className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            Geri Dön
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 py-4">
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
              <h1 className="text-2xl font-bold text-gray-900">
                {isOwnProfile ? '👤 Profilim' : `👤 ${profileData.name}`}
              </h1>
            </div>

            {isOwnProfile && (
              <button
                onClick={handleEditToggle}
                className={`px-6 py-2 rounded-lg font-medium transition-colors ${
                  isEditing
                    ? 'bg-green-500 text-white hover:bg-green-600'
                    : 'bg-blue-500 text-white hover:bg-blue-600'
                }`}
              >
                {isEditing ? '💾 Kaydet' : '✏️ Düzenle'}
              </button>
            )}
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          {/* Profile Sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow-sm p-6 text-center">
              {/* User Avatar (Name Initials) */}
              <div className="w-24 h-24 bg-blue-500 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-white">
                  {getInitials(profileData.name)}
                </span>
              </div>
              
              <h2 className="text-xl font-bold text-gray-900 mb-1">{profileData.name}</h2>
              
              {profileData.user_type === 'craftsman' && (
                <p className="text-blue-600 font-medium mb-2">{profileData.business_name}</p>
              )}
              
              <p className="text-gray-600 text-sm mb-4">{profileData.city}, {profileData.district}</p>
              
              {profileData.user_type === 'craftsman' && (
                <div className="flex items-center justify-center space-x-4 text-sm text-gray-600 mb-4">
                  <div className="flex items-center">
                    <svg className="w-4 h-4 text-yellow-500 mr-1" fill="currentColor" viewBox="0 0 20 20">
                      <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                    </svg>
                    <span>{profileData.rating}</span>
                  </div>
                  <div>
                    <span>{profileData.total_jobs} iş</span>
                  </div>
                </div>
              )}
              
              <div className="space-y-2">
                {!isOwnProfile && (
                  <>
                    <button
                      onClick={() => navigate(`/messages/${profileData.id}`)}
                      className="w-full px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                    >
                      💬 Mesaj Gönder
                    </button>
                    {profileData.user_type === 'craftsman' && (
                      <button
                        onClick={() => navigate(`/job-request?craftsman=${profileData.id}`)}
                        className="w-full px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
                      >
                        📋 İş Talebi Oluştur
                      </button>
                    )}
                  </>
                )}
              </div>
            </div>
          </div>

          {/* Profile Content */}
          <div className="lg:col-span-3">
            {/* Tabs */}
            <div className="bg-white rounded-lg shadow-sm mb-6">
              <div className="border-b border-gray-200">
                <nav className="flex space-x-8 px-6">
                  <button
                    onClick={() => setActiveTab('info')}
                    className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                      activeTab === 'info'
                        ? 'border-blue-500 text-blue-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                    }`}
                  >
                    📋 Bilgiler
                  </button>
                  {profileData.user_type === 'craftsman' && (
                    <>
                      <button
                        onClick={() => setActiveTab('portfolio')}
                        className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                          activeTab === 'portfolio'
                            ? 'border-blue-500 text-blue-600'
                            : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                        }`}
                      >
                        📷 Portföy
                      </button>
                      <button
                        onClick={() => setActiveTab('stats')}
                        className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                          activeTab === 'stats'
                            ? 'border-blue-500 text-blue-600'
                            : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                        }`}
                      >
                        📊 İstatistikler
                      </button>
                    </>
                  )}
                  {isOwnProfile && (
                    <button
                      onClick={() => setActiveTab('settings')}
                      className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                        activeTab === 'settings'
                          ? 'border-blue-500 text-blue-600'
                          : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                      }`}
                    >
                      ⚙️ Ayarlar
                    </button>
                  )}
                </nav>
              </div>

              <div className="p-6">
                {activeTab === 'info' && renderInfoTab()}
                {activeTab === 'portfolio' && renderPortfolioTab()}
                {activeTab === 'stats' && renderStatsTab()}
                {activeTab === 'settings' && renderSettingsTab()}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Business Logo Upload Modal */}
      {showAvatarUpload && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">🏢 İşletme Logosu Yükle</h3>
              <button
                onClick={() => setShowAvatarUpload(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
              <svg className="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
              <p className="text-gray-600 mb-4">İşletme logonuzu seçin</p>
              <input
                type="file"
                accept="image/*"
                onChange={(e) => {
                  if (e.target.files[0]) {
                    handleBusinessLogoUpload(e.target.files[0]);
                  }
                }}
                className="hidden"
                id="logo-upload"
              />
              <label
                htmlFor="logo-upload"
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors cursor-pointer"
              >
                📁 Dosya Seç
              </label>
            </div>

            <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p className="text-yellow-800 text-sm">
                ⚠️ <strong>Önemli:</strong> Yüklediğiniz logo yönetim onayından geçecektir. 
                Onaylandıktan sonra profilinizde görünür olacak.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Delete Account Modal */}
      <DeleteAccountModal 
        isOpen={showDeleteModal} 
        onClose={() => setShowDeleteModal(false)} 
      />
    </div>
  );
};

export default ProfilePage;