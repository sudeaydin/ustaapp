import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const CustomerQuoteDecisionModal = ({ isOpen, onClose, quote, onDecision }) => {
  const [decision, setDecision] = useState('');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    setSubmitting(true);
    
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/quote-requests/customer-decision', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          quote_id: quote.id,
          decision: decision,
          notes: notes
        })
      });

      const data = await response.json();

      if (data.success) {
        if (decision === 'accept') {
          alert('Teklif kabul edildi! Ödeme sayfasına yönlendiriliyorsunuz.');
          navigate(`/payment/quote/${quote.id}`);
        } else {
          alert('Kararınız başarıyla iletildi!');
        }
        onDecision(data.quote);
        onClose();
      } else {
        alert(data.message || 'Karar iletilirken bir hata oluştu');
      }
    } catch (error) {
      console.error('Karar iletme hatası:', error);
      alert('Karar iletilirken bir hata oluştu');
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
            <h2 className="text-xl font-bold text-gray-800">Teklif Kararı</h2>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Quote Summary */}
          <div className="bg-blue-50 rounded-lg p-4 mb-6">
            <h3 className="font-semibold text-blue-800 mb-2">Gelen Teklif</h3>
            <div className="space-y-2 text-sm">
              <p><span className="font-medium">Usta:</span> {quote.craftsman?.name}</p>
              <p><span className="font-medium">Fiyat:</span> {quote.quoted_price} TL</p>
              <p><span className="font-medium">Başlangıç:</span> {quote.estimated_start_date}</p>
              <p><span className="font-medium">Bitiş:</span> {quote.estimated_end_date}</p>
              {quote.craftsman_notes && (
                <p><span className="font-medium">Notlar:</span> {quote.craftsman_notes}</p>
              )}
            </div>
          </div>

          {/* Decision Options */}
          <div className="mb-6">
            <h3 className="font-semibold text-gray-800 mb-3">Kararınız</h3>
            <div className="space-y-2">
              <label className="flex items-center">
                <input
                  type="radio"
                  value="accept"
                  checked={decision === 'accept'}
                  onChange={(e) => setDecision(e.target.value)}
                  className="mr-2"
                />
                <span>✅ Teklifi Kabul Et</span>
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  value="revision"
                  checked={decision === 'revision'}
                  onChange={(e) => setDecision(e.target.value)}
                  className="mr-2"
                />
                <span>🔄 Yeni Teklif İste</span>
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  value="reject"
                  checked={decision === 'reject'}
                  onChange={(e) => setDecision(e.target.value)}
                  className="mr-2"
                />
                <span>❌ Teklifi Reddet</span>
              </label>
            </div>
          </div>

          {/* Notes for revision or rejection */}
          {(decision === 'revision' || decision === 'reject') && (
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                {decision === 'revision' ? 'Revizyon Talebi' : 'Red Sebebi'} (Opsiyonel)
              </label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder={
                  decision === 'revision' 
                    ? "Teklifte neyin değişmesini istiyorsunuz?" 
                    : "Red sebebinizi belirtebilirsiniz..."
                }
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
              />
            </div>
          )}

          {/* Action Buttons */}
          <form onSubmit={handleSubmit}>
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
                disabled={submitting || !decision}
                className={`flex-1 px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
                  decision === 'accept' 
                    ? 'bg-green-500 text-white hover:bg-green-600'
                    : decision === 'revision'
                    ? 'bg-orange-500 text-white hover:bg-orange-600'
                    : 'bg-red-500 text-white hover:bg-red-600'
                }`}
              >
                {submitting ? (
                  <div className="flex items-center justify-center">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Gönderiliyor...
                  </div>
                ) : (
                  decision === 'accept' ? 'Kabul Et' : 
                  decision === 'revision' ? 'Revizyon İste' : 'Reddet'
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default CustomerQuoteDecisionModal;