import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const CraftsmanJobHistoryPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('jobs');
  const [filterStatus, setFilterStatus] = useState('all');
  const [dateRange, setDateRange] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [quotes, setQuotes] = useState([]);
  const [loadingQuotes, setLoadingQuotes] = useState(false);

  // Mock Data
  const [jobs] = useState([
    {
      id: 1,
      customer: 'Ahmet Yılmaz',
      service: 'Elektrik Tesisatı Onarımı',
      description: 'Ev elektrik panosu arızası, LED aydınlatma montajı',
      location: 'Kadıköy, İstanbul',
      status: 'completed',
      payment: 2500,
      date_created: '2025-01-15',
      date_completed: '2025-01-17',
      duration: '6 saat',
      rating: 5,
      review: 'Çok memnun kaldım. Hızlı ve kaliteli iş çıkardı.',
      images: ['job1_before.jpg', 'job1_after.jpg']
    },
    {
      id: 2,
      customer: 'Ayşe Demir',
      service: 'Ofis Aydınlatması',
      description: 'Ofis LED aydınlatma sistemi kurulumu',
      location: 'Şişli, İstanbul',
      status: 'in_progress',
      payment: 3200,
      date_created: '2025-01-20',
      date_completed: null,
      duration: '8 saat (tahmini)',
      rating: null,
      review: null,
      images: ['job2_progress.jpg']
    },
    {
      id: 3,
      customer: 'Mehmet Kaya',
      service: 'Ev Elektrik Kontrolü',
      description: 'Genel elektrik sistemi kontrolü ve bakımı',
      location: 'Beşiktaş, İstanbul',
      status: 'completed',
      payment: 800,
      date_created: '2025-01-10',
      date_completed: '2025-01-10',
      duration: '2 saat',
      rating: 4,
      review: 'İyi iş çıkardı, teşekkürler.',
      images: []
    },
    {
      id: 4,
      customer: 'Fatma Öz',
      service: 'Klima Elektrik Bağlantısı',
      description: 'Yeni klima için elektrik bağlantısı',
      location: 'Kadıköy, İstanbul',
      status: 'cancelled',
      payment: 0,
      date_created: '2025-01-08',
      date_completed: null,
      duration: null,
      rating: null,
      review: 'Müşteri iptal etti',
      images: []
    }
  ]);

  const [quotesData] = useState([
    {
      id: 1,
      customer: 'Ali Veli',
      service: 'Banyo Elektrik İşleri',
      description: 'Banyo renovasyonu için elektrik işleri',
      location: 'Üsküdar, İstanbul',
      status: 'pending',
      quote_amount: 1800,
      date_created: '2025-01-22',
      response_deadline: '2025-01-25',
      customer_budget: '1500-2000₺'
    },
    {
      id: 2,
      customer: 'Zeynep Kara',
      service: 'Ev Elektrik Yenileme',
      description: 'Eski ev elektrik sisteminin yenilenmesi',
      location: 'Bakırköy, İstanbul',
      status: 'accepted',
      quote_amount: 4500,
      date_created: '2025-01-18',
      response_deadline: '2025-01-21',
      customer_budget: '4000-5000₺'
    },
    {
      id: 3,
      customer: 'Hasan Çelik',
      service: 'Dış Aydınlatma',
      description: 'Villa dış aydınlatma sistemi',
      location: 'Sarıyer, İstanbul',
      status: 'rejected',
      quote_amount: 6000,
      date_created: '2025-01-12',
      response_deadline: '2025-01-15',
      customer_budget: '3000-4000₺'
    }
  ]);

  // Statistics
  const stats = {
    total_jobs: jobs.length,
    completed_jobs: jobs.filter(job => job.status === 'completed').length,
    in_progress: jobs.filter(job => job.status === 'in_progress').length,
    total_earnings: jobs.filter(job => job.status === 'completed').reduce((sum, job) => sum + job.payment, 0),
    average_rating: jobs.filter(job => job.rating).reduce((sum, job) => sum + job.rating, 0) / jobs.filter(job => job.rating).length || 0,
    pending_quotes: quotes.filter(quote => quote.status === 'pending').length
  };

  // Filter functions
  const filterJobs = () => {
    let filtered = jobs;

    if (filterStatus !== 'all') {
      filtered = filtered.filter(job => job.status === filterStatus);
    }

    if (searchTerm) {
      filtered = filtered.filter(job => 
        job.customer.toLowerCase().includes(searchTerm.toLowerCase()) ||
        job.service.toLowerCase().includes(searchTerm.toLowerCase()) ||
        job.description.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    if (dateRange !== 'all') {
      const now = new Date();
      const filterDate = new Date();
      
      switch(dateRange) {
        case 'week':
          filterDate.setDate(now.getDate() - 7);
          break;
        case 'month':
          filterDate.setMonth(now.getMonth() - 1);
          break;
        case 'year':
          filterDate.setFullYear(now.getFullYear() - 1);
          break;
      }
      
      filtered = filtered.filter(job => new Date(job.date_created) >= filterDate);
    }

    return filtered.sort((a, b) => new Date(b.date_created) - new Date(a.date_created));
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'completed': return 'bg-green-100 text-green-800';
      case 'in_progress': return 'bg-blue-100 text-blue-800';
      case 'cancelled': return 'bg-red-100 text-red-800';
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      case 'accepted': return 'bg-green-100 text-green-800';
      case 'rejected': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'completed': return 'Tamamlandı';
      case 'in_progress': return 'Devam Ediyor';
      case 'cancelled': return 'İptal Edildi';
      case 'pending': return 'Bekliyor';
      case 'accepted': return 'Kabul Edildi';
      case 'rejected': return 'Reddedildi';
      default: return status;
    }
  };

  const renderStars = (rating) => {
    if (!rating) return null;
    return Array.from({ length: 5 }, (_, i) => (
      <svg
        key={i}
        className={`w-4 h-4 ${i < rating ? 'text-yellow-400' : 'text-gray-300'}`}
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
      </svg>
    ));
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => navigate('/dashboard/craftsman')}
                className="p-2 hover:bg-gray-100 rounded-full transition-colors"
              >
                <svg className="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </button>
              <div>
                <h1 className="text-xl font-semibold text-gray-900">
                  📊 Geçmiş İşlemlerim
                </h1>
                <p className="text-sm text-gray-600">
                  İş geçmişiniz ve teklifleriniz
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 py-6">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-4 mb-8">
          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-600">{stats.total_jobs}</div>
              <div className="text-sm text-gray-600">Toplam İş</div>
            </div>
          </div>
          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-green-600">{stats.completed_jobs}</div>
              <div className="text-sm text-gray-600">Tamamlanan</div>
            </div>
          </div>
          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-purple-600">{stats.in_progress}</div>
              <div className="text-sm text-gray-600">Devam Eden</div>
            </div>
          </div>
          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-indigo-600">{stats.total_earnings.toLocaleString()}₺</div>
              <div className="text-sm text-gray-600">Toplam Kazanç</div>
            </div>
          </div>
          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-yellow-600">{stats.average_rating.toFixed(1)}</div>
              <div className="text-sm text-gray-600">Ortalama Puan</div>
            </div>
          </div>
          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-orange-600">{stats.pending_quotes}</div>
              <div className="text-sm text-gray-600">Bekleyen Teklif</div>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-lg shadow-sm mb-6">
          <div className="border-b border-gray-200">
            <nav className="flex space-x-8 px-6">
              <button
                onClick={() => setActiveTab('jobs')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'jobs'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                🔧 İşlerim ({jobs.length})
              </button>
              <button
                onClick={() => setActiveTab('quotes')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'quotes'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                💰 Tekliflerim ({quotes.length})
              </button>
            </nav>
          </div>

          {/* Filters */}
          <div className="p-6 border-b border-gray-200">
            <div className="grid md:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Durum
                </label>
                <select
                  value={filterStatus}
                  onChange={(e) => setFilterStatus(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="all">Tüm Durumlar</option>
                  {activeTab === 'jobs' ? (
                    <>
                      <option value="completed">Tamamlanan</option>
                      <option value="in_progress">Devam Eden</option>
                      <option value="cancelled">İptal Edilen</option>
                    </>
                  ) : (
                    <>
                      <option value="pending">Bekleyen</option>
                      <option value="accepted">Kabul Edilen</option>
                      <option value="rejected">Reddedilen</option>
                    </>
                  )}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Tarih Aralığı
                </label>
                <select
                  value={dateRange}
                  onChange={(e) => setDateRange(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="all">Tüm Zamanlar</option>
                  <option value="week">Son Hafta</option>
                  <option value="month">Son Ay</option>
                  <option value="year">Son Yıl</option>
                </select>
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Arama
                </label>
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Müşteri adı, hizmet türü..."
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>
          </div>

          {/* Content */}
          <div className="p-6">
            {activeTab === 'jobs' ? (
              <div className="space-y-4">
                {filterJobs().map((job) => (
                  <div key={job.id} className="border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex-1">
                        <div className="flex items-center space-x-3 mb-2">
                          <h3 className="text-lg font-medium text-gray-900">{job.service}</h3>
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(job.status)}`}>
                            {getStatusText(job.status)}
                          </span>
                        </div>
                        <p className="text-sm text-gray-600 mb-2">{job.description}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500 mb-2">
                          <span>👤 {job.customer}</span>
                          <span>📍 {job.location}</span>
                          <span>📅 {job.date_created}</span>
                          {job.duration && <span>⏱️ {job.duration}</span>}
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-lg font-semibold text-green-600 mb-1">
                          {job.payment > 0 ? `${job.payment.toLocaleString()}₺` : '-'}
                        </div>
                        {job.rating && (
                          <div className="flex items-center space-x-1">
                            {renderStars(job.rating)}
                            <span className="text-sm text-gray-500 ml-1">{job.rating}</span>
                          </div>
                        )}
                      </div>
                    </div>

                    {job.review && (
                      <div className="bg-gray-50 rounded-lg p-3 mb-4">
                        <p className="text-sm text-gray-700 italic">"{job.review}"</p>
                      </div>
                    )}

                    {job.images.length > 0 && (
                      <div className="flex space-x-2 mb-4">
                        {job.images.map((image, index) => (
                          <div key={index} className="w-16 h-16 bg-gray-200 rounded-lg flex items-center justify-center">
                            <svg className="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                          </div>
                        ))}
                      </div>
                    )}

                    <div className="flex items-center space-x-3">
                      <button
                        onClick={() => navigate(`/messages/${job.customer}`)}
                        className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
                      >
                        Mesaj Gönder
                      </button>
                      {job.status === 'completed' && !job.rating && (
                        <button className="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors text-sm">
                          Değerlendirme İste
                        </button>
                      )}
                      <button className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors text-sm">
                        Detay Görüntüle
                      </button>
                    </div>
                  </div>
                ))}

                {filterJobs().length === 0 && (
                  <div className="text-center py-12">
                    <svg className="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v6a2 2 0 002 2h6a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                    <h3 className="text-lg font-medium text-gray-900 mb-2">İş bulunamadı</h3>
                    <p className="text-gray-600">Filtrelere uygun iş bulunmuyor.</p>
                  </div>
                )}
              </div>
            ) : (
              <div className="space-y-4">
                {quotes.map((quote) => (
                  <div key={quote.id} className="border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex-1">
                        <div className="flex items-center space-x-3 mb-2">
                          <h3 className="text-lg font-medium text-gray-900">{quote.service}</h3>
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(quote.status)}`}>
                            {getStatusText(quote.status)}
                          </span>
                        </div>
                        <p className="text-sm text-gray-600 mb-2">{quote.description}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500 mb-2">
                          <span>👤 {quote.customer}</span>
                          <span>📍 {quote.location}</span>
                          <span>📅 {quote.date_created}</span>
                          {quote.response_deadline && (
                            <span>⏰ Son: {quote.response_deadline}</span>
                          )}
                        </div>
                        <div className="text-sm text-gray-600">
                          <span>💰 Müşteri Bütçesi: {quote.customer_budget}</span>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-lg font-semibold text-blue-600 mb-1">
                          {quote.quote_amount.toLocaleString()}₺
                        </div>
                        <div className="text-sm text-gray-500">Teklif Tutarı</div>
                      </div>
                    </div>

                    <div className="flex items-center space-x-3">
                      {quote.status === 'pending' && (
                        <>
                          <button className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors text-sm">
                            Teklifi Güncelle
                          </button>
                          <button className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm">
                            Teklifi Geri Çek
                          </button>
                        </>
                      )}
                      <button
                        onClick={() => navigate(`/messages/${quote.customer}`)}
                        className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
                      >
                        Müşteriyle İletişim
                      </button>
                      <button className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors text-sm">
                        Detay Görüntüle
                      </button>
                    </div>
                  </div>
                ))}

                {quotes.length === 0 && (
                  <div className="text-center py-12">
                    <svg className="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                    </svg>
                    <h3 className="text-lg font-medium text-gray-900 mb-2">Teklif bulunamadı</h3>
                    <p className="text-gray-600">Henüz teklif vermediniz.</p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CraftsmanJobHistoryPage;