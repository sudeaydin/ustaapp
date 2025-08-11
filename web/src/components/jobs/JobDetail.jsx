import React, { useState, useEffect } from 'react';
import { formatDate, formatCurrency } from '../../utils/formatters';
import api from '../../utils/api';
import LoadingSpinner from '../ui/LoadingSpinner';
import MaterialsList from './MaterialsList';
import ProgressUpdates from './ProgressUpdates';
import TimelineView from './TimelineView';
import CostBreakdown from './CostBreakdown';

const JobDetail = ({ job, userType, onClose, onUpdate }) => {
  const [activeTab, setActiveTab] = useState('overview');
  const [jobDetail, setJobDetail] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadJobDetail();
  }, [job.id]);

  const loadJobDetail = async () => {
    try {
      setLoading(true);
      const response = await api.get(`/job-management/jobs/${job.id}`);
      setJobDetail(response.data.data);
    } catch (err) {
      setError(err.message);
      console.error('Failed to load job detail:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async (newStatus, notes = '') => {
    try {
      await api.put(`/job-management/jobs/${job.id}`, {
        status: newStatus,
        notes: notes
      });
      onUpdate();
      loadJobDetail();
    } catch (error) {
      console.error('Failed to update job status:', error);
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      pending: 'bg-yellow-100 text-yellow-800 border-yellow-200',
      accepted: 'bg-blue-100 text-blue-800 border-blue-200',
      in_progress: 'bg-purple-100 text-purple-800 border-purple-200',
      paused: 'bg-orange-100 text-orange-800 border-orange-200',
      materials_needed: 'bg-red-100 text-red-800 border-red-200',
      quality_check: 'bg-indigo-100 text-indigo-800 border-indigo-200',
      completed: 'bg-green-100 text-green-800 border-green-200',
      cancelled: 'bg-gray-100 text-gray-800 border-gray-200',
      disputed: 'bg-red-100 text-red-800 border-red-200'
    };
    return colors[status] || 'bg-gray-100 text-gray-800 border-gray-200';
  };

  const tabs = [
    { id: 'overview', label: 'Genel Bakış', icon: '📋' },
    { id: 'timeline', label: 'Zaman Çizelgesi', icon: '📅' },
    { id: 'materials', label: 'Malzemeler', icon: '🧰' },
    { id: 'progress', label: 'İlerleme', icon: '📈' },
    { id: 'cost', label: 'Maliyet', icon: '💰' }
  ];

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-8">
          <LoadingSpinner />
        </div>
      </div>
    );
  }

  if (!jobDetail) {
    return null;
  }

  const { job: detailedJob, timeline, cost_breakdown, progress_updates } = jobDetail;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-6xl w-full max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <div className="flex-1">
            <h2 className="text-2xl font-bold text-gray-900">{detailedJob.title}</h2>
            <div className="flex items-center mt-2 space-x-4">
              <span className={`px-3 py-1 rounded-full text-sm font-medium border ${getStatusColor(detailedJob.status)}`}>
                {detailedJob.status}
              </span>
              {detailedJob.is_emergency && (
                <span className="px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800 border border-red-200">
                  🚨 Acil Servis
                </span>
              )}
              {detailedJob.is_overdue && (
                <span className="px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800 border border-red-200">
                  ⚠️ Gecikmiş
                </span>
              )}
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Quick Actions */}
        {userType === 'craftsman' && (
          <div className="px-6 py-4 bg-gray-50 border-b border-gray-200">
            <div className="flex space-x-3">
              {detailedJob.status === 'accepted' && (
                <button
                  onClick={() => handleStatusUpdate('in_progress', 'İş başlatıldı')}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium"
                >
                  İşi Başlat
                </button>
              )}
              {detailedJob.status === 'in_progress' && (
                <>
                  <button
                    onClick={() => handleStatusUpdate('paused', 'İş duraklatıldı')}
                    className="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 transition-colors text-sm font-medium"
                  >
                    Duraklat
                  </button>
                  <button
                    onClick={() => handleStatusUpdate('quality_check', 'Kalite kontrole hazır')}
                    className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors text-sm font-medium"
                  >
                    Kalite Kontrolü
                  </button>
                </>
              )}
              {detailedJob.status === 'quality_check' && (
                <button
                  onClick={() => handleStatusUpdate('completed', 'İş tamamlandı')}
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors text-sm font-medium"
                >
                  Tamamla
                </button>
              )}
            </div>
          </div>
        )}

        {/* Tabs */}
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <span className="mr-2">{tab.icon}</span>
                {tab.label}
              </button>
            ))}
          </nav>
        </div>

        {/* Content */}
        <div className="overflow-y-auto max-h-[60vh]">
          {error && (
            <div className="p-6 bg-red-50 border border-red-200 text-red-600">
              {error}
            </div>
          )}

          {activeTab === 'overview' && (
            <div className="p-6 space-y-6">
              {/* Basic Information */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-gray-900">Temel Bilgiler</h3>
                  
                  <div className="space-y-3">
                    <div>
                      <label className="text-sm font-medium text-gray-600">Açıklama</label>
                      <p className="text-gray-900">{detailedJob.description}</p>
                    </div>
                    
                    <div>
                      <label className="text-sm font-medium text-gray-600">Kategori</label>
                      <p className="text-gray-900 capitalize">
                        {detailedJob.category}
                        {detailedJob.subcategory && ` - ${detailedJob.subcategory}`}
                      </p>
                    </div>
                    
                    {detailedJob.address && (
                      <div>
                        <label className="text-sm font-medium text-gray-600">Adres</label>
                        <p className="text-gray-900">{detailedJob.address}</p>
                      </div>
                    )}
                    
                    {detailedJob.special_requirements && (
                      <div>
                        <label className="text-sm font-medium text-gray-600">Özel Gereksinimler</label>
                        <p className="text-gray-900">{detailedJob.special_requirements}</p>
                      </div>
                    )}
                  </div>
                </div>

                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-gray-900">Durum ve Zaman</h3>
                  
                  <div className="space-y-3">
                    <div>
                      <label className="text-sm font-medium text-gray-600">Mevcut Durum</label>
                      <span className={`inline-block px-3 py-1 rounded-full text-sm font-medium border ${getStatusColor(detailedJob.status)}`}>
                        {detailedJob.status}
                      </span>
                    </div>
                    
                    <div>
                      <label className="text-sm font-medium text-gray-600">Öncelik</label>
                      <p className="text-gray-900 capitalize">{detailedJob.priority}</p>
                    </div>
                    
                    {detailedJob.estimated_duration && (
                      <div>
                        <label className="text-sm font-medium text-gray-600">Tahmini Süre</label>
                        <p className="text-gray-900">{detailedJob.estimated_duration} saat</p>
                      </div>
                    )}
                    
                    {detailedJob.actual_duration && (
                      <div>
                        <label className="text-sm font-medium text-gray-600">Gerçek Süre</label>
                        <p className="text-gray-900">{detailedJob.actual_duration} saat</p>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Participants */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Katılımcılar</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {detailedJob.customer && (
                    <div className="bg-gray-50 rounded-lg p-4">
                      <h4 className="font-medium text-gray-900 mb-2">Müşteri</h4>
                      <p className="text-gray-700">{detailedJob.customer.first_name} {detailedJob.customer.last_name}</p>
                      <p className="text-gray-600 text-sm">{detailedJob.customer.email}</p>
                      {detailedJob.customer.phone && (
                        <p className="text-gray-600 text-sm">{detailedJob.customer.phone}</p>
                      )}
                    </div>
                  )}
                  
                  {detailedJob.craftsman && (
                    <div className="bg-gray-50 rounded-lg p-4">
                      <h4 className="font-medium text-gray-900 mb-2">Usta</h4>
                      <p className="text-gray-700">{detailedJob.craftsman.first_name} {detailedJob.craftsman.last_name}</p>
                      <p className="text-gray-600 text-sm">{detailedJob.craftsman.email}</p>
                      {detailedJob.craftsman.phone && (
                        <p className="text-gray-600 text-sm">{detailedJob.craftsman.phone}</p>
                      )}
                    </div>
                  )}
                </div>
              </div>

              {/* Images */}
              {detailedJob.images && detailedJob.images.length > 0 && (
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Fotoğraflar</h3>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    {detailedJob.images.map((image, index) => (
                      <img
                        key={index}
                        src={image}
                        alt={`Job image ${index + 1}`}
                        className="w-full h-24 object-cover rounded-lg"
                      />
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'timeline' && (
            <TimelineView 
              timeline={timeline} 
              jobId={detailedJob.id}
              onUpdate={loadJobDetail}
            />
          )}

          {activeTab === 'materials' && (
            <MaterialsList 
              jobId={detailedJob.id}
              materials={detailedJob.materials}
              userType={userType}
              onUpdate={loadJobDetail}
            />
          )}

          {activeTab === 'progress' && (
            <ProgressUpdates 
              jobId={detailedJob.id}
              progressUpdates={progress_updates}
              userType={userType}
              currentProgress={detailedJob.completion_percentage}
              onUpdate={loadJobDetail}
            />
          )}

          {activeTab === 'cost' && (
            <CostBreakdown 
              costBreakdown={cost_breakdown}
              job={detailedJob}
            />
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 bg-gray-50 border-t border-gray-200">
          <div className="flex items-center justify-between">
            <div className="text-sm text-gray-600">
              Son güncelleme: {formatDate(detailedJob.updated_at)}
            </div>
            
            <div className="flex space-x-3">
              {/* Warranty Claim Button for Customers */}
              {userType === 'customer' && detailedJob.status === 'completed' && detailedJob.warranty_status === 'active' && (
                <button
                  onClick={() => {
                    // TODO: Open warranty claim modal
                    console.log('Open warranty claim modal');
                  }}
                  className="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 transition-colors text-sm font-medium"
                >
                  Garanti Talebi
                </button>
              )}
              
              <button
                onClick={onClose}
                className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors text-sm font-medium"
              >
                Kapat
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default JobDetail;