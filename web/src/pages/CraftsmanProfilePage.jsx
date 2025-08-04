import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
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
  const [reviews, setReviews] = useState([{
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
  }]);
  const [reviewStats, setReviewStats] = useState({});

  // Mock Craftsman Data
  const [craftsman] = useState({
    id: 1,
    name: 'Ahmet Yılmaz',
    business_name: 'Yılmaz Elektrik',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
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
      images: [
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1551434678-e076c223a692?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1563013544-824ae1b704d3?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80'
      ],
      date: '2025-01-15',
      category: 'LED Aydınlatma',
      client_review: 'Mükemmel iş çıkardı, çok memnunuz!'
    },
    {
      id: 2,
      title: 'Ofis Elektrik Tesisatı Yenileme',
      description: '200m² ofis alanı elektrik tesisatı tamamen yenilendi',
      images: [
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1551434678-e076c223a692?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80'
      ],
      date: '2025-01-08',
      category: 'Elektrik Tesisatı',
      client_review: 'Zamanında ve kaliteli hizmet'
    },
    {
      id: 3,
      title: 'Akıllı Ev Otomasyonu',
      description: 'Ev geneli akıllı anahtar ve sensör sistemi',
      images: [
        'https://images.unsplash.com/photo-1563013544-824ae1b704d3?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80'
      ],
      date: '2024-12-20',
      category: 'Ev Otomasyonu',
      client_review: 'Teknolojik çözümler harika!'
    }
  ]);

  useEffect(() => {
    loadReviews();
    setLoading(false);
  }, []);

  const loadReviews = async () => {
    // Mock reviews data
    const mockReviews = [
      {
        id: 1,
        user_name: 'Mehmet K.',
        rating: 5,
        comment: 'Çok profesyonel ve titiz bir iş çıkardı. LED aydınlatma projemizde mükemmel sonuç aldık.',
        date: '2025-01-20',
        helpful_count: 12,
        reply: null
      },
      {
        id: 2,
        user_name: 'Ayşe Y.',
        rating: 4,
        comment: 'Zamanında geldi ve işini hızlıca bitirdi. Fiyatı da makuldu.',
        date: '2025-01-18',
        helpful_count: 8,
        reply: {
          text: 'Teşekkür ederim, memnun kaldığınıza sevindim.',
          date: '2025-01-18'
        }
      }
    ];
    setReviews(mockReviews);
  };

  const renderStars = (rating) => {
    return [...Array(5)].map((_, i) => (
      <svg
        key={i}
        className={`w-4 h-4 ${i < rating ? 'text-yellow-400' : 'text-gray-300'}`}
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
    ));
  };

  const getRatingDistribution = () => {
    return { 5: 80, 4: 15, 3: 3, 2: 1, 1: 1 };
  };

  const handleReplyClick = (review) => {
    setSelectedReview(review);
    setShowReplyModal(true);
  };

  const handleReplySubmit = (reviewId, replyData) => {
    // Handle reply submission
    setShowReplyModal(false);
  };

  const handleHelpfulVote = async (reviewId, isHelpful) => {
    // Handle helpful vote
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Yükleniyor...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm">
        <div className="max-w-4xl mx-auto px-4 py-6">
          <div className="flex items-center justify-between">
            <button
              onClick={() => navigate(-1)}
              className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
              Geri
            </button>
            <div className="flex items-center space-x-4">
              <button
                onClick={() => setIsFavorite(!isFavorite)}
                className={`p-2 rounded-full transition-colors ${
                  isFavorite ? 'text-red-500 bg-red-50' : 'text-gray-400 hover:text-red-500'
                }`}
              >
                <svg className="w-6 h-6" fill={isFavorite ? 'currentColor' : 'none'} stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
              </button>
              <button className="p-2 text-gray-400 hover:text-gray-600 rounded-full transition-colors">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.367 2.684 3 3 0 00-5.367-2.684z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Profile Header */}
      <div className="bg-white">
        <div className="max-w-4xl mx-auto px-4 py-8">
          <div className="flex flex-col md:flex-row items-start space-y-6 md:space-y-0 md:space-x-8">
            {/* Avatar and Basic Info */}
            <div className="flex-shrink-0">
              <div className="relative">
                <img
                  src={craftsman.avatar}
                  alt={craftsman.name}
                  className="w-32 h-32 rounded-2xl object-cover"
                />
                {craftsman.is_online && (
                  <div className="absolute -bottom-2 -right-2 w-6 h-6 bg-green-500 rounded-full border-4 border-white"></div>
                )}
              </div>
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
              
              <p className="text-lg text-gray-600 mb-3">{craftsman.business_name}</p>
              
              <div className="flex items-center space-x-4 mb-4">
                <div className="flex items-center space-x-1">
                  {renderStars(craftsman.rating)}
                  <span className="text-sm text-gray-600 ml-2">
                    {craftsman.rating} ({craftsman.review_count} değerlendirme)
                  </span>
                </div>
                <span className="text-sm text-gray-500">•</span>
                <span className="text-sm text-gray-600">{craftsman.completed_jobs} tamamlanan iş</span>
                <span className="text-sm text-gray-500">•</span>
                <span className="text-sm text-gray-600">{craftsman.experience_years} yıl deneyim</span>
              </div>

              <div className="flex flex-wrap gap-2 mb-4">
                {craftsman.skills.map((skill, index) => (
                  <span
                    key={index}
                    className="px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full font-medium"
                  >
                    {skill}
                  </span>
                ))}
              </div>

              <div className="flex items-center space-x-4 text-sm text-gray-600">
                <div className="flex items-center space-x-1">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  <span>{craftsman.city}, {craftsman.district}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span>Yanıt süresi: {craftsman.response_time}</span>
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex-shrink-0 space-y-3">
              <button
                onClick={() => setShowQuoteModal(true)}
                className="w-full bg-blue-600 text-white px-6 py-3 rounded-xl font-semibold hover:bg-blue-700 transition-colors"
              >
                Teklif Al
              </button>
              <button className="w-full bg-gray-100 text-gray-700 px-6 py-3 rounded-xl font-semibold hover:bg-gray-200 transition-colors">
                Mesaj Gönder
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white border-b">
        <div className="max-w-4xl mx-auto px-4">
          <div className="flex space-x-8">
            {[
              { id: 'about', label: 'Hakkında' },
              { id: 'portfolio', label: 'Portföy' },
              { id: 'reviews', label: 'Değerlendirmeler' },
              { id: 'contact', label: 'İletişim' }
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                  activeTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Tab Content */}
      <div className="max-w-4xl mx-auto px-4 py-8">
        {activeTab === 'about' && (
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Hakkında</h3>
              <p className="text-gray-700 leading-relaxed whitespace-pre-line">{craftsman.description}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <h4 className="font-semibold text-gray-900 mb-3">Sertifikalar</h4>
                <ul className="space-y-2">
                  {craftsman.certifications.map((cert, index) => (
                    <li key={index} className="flex items-center space-x-2 text-gray-700">
                      <svg className="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                      </svg>
                      <span>{cert}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <div>
                <h4 className="font-semibold text-gray-900 mb-3">Hizmet Bölgeleri</h4>
                <div className="flex flex-wrap gap-2">
                  {craftsman.location.service_areas.map((area, index) => (
                    <span key={index} className="px-3 py-1 bg-gray-100 text-gray-700 text-sm rounded-full">
                      {area}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            <div>
              <h4 className="font-semibold text-gray-900 mb-3">Çalışma Saatleri</h4>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {Object.entries(craftsman.working_hours).map(([day, hours]) => (
                  <div key={day} className="flex justify-between">
                    <span className="text-gray-600 capitalize">{day}</span>
                    <span className="text-gray-900">{hours}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {activeTab === 'portfolio' && (
          <div className="space-y-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Portföy</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {portfolio.map((item) => (
                <div key={item.id} className="bg-white rounded-xl shadow-sm border overflow-hidden">
                  <div className="aspect-w-16 aspect-h-9">
                    <img
                      src={item.images[0]}
                      alt={item.title}
                      className="w-full h-48 object-cover"
                    />
                  </div>
                  <div className="p-4">
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-sm text-blue-600 font-medium">{item.category}</span>
                      <span className="text-sm text-gray-500">{item.date}</span>
                    </div>
                    <h4 className="font-semibold text-gray-900 mb-2">{item.title}</h4>
                    <p className="text-gray-600 text-sm mb-3">{item.description}</p>
                    {item.client_review && (
                      <div className="bg-gray-50 p-3 rounded-lg">
                        <p className="text-sm text-gray-700 italic">"{item.client_review}"</p>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'reviews' && (
          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-semibold text-gray-900">Değerlendirmeler</h3>
              <div className="flex items-center space-x-4">
                <div className="flex items-center space-x-1">
                  {renderStars(craftsman.rating)}
                  <span className="text-lg font-semibold text-gray-900 ml-2">{craftsman.rating}</span>
                </div>
                <span className="text-gray-500">({craftsman.review_count} değerlendirme)</span>
              </div>
            </div>

            {/* Rating Distribution */}
            <div className="bg-gray-50 rounded-xl p-4">
              <h4 className="font-medium text-gray-900 mb-3">Değerlendirme Dağılımı</h4>
              <div className="space-y-2">
                {Object.entries(getRatingDistribution()).reverse().map(([rating, percentage]) => (
                  <div key={rating} className="flex items-center space-x-3">
                    <span className="text-sm text-gray-600 w-8">{rating} yıldız</span>
                    <div className="flex-1 bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-yellow-400 h-2 rounded-full"
                        style={{ width: `${percentage}%` }}
                      ></div>
                    </div>
                    <span className="text-sm text-gray-600 w-12">{percentage}%</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Reviews List */}
            <div className="space-y-4">
              {reviews.map((review) => (
                <div key={review.id} className="bg-white rounded-xl p-6 border">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <div className="flex items-center space-x-2 mb-2">
                        <span className="font-medium text-gray-900">{review.user_name}</span>
                        <div className="flex items-center space-x-1">
                          {renderStars(review.rating)}
                        </div>
                      </div>
                      <p className="text-gray-700 mb-3">{review.comment}</p>
                    </div>
                    <span className="text-sm text-gray-500">{review.date}</span>
                  </div>

                  {review.reply && (
                    <div className="bg-blue-50 rounded-lg p-3 ml-4 border-l-4 border-blue-500">
                      <div className="flex items-center space-x-2 mb-1">
                        <span className="font-medium text-blue-900">{craftsman.name}</span>
                        <span className="text-sm text-blue-600">Yanıtladı</span>
                      </div>
                      <p className="text-blue-800 text-sm">{review.reply.text}</p>
                    </div>
                  )}

                  <div className="flex items-center justify-between mt-4 pt-4 border-t">
                    <div className="flex items-center space-x-4">
                      <button
                        onClick={() => handleHelpfulVote(review.id, true)}
                        className="flex items-center space-x-1 text-sm text-gray-500 hover:text-gray-700"
                      >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21H4.737a2 2 0 01-1.789-2.894l3.5-7A2 2 0 014.764 10H9v-4a2 2 0 012-2h2a2 2 0 012 2v4z" />
                        </svg>
                        <span>Faydalı ({review.helpful_count})</span>
                      </button>
                    </div>
                    {user?.user_type === 'craftsman' && !review.reply && (
                      <button
                        onClick={() => handleReplyClick(review)}
                        className="text-sm text-blue-600 hover:text-blue-700 font-medium"
                      >
                        Yanıtla
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'contact' && (
          <div className="space-y-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">İletişim Bilgileri</h3>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                    <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Telefon</p>
                    <p className="font-medium text-gray-900">{craftsman.contact.phone}</p>
                  </div>
                </div>

                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                    <svg className="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">E-posta</p>
                    <p className="font-medium text-gray-900">{craftsman.contact.email}</p>
                  </div>
                </div>

                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                    <svg className="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Website</p>
                    <p className="font-medium text-gray-900">{craftsman.contact.website}</p>
                  </div>
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <h4 className="font-medium text-gray-900 mb-2">Adres</h4>
                  <p className="text-gray-700">{craftsman.location.address}</p>
                </div>

                <div>
                  <h4 className="font-medium text-gray-900 mb-2">Hizmet Bölgeleri</h4>
                  <div className="flex flex-wrap gap-2">
                    {craftsman.location.service_areas.map((area, index) => (
                      <span key={index} className="px-3 py-1 bg-gray-100 text-gray-700 text-sm rounded-full">
                        {area}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Reply Modal */}
      {showReplyModal && selectedReview && (
        <ReviewReplyModal
          review={selectedReview}
          onClose={() => setShowReplyModal(false)}
          onSubmit={handleReplySubmit}
        />
      )}
    </div>
  );
};

export default CraftsmanProfilePage;