import React, { useState } from 'react';

export const ReviewReplyModal = ({ review, isOpen, onClose, onReply }) => {
  const [replyText, setReplyText] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (replyText.trim().length < 5) {
      alert('Yanıt en az 5 karakter olmalıdır!');
      return;
    }

    setSubmitting(true);
    
    try {
      const response = await fetch(`http://localhost:5001/api/reviews/${review.id}/reply`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          reply: replyText.trim()
        })
      });

      const result = await response.json();

      if (result.success) {
        onReply(review.id, result.data);
        setReplyText('');
        onClose();
        alert('✅ Yanıtınız başarıyla gönderildi!');
      } else {
        alert('❌ Hata: ' + result.error);
      }
    } catch (error) {
      console.error('Error submitting reply:', error);
      alert('❌ Yanıt gönderilirken hata oluştu!');
    } finally {
      setSubmitting(false);
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const renderStars = (rating) => {
    return Array.from({ length: 5 }, (_, i) => (
      <span key={i} className={`text-sm ${i < Math.floor(rating) ? 'text-yellow-400' : 'text-gray-300'}`}>
        ⭐
      </span>
    ));
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-xl font-medium text-gray-900">💬 Yoruma Yanıt Ver</h3>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Original Review */}
          <div className="bg-gray-50 rounded-lg p-4 mb-6">
            <div className="flex items-start space-x-3">
              <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                <span className="text-gray-600 font-medium text-sm">
                  {review.customer_name.charAt(0)}
                </span>
              </div>
              <div className="flex-1">
                <div className="flex items-center space-x-2 mb-2">
                  <h4 className="font-medium text-gray-900">{review.customer_name}</h4>
                  <div className="flex items-center space-x-1">
                    {renderStars(review.rating)}
                  </div>
                  <span className="text-sm text-gray-500">
                    {formatDate(review.created_at)}
                  </span>
                </div>
                {review.service_category && (
                  <p className="text-sm text-blue-600 mb-2">🔧 {review.service_category}</p>
                )}
                <p className="text-gray-700">{review.comment}</p>
                
                {review.helpful_votes > 0 && (
                  <div className="mt-2 text-sm text-gray-500">
                    👍 {review.helpful_votes} kişi faydalı buldu
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Reply Form */}
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Yanıtınız
              </label>
              <textarea
                value={replyText}
                onChange={(e) => setReplyText(e.target.value)}
                rows={4}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Müşterinizin yorumuna profesyonel bir yanıt yazın..."
                required
              />
              <p className="text-sm text-gray-500 mt-1">
                {replyText.length}/300 karakter
              </p>
            </div>

            {/* Guidelines */}
            <div className="bg-blue-50 rounded-lg p-4 mb-6">
              <h4 className="text-sm font-medium text-blue-900 mb-2">💡 Yanıt Yazma İpuçları:</h4>
              <ul className="text-sm text-blue-800 space-y-1">
                <li>• Müşterinize teşekkür edin</li>
                <li>• Profesyonel ve kibar bir dil kullanın</li>
                <li>• Varsa sorunları kabul edin ve özür dileyin</li>
                <li>• Gelecekteki hizmetlerinizden bahsedin</li>
              </ul>
            </div>

            {/* Buttons */}
            <div className="flex space-x-3">
              <button
                type="button"
                onClick={onClose}
                className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
              >
                İptal
              </button>
              <button
                type="submit"
                disabled={submitting || replyText.trim().length < 5}
                className="flex-1 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {submitting ? (
                  <div className="flex items-center justify-center space-x-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span>Gönderiliyor...</span>
                  </div>
                ) : (
                  '💬 Yanıtı Gönder'
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default ReviewReplyModal;