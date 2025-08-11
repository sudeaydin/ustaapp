import React from 'react';
import { formatDate, formatCurrency } from '../../utils/formatters';

const JobCard = ({ job, userType, onSelect, onUpdate }) => {
  const getStatusColor = (status) => {
    const colors = {
      pending: 'bg-yellow-100 text-yellow-800',
      accepted: 'bg-blue-100 text-blue-800',
      in_progress: 'bg-purple-100 text-purple-800',
      paused: 'bg-orange-100 text-orange-800',
      materials_needed: 'bg-red-100 text-red-800',
      quality_check: 'bg-indigo-100 text-indigo-800',
      completed: 'bg-green-100 text-green-800',
      cancelled: 'bg-gray-100 text-gray-800',
      disputed: 'bg-red-100 text-red-800'
    };
    return colors[status] || 'bg-gray-100 text-gray-800';
  };

  const getStatusText = (status) => {
    const texts = {
      pending: 'Beklemede',
      accepted: 'Kabul Edildi',
      in_progress: 'Devam Ediyor',
      paused: 'Duraklatıldı',
      materials_needed: 'Malzeme Gerekli',
      quality_check: 'Kalite Kontrolü',
      completed: 'Tamamlandı',
      cancelled: 'İptal Edildi',
      disputed: 'Anlaşmazlık'
    };
    return texts[status] || status;
  };

  const getPriorityIcon = (priority) => {
    const icons = {
      low: '🟢',
      normal: '🟡',
      high: '🟠',
      urgent: '🔴',
      emergency: '🚨'
    };
    return icons[priority] || '🟡';
  };

  const handleQuickAction = async (action) => {
    try {
      if (action === 'start' && userType === 'craftsman') {
        await api.put(`/job-management/jobs/${job.id}`, {
          status: 'in_progress'
        });
      } else if (action === 'complete' && userType === 'craftsman') {
        await api.put(`/job-management/jobs/${job.id}`, {
          status: 'completed'
        });
      }
      onUpdate();
    } catch (error) {
      console.error('Failed to update job:', error);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200 overflow-hidden">
      {/* Header */}
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">
              {job.title}
            </h3>
            <p className="text-gray-600 text-sm line-clamp-2">
              {job.description}
            </p>
          </div>
          <div className="ml-4 flex flex-col items-end">
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(job.status)}`}>
              {getStatusText(job.status)}
            </span>
            <div className="mt-2 flex items-center">
              <span className="mr-1">{getPriorityIcon(job.priority)}</span>
              <span className="text-xs text-gray-500 capitalize">{job.priority}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="p-6">
        <div className="space-y-3">
          {/* Category and Location */}
          <div className="flex items-center text-sm text-gray-600">
            <span className="mr-2">🏷️</span>
            <span className="capitalize">{job.category}</span>
            {job.subcategory && (
              <>
                <span className="mx-2">•</span>
                <span className="capitalize">{job.subcategory}</span>
              </>
            )}
          </div>

          {job.city && (
            <div className="flex items-center text-sm text-gray-600">
              <span className="mr-2">📍</span>
              <span>{job.city}{job.district && `, ${job.district}`}</span>
            </div>
          )}

          {/* Progress Bar */}
          {job.completion_percentage !== undefined && (
            <div className="space-y-1">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">İlerleme</span>
                <span className="font-medium">{Math.round(job.completion_percentage)}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${job.completion_percentage}%` }}
                ></div>
              </div>
            </div>
          )}

          {/* Cost Information */}
          <div className="flex items-center justify-between text-sm">
            <span className="text-gray-600">Maliyet:</span>
            <span className="font-medium text-gray-900">
              {job.final_cost ? 
                formatCurrency(job.final_cost) : 
                job.estimated_cost ? 
                  `~${formatCurrency(job.estimated_cost)}` : 
                  'Belirtilmedi'
              }
            </span>
          </div>

          {/* Timeline */}
          <div className="flex items-center justify-between text-sm">
            <span className="text-gray-600">Oluşturulma:</span>
            <span className="text-gray-900">{formatDate(job.created_at)}</span>
          </div>

          {job.scheduled_start && (
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600">Planlanan Başlangıç:</span>
              <span className="text-gray-900">{formatDate(job.scheduled_start)}</span>
            </div>
          )}

          {/* Emergency Indicator */}
          {job.is_emergency && (
            <div className="flex items-center text-sm text-red-600 bg-red-50 rounded-lg p-2">
              <span className="mr-2">🚨</span>
              <span className="font-medium">Acil Servis</span>
              {job.emergency_level && (
                <span className="ml-2 text-xs">Seviye {job.emergency_level}</span>
              )}
            </div>
          )}

          {/* Warranty Info for Completed Jobs */}
          {job.status === 'completed' && job.warranty_end_date && (
            <div className="flex items-center text-sm text-green-600 bg-green-50 rounded-lg p-2">
              <span className="mr-2">🛡️</span>
              <span>Garanti: {formatDate(job.warranty_end_date)} tarihine kadar</span>
            </div>
          )}

          {/* Overdue Warning */}
          {job.is_overdue && (
            <div className="flex items-center text-sm text-red-600 bg-red-50 rounded-lg p-2">
              <span className="mr-2">⚠️</span>
              <span className="font-medium">Gecikmiş</span>
            </div>
          )}
        </div>
      </div>

      {/* Actions */}
      <div className="px-6 py-4 bg-gray-50 border-t border-gray-200">
        <div className="flex items-center justify-between">
          <button
            onClick={() => onSelect(job)}
            className="text-blue-600 hover:text-blue-800 text-sm font-medium transition-colors"
          >
            Detayları Görüntüle
          </button>

          <div className="flex space-x-2">
            {/* Quick Actions for Craftsmen */}
            {userType === 'craftsman' && (
              <>
                {job.status === 'accepted' && (
                  <button
                    onClick={() => handleQuickAction('start')}
                    className="px-3 py-1 bg-blue-600 text-white text-xs rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Başlat
                  </button>
                )}
                {job.status === 'in_progress' && (
                  <button
                    onClick={() => handleQuickAction('complete')}
                    className="px-3 py-1 bg-green-600 text-white text-xs rounded-lg hover:bg-green-700 transition-colors"
                  >
                    Tamamla
                  </button>
                )}
              </>
            )}

            {/* Contact Button */}
            {((userType === 'customer' && job.craftsman) || (userType === 'craftsman' && job.customer)) && (
              <button className="px-3 py-1 bg-gray-600 text-white text-xs rounded-lg hover:bg-gray-700 transition-colors">
                İletişim
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default JobCard;