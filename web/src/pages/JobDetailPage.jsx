import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { CATEGORIES } from '../data/categories';

export const JobDetailPage = () => {
  const navigate = useNavigate();
  const { jobId } = useParams();
  const { user } = useAuth();
  
  const [loading, setLoading] = useState(true);
  const [job, setJob] = useState(null);
  const [proposals, setProposals] = useState([]);
  const [activeTab, setActiveTab] = useState('details');

  useEffect(() => {
    loadJobDetails();
    loadProposals();
  }, [jobId]);

  const loadJobDetails = async () => {
    try {
      setLoading(true);
      const response = await fetch(`http://localhost:5001/api/job-requests/${jobId}`);
      const data = await response.json();
      
      if (data.success) {
        setJob(data.data);
      } else {
        alert('İş bulunamadı!');
        navigate('/jobs');
      }
    } catch (error) {
      console.error('Error loading job:', error);
      alert('İş yüklenirken hata oluştu!');
      navigate('/jobs');
    } finally {
      setLoading(false);
    }
  };

  const loadProposals = async () => {
    try {
      const response = await fetch(`http://localhost:5001/api/job-requests/${jobId}/proposals`);
      const data = await response.json();
      
      if (data.success) {
        setProposals(data.data);
      }
    } catch (error) {
      console.error('Error loading proposals:', error);
    }
  };

  const getSkillName = (skillId) => {
    for (const category of CATEGORIES) {
      const skill = category.skills.find(s => s.id === skillId);
      if (skill) return skill.name;
    }
    return '';
  };

  const getUrgencyColor = (urgency) => {
    switch (urgency) {
      case 'urgent': return 'bg-red-100 text-red-800';
      case 'normal': return 'bg-yellow-100 text-yellow-800';
      case 'flexible': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getUrgencyIcon = (urgency) => {
    switch (urgency) {
      case 'urgent': return '🔴';
      case 'normal': return '🟡';
      case 'flexible': return '🟢';
      default: return '⚪';
    }
  };

  const getBudgetTypeText = (budgetType) => {
    switch (budgetType) {
      case 'fixed': return 'Sabit Fiyat';
      case 'hourly': return 'Saatlik Ücret';
      case 'negotiable': return 'Pazarlık';
      default: return budgetType;
    }
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

  const canMakeProposal = () => {
    return user?.user_type === 'craftsman' && job?.status === 'open';
  };

  const isCustomer = () => {
    return user?.user_type === 'customer' && job?.customer_id === user?.id;
  };

  const handleAcceptProposal = async (proposalId) => {
    if (!confirm('Bu teklifi kabul etmek istediğinizden emin misiniz?')) {
      return;
    }

    try {
      const response = await fetch(`http://localhost:5001/api/proposals/${proposalId}/accept`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        }
      });

      const result = await response.json();

      if (result.success) {
        alert('✅ Teklif kabul edildi! İş başlatıldı.');
        // Reload data
        loadJobDetails();
        loadProposals();
      } else {
        alert('❌ Hata: ' + result.error);
      }
    } catch (error) {
      console.error('Error accepting proposal:', error);
      alert('❌ Teklif kabul edilirken hata oluştu!');
    }
  };

  const handleRejectProposal = async (proposalId) => {
    if (!confirm('Bu teklifi reddetmek istediğinizden emin misiniz?')) {
      return;
    }

    try {
      const response = await fetch(`http://localhost:5001/api/proposals/${proposalId}/reject`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        }
      });

      const result = await response.json();

      if (result.success) {
        alert('❌ Teklif reddedildi.');
        // Reload data
        loadProposals();
      } else {
        alert('❌ Hata: ' + result.error);
      }
    } catch (error) {
      console.error('Error rejecting proposal:', error);
      alert('❌ Teklif reddedilirken hata oluştu!');
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">İş detayları yükleniyor...</p>
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
          <p className="text-gray-600 mb-6">Aradığınız iş talebi bulunamadı veya kaldırılmış.</p>
          <button
            onClick={() => navigate('/jobs')}
            className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            İş Listesine Dön
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
              <h1 className="text-2xl font-bold text-gray-900">📋 İş Detayı</h1>
              <span className={`px-3 py-1 text-sm font-medium rounded-full ${
                job.status === 'open' ? 'bg-green-100 text-green-800' :
                job.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                job.status === 'completed' ? 'bg-gray-100 text-gray-800' :
                'bg-red-100 text-red-800'
              }`}>
                {job.status === 'open' ? '🟢 Açık' :
                 job.status === 'in_progress' ? '🔵 Devam Ediyor' :
                 job.status === 'completed' ? '✅ Tamamlandı' :
                 '❌ İptal'}
              </span>
            </div>

            {canMakeProposal() && (
              <button
                onClick={() => navigate(`/job/${jobId}/proposal`)}
                className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors font-medium"
              >
                💰 Teklif Ver
              </button>
            )}
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Job Header */}
            <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
              <div className="flex items-start justify-between mb-4">
                <div className="flex-1">
                  <h2 className="text-2xl font-bold text-gray-900 mb-3">{job.title}</h2>
                  
                  <div className="flex items-center space-x-4 text-sm text-gray-600 mb-4">
                    <span className="flex items-center space-x-1">
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                      </svg>
                      <span>{job.category}</span>
                    </span>
                    <span className="flex items-center space-x-1">
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                      <span>{job.location}</span>
                    </span>
                    <span className="flex items-center space-x-1">
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      <span>{getTimeAgo(job.created_at)}</span>
                    </span>
                  </div>

                  <div className="flex items-center space-x-3 mb-4">
                    <span className={`px-3 py-1 text-sm font-medium rounded-full ${getUrgencyColor(job.urgency)}`}>
                      {getUrgencyIcon(job.urgency)} {job.urgency === 'urgent' ? 'Acil' : job.urgency === 'normal' ? 'Normal' : 'Esnek'}
                    </span>
                    <span className="text-2xl font-bold text-green-600">
                      {job.budget.toLocaleString('tr-TR')}₺
                    </span>
                    <span className="text-sm text-gray-500">
                      ({getBudgetTypeText(job.budget_type)})
                    </span>
                  </div>
                </div>
              </div>

              {/* Skills */}
              {job.skills_needed && job.skills_needed.length > 0 && (
                <div className="mb-6">
                  <h3 className="text-sm font-medium text-gray-900 mb-3">🎯 İhtiyaç Duyulan Yetenekler:</h3>
                  <div className="flex flex-wrap gap-2">
                    {job.skills_needed.map((skillId) => (
                      <span
                        key={skillId}
                        className="px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full font-medium"
                      >
                        {getSkillName(skillId)}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {/* Description */}
              <div className="mb-6">
                <h3 className="text-sm font-medium text-gray-900 mb-3">📝 İş Açıklaması:</h3>
                <div className="prose prose-gray max-w-none">
                  {job.description.split('\n').map((paragraph, index) => (
                    <p key={index} className="text-gray-700 mb-3">
                      {paragraph}
                    </p>
                  ))}
                </div>
              </div>

              {/* Additional Info */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-6 border-t">
                {job.address && (
                  <div>
                    <h4 className="text-sm font-medium text-gray-900 mb-2">📍 Adres Detayı:</h4>
                    <p className="text-gray-700">{job.address}</p>
                  </div>
                )}
                
                {job.preferred_date && (
                  <div>
                    <h4 className="text-sm font-medium text-gray-900 mb-2">📅 Tercih Edilen Tarih:</h4>
                    <p className="text-gray-700">
                      {new Date(job.preferred_date).toLocaleDateString('tr-TR', {
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric'
                      })}
                    </p>
                  </div>
                )}
              </div>
            </div>

            {/* Tabs */}
            <div className="bg-white rounded-lg shadow-sm">
              <div className="border-b border-gray-200">
                <nav className="flex space-x-8 px-6">
                  <button
                    onClick={() => setActiveTab('details')}
                    className={`py-4 px-1 border-b-2 font-medium text-sm ${
                      activeTab === 'details'
                        ? 'border-blue-500 text-blue-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700'
                    }`}
                  >
                    📋 Detaylar
                  </button>
                  <button
                    onClick={() => setActiveTab('proposals')}
                    className={`py-4 px-1 border-b-2 font-medium text-sm ${
                      activeTab === 'proposals'
                        ? 'border-blue-500 text-blue-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700'
                    }`}
                  >
                    💰 Teklifler ({proposals.length})
                  </button>
                </nav>
              </div>

              <div className="p-6">
                {activeTab === 'details' && (
                  <div className="space-y-6">
                    <div>
                      <h3 className="text-lg font-medium text-gray-900 mb-4">📊 İş İstatistikleri</h3>
                      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                        <div className="bg-blue-50 rounded-lg p-4 text-center">
                          <div className="text-2xl font-bold text-blue-600">{job.proposal_count}</div>
                          <div className="text-sm text-blue-800">Teklif</div>
                        </div>
                        <div className="bg-green-50 rounded-lg p-4 text-center">
                          <div className="text-2xl font-bold text-green-600">{job.view_count}</div>
                          <div className="text-sm text-green-800">Görüntüleme</div>
                        </div>
                        <div className="bg-purple-50 rounded-lg p-4 text-center">
                          <div className="text-2xl font-bold text-purple-600">
                            {job.expires_at ? Math.ceil((new Date(job.expires_at) - new Date()) / (1000 * 60 * 60 * 24)) : 0}
                          </div>
                          <div className="text-sm text-purple-800">Kalan Gün</div>
                        </div>
                        <div className="bg-orange-50 rounded-lg p-4 text-center">
                          <div className="text-2xl font-bold text-orange-600">
                            {job.budget_type === 'hourly' ? 'Saatlik' : job.budget_type === 'negotiable' ? 'Pazarlık' : 'Sabit'}
                          </div>
                          <div className="text-sm text-orange-800">Bütçe Türü</div>
                        </div>
                      </div>
                    </div>

                    {job.photos && job.photos.length > 0 && (
                      <div>
                        <h3 className="text-lg font-medium text-gray-900 mb-4">📷 Fotoğraflar</h3>
                        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                          {job.photos.map((photo, index) => (
                            <div key={index} className="aspect-square bg-gray-200 rounded-lg flex items-center justify-center">
                              <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                              </svg>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}

                {activeTab === 'proposals' && (
                  <div className="space-y-4">
                    {proposals.length === 0 ? (
                      <div className="text-center py-12">
                        <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                          <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586l-4-4A2 2 0 013 11V5a2 2 0 012-2h6a2 2 0 012 2v6a2 2 0 01-2 2H9l-4 4v-4H3" />
                          </svg>
                        </div>
                        <h3 className="text-lg font-medium text-gray-900 mb-2">Henüz teklif yok</h3>
                        <p className="text-gray-600">İlk teklif geldiğinde burada görünecek.</p>
                      </div>
                    ) : (
                      proposals.map((proposal) => (
                        <div key={proposal.id} className="border border-gray-200 rounded-lg p-6">
                          <div className="flex items-start justify-between mb-4">
                            <div className="flex items-center space-x-4">
                              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                                <span className="text-blue-600 font-medium">
                                  {proposal.craftsman_name.charAt(0)}
                                </span>
                              </div>
                              <div>
                                <h4 className="font-semibold text-gray-900">{proposal.craftsman_name}</h4>
                                <div className="flex items-center space-x-2 text-sm text-gray-600">
                                  <div className="flex items-center space-x-1">
                                    {Array.from({ length: 5 }, (_, i) => (
                                      <svg
                                        key={i}
                                        className={`w-4 h-4 ${i < Math.floor(proposal.craftsman_rating) ? 'text-yellow-400' : 'text-gray-300'}`}
                                        fill="currentColor"
                                        viewBox="0 0 20 20"
                                      >
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                                      </svg>
                                    ))}
                                  </div>
                                  <span>({proposal.craftsman_rating})</span>
                                  <span>• {formatDate(proposal.created_at)}</span>
                                </div>
                              </div>
                            </div>

                            <div className="text-right">
                              <div className="text-2xl font-bold text-green-600">
                                {proposal.price.toLocaleString('tr-TR')}₺
                              </div>
                              <div className="text-sm text-gray-500">
                                {proposal.price_type === 'fixed' ? 'Sabit' : proposal.price_type === 'hourly' ? 'Saatlik' : 'Pazarlık'}
                              </div>
                            </div>
                          </div>

                          <p className="text-gray-700 mb-4">{proposal.message}</p>

                          <div className="flex items-center justify-between text-sm text-gray-600 mb-4">
                            {proposal.estimated_duration && (
                              <span className="flex items-center space-x-1">
                                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>Süre: {proposal.estimated_duration}</span>
                              </span>
                            )}
                            {proposal.availability && (
                              <span className="flex items-center space-x-1">
                                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3a1 1 0 011-1h6a1 1 0 011 1v4h3a1 1 0 011 1v9a2 2 0 01-2 2H5a2 2 0 01-2-2V8a1 1 0 011-1h3z" />
                                </svg>
                                <span>Müsaitlik: {proposal.availability}</span>
                              </span>
                            )}
                          </div>

                                                     {isCustomer() && proposal.status === 'pending' && (
                             <div className="flex space-x-3">
                               <button
                                 onClick={() => handleAcceptProposal(proposal.id)}
                                 className="flex-1 px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors font-medium"
                               >
                                 ✅ Kabul Et
                               </button>
                               <button
                                 onClick={() => handleRejectProposal(proposal.id)}
                                 className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
                               >
                                 ❌ Reddet
                               </button>
                             </div>
                           )}

                          {proposal.status === 'accepted' && (
                            <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                              <div className="flex items-center space-x-2 text-green-800">
                                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                                </svg>
                                <span className="font-medium">Teklif kabul edildi</span>
                              </div>
                            </div>
                          )}

                          {proposal.status === 'rejected' && (
                            <div className="bg-red-50 border border-red-200 rounded-lg p-3">
                              <div className="flex items-center space-x-2 text-red-800">
                                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                                </svg>
                                <span className="font-medium">Teklif reddedildi</span>
                              </div>
                            </div>
                          )}
                        </div>
                      ))
                    )}
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="lg:col-span-1">
            {/* Customer Info */}
            <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">👤 Müşteri Bilgileri</h3>
              
              <div className="flex items-center space-x-3 mb-4">
                <div className="w-12 h-12 bg-gray-200 rounded-full flex items-center justify-center">
                  <span className="text-gray-600 font-medium">
                    {job.customer_name.charAt(0)}
                  </span>
                </div>
                <div>
                  <div className="font-medium text-gray-900">{job.customer_name}</div>
                  <div className="text-sm text-gray-600">Müşteri</div>
                </div>
              </div>

              {job.customer_phone && (
                <div className="flex items-center space-x-2 text-sm text-gray-600 mb-3">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                  </svg>
                  <span>{job.customer_phone}</span>
                </div>
              )}

              <div className="text-sm text-gray-600">
                <div className="flex items-center space-x-2 mb-2">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3a1 1 0 011-1h6a1 1 0 011 1v4h3a1 1 0 011 1v9a2 2 0 01-2 2H5a2 2 0 01-2-2V8a1 1 0 011-1h3z" />
                  </svg>
                  <span>İlan tarihi: {formatDate(job.created_at)}</span>
                </div>
                
                {job.expires_at && (
                  <div className="flex items-center space-x-2">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span>Son tarih: {formatDate(job.expires_at)}</span>
                  </div>
                )}
              </div>
            </div>

            {/* Quick Actions */}
            {canMakeProposal() && (
              <div className="bg-white rounded-lg shadow-sm p-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">⚡ Hızlı İşlemler</h3>
                
                <div className="space-y-3">
                  <button
                    onClick={() => navigate(`/job/${jobId}/proposal`)}
                    className="w-full p-4 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-left"
                  >
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                        </svg>
                      </div>
                      <div>
                        <div className="font-medium text-white">Teklif Ver</div>
                        <div className="text-sm text-blue-100">Fiyat ve şartlarınızı belirtin</div>
                      </div>
                    </div>
                  </button>

                                     <button
                     onClick={() => navigate(`/job/${jobId}/progress`)}
                     className="w-full p-4 bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors text-left"
                   >
                     <div className="flex items-center space-x-3">
                       <div className="w-10 h-10 bg-purple-500 rounded-lg flex items-center justify-center">
                         <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                           <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                         </svg>
                       </div>
                       <div>
                         <div className="font-medium text-gray-900">İş Takibi</div>
                         <div className="text-sm text-gray-600">İlerlemeyi izle</div>
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
                         <div className="text-sm text-gray-600">Detayları konuşun</div>
                       </div>
                     </div>
                   </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default JobDetailPage;