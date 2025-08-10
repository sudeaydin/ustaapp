import React, { useState } from 'react';

const QuoteResponseModal = ({ isOpen, onClose, quote, onResponse }) => {
  const [responseType, setResponseType] = useState('');
  const [formData, setFormData] = useState({
    quoted_price: '',
    estimated_start_date: '',
    estimated_end_date: '',
    notes: ''
  });
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (responseType === 'quote') {
      if (!formData.quoted_price || !formData.estimated_start_date || !formData.estimated_end_date) {
        alert('Teklif verirken fiyat ve tarih aralığı zorunludur');
        return;
      }
    }

    setSubmitting(true);
    
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/quote-requests/respond', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          quote_id: quote.id,
          response_type: responseType,
          quoted_price: formData.quoted_price ? parseFloat(formData.quoted_price) : null,
          estimated_start_date: formData.estimated_start_date,
          estimated_end_date: formData.estimated_end_date,
          notes: formData.notes
        })
      });

      const data = await response.json();

      if (data.success) {
        alert('Yanıtınız başarıyla gönderildi!');
        onResponse(data.quote);
        onClose();
      } else {
        alert(data.message || 'Yanıt gönderilirken bir hata oluştu');
      }
    } catch (error) {
      console.error('Teklif yanıtı hatası:', error);
      alert('Yanıt gönderilirken bir hata oluştu');
    } finally {
      setSubmitting(false);
    }
  };

  if (!isOpen || !quote) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-md w-full max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-gray-800">Teklif Talebi Yanıtla</h2>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Quote Details */}
          <div className="bg-gray-50 rounded-lg p-4 mb-6">
            <h3 className="font-semibold text-gray-800 mb-2">Teklif Detayları</h3>
            <div className="space-y-2 text-sm">
              <p><span className="font-medium">Kategori:</span> {quote.category}</p>
              <p><span className="font-medium">Alan:</span> {quote.area_type}</p>
              <p><span className="font-medium">Bütçe:</span> {quote.budget_range} TL</p>
              {quote.square_meters && (
                <p><span className="font-medium">Metrekare:</span> {quote.square_meters} m²</p>
              )}
              <p><span className="font-medium">Açıklama:</span> {quote.description}</p>
              {quote.additional_details && (
                <p><span className="font-medium">Ek Detaylar:</span> {quote.additional_details}</p>
              )}
            </div>
          </div>

          {/* Response Type Selection */}
          <div className="mb-6">
            <h3 className="font-semibold text-gray-800 mb-3">Yanıt Türünüz</h3>
            <div className="space-y-2">
              <label className="flex items-center">
                <input
                  type="radio"
                  value="quote"
                  checked={responseType === 'quote'}
                  onChange={(e) => setResponseType(e.target.value)}
                  className="mr-2"
                />
                <span>💰 Teklif Ver</span>
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  value="details_request"
                  checked={responseType === 'details_request'}
                  onChange={(e) => setResponseType(e.target.value)}
                  className="mr-2"
                />
                <span>❓ Daha Fazla Detay İste</span>
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  value="reject"
                  checked={responseType === 'reject'}
                  onChange={(e) => setResponseType(e.target.value)}
                  className="mr-2"
                />
                <span>❌ Teklifi Reddet</span>
              </label>
            </div>
          </div>

          {/* Form based on response type */}
          <form onSubmit={handleSubmit}>
            {responseType === 'quote' && (
              <div className="space-y-4 mb-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Teklif Fiyatı (TL) *
                  </label>
                  <input
                    type="number"
                    value={formData.quoted_price}
                    onChange={(e) => setFormData(prev => ({ ...prev, quoted_price: e.target.value }))}
                    placeholder="Örn: 2500"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Tahmini Başlangıç Tarihi *
                  </label>
                  <input
                    type="date"
                    value={formData.estimated_start_date}
                    onChange={(e) => setFormData(prev => ({ ...prev, estimated_start_date: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Tahmini Bitiş Tarihi *
                  </label>
                  <input
                    type="date"
                    value={formData.estimated_end_date}
                    onChange={(e) => setFormData(prev => ({ ...prev, estimated_end_date: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Teklif Notları
                  </label>
                  <textarea
                    value={formData.notes}
                    onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
                    placeholder="Teklif hakkında ek bilgiler..."
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                  />
                </div>
              </div>
            )}

            {responseType === 'details_request' && (
              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Detay Talebi Mesajı
                </label>
                <textarea
                  value={formData.notes}
                  onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
                  placeholder="Hangi konularda daha fazla bilgiye ihtiyacınız var?"
                  rows={4}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                />
              </div>
            )}

            {responseType === 'reject' && (
              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Red Sebebi (Opsiyonel)
                </label>
                <textarea
                  value={formData.notes}
                  onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
                  placeholder="Red sebebinizi belirtebilirsiniz..."
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                />
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex space-x-3">
              <button
                type="button"
                onClick={onClose}
                disabled={submitting}
                className="flex-1 px-4 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400 transition-colors disabled:opacity-50"
              >
                İptal
              </button>
              <button
                type="submit"
                disabled={submitting || !responseType}
                className="flex-1 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {submitting ? (
                  <div className="flex items-center justify-center">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Gönderiliyor...
                  </div>
                ) : (
                  'Yanıtla'
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default QuoteResponseModal;