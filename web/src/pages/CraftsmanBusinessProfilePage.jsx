import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { PageSEO } from '../utils/seo';

export const CraftsmanBusinessProfilePage = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [craftsman, setCraftsman] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('about');

  useEffect(() => {
    loadCraftsmanProfile();
  }, [id]);

  const loadCraftsmanProfile = async () => {
    try {
      const response = await fetch(`http://localhost:5000/api/craftsmen/${id}/business-profile`);
      const data = await response.json();
      
      if (data.success) {
        setCraftsman(data.data);
      } else {
        console.error('Usta profili yüklenemedi:', data.message);
      }
    } catch (error) {
      console.error('Usta profili yükleme hatası:', error);
    } finally {
      setLoading(false);
    }
  };

  const renderStars = (rating) => {
    return Array.from({ length: 5 }, (_, i) => (
      <svg
        key={i}
        className={`w-4 h-4 ${i < Math.floor(rating) ? 'text-yellow-400' : 'text-gray-300'}`}
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
    ));
  };

  const formatDate = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
          <p className="mt-4 text-gray-600">Usta profili yükleniyor...</p>
        </div>
      </div>
    );
  }

  if (!craftsman) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-600">Usta profili bulunamadı</p>
          <button 
            onClick={() => navigate(-1)}
            className="mt-4 bg-blue-500 text-white px-4 py-2 rounded-lg"
          >
            Geri Dön
          </button>
        </div>
      </div>
    );
  }

  return (
    <PageSEO 
      pageType="craftsman" 
      data={craftsman}
    >
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <button 
              onClick={() => navigate(-1)}
              className="p-2 hover:bg-gray-100 rounded-full"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h1 className="text-xl font-semibold text-gray-900">İşletme Profili</h1>
            <div className="w-10"></div>
          </div>
        </div>
      </div>

      {/* Business Header */}
      <div className="bg-white border-b">
        <div className="max-w-4xl mx-auto px-4 py-6">
          <div className="flex items-start gap-6">
            <img 
              src={craftsman.avatar || `https://ui-avatars.com/api/?name=${encodeURIComponent(craftsman.name)}&background=3B82F6&color=fff&size=120`} 
              alt={craftsman.name}
              className="w-24 h-24 rounded-full object-cover"
            />
            <div className="flex-1">
              <div className="flex items-start justify-between">
                <div>
                  <h2 className="text-2xl font-bold text-gray-900">{craftsman.business_name}</h2>
                  <p className="text-lg text-gray-600">{craftsman.name}</p>
                  <div className="flex items-center gap-2 mt-2">
                    <div className="flex items-center gap-1">
                      {renderStars(craftsman.average_rating)}
                      <span className="text-sm font-medium">{craftsman.average_rating}</span>
                    </div>
                    <span className="text-sm text-gray-500">({craftsman.total_reviews} değerlendirme)</span>
                    {craftsman.is_verified && (
                      <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full">
                        ✓ Doğrulanmış
                      </span>
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  {craftsman.is_available ? (
                    <span className="flex items-center gap-2 text-green-600">
                      <span className="w-3 h-3 bg-green-500 rounded-full"></span>
                      Müsait
                    </span>
                  ) : (
                    <span className="flex items-center gap-2 text-red-600">
                      <span className="w-3 h-3 bg-red-500 rounded-full"></span>
                      Meşgul
                    </span>
                  )}
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  {craftsman.city}, {craftsman.district}
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  {craftsman.experience_years} yıl deneyim
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                  </svg>
                  {craftsman.hourly_rate ? `₺${craftsman.hourly_rate}/saat` : 'Fiyat belirtilmemiş'}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white border-b">
        <div className="max-w-4xl mx-auto px-4">
          <div className="flex">
            {[
              { key: 'about', label: 'İşletme Bilgileri' },
              { key: 'portfolio', label: 'Portfolyo' },
              { key: 'jobs', label: 'Tamamlanan İşler' },
              { key: 'reviews', label: 'Yorumlar' }
            ].map(tab => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`px-6 py-3 text-sm font-medium border-b-2 transition-colors ${
                  activeTab === tab.key
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Tab Content */}
      <div className="max-w-4xl mx-auto px-4 py-6">
        {activeTab === 'about' && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <div className="space-y-6">
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-3">İşletme Açıklaması</h3>
                <p className="text-gray-600 leading-relaxed">
                  {craftsman.description || 'Henüz açıklama eklenmemiş.'}
                </p>
              </div>

              {craftsman.skills && (
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-3">Uzmanlık Alanları</h3>
                  <div className="flex flex-wrap gap-2">
                    {JSON.parse(craftsman.skills).map((skill, index) => (
                      <span key={index} className="bg-blue-100 text-blue-800 text-sm px-3 py-1 rounded-full">
                        {skill}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {craftsman.certifications && (
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-3">Sertifikalar</h3>
                  <div className="space-y-2">
                    {JSON.parse(craftsman.certifications).map((cert, index) => (
                      <div key={index} className="flex items-center gap-2">
                        <svg className="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                          <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                        </svg>
                        <span className="text-gray-700">{cert}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            <div className="space-y-6">
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-3">İletişim Bilgileri</h3>
                <div className="space-y-3">
                  <div className="flex items-center gap-3">
                    <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    <span className="text-gray-700">{craftsman.address || `${craftsman.city}, ${craftsman.district}`}</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                    </svg>
                    <span className="text-gray-700">{craftsman.user.phone}</span>
                  </div>
                  {craftsman.website && (
                    <div className="flex items-center gap-3">
                      <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
                      </svg>
                      <a href={craftsman.website} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">
                        {craftsman.website}
                      </a>
                    </div>
                  )}
                  {craftsman.working_hours && (
                    <div className="flex items-center gap-3">
                      <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      <span className="text-gray-700">{craftsman.working_hours}</span>
                    </div>
                  )}
                </div>
              </div>

              {craftsman.service_areas && (
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-3">Hizmet Alanları</h3>
                  <div className="flex flex-wrap gap-2">
                    {JSON.parse(craftsman.service_areas).map((area, index) => (
                      <span key={index} className="bg-gray-100 text-gray-800 text-sm px-3 py-1 rounded-full">
                        {area}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Tab Content */}
      <div className="max-w-4xl mx-auto px-4 py-6">
        {activeTab === 'portfolio' && (
          <div>
            <h3 className="text-xl font-semibold text-gray-900 mb-6">İşletme Portföyü</h3>
            {craftsman.portfolio_images && craftsman.portfolio_images.length > 0 ? (
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                {craftsman.portfolio_images.map((image, index) => (
                  <div key={index} className="aspect-square">
                    <img
                      src={`http://localhost:5000${image}`}
                      alt={`Portfolyo ${index + 1}`}
                      className="w-full h-full object-cover rounded-lg hover:opacity-90 transition-opacity cursor-pointer"
                      onClick={() => window.open(`http://localhost:5000${image}`, '_blank')}
                    />
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <p className="text-gray-500">Henüz portfolyo görseli eklenmemiş</p>
              </div>
            )}
          </div>
        )}

        {activeTab === 'jobs' && (
          <div>
            <h3 className="text-xl font-semibold text-gray-900 mb-6">Tamamlanan İşler</h3>
            {craftsman.completed_jobs && craftsman.completed_jobs.length > 0 ? (
              <div className="space-y-4">
                {craftsman.completed_jobs.map((job) => (
                  <div key={job.id} className="bg-white border rounded-lg p-6">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h4 className="text-lg font-semibold text-gray-900">{job.title}</h4>
                        <p className="text-gray-600 mt-1">{job.description}</p>
                        <div className="flex items-center gap-4 mt-3 text-sm text-gray-500">
                          <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded-full">{job.category}</span>
                          <span>{job.location}</span>
                          <span>Tamamlandı: {formatDate(job.completed_at)}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                </svg>
                <p className="text-gray-500">Henüz tamamlanmış iş bulunmuyor</p>
              </div>
            )}
          </div>
        )}

        {activeTab === 'reviews' && (
          <div>
            <h3 className="text-xl font-semibold text-gray-900 mb-6">
              Müşteri Yorumları ({craftsman.total_reviews})
            </h3>
            {craftsman.recent_reviews && craftsman.recent_reviews.length > 0 ? (
              <div className="space-y-4">
                {craftsman.recent_reviews.map((review) => (
                  <div key={review.id} className="bg-white border rounded-lg p-6">
                    <div className="flex items-start justify-between mb-3">
                      <div>
                        <h4 className="font-medium text-gray-900">{review.customer_name}</h4>
                        <div className="flex items-center gap-1 mt-1">
                          {renderStars(review.rating)}
                        </div>
                      </div>
                      <span className="text-sm text-gray-500">{formatDate(review.created_at)}</span>
                    </div>
                    <p className="text-gray-700">{review.comment}</p>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
                <p className="text-gray-500">Henüz yorum bulunmuyor</p>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Bottom Actions */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t p-4">
        <div className="max-w-4xl mx-auto flex gap-3">
          <button className="flex-1 bg-gray-100 text-gray-700 py-3 rounded-lg font-medium hover:bg-gray-200 transition-colors">
            Mesaj Gönder
          </button>
          <button 
            onClick={() => navigate(`/quote-request/${craftsman.id}`)}
            className="flex-1 bg-blue-500 text-white py-3 rounded-lg font-medium hover:bg-blue-600 transition-colors"
          >
            Teklif İste
          </button>
        </div>
      </div>

      {/* Bottom padding for fixed button */}
      <div className="h-20"></div>
    </div>
    </PageSEO>
  );
};