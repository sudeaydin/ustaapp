import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const CustomerJobHistoryPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('requests');
  const [filterStatus, setFilterStatus] = useState('all');
  const [dateRange, setDateRange] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [quotes, setQuotes] = useState([]);
  const [loadingQuotes, setLoadingQuotes] = useState(false);

  useEffect(() => {
    if (activeTab === 'quotes') {
      loadQuotes();
    }
  }, [activeTab]);

  const loadQuotes = async () => {
    try {
      setLoadingQuotes(true);
      const token = localStorage.getItem('token');
      const response = await fetch('/api/quote-requests/my-quotes', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      const data = await response.json();
      if (data.success) {
        setQuotes(data.quotes);
      }
    } catch (error) {
      console.error('Teklifler yüklenirken hata:', error);
    } finally {
      setLoadingQuotes(false);
    }
  };

  // Mock Data
  const [requests] = useState([
    {
      id: 1,
      service: 'Elektrik Tesisatı Onarımı',
      description: 'Ev elektrik panosu arızası, LED aydınlatma montajı',
      category: 'Elektrikçi',
      location: 'Kadıköy, İstanbul',
      status: 'completed',
      budget: '2000-3000₺',
      date_created: '2025-01-15',
      date_completed: '2025-01-17',
      craftsman: 'Ahmet Yılmaz - Yılmaz Elektrik',
      final_price: 2500,
      rating_given: 5,
      review_given: 'Çok memnun kaldım. Hızlı ve kaliteli iş çıkardı.',
      quotes_received: 3
    },
    {
      id: 2,
      service: 'Banyo Tadilat İşi',
      description: 'Banyo renovasyonu, seramik değişimi',
      category: 'Tadilat',
      location: 'Şişli, İstanbul',
      status: 'in_progress',
      budget: '5000-7000₺',
      date_created: '2025-01-20',
      date_completed: null,
      craftsman: 'Mehmet Kaya - Kaya Tadilat',
      final_price: 6200,
      rating_given: null,
      review_given: null,
      quotes_received: 5
    },
    {
      id: 3,
      service: 'Klima Montajı',
      description: '2 adet split klima montajı',
      category: 'Klima Teknisyeni',
      location: 'Beşiktaş, İstanbul',
      status: 'completed',
      budget: '1000-1500₺',
      date_created: '2025-01-10',
      date_completed: '2025-01-12',
      craftsman: 'Ali Demir - Demir Klima',
      final_price: 1200,
      rating_given: 4,
      review_given: 'İyi iş çıkardı, zamanında geldi.',
      quotes_received: 2
    },
    {
      id: 4,
      service: 'Ev Temizliği',
      description: 'Genel ev temizliği, cam temizliği',
      category: 'Temizlik',
      location: 'Kadıköy, İstanbul',
      status: 'cancelled',
      budget: '200-300₺',
      date_created: '2025-01-08',
      date_completed: null,
      craftsman: null,
      final_price: 0,
      rating_given: null,
      review_given: 'Uygun usta bulunamadı',
      quotes_received: 1
    }
  ]);

  const [quotesData] = useState([
    {
      id: 1,
      request_id: 2,
      service: 'Banyo Tadilat İşi',
      craftsman: 'Mehmet Kaya',
      business_name: 'Kaya Tadilat',
      quote_amount: 6200,
      status: 'accepted',
      date_received: '2025-01-21',
      response_time: '2 saat',
      craftsman_rating: 4.9,
      craftsman_reviews: 203,
      description: 'Banyo tamamen yenilenecek, kaliteli malzeme kullanılacak',
      includes: ['Malzeme', 'İşçilik', '1 yıl garanti']
    },
    {
      id: 2,
      request_id: 2,
      service: 'Banyo Tadilat İşi',
      craftsman: 'Hasan Çelik',
      business_name: 'Çelik Yapı',
      quote_amount: 5800,
      status: 'rejected',
      date_received: '2025-01-21',
      response_time: '4 saat',
      craftsman_rating: 4.6,
      craftsman_reviews: 156,
      description: 'Ekonomik çözüm, hızlı teslim',
      includes: ['Malzeme', 'İşçilik']
    },
    {
      id: 3,
      request_id: 5,
      service: 'Boyama İşi',
      craftsman: 'Ayşe Kara',
      business_name: 'Kara Boyacılık',
      quote_amount: 2400,
      status: 'pending',
      date_received: '2025-01-23',
      response_time: '1 saat',
      craftsman_rating: 4.4,
      craftsman_reviews: 89,
      description: 'Duvar boyama, tavan boyama, dekoratif işler',
      includes: ['Boya malzemesi', 'İşçilik', 'Temizlik']
    }
  ]);

  const [reviews] = useState([
    {
      id: 1,
      craftsman: 'Ahmet Yılmaz',
      business_name: 'Yılmaz Elektrik',
      service: 'Elektrik Tesisatı Onarımı',
      rating: 5,
      review: 'Çok memnun kaldım. Hızlı ve kaliteli iş çıkardı. Kesinlikle tavsiye ederim.',
      date: '2025-01-17',
      helpful_votes: 3
    },
    {
      id: 2,
      craftsman: 'Ali Demir',
      business_name: 'Demir Klima',
      service: 'Klima Montajı',
      rating: 4,
      review: 'İyi iş çıkardı, zamanında geldi. Fiyat uygundu.',
      date: '2025-01-12',
      helpful_votes: 1
    }
  ]);

  // Statistics
  const stats = {
    total_requests: requests.length,
    completed_requests: requests.filter(req => req.status === 'completed').length,
    in_progress: requests.filter(req => req.status === 'in_progress').length,
    total_spent: requests.filter(req => req.status === 'completed').reduce((sum, req) => sum + req.final_price, 0),
    average_rating_given: reviews.reduce((sum, review) => sum + review.rating, 0) / reviews.length || 0,
    pending_quotes: quotes.filter(quote => quote.status === 'pending').length
  };

  // Filter functions
  const filterRequests = () => {
    let filtered = requests;

    if (filterStatus !== 'all') {
      filtered = filtered.filter(req => req.status === filterStatus);
    }

    if (searchTerm) {
      filtered = filtered.filter(req => 
        req.service.toLowerCase().includes(searchTerm.toLowerCase()) ||
        req.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
        req.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (req.craftsman && req.craftsman.toLowerCase().includes(searchTerm.toLowerCase()))
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
      
      filtered = filtered.filter(req => new Date(req.date_created) >= filterDate);
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

  const getQuoteStatusColor = (status) => {
    switch(status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      case 'quoted': return 'bg-blue-100 text-blue-800';
      case 'accepted': return 'bg-green-100 text-green-800';
      case 'rejected': return 'bg-red-100 text-red-800';
      case 'details_requested': return 'bg-orange-100 text-orange-800';
      case 'revision_requested': return 'bg-purple-100 text-purple-800';
      case 'completed': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getQuoteStatusText = (status) => {
    switch(status) {
      case 'pending': return 'Beklemede';
      case 'quoted': return 'Teklif Alındı';
      case 'accepted': return 'Kabul Edildi';
      case 'rejected': return 'Reddedildi';
      case 'details_requested': return 'Detay İstendi';
      case 'revision_requested': return 'Revizyon İstendi';
      case 'completed': return 'Tamamlandı';
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
                onClick={() => navigate('/dashboard/customer')}
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
                  Talep geçmişiniz ve aldığınız teklifler
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
              <div className="text-2xl font-bold text-green-600">{stats.total_requests}</div>
              <div className="text-sm text-gray-600">Toplam Talep</div>
            </div>
          </div>
          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-600">{stats.completed_requests}</div>
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
              <div className="text-2xl font-bold text-indigo-600">{stats.total_spent.toLocaleString()}₺</div>
              <div className="text-sm text-gray-600">Toplam Harcama</div>
            </div>
          </div>
          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-yellow-600">{stats.average_rating_given.toFixed(1)}</div>
              <div className="text-sm text-gray-600">Ortalama Puanım</div>
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
                onClick={() => setActiveTab('requests')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'requests'
                    ? 'border-green-500 text-green-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                📋 Taleplerim ({requests.length})
              </button>
              <button
                onClick={() => setActiveTab('quotes')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'quotes'
                    ? 'border-green-500 text-green-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                💰 Tekliflerim ({quotes.length})
              </button>
              <button
                onClick={() => setActiveTab('reviews')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'reviews'
                    ? 'border-green-500 text-green-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                ⭐ Verdiğim Yorumlar ({reviews.length})
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
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                >
                  <option value="all">Tüm Durumlar</option>
                  {activeTab === 'requests' ? (
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
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
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
                  placeholder="Hizmet türü, usta adı, açıklama..."
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                />
              </div>
            </div>
          </div>

          {/* Content */}
          <div className="p-6">
            {activeTab === 'requests' ? (
              <div className="space-y-4">
                {filterRequests().map((request) => (
                  <div key={request.id} className="border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex-1">
                        <div className="flex items-center space-x-3 mb-2">
                          <h3 className="text-lg font-medium text-gray-900">{request.service}</h3>
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(request.status)}`}>
                            {getStatusText(request.status)}
                          </span>
                        </div>
                        <p className="text-sm text-gray-600 mb-2">{request.description}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500 mb-2">
                          <span>🏷️ {request.category}</span>
                          <span>📍 {request.location}</span>
                          <span>📅 {request.date_created}</span>
                          <span>💰 {request.budget}</span>
                        </div>
                        {request.craftsman && (
                          <div className="text-sm text-green-600 font-medium">
                            👤 {request.craftsman}
                          </div>
                        )}
                      </div>
                      <div className="text-right">
                        <div className="text-lg font-semibold text-green-600 mb-1">
                          {request.final_price > 0 ? `${request.final_price.toLocaleString()}₺` : '-'}
                        </div>
                        <div className="text-sm text-gray-500 mb-2">
                          {request.quotes_received} teklif alındı
                        </div>
                        {request.rating_given && (
                          <div className="flex items-center space-x-1">
                            {renderStars(request.rating_given)}
                            <span className="text-sm text-gray-500 ml-1">{request.rating_given}</span>
                          </div>
                        )}
                      </div>
                    </div>

                    {request.review_given && (
                      <div className="bg-gray-50 rounded-lg p-3 mb-4">
                        <p className="text-sm text-gray-700 italic">"{request.review_given}"</p>
                      </div>
                    )}

                    <div className="flex items-center space-x-3">
                      {request.craftsman && (
                        <button
                          onClick={() => navigate(`/messages/${request.craftsman}`)}
                          className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors text-sm"
                        >
                          Mesaj Gönder
                        </button>
                      )}
                      {request.status === 'completed' && !request.rating_given && (
                        <button className="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors text-sm">
                          Değerlendir
                        </button>
                      )}
                      <button
                        onClick={() => navigate(`/craftsmen?category=${request.category}`)}
                        className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
                      >
                        Benzer Hizmet
                      </button>
                      <button className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors text-sm">
                        Detay Görüntüle
                      </button>
                    </div>
                  </div>
                ))}

                {filterRequests().length === 0 && (
                  <div className="text-center py-12">
                    <svg className="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v6a2 2 0 002 2h6a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                    <h3 className="text-lg font-medium text-gray-900 mb-2">Talep bulunamadı</h3>
                    <p className="text-gray-600">Filtrelere uygun talep bulunmuyor.</p>
                  </div>
                )}
              </div>
            ) : activeTab === 'quotes' ? (
              <div className="space-y-4">
                {loadingQuotes ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                    <p className="text-gray-600 mt-2">Teklifler yükleniyor...</p>
                  </div>
                ) : quotes.length > 0 ? (
                  quotes.map((quote) => (
                    <div key={quote.id} className="border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow">
                      <div className="flex items-start justify-between mb-4">
                        <div className="flex-1">
                          <div className="flex items-center space-x-3 mb-2">
                            <h3 className="text-lg font-medium text-gray-900">{quote.category}</h3>
                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getQuoteStatusColor(quote.status)}`}>
                              {getQuoteStatusText(quote.status)}
                            </span>
                          </div>
                          <p className="text-sm text-gray-600 mb-2">{quote.description}</p>
                          <div className="flex items-center space-x-4 text-sm text-gray-500 mb-2">
                            <span>👤 {quote.craftsman?.name}</span>
                            <span>🏠 {quote.area_type}</span>
                            <span>📅 {new Date(quote.created_at).toLocaleDateString('tr-TR')}</span>
                            <span>💰 {quote.budget_range} TL</span>
                          </div>
                          {quote.square_meters && (
                            <div className="text-sm text-gray-600 mb-2">
                              <span className="font-medium">Metrekare:</span> {quote.square_meters} m²
                            </div>
                          )}
                        </div>
                        <div className="text-right">
                          {quote.quoted_price ? (
                            <div className="text-lg font-semibold text-green-600 mb-1">
                              {parseFloat(quote.quoted_price).toLocaleString()} TL
                            </div>
                          ) : (
                            <div className="text-lg font-medium text-gray-500 mb-1">
                              Beklemede
                            </div>
                          )}
                          <div className="text-sm text-gray-500">
                            {quote.estimated_start_date && quote.estimated_end_date && (
                              <div>{quote.estimated_start_date} - {quote.estimated_end_date}</div>
                            )}
                          </div>
                        </div>
                      </div>

                      {quote.craftsman_notes && (
                        <div className="bg-blue-50 rounded-lg p-3 mb-4">
                          <p className="text-sm text-blue-800">{quote.craftsman_notes}</p>
                        </div>
                      )}

                      <div className="flex items-center space-x-3">
                        {quote.status === 'quoted' && (
                          <>
                            <button 
                              onClick={() => navigate(`/payment/quote/${quote.id}`)}
                              className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors text-sm"
                            >
                              Kabul Et & Öde
                            </button>
                            <button className="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors text-sm">
                              Revizyon İste
                            </button>
                            <button className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm">
                              Reddet
                            </button>
                          </>
                        )}
                        {quote.status === 'accepted' && (
                          <button 
                            onClick={() => navigate(`/payment/quote/${quote.id}`)}
                            className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors text-sm"
                          >
                            Ödeme Yap
                          </button>
                        )}
                        <button
                          onClick={() => navigate(`/messages`)}
                          className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
                        >
                          Mesajlaşma
                        </button>
                      </div>
                    </div>
                  </div>
                )) : (
                  <div className="text-center py-12">
                    <svg className="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                    </svg>
                    <h3 className="text-lg font-medium text-gray-900 mb-2">Teklif bulunamadı</h3>
                    <p className="text-gray-600">Henüz teklif talebinde bulunmadınız.</p>
                    <button
                      onClick={() => navigate('/craftsmen')}
                      className="mt-4 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                    >
                      Usta Ara
                    </button>
                  </div>
                )}
              </div>
            ) : (
              <div className="space-y-4">
                {reviews.map((review) => (
                  <div key={review.id} className="border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex-1">
                        <div className="flex items-center space-x-3 mb-2">
                          <h3 className="text-lg font-medium text-gray-900">{review.service}</h3>
                          <div className="flex items-center space-x-1">
                            {renderStars(review.rating)}
                            <span className="text-sm font-medium text-gray-900 ml-1">{review.rating}</span>
                          </div>
                        </div>
                        <p className="text-sm text-gray-600 mb-2">👤 {review.craftsman} - {review.business_name}</p>
                        <p className="text-sm text-gray-700 mb-2">"{review.review}"</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500">
                          <span>📅 {review.date}</span>
                          <span>👍 {review.helpful_votes} kişi faydalı buldu</span>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center space-x-3">
                      <button
                        onClick={() => navigate(`/messages/${review.craftsman}`)}
                        className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors text-sm"
                      >
                        Tekrar Mesaj Gönder
                      </button>
                      <button
                        onClick={() => navigate(`/craftsman/${review.craftsman}`)}
                        className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
                      >
                        Profil Görüntüle
                      </button>
                      <button className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors text-sm">
                        Yorumu Düzenle
                      </button>
                    </div>
                  </div>
                ))}

                {reviews.length === 0 && (
                  <div className="text-center py-12">
                    <svg className="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                    </svg>
                    <h3 className="text-lg font-medium text-gray-900 mb-2">Yorum bulunamadı</h3>
                    <p className="text-gray-600">Henüz yorum yapmadınız.</p>
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

export default CustomerJobHistoryPage;