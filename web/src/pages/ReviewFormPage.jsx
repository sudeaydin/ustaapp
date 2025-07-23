import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const ReviewFormPage = () => {
  const navigate = useNavigate();
  const { jobId } = useParams();
  const { user } = useAuth();
  
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [canReview, setCanReview] = useState(false);
  const [jobDetails, setJobDetails] = useState(null);
  
  // Form states
  const [rating, setRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [comment, setComment] = useState('');
  const [serviceCategory, setServiceCategory] = useState('');
  const [photos, setPhotos] = useState([]);
  const [isAnonymous, setIsAnonymous] = useState(false);

  // Mock job details
  const mockJobDetails = {
    id: parseInt(jobId),
    craftsman: {
      id: 1,
      name: 'Ahmet Yılmaz',
      business_name: 'Yılmaz Elektrik',
      avatar: null
    },
    service: 'LED Aydınlatma Sistemi',
    date: '2025-01-20',
    amount: 2500,
    status: 'completed'
  };

  useEffect(() => {
    checkCanReview();
  }, [jobId]);

  const checkCanReview = async () => {
    try {
      setLoading(true);
      
      // Mock API call - check if job can be reviewed
      const response = await fetch(`http://localhost:5001/api/jobs/${jobId}/can-review`);
      const data = await response.json();
      
      if (data.can_review) {
        setCanReview(true);
        setJobDetails(mockJobDetails);
        setServiceCategory(mockJobDetails.service);
      } else {
        setCanReview(false);
      }
    } catch (error) {
      console.error('Error checking review eligibility:', error);
      setCanReview(false);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (rating === 0) {
      alert('Lütfen bir puan verin!');
      return;
    }
    
    if (comment.trim().length < 10) {
      alert('Yorum en az 10 karakter olmalıdır!');
      return;
    }

    setSubmitting(true);
    
    try {
      const reviewData = {
        job_id: parseInt(jobId),
        craftsman_id: jobDetails.craftsman.id,
        customer_id: user?.id || 1,
        customer_name: isAnonymous ? 'Anonim Müşteri' : (user?.name || 'Müşteri'),
        rating: rating,
        comment: comment.trim(),
        service_category: serviceCategory,
        photos: photos
      };

      const response = await fetch('http://localhost:5001/api/reviews', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(reviewData)
      });

      const result = await response.json();

      if (result.success) {
        alert('✅ Değerlendirmeniz başarıyla gönderildi!');
        navigate(`/craftsman/${jobDetails.craftsman.id}`);
      } else {
        alert('❌ Hata: ' + result.error);
      }
    } catch (error) {
      console.error('Error submitting review:', error);
      alert('❌ Değerlendirme gönderilirken hata oluştu!');
    } finally {
      setSubmitting(false);
    }
  };

  const renderStars = () => {
    return Array.from({ length: 5 }, (_, i) => {
      const starValue = i + 1;
      return (
        <button
          key={i}
          type="button"
          className={`text-3xl transition-colors ${
            starValue <= (hoverRating || rating) ? 'text-yellow-400' : 'text-gray-300'
          }`}
          onMouseEnter={() => setHoverRating(starValue)}
          onMouseLeave={() => setHoverRating(0)}
          onClick={() => setRating(starValue)}
        >
          ⭐
        </button>
      );
    });
  };

  const getRatingText = (rating) => {
    switch (rating) {
      case 1: return '😞 Çok Kötü';
      case 2: return '😐 Kötü';
      case 3: return '😊 Orta';
      case 4: return '😄 İyi';
      case 5: return '🤩 Mükemmel';
      default: return 'Puan verin';
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Kontrol ediliyor...</p>
        </div>
      </div>
    );
  }

  if (!canReview) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="max-w-md mx-auto bg-white rounded-lg shadow-sm p-8 text-center">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">
            Değerlendirme Yapılamaz
          </h2>
          <p className="text-gray-600 mb-6">
            Bu iş için değerlendirme yapamazsınız. İş tamamlanmamış olabilir veya daha önce değerlendirme yapmış olabilirsiniz.
          </p>
          <button
            onClick={() => navigate(-1)}
            className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            Geri Dön
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-4xl mx-auto px-4 py-4">
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
              <h1 className="text-2xl font-bold text-gray-900">⭐ Değerlendirme Yap</h1>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Job Info Card */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
          <div className="flex items-center space-x-4">
            <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center">
              {jobDetails.craftsman.avatar ? (
                <img src={jobDetails.craftsman.avatar} alt={jobDetails.craftsman.name} className="w-16 h-16 rounded-full object-cover" />
              ) : (
                <span className="text-blue-600 font-medium text-xl">
                  {jobDetails.craftsman.name.charAt(0)}
                </span>
              )}
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-gray-900">{jobDetails.craftsman.name}</h3>
              <p className="text-gray-600">{jobDetails.craftsman.business_name}</p>
              <div className="flex items-center space-x-4 mt-2 text-sm text-gray-500">
                <span>🔧 {jobDetails.service}</span>
                <span>📅 {jobDetails.date}</span>
                <span>💰 {jobDetails.amount}₺</span>
              </div>
            </div>
            <div className="text-right">
              <span className="px-3 py-1 bg-green-100 text-green-800 text-sm rounded-full font-medium">
                ✅ Tamamlandı
              </span>
            </div>
          </div>
        </div>

        {/* Review Form */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Rating */}
            <div className="text-center">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Hizmetten ne kadar memnun kaldınız?
              </h3>
              <div className="flex justify-center space-x-2 mb-4">
                {renderStars()}
              </div>
              <p className="text-lg font-medium text-gray-700">
                {getRatingText(hoverRating || rating)}
              </p>
            </div>

            {/* Service Category */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Hizmet Kategorisi
              </label>
              <input
                type="text"
                value={serviceCategory}
                onChange={(e) => setServiceCategory(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Örn: LED Aydınlatma, Elektrik Onarımı"
              />
            </div>

            {/* Comment */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Yorumunuz *
              </label>
              <textarea
                value={comment}
                onChange={(e) => setComment(e.target.value)}
                rows={5}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Aldığınız hizmet hakkında detaylı yorumunuzu yazın. Bu yorum diğer müşterilere yardımcı olacaktır..."
                required
              />
              <p className="text-sm text-gray-500 mt-1">
                {comment.length}/500 karakter (En az 10 karakter gerekli)
              </p>
            </div>

            {/* Photo Upload */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Fotoğraf Ekle (İsteğe bağlı)
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                <svg className="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <p className="text-gray-600 mb-2">Yapılan işin fotoğraflarını ekleyebilirsiniz</p>
                <button
                  type="button"
                  className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                >
                  📷 Fotoğraf Seç
                </button>
              </div>
            </div>

            {/* Anonymous Option */}
            <div className="flex items-center">
              <input
                type="checkbox"
                id="anonymous"
                checked={isAnonymous}
                onChange={(e) => setIsAnonymous(e.target.checked)}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <label htmlFor="anonymous" className="ml-2 text-sm text-gray-700">
                Yorumumu anonim olarak yayınla
              </label>
            </div>

            {/* Guidelines */}
            <div className="bg-blue-50 rounded-lg p-4">
              <h4 className="text-sm font-medium text-blue-900 mb-2">📋 Değerlendirme Kuralları:</h4>
              <ul className="text-sm text-blue-800 space-y-1">
                <li>• Sadece aldığınız hizmet hakkında yorum yapın</li>
                <li>• Kişisel bilgileri paylaşmayın</li>
                <li>• Saygılı bir dil kullanın</li>
                <li>• Gerçek deneyiminizi paylaşın</li>
              </ul>
            </div>

            {/* Submit Button */}
            <div className="flex space-x-4">
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="flex-1 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
              >
                İptal
              </button>
              <button
                type="submit"
                disabled={submitting || rating === 0 || comment.trim().length < 10}
                className="flex-1 px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {submitting ? (
                  <div className="flex items-center justify-center space-x-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span>Gönderiliyor...</span>
                  </div>
                ) : (
                  '⭐ Değerlendirmeyi Gönder'
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default ReviewFormPage;