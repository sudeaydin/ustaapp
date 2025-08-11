import React, { useState, useEffect } from 'react';
import { useAuth } from '../../context/AuthContext';
import api from '../../utils/api';
import { formatTime } from '../../utils/formatters';

const TimeTracker = ({ onUpdate }) => {
  const { user } = useAuth();
  const [activeEntry, setActiveEntry] = useState(null);
  const [activeJobs, setActiveJobs] = useState([]);
  const [selectedJobId, setSelectedJobId] = useState('');
  const [entryType, setEntryType] = useState('work');
  const [description, setDescription] = useState('');
  const [location, setLocation] = useState('');
  const [elapsedTime, setElapsedTime] = useState(0);
  const [isMinimized, setIsMinimized] = useState(false);

  useEffect(() => {
    loadActiveJobs();
    checkActiveEntry();
  }, []);

  useEffect(() => {
    let interval;
    if (activeEntry) {
      interval = setInterval(() => {
        const startTime = new Date(activeEntry.start_time);
        const now = new Date();
        setElapsedTime(Math.floor((now - startTime) / 1000));
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [activeEntry]);

  const loadActiveJobs = async () => {
    try {
      const response = await api.get('/job-management/jobs', {
        params: { 
          user_type: 'craftsman',
          status: 'in_progress'
        }
      });
      setActiveJobs(response.data.data?.jobs || []);
    } catch (error) {
      console.error('Failed to load active jobs:', error);
    }
  };

  const checkActiveEntry = async () => {
    try {
      // Check if there's an active time entry
      const response = await api.get('/job-management/craftsman/time-summary');
      // This would need to be enhanced to check for active entries
      // For now, we'll assume no active entry
    } catch (error) {
      console.error('Failed to check active entry:', error);
    }
  };

  const startTimeTracking = async () => {
    if (!selectedJobId) {
      alert('Lütfen bir iş seçin');
      return;
    }

    try {
      const response = await api.post(`/job-management/jobs/${selectedJobId}/time/start`, {
        entry_type: entryType,
        description: description,
        location: location
      });

      setActiveEntry(response.data.data);
      setElapsedTime(0);
      setDescription('');
      setLocation('');
      onUpdate();
    } catch (error) {
      console.error('Failed to start time tracking:', error);
      alert('Zaman takibi başlatılamadı: ' + error.message);
    }
  };

  const endTimeTracking = async () => {
    if (!activeEntry) return;

    try {
      const notes = prompt('İsteğe bağlı notlar:');
      
      await api.put(`/job-management/time-entries/${activeEntry.id}/end`, {
        notes: notes || undefined
      });

      setActiveEntry(null);
      setElapsedTime(0);
      onUpdate();
    } catch (error) {
      console.error('Failed to end time tracking:', error);
      alert('Zaman takibi sonlandırılamadı: ' + error.message);
    }
  };

  const entryTypes = [
    { value: 'work', label: 'Çalışma', icon: '🔧' },
    { value: 'travel', label: 'Seyahat', icon: '🚗' },
    { value: 'break', label: 'Mola', icon: '☕' },
    { value: 'materials', label: 'Malzeme', icon: '📦' },
    { value: 'consultation', label: 'Danışmanlık', icon: '💬' }
  ];

  if (user?.user_type !== 'craftsman') {
    return null;
  }

  return (
    <div className={`fixed bottom-4 right-4 bg-white rounded-lg shadow-lg border border-gray-200 transition-all duration-300 ${
      isMinimized ? 'w-64' : 'w-80'
    }`}>
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b border-gray-200 bg-blue-50">
        <div className="flex items-center">
          <span className="mr-2">⏱️</span>
          <h3 className="font-semibold text-gray-900">Zaman Takibi</h3>
        </div>
        <button
          onClick={() => setIsMinimized(!isMinimized)}
          className="text-gray-400 hover:text-gray-600 transition-colors"
        >
          {isMinimized ? '▲' : '▼'}
        </button>
      </div>

      {!isMinimized && (
        <div className="p-4">
          {activeEntry ? (
            /* Active Time Tracking */
            <div className="space-y-4">
              <div className="text-center">
                <div className="text-3xl font-bold text-blue-600 mb-2">
                  {formatTime(elapsedTime)}
                </div>
                <p className="text-sm text-gray-600">
                  {entryTypes.find(t => t.value === activeEntry.entry_type)?.label} - 
                  {activeJobs.find(j => j.id === activeEntry.job_id)?.title}
                </p>
              </div>

              <div className="flex space-x-2">
                <button
                  onClick={endTimeTracking}
                  className="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-medium"
                >
                  Durdur
                </button>
              </div>

              {activeEntry.description && (
                <div className="text-sm text-gray-600 bg-gray-50 rounded-lg p-3">
                  <strong>Açıklama:</strong> {activeEntry.description}
                </div>
              )}
            </div>
          ) : (
            /* Start Time Tracking */
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  İş Seçin
                </label>
                <select
                  value={selectedJobId}
                  onChange={(e) => setSelectedJobId(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="">İş seçin...</option>
                  {activeJobs.map(job => (
                    <option key={job.id} value={job.id}>
                      {job.title}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Aktivite Türü
                </label>
                <select
                  value={entryType}
                  onChange={(e) => setEntryType(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  {entryTypes.map(type => (
                    <option key={type.value} value={type.value}>
                      {type.icon} {type.label}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Açıklama (İsteğe bağlı)
                </label>
                <input
                  type="text"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Ne yapıyorsunuz?"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Konum (İsteğe bağlı)
                </label>
                <input
                  type="text"
                  value={location}
                  onChange={(e) => setLocation(e.target.value)}
                  placeholder="Neredesiniz?"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <button
                onClick={startTimeTracking}
                disabled={!selectedJobId}
                className="w-full px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors font-medium"
              >
                Başlat
              </button>
            </div>
          )}
        </div>
      )}

      {/* Minimized View */}
      {isMinimized && activeEntry && (
        <div className="p-4">
          <div className="text-center">
            <div className="text-xl font-bold text-blue-600">
              {formatTime(elapsedTime)}
            </div>
            <p className="text-xs text-gray-600 truncate">
              {entryTypes.find(t => t.value === activeEntry.entry_type)?.icon} 
              {activeJobs.find(j => j.id === activeEntry.job_id)?.title}
            </p>
            <button
              onClick={endTimeTracking}
              className="mt-2 px-3 py-1 bg-red-600 text-white rounded text-xs hover:bg-red-700 transition-colors"
            >
              Durdur
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default TimeTracker;