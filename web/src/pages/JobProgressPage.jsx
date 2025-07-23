import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const JobProgressPage = () => {
  const navigate = useNavigate();
  const { jobId } = useParams();
  const { user } = useAuth();
  
  const [loading, setLoading] = useState(true);
  const [job, setJob] = useState(null);
  const [progressUpdates, setProgressUpdates] = useState([]);
  const [showUpdateModal, setShowUpdateModal] = useState(false);
  const [updateForm, setUpdateForm] = useState({
    status: '',
    message: '',
    photos: []
  });

  // Progress statuses
  const progressStatuses = [
    { 
      value: 'in_progress', 
      label: '🔵 Devam Ediyor', 
      description: 'İş aktif olarak yapılıyor',
      color: 'bg-blue-100 text-blue-800'
    },
    { 
      value: 'materials_ordered', 
      label: '📦 Malzeme Sipariş Edildi', 
      description: 'Gerekli malzemeler sipariş verildi',
      color: 'bg-purple-100 text-purple-800'
    },
    { 
      value: 'materials_arrived', 
      label: '📋 Malzemeler Geldi', 
      description: 'Malzemeler teslim alındı',
      color: 'bg-indigo-100 text-indigo-800'
    },
    { 
      value: 'work_started', 
      label: '🔨 İş Başladı', 
      description: 'Aktif olarak çalışma başladı',
      color: 'bg-orange-100 text-orange-800'
    },
    { 
      value: 'work_in_progress', 
      label: '⚙️ İş Devam Ediyor', 
      description: 'İş yarı yolda, devam ediyor',
      color: 'bg-yellow-100 text-yellow-800'
    },
    { 
      value: 'work_almost_done', 
      label: '🎯 İş Neredeyse Bitti', 
      description: 'Son aşamada, yakında tamamlanacak',
      color: 'bg-green-100 text-green-800'
    },
    { 
      value: 'completed', 
      label: '✅ Tamamlandı', 
      description: 'İş başarıyla tamamlandı',
      color: 'bg-green-200 text-green-900'
    },
    { 
      value: 'on_hold', 
      label: '⏸️ Beklemede', 
      description: 'İş geçici olarak durduruldu',
      color: 'bg-gray-100 text-gray-800'
    }
  ];

  useEffect(() => {
    loadJobProgress();
  }, [jobId]);

  const loadJobProgress = async () => {
    try {
      setLoading(true);
      
      // Load job details
      const jobResponse = await fetch(`http://localhost:5001/api/job-requests/${jobId}`);
      const jobData = await jobResponse.json();
      
      if (jobData.success) {
        setJob(jobData.data);
      }

      // Mock progress updates - in real app, fetch from API
      const mockProgressUpdates = [
        {
          id: 1,
          status: 'in_progress',
          message: 'İş kabul edildi ve başlatıldı. Malzeme listesi hazırlanıyor.',
          created_at: '2025-01-21T09:00:00',
          created_by: 'craftsman',
          created_by_name: 'Ahmet Yılmaz',
          photos: []
        },
        {
          id: 2,
          status: 'materials_ordered',
          message: 'LED aydınlatma malzemeleri sipariş edildi. 2-3 gün içinde gelecek.',
          created_at: '2025-01-21T14:30:00',
          created_by: 'craftsman',
          created_by_name: 'Ahmet Yılmaz',
          photos: []
        },
        {
          id: 3,
          status: 'materials_arrived',
          message: 'Tüm malzemeler geldi. Yarın işe başlayacağım.',
          created_at: '2025-01-23T16:15:00',
          created_by: 'craftsman',
          created_by_name: 'Ahmet Yılmaz',
          photos: ['materials.jpg']
        }
      ];
      
      setProgressUpdates(mockProgressUpdates);
    } catch (error) {
      console.error('Error loading job progress:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async (e) => {
    e.preventDefault();
    
    if (!updateForm.status) {
      alert('Lütfen durum seçin!');
      return;
    }
    
    if (!updateForm.message.trim()) {
      alert('Lütfen açıklama yazın!');
      return;
    }

    try {
      // In real app, send to API
      const newUpdate = {
        id: progressUpdates.length + 1,
        status: updateForm.status,
        message: updateForm.message.trim(),
        created_at: new Date().toISOString(),
        created_by: user?.user_type,
        created_by_name: user?.name || 'Kullanıcı',
        photos: updateForm.photos
      };

      setProgressUpdates(prev => [newUpdate, ...prev]);
      
      // Update job status if completed
      if (updateForm.status === 'completed') {
        setJob(prev => ({ ...prev, status: 'completed' }));
      }

      setUpdateForm({ status: '', message: '', photos: [] });
      setShowUpdateModal(false);
      
      alert('✅ Durum güncellendi!');
    } catch (error) {
      console.error('Error updating progress:', error);
      alert('❌ Güncelleme sırasında hata oluştu!');
    }
  };

  const getStatusInfo = (status) => {
    return progressStatuses.find(s => s.value === status) || progressStatuses[0];
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getTimeAgo = (dateString) => {
    const now = new Date();
    const date = new Date(dateString);
    const diffInHours = Math.floor((now - date) / (1000 * 60 * 60));
    
    if (diffInHours < 1) return 'Az önce';
    if (diffInHours < 24) return `${diffInHours} saat önce`;
    
    const diffInDays = Math.floor(diffInHours / 24);
    if (diffInDays < 7) return `${diffInDays} gün önce`;
    
    return formatDate(dateString);
  };

  const canUpdateProgress = () => {
    return user?.user_type === 'craftsman' && job?.status !== 'completed';
  };

  const getProgressPercentage = () => {
    if (!progressUpdates.length) return 0;
    
    const latestStatus = progressUpdates[0]?.status;
    const statusIndex = progressStatuses.findIndex(s => s.value === latestStatus);
    
    if (statusIndex === -1) return 0;
    return Math.round(((statusIndex + 1) / progressStatuses.length) * 100);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">İş durumu yükleniyor...</p>
        </div>
      </div>
    );
  }

  if (!job) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">İş Bulunamadı</h2>
          <p className="text-gray-600 mb-6">Aradığınız iş bulunamadı.</p>
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
              <h1 className="text-2xl font-bold text-gray-900">📈 İş Takibi</h1>
              <span className={`px-3 py-1 text-sm font-medium rounded-full ${
                job.status === 'completed' ? 'bg-green-100 text-green-800' :
                job.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                'bg-gray-100 text-gray-800'
              }`}>
                {job.status === 'completed' ? '✅ Tamamlandı' :
                 job.status === 'in_progress' ? '🔵 Devam Ediyor' :
                 '⏸️ Beklemede'}
              </span>
            </div>

            {canUpdateProgress() && (
              <button
                onClick={() => setShowUpdateModal(true)}
                className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors font-medium"
              >
                📝 Durum Güncelle
              </button>
            )}
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Job Summary */}
            <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
              <h2 className="text-xl font-bold text-gray-900 mb-4">{job.title}</h2>
              
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-600">{getProgressPercentage()}%</div>
                  <div className="text-sm text-gray-600">Tamamlandı</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-600">
                    {job.budget?.toLocaleString('tr-TR')}₺
                  </div>
                  <div className="text-sm text-gray-600">Bütçe</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-600">{progressUpdates.length}</div>
                  <div className="text-sm text-gray-600">Güncelleme</div>
                </div>
              </div>

              {/* Progress Bar */}
              <div className="mb-6">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium text-gray-700">İş İlerlemesi</span>
                  <span className="text-sm text-gray-500">{getProgressPercentage()}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div 
                    className="bg-blue-500 h-3 rounded-full transition-all duration-300"
                    style={{ width: `${getProgressPercentage()}%` }}
                  ></div>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
                <div>
                  <span className="font-medium">Kategori:</span> {job.category}
                </div>
                <div>
                  <span className="font-medium">Konum:</span> {job.location}
                </div>
                <div>
                  <span className="font-medium">Müşteri:</span> {job.customer_name}
                </div>
                <div>
                  <span className="font-medium">Başlangıç:</span> {formatDate(job.created_at)}
                </div>
              </div>
            </div>

            {/* Progress Timeline */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-6">📋 İş Geçmişi</h3>
              
              {progressUpdates.length === 0 ? (
                <div className="text-center py-12">
                  <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                  </div>
                  <h4 className="text-lg font-medium text-gray-900 mb-2">Henüz güncelleme yok</h4>
                  <p className="text-gray-600">İlk durum güncellemesi geldiğinde burada görünecek.</p>
                </div>
              ) : (
                <div className="space-y-6">
                  {progressUpdates.map((update, index) => {
                    const statusInfo = getStatusInfo(update.status);
                    const isLast = index === progressUpdates.length - 1;
                    
                    return (
                      <div key={update.id} className="relative">
                        {/* Timeline line */}
                        {!isLast && (
                          <div className="absolute left-6 top-12 w-0.5 h-16 bg-gray-200"></div>
                        )}
                        
                        <div className="flex items-start space-x-4">
                          {/* Status icon */}
                          <div className={`w-12 h-12 rounded-full flex items-center justify-center ${statusInfo.color} flex-shrink-0`}>
                            <span className="text-lg">
                              {statusInfo.label.split(' ')[0]}
                            </span>
                          </div>
                          
                          {/* Content */}
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center justify-between mb-2">
                              <h4 className="font-medium text-gray-900">
                                {statusInfo.label.replace(/^[^\s]+ /, '')}
                              </h4>
                              <div className="text-sm text-gray-500">
                                {getTimeAgo(update.created_at)}
                              </div>
                            </div>
                            
                            <p className="text-gray-700 mb-3">{update.message}</p>
                            
                            <div className="flex items-center justify-between text-sm text-gray-500">
                              <span>
                                {update.created_by === 'craftsman' ? '🔨 Usta' : '👤 Müşteri'}: {update.created_by_name}
                              </span>
                              <span>{formatDate(update.created_at)}</span>
                            </div>
                            
                            {/* Photos */}
                            {update.photos && update.photos.length > 0 && (
                              <div className="mt-3">
                                <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                                  {update.photos.map((photo, photoIndex) => (
                                    <div key={photoIndex} className="aspect-square bg-gray-200 rounded-lg flex items-center justify-center">
                                      <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                      </svg>
                                    </div>
                                  ))}
                                </div>
                              </div>
                            )}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>

          {/* Sidebar */}
          <div className="lg:col-span-1">
            {/* Quick Stats */}
            <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">📊 Özet</h3>
              
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Durum:</span>
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                    progressUpdates.length > 0 
                      ? getStatusInfo(progressUpdates[0].status).color
                      : 'bg-gray-100 text-gray-800'
                  }`}>
                    {progressUpdates.length > 0 
                      ? getStatusInfo(progressUpdates[0].status).label
                      : '⏸️ Beklemede'
                    }
                  </span>
                </div>
                
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">İlerleme:</span>
                  <span className="text-sm font-medium text-blue-600">
                    {getProgressPercentage()}%
                  </span>
                </div>
                
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Son Güncelleme:</span>
                  <span className="text-sm text-gray-900">
                    {progressUpdates.length > 0 
                      ? getTimeAgo(progressUpdates[0].created_at)
                      : 'Henüz yok'
                    }
                  </span>
                </div>
                
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Toplam Güncelleme:</span>
                  <span className="text-sm font-medium text-gray-900">
                    {progressUpdates.length}
                  </span>
                </div>
              </div>
            </div>

            {/* Quick Actions */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">⚡ Hızlı İşlemler</h3>
              
              <div className="space-y-3">
                {canUpdateProgress() && (
                  <button
                    onClick={() => setShowUpdateModal(true)}
                    className="w-full p-4 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-left"
                  >
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </div>
                      <div>
                        <div className="font-medium text-white">Durum Güncelle</div>
                        <div className="text-sm text-blue-100">İş ilerlemesini paylaş</div>
                      </div>
                    </div>
                  </button>
                )}

                <button
                  onClick={() => navigate(`/job/${jobId}`)}
                  className="w-full p-4 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors text-left"
                >
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-gray-500 rounded-lg flex items-center justify-center">
                      <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                      </svg>
                    </div>
                    <div>
                      <div className="font-medium text-gray-900">İş Detayları</div>
                      <div className="text-sm text-gray-600">Tüm bilgileri görüntüle</div>
                    </div>
                  </div>
                </button>

                <button
                  onClick={() => navigate(`/messages/${job.customer_id}`)}
                  className="w-full p-4 bg-green-50 hover:bg-green-100 rounded-lg transition-colors text-left"
                >
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-green-500 rounded-lg flex items-center justify-center">
                      <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                      </svg>
                    </div>
                    <div>
                      <div className="font-medium text-gray-900">Mesaj Gönder</div>
                      <div className="text-sm text-gray-600">Müşteri ile iletişim</div>
                    </div>
                  </div>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Status Update Modal */}
      {showUpdateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-medium text-gray-900">📝 Durum Güncelle</h3>
                <button
                  onClick={() => setShowUpdateModal(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <form onSubmit={handleStatusUpdate} className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Yeni Durum *
                  </label>
                  <select
                    value={updateForm.status}
                    onChange={(e) => setUpdateForm(prev => ({ ...prev, status: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Durum seçin</option>
                    {progressStatuses.map((status) => (
                      <option key={status.value} value={status.value}>
                        {status.label}
                      </option>
                    ))}
                  </select>
                  {updateForm.status && (
                    <p className="text-sm text-gray-500 mt-1">
                      {getStatusInfo(updateForm.status).description}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Açıklama *
                  </label>
                  <textarea
                    value={updateForm.message}
                    onChange={(e) => setUpdateForm(prev => ({ ...prev, message: e.target.value }))}
                    rows={4}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="İş durumu hakkında detaylı bilgi verin..."
                    required
                  />
                  <p className="text-sm text-gray-500 mt-1">
                    {updateForm.message.length}/500 karakter
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Fotoğraf Ekle (İsteğe bağlı)
                  </label>
                  <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                    <svg className="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <p className="text-gray-600 mb-2">İş ilerlemesini gösteren fotoğraflar</p>
                    <button
                      type="button"
                      className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                    >
                      📷 Fotoğraf Seç
                    </button>
                  </div>
                </div>

                <div className="flex space-x-3 pt-6">
                  <button
                    type="button"
                    onClick={() => setShowUpdateModal(false)}
                    className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    İptal
                  </button>
                  <button
                    type="submit"
                    className="flex-1 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                  >
                    📝 Güncelle
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default JobProgressPage;