import React, { useState, useEffect } from 'react';
import { useAuth } from '../../context/AuthContext';
import api from '../../utils/api';
import JobCard from './JobCard';
import JobDetail from './JobDetail';
import EmergencyServiceCard from './EmergencyServiceCard';
import WarrantyCard from './WarrantyCard';
import TimeTracker from './TimeTracker';
import LoadingSpinner from '../ui/LoadingSpinner';
import ErrorMessage from '../ui/ErrorMessage';

const JobDashboard = () => {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('active');
  const [jobs, setJobs] = useState([]);
  const [warranties, setWarranties] = useState([]);
  const [emergencies, setEmergencies] = useState([]);
  const [selectedJob, setSelectedJob] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [performanceMetrics, setPerformanceMetrics] = useState(null);

  const userType = user?.user_type || 'customer';

  useEffect(() => {
    loadDashboardData();
  }, [activeTab, user]);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      setError(null);

      const promises = [];

      // Load jobs based on active tab
      if (activeTab === 'active') {
        promises.push(
          api.get('/job-management/jobs', { 
            params: { 
              user_type: userType, 
              status: 'in_progress' 
            } 
          })
        );
      } else if (activeTab === 'completed') {
        promises.push(
          api.get('/job-management/jobs', { 
            params: { 
              user_type: userType, 
              status: 'completed' 
            } 
          })
        );
      } else if (activeTab === 'all') {
        promises.push(
          api.get('/job-management/jobs', { 
            params: { user_type: userType } 
          })
        );
      }

      // Load warranties
      if (activeTab === 'warranties') {
        promises.push(
          api.get('/job-management/warranties', { 
            params: { user_type: userType } 
          })
        );
      }

      // Load emergency services for craftsmen
      if (userType === 'craftsman' && activeTab === 'emergency') {
        promises.push(
          api.get('/job-management/emergency-services/nearby')
        );
      }

      // Load performance metrics
      promises.push(
        api.get('/job-management/analytics/performance', { 
          params: { user_type: userType } 
        })
      );

      const results = await Promise.all(promises);

      if (activeTab === 'warranties') {
        setWarranties(results[0].data.data || []);
      } else if (userType === 'craftsman' && activeTab === 'emergency') {
        setEmergencies(results[0].data.data || []);
      } else {
        setJobs(results[0].data.data?.jobs || []);
      }

      // Performance metrics are always the last promise
      setPerformanceMetrics(results[results.length - 1].data.data || {});

    } catch (err) {
      setError(err.message);
      console.error('Failed to load dashboard data:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleJobSelect = (job) => {
    setSelectedJob(job);
  };

  const handleJobUpdate = () => {
    loadDashboardData();
    setSelectedJob(null);
  };

  const tabs = [
    { id: 'active', label: 'Aktif İşler', icon: '🔧' },
    { id: 'completed', label: 'Tamamlanan', icon: '✅' },
    { id: 'warranties', label: 'Garantiler', icon: '🛡️' },
    { id: 'all', label: 'Tüm İşler', icon: '📋' }
  ];

  // Add emergency tab for craftsmen
  if (userType === 'craftsman') {
    tabs.splice(3, 0, { id: 'emergency', label: 'Acil Servis', icon: '🚨' });
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          İş Yönetimi
        </h1>
        <p className="text-gray-600">
          İşlerinizi takip edin, malzemeleri yönetin ve garantileri kontrol edin
        </p>
      </div>

      {/* Performance Metrics */}
      {performanceMetrics && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-blue-100 text-blue-600">
                📊
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Toplam İş</p>
                <p className="text-2xl font-bold text-gray-900">
                  {performanceMetrics.total_jobs || 0}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-green-100 text-green-600">
                ✅
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tamamlanan</p>
                <p className="text-2xl font-bold text-gray-900">
                  {performanceMetrics.completed_jobs || 0}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-yellow-100 text-yellow-600">
                📈
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tamamlanma Oranı</p>
                <p className="text-2xl font-bold text-gray-900">
                  {Math.round(performanceMetrics.completion_rate || 0)}%
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-full bg-purple-100 text-purple-600">
                ⭐
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Ortalama Puan</p>
                <p className="text-2xl font-bold text-gray-900">
                  {performanceMetrics.avg_satisfaction || 0}/5
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tabs */}
      <div className="border-b border-gray-200 mb-6">
        <nav className="-mb-px flex space-x-8">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
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

      {error && <ErrorMessage message={error} onClose={() => setError(null)} />}

      {/* Content */}
      <div className="space-y-6">
        {activeTab === 'warranties' ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {warranties.length > 0 ? (
              warranties.map((warranty) => (
                <WarrantyCard
                  key={warranty.id}
                  warranty={warranty}
                  userType={userType}
                  onUpdate={loadDashboardData}
                />
              ))
            ) : (
              <div className="col-span-full text-center py-12">
                <div className="text-gray-400 mb-4">🛡️</div>
                <p className="text-gray-600">Aktif garanti bulunamadı</p>
              </div>
            )}
          </div>
        ) : activeTab === 'emergency' && userType === 'craftsman' ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {emergencies.length > 0 ? (
              emergencies.map((emergency) => (
                <EmergencyServiceCard
                  key={emergency.id}
                  emergency={emergency}
                  onUpdate={loadDashboardData}
                />
              ))
            ) : (
              <div className="col-span-full text-center py-12">
                <div className="text-gray-400 mb-4">🚨</div>
                <p className="text-gray-600">Yakında acil servis talebi yok</p>
              </div>
            )}
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {jobs.length > 0 ? (
              jobs.map((job) => (
                <JobCard
                  key={job.id}
                  job={job}
                  userType={userType}
                  onSelect={handleJobSelect}
                  onUpdate={loadDashboardData}
                />
              ))
            ) : (
              <div className="col-span-full text-center py-12">
                <div className="text-gray-400 mb-4">📋</div>
                <p className="text-gray-600">
                  {activeTab === 'active' ? 'Aktif iş bulunamadı' : 
                   activeTab === 'completed' ? 'Tamamlanan iş bulunamadı' : 
                   'İş bulunamadı'}
                </p>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Job Detail Modal */}
      {selectedJob && (
        <JobDetail
          job={selectedJob}
          userType={userType}
          onClose={() => setSelectedJob(null)}
          onUpdate={handleJobUpdate}
        />
      )}

      {/* Time Tracker for Craftsmen */}
      {userType === 'craftsman' && (
        <TimeTracker onUpdate={loadDashboardData} />
      )}
    </div>
  );
};

export default JobDashboard;