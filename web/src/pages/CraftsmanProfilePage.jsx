import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import ReviewReplyModal from '../components/ReviewReplyModal';

export const CraftsmanProfilePage = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('about');
  const [isFavorite, setIsFavorite] = useState(false);
  const [showQuoteModal, setShowQuoteModal] = useState(false);
  const [showReplyModal, setShowReplyModal] = useState(false);
  const [selectedReview, setSelectedReview] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [reviewStats, setReviewStats] = useState({});

  // Mock Craftsman Data
  const [craftsman] = useState({
    id: 1,
    name: 'Ahmet Yılmaz',
    business_name: 'Yılmaz Elektrik',
    avatar: null,
    category: 'Elektrikçi',
    skills: ['Elektrikçi', 'LED Aydınlatma', 'Ev Otomasyonu', 'Panel Montajı'],
    city: 'İstanbul',
    district: 'Kadıköy',
    rating: 4.8,
    review_count: 127,
    completed_jobs: 89,
    experience_years: 8,
    hourly_rate: 150,
    response_time: '2 saat',
    is_verified: true,
    is_online: true,
    last_seen: '5 dakika önce',
    description: `8 yıllık deneyimim ile ev ve işyeri elektrik tesisatı, LED aydınlatma sistemleri, akıllı ev otomasyonu ve elektrik panosu montajı konularında profesyonel hizmet veriyorum. 

Müşteri memnuniyeti önceliğim olup, işlerimi titizlikle ve zamanında teslim ederim. Tüm işlerim için garanti veriyorum.

Hizmet verdiğim alanlar:
• Ev ve işyeri elektrik tesisatı
• LED aydınlatma sistemleri  
• Akıllı ev otomasyonu
• Elektrik panosu montajı ve bakımı
• Arıza tespiti ve onarımı`,
    contact: {
      phone: '+90 555 123 4567',
      email: 'ahmet@yilmazelektrik.com',
      website: 'www.yilmazelektrik.com'
    },
    location: {
      address: 'Kadıköy, İstanbul',
      service_areas: ['Kadıköy', 'Üsküdar', 'Ataşehir', 'Maltepe', 'Kartal']
    },
    certifications: [
      'Elektrik Tesisatı Yeterlilik Belgesi',
      'LED Aydınlatma Uzmanı Sertifikası',
      'Akıllı Ev Sistemleri Eğitimi'
    ],
    working_hours: {
      monday: '09:00 - 18:00',
      tuesday: '09:00 - 18:00',
      wednesday: '09:00 - 18:00',
      thursday: '09:00 - 18:00',
      friday: '09:00 - 18:00',
      saturday: '09:00 - 15:00',
      sunday: 'Kapalı'
    }
  });

  const [portfolio] = useState([
    {
      id: 1,
      title: 'Villa LED Aydınlatma Projesi',
      description: 'Müstakil villa için tam LED aydınlatma sistemi kurulumu',
      images: ['portfolio1_1.jpg', 'portfolio1_2.jpg', 'portfolio1_3.jpg'],
      date: '2025-01-15',
      category: 'LED Aydınlatma',
      client_review: 'Mükemmel iş çıkardı, çok memnunuz!'
    },
    {
      id: 2,
      title: 'Ofis Elektrik Tesisatı Yenileme',
      description: '200m² ofis alanı elektrik tesisatı tamamen yenilendi',
      images: ['portfolio2_1.jpg', 'portfolio2_2.jpg'],
      date: '2025-01-08',
      category: 'Elektrik Tesisatı',
      client_review: 'Zamanında ve kaliteli hizmet'
    },
    {
      id: 3,
      title: 'Akıllı Ev Otomasyonu',
      description: 'Ev geneli akıllı anahtar ve sensör sistemi',
      images: ['portfolio3_1.jpg'],
      date: '2024-12-20',
      category: 'Ev Otomasyonu',
      client_review: 'Teknolojik çözümler harika!'
    }
  ]);

  useEffect(() => {
    // Set reviews data
    setReviews([
      {
        id: 1,
        customer: 'Mehmet K.',
        rating: 5,
        comment: 'Çok profesyonel ve titiz çalışıyor. LED aydınlatma sistemi için aldığım hizmet mükemmeldi. Kesinlikle tavsiye ederim.',
        date: '2025-01-20',
        service: 'LED Aydınlatma',
        helpful_votes: 8
      },
      {
        id: 2,
        customer: 'Ayşe D.',
        rating: 5,
        comment: 'Elektrik panosu arızası için çağırdım. Çok hızlı geldi ve sorunu kısa sürede çözdü. Fiyatı da uygundu.',
        date: '2025-01-18',
        service: 'Elektrik Onarımı',
        helpful_votes: 5
      },
      {
        id: 3,
        customer: 'Can S.',
        rating: 4,
        comment: 'İyi iş çıkardı ama biraz geç geldi. Sonuç olarak memnunum.',
        date: '2025-01-15',
        service: 'Ev Elektrik Tesisatı',
        helpful_votes: 2
      },
      {
        id: 4,
        customer: 'Zeynep T.',
        rating: 5,
        comment: 'Akıllı ev sistemleri konusunda çok bilgili. Evimizi tamamen otomatikleştirdi. Harika!',
        date: '2025-01-12',
        service: 'Ev Otomasyonu',
        helpful_votes: 12
      }
    ]);
    
    // Simulate loading
    setTimeout(() => setLoading(false), 1000);
    loadReviews();
  }, [id]);

  const loadReviews = async () => {
    try {
      const response = await fetch(`http://localhost:5001/api/reviews/craftsman/${id || 1}`);
      const data = await response.json();
      
      setReviews(data.reviews || []);
      setReviewStats(data.stats || {});
    } catch (error) {
      console.error('Error loading reviews:', error);
    }
  };

  const renderStars = (rating) => {
    return Array.from({ length: 5 }, (_, i) => (
      <svg
        key={i}
        className={`w-5 h-5 ${i < Math.floor(rating) ? 'text-yellow-400' : 'text-gray-300'}`}
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
      </svg>
    ));
  };

  const getRatingDistribution = () => {
    return reviewStats.rating_distribution || { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
  };

  const handleReplyClick = (review) => {
    setSelectedReview(review);
    setShowReplyModal(true);
  };

  const handleReplySubmit = (reviewId, replyData) => {
    setReviews(prev => prev.map(review => 
      review.id === reviewId 
        ? { ...review, craftsman_reply: replyData.reply, reply_date: replyData.reply_date }
        : review
    ));
  };

  const handleHelpfulVote = async (reviewId, isHelpful) => {
    try {
      const response = await fetch(`http://localhost:5001/api/reviews/${reviewId}/helpful`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ is_helpful: isHelpful })
      });

      const result = await response.json();
      
      if (result.success) {
        setReviews(prev => prev.map(review => 
          review.id === reviewId 
            ? { ...review, helpful_votes: result.helpful_votes }
            : review
        ));
      }
    } catch (error) {
      console.error('Error voting helpful:', error);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <button
              onClick={() => navigate(-1)}
              className="flex items-center space-x-2 text-gray-600 hover:text-gray-900 transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
              <span>Geri</span>
            </button>

            <div className="flex items-center space-x-4">
              <button
                onClick={() => setIsFavorite(!isFavorite)}
                className={`p-2 rounded-full transition-colors ${
                  isFavorite ? 'bg-red-100 text-red-600' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                <svg className="w-6 h-6" fill={isFavorite ? 'currentColor' : 'none'} stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
              </button>

              <button className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-full transition-colors">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.367 2.684 3 3 0 00-5.367-2.684z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 py-6">
        {/* Profile Header */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
          <div className="flex items-start space-x-6">
            {/* Avatar */}
            <div className="relative">
              <div className="w-24 h-24 bg-blue-100 rounded-full flex items-center justify-center">
                {craftsman.avatar ? (
                  <img src={craftsman.avatar} alt={craftsman.name} className="w-24 h-24 rounded-full object-cover" />
                ) : (
                  <span className="text-blue-600 font-medium text-2xl">
                    {craftsman.name.charAt(0)}
                  </span>
                )}
              </div>
              {craftsman.is_online && (
                <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-green-500 border-2 border-white rounded-full"></div>
              )}
            </div>

            {/* Info */}
            <div className="flex-1">
              <div className="flex items-center space-x-3 mb-2">
                <h1 className="text-2xl font-bold text-gray-900">{craftsman.name}</h1>
                {craftsman.is_verified && (
                  <svg className="w-6 h-6 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                  </svg>
                )}
              </div>

              <p className="text-lg text-gray-600 mb-2">{craftsman.business_name}</p>
              <p className="text-blue-600 font-medium mb-3">{craftsman.category}</p>

              {/* Skills */}
              <div className="flex flex-wrap gap-2 mb-4">
                {craftsman.skills.map((skill, index) => (
                  <span key={index} className="px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full font-medium">
                    {skill}
                  </span>
                ))}
              </div>

              {/* Stats */}
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
                <div className="text-center">
                  <div className="flex items-center justify-center space-x-1 mb-1">
                    {renderStars(craftsman.rating)}
                  </div>
                  <div className="text-lg font-semibold text-gray-900">{craftsman.rating}</div>
                  <div className="text-sm text-gray-500">{craftsman.review_count} değerlendirme</div>
                </div>
                <div className="text-center">
                  <div className="text-lg font-semibold text-gray-900">{craftsman.completed_jobs}</div>
                  <div className="text-sm text-gray-500">Tamamlanan iş</div>
                </div>
                <div className="text-center">
                  <div className="text-lg font-semibold text-gray-900">{craftsman.experience_years} yıl</div>
                  <div className="text-sm text-gray-500">Deneyim</div>
                </div>
                <div className="text-center">
                  <div className="text-lg font-semibold text-green-600">{craftsman.hourly_rate}₺</div>
                  <div className="text-sm text-gray-500">Saatlik ücret</div>
                </div>
              </div>

              {/* Status */}
              <div className="flex items-center space-x-4 text-sm text-gray-500 mb-4">
                <span>📍 {craftsman.district}, {craftsman.city}</span>
                <span>⏱️ {craftsman.response_time} yanıt süresi</span>
                <span className={craftsman.is_online ? 'text-green-600' : 'text-gray-500'}>
                  {craftsman.is_online ? '🟢 Çevrimiçi' : `🔴 ${craftsman.last_seen}`}
                </span>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center space-x-3">
                <button
                  onClick={() => setShowQuoteModal(true)}
                  className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors font-medium"
                >
                  💰 Teklif Al
                </button>
                <button
                  onClick={() => navigate(`/messages/${craftsman.id}`)}
                  className="px-6 py-3 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors font-medium"
                >
                  💬 Mesaj Gönder
                </button>
                <button
                  onClick={() => navigate(`/chat/${craftsman.id}`)}
                  className="px-6 py-3 bg-purple-500 text-white rounded-lg hover:bg-purple-600 transition-colors font-medium"
                >
                  🚀 Hızlı Chat
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-lg shadow-sm mb-6">
          <div className="border-b border-gray-200">
            <nav className="flex space-x-8 px-6">
              <button
                onClick={() => setActiveTab('about')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'about'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                👤 Hakkında
              </button>
              <button
                onClick={() => setActiveTab('portfolio')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'portfolio'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                🏆 Portfolio ({portfolio.length})
              </button>
              <button
                onClick={() => setActiveTab('reviews')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'reviews'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                ⭐ Yorumlar ({reviews.length})
              </button>
              <button
                onClick={() => setActiveTab('contact')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'contact'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                📞 İletişim
              </button>
            </nav>
          </div>

          {/* Tab Content */}
          <div className="p-6">
            {activeTab === 'about' && (
              <div className="space-y-6">
                {/* Description */}
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-3">📝 Hakkımda</h3>
                  <div className="prose prose-gray max-w-none">
                    {craftsman.description.split('\n').map((paragraph, index) => (
                      <p key={index} className="text-gray-700 mb-3">
                        {paragraph}
                      </p>
                    ))}
                  </div>
                </div>

                {/* Certifications */}
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-3">🏅 Sertifikalar</h3>
                  <div className="space-y-2">
                    {craftsman.certifications.map((cert, index) => (
                      <div key={index} className="flex items-center space-x-2">
                        <svg className="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                          <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                        </svg>
                        <span className="text-gray-700">{cert}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Service Areas */}
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-3">📍 Hizmet Verdiğim Bölgeler</h3>
                  <div className="flex flex-wrap gap-2">
                    {craftsman.location.service_areas.map((area, index) => (
                      <span key={index} className="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm">
                        {area}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Working Hours */}
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-3">⏰ Çalışma Saatleri</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                    {Object.entries(craftsman.working_hours).map(([day, hours]) => (
                      <div key={day} className="flex justify-between py-2 px-3 bg-gray-50 rounded">
                        <span className="font-medium capitalize">
                          {day === 'monday' && 'Pazartesi'}
                          {day === 'tuesday' && 'Salı'}
                          {day === 'wednesday' && 'Çarşamba'}
                          {day === 'thursday' && 'Perşembe'}
                          {day === 'friday' && 'Cuma'}
                          {day === 'saturday' && 'Cumartesi'}
                          {day === 'sunday' && 'Pazar'}
                        </span>
                        <span className={hours === 'Kapalı' ? 'text-red-600' : 'text-green-600'}>
                          {hours}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'portfolio' && (
              <div className="space-y-6">
                {portfolio.map((item) => (
                  <div key={item.id} className="border border-gray-200 rounded-lg p-6">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex-1">
                        <div className="flex items-center space-x-3 mb-2">
                          <h3 className="text-lg font-medium text-gray-900">{item.title}</h3>
                          <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full font-medium">
                            {item.category}
                          </span>
                        </div>
                        <p className="text-gray-600 mb-3">{item.description}</p>
                        <div className="text-sm text-gray-500 mb-3">📅 {item.date}</div>
                        {item.client_review && (
                          <div className="bg-green-50 rounded-lg p-3">
                            <p className="text-sm text-green-800 italic">
                              "💬 {item.client_review}"
                            </p>
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Images */}
                    <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                      {item.images.map((image, index) => (
                        <div key={index} className="aspect-square bg-gray-200 rounded-lg flex items-center justify-center">
                          <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                          </svg>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            )}

            {activeTab === 'reviews' && (
              <div className="space-y-6">
                {/* Rating Summary */}
                <div className="bg-gray-50 rounded-lg p-6">
                  <div className="grid md:grid-cols-2 gap-6">
                    <div className="text-center">
                      <div className="text-4xl font-bold text-gray-900 mb-2">
                        {reviewStats.average_rating || 0}
                      </div>
                      <div className="flex items-center justify-center space-x-1 mb-2">
                        {renderStars(reviewStats.average_rating || 0)}
                      </div>
                      <div className="text-gray-600">
                        {reviewStats.total_reviews || 0} değerlendirme
                      </div>
                    </div>
                    <div className="space-y-2">
                      {Object.entries(getRatingDistribution()).reverse().map(([rating, count]) => (
                        <div key={rating} className="flex items-center space-x-2">
                          <span className="text-sm w-8">{rating} ⭐</span>
                          <div className="flex-1 bg-gray-200 rounded-full h-2">
                            <div 
                              className="bg-yellow-400 h-2 rounded-full" 
                              style={{ 
                                width: reviewStats.total_reviews > 0 
                                  ? `${(count / reviewStats.total_reviews) * 100}%` 
                                  : '0%' 
                              }}
                            ></div>
                          </div>
                          <span className="text-sm text-gray-600 w-8">{count}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>

                {/* Reviews List */}
                <div className="space-y-4">
                  {reviews.length === 0 ? (
                    <div className="text-center py-12">
                      <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                        <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                        </svg>
                      </div>
                      <h3 className="text-lg font-medium text-gray-900 mb-2">Henüz değerlendirme yok</h3>
                      <p className="text-gray-600">İlk değerlendirme geldiğinde burada görünecek.</p>
                    </div>
                  ) : (
                    reviews.map((review) => (
                      <div key={review.id} className="border border-gray-200 rounded-lg p-6">
                        <div className="flex items-start justify-between mb-3">
                          <div className="flex-1">
                            <div className="flex items-center space-x-3 mb-2">
                              <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                                <span className="text-gray-600 font-medium text-sm">
                                  {review.customer_name.charAt(0)}
                                </span>
                              </div>
                              <div>
                                <div className="font-medium text-gray-900">{review.customer_name}</div>
                                <div className="flex items-center space-x-2">
                                  <div className="flex items-center space-x-1">
                                    {renderStars(review.rating)}
                                  </div>
                                  <span className="text-sm text-gray-500">
                                    • {new Date(review.created_at).toLocaleDateString('tr-TR')}
                                  </span>
                                  {review.service_category && (
                                    <span className="text-sm text-blue-600">• {review.service_category}</span>
                                  )}
                                </div>
                              </div>
                            </div>
                          </div>
                          {user?.user_type === 'craftsman' && !review.craftsman_reply && (
                            <button
                              onClick={() => handleReplyClick(review)}
                              className="px-3 py-1 text-blue-600 hover:text-blue-800 text-sm font-medium transition-colors"
                            >
                              💬 Yanıtla
                            </button>
                          )}
                        </div>
                        
                        <p className="text-gray-700 mb-3">{review.comment}</p>
                        
                        {/* Craftsman Reply */}
                        {review.craftsman_reply && (
                          <div className="mt-4 bg-blue-50 rounded-lg p-4">
                            <div className="flex items-start space-x-3">
                              <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                                <svg className="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                </svg>
                              </div>
                              <div className="flex-1">
                                <div className="flex items-center space-x-2 mb-2">
                                  <span className="font-medium text-blue-900">Usta Yanıtı</span>
                                  <span className="text-sm text-blue-600">
                                    {new Date(review.reply_date).toLocaleDateString('tr-TR')}
                                  </span>
                                </div>
                                <p className="text-blue-800">{review.craftsman_reply}</p>
                              </div>
                            </div>
                          </div>
                        )}
                        
                        <div className="flex items-center space-x-4 text-sm text-gray-500 mt-3">
                          <button 
                            onClick={() => handleHelpfulVote(review.id, true)}
                            className="flex items-center space-x-1 hover:text-blue-600 transition-colors"
                          >
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5" />
                            </svg>
                            <span>Faydalı ({review.helpful_votes})</span>
                          </button>
                          {review.is_verified && (
                            <span className="flex items-center space-x-1 text-green-600">
                              <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                              </svg>
                              <span>Doğrulanmış</span>
                            </span>
                          )}
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </div>
            )}

            {activeTab === 'contact' && (
              <div className="space-y-6">
                <div className="grid md:grid-cols-2 gap-6">
                  {/* Contact Info */}
                  <div>
                    <h3 className="text-lg font-medium text-gray-900 mb-4">📞 İletişim Bilgileri</h3>
                    <div className="space-y-3">
                      <div className="flex items-center space-x-3">
                        <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                        </svg>
                        <span className="text-gray-700">{craftsman.contact.phone}</span>
                      </div>
                      <div className="flex items-center space-x-3">
                        <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                        </svg>
                        <span className="text-gray-700">{craftsman.contact.email}</span>
                      </div>
                      <div className="flex items-center space-x-3">
                        <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9v-9m0-9v9m0 9c-5 0-9-4-9-9s4-9 9-9" />
                        </svg>
                        <a href={`https://${craftsman.contact.website}`} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">
                          {craftsman.contact.website}
                        </a>
                      </div>
                      <div className="flex items-center space-x-3">
                        <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                        </svg>
                        <span className="text-gray-700">{craftsman.location.address}</span>
                      </div>
                    </div>
                  </div>

                  {/* Quick Actions */}
                  <div>
                    <h3 className="text-lg font-medium text-gray-900 mb-4">⚡ Hızlı İşlemler</h3>
                    <div className="space-y-3">
                      <button
                        onClick={() => setShowQuoteModal(true)}
                        className="w-full p-4 bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors text-left"
                      >
                        <div className="flex items-center space-x-3">
                          <div className="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
                            <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                            </svg>
                          </div>
                          <div>
                            <div className="font-medium text-gray-900">Teklif Al</div>
                            <div className="text-sm text-gray-600">Özel fiyat teklifi isteyin</div>
                          </div>
                        </div>
                      </button>

                      <button
                        onClick={() => navigate(`/messages/${craftsman.id}`)}
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

                      <button
                        onClick={() => navigate(`/chat/${craftsman.id}`)}
                        className="w-full p-4 bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors text-left"
                      >
                        <div className="flex items-center space-x-3">
                          <div className="w-10 h-10 bg-purple-500 rounded-lg flex items-center justify-center">
                            <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                            </svg>
                          </div>
                          <div>
                            <div className="font-medium text-gray-900">Hızlı Chat</div>
                            <div className="text-sm text-gray-600">Anlık mesajlaşma</div>
                          </div>
                        </div>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Quote Request Modal */}
      {showQuoteModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-lg w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-medium text-gray-900">💰 Teklif Talebi</h3>
                <button
                  onClick={() => setShowQuoteModal(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <form className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Hizmet Türü
                  </label>
                  <select className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <option value="">Seçiniz</option>
                    {craftsman.skills.map((skill, index) => (
                      <option key={index} value={skill}>{skill}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    İş Açıklaması
                  </label>
                  <textarea
                    rows={4}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="İşin detaylarını açıklayın..."
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Bütçe (₺)
                    </label>
                    <input
                      type="number"
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="1000"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Tarih
                    </label>
                    <input
                      type="date"
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Adres
                  </label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="İş adresi"
                  />
                </div>

                <div className="flex space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => setShowQuoteModal(false)}
                    className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    İptal
                  </button>
                  <button
                    type="submit"
                    className="flex-1 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                  >
                    Teklif Gönder
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Review Reply Modal */}
      <ReviewReplyModal
        review={selectedReview}
        isOpen={showReplyModal}
        onClose={() => {
          setShowReplyModal(false);
          setSelectedReview(null);
        }}
        onReply={handleReplySubmit}
      />
    </div>
  );
};

export default CraftsmanProfilePage;