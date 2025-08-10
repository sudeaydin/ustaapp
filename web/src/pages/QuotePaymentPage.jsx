import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const QuotePaymentPage = () => {
  const navigate = useNavigate();
  const { quoteId } = useParams();
  const { user } = useAuth();
  
  const [quote, setQuote] = useState(null);
  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState(false);
  const [showMockPayment, setShowMockPayment] = useState(false);

  useEffect(() => {
    loadQuote();
  }, [quoteId]);

  const loadQuote = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/quote-requests/${quoteId}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      const data = await response.json();

      if (data.success) {
        setQuote(data.quote);
      } else {
        alert('Teklif bilgileri yüklenemedi');
        navigate('/messages');
      }
    } catch (error) {
      console.error('Teklif yükleme hatası:', error);
      alert('Teklif bilgileri yüklenemedi');
      navigate('/messages');
    } finally {
      setLoading(false);
    }
  };

  const handlePayment = () => {
    setShowMockPayment(true);
  };

  const handleMockPaymentConfirm = () => {
    setProcessing(true);
    
    // Mock payment processing
    setTimeout(() => {
      alert('Ödeme başarıyla tamamlandı! (Mock ödeme sistemi)');
      setProcessing(false);
      setShowMockPayment(false);
      navigate('/customer/jobs');
    }, 2000);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!quote || quote.status !== 'accepted') {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-xl font-semibold text-gray-800 mb-2">Ödeme Yapılamaz</h2>
          <p className="text-gray-600 mb-4">Bu teklif için ödeme yapılamaz</p>
          <button
            onClick={() => navigate('/messages')}
            className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            Mesajlara Dön
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      {/* Header */}
      <div className="bg-white shadow-sm">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <button
              onClick={() => navigate(-1)}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h1 className="text-lg font-semibold text-gray-900">Ödeme</h1>
            <div className="w-10"></div>
          </div>
        </div>
      </div>

      <div className="max-w-md mx-auto px-4 py-6 space-y-6">
        {/* Quote Summary */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-lg font-semibold text-gray-800 mb-4">İş Özeti</h2>
          
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-600">Usta:</span>
              <span className="font-medium">{quote.craftsman?.name}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Kategori:</span>
              <span className="font-medium">{quote.category}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Alan:</span>
              <span className="font-medium">{quote.area_type}</span>
            </div>
            {quote.square_meters && (
              <div className="flex justify-between">
                <span className="text-gray-600">Metrekare:</span>
                <span className="font-medium">{quote.square_meters} m²</span>
              </div>
            )}
            <div className="flex justify-between">
              <span className="text-gray-600">Başlangıç:</span>
              <span className="font-medium">{quote.estimated_start_date}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Bitiş:</span>
              <span className="font-medium">{quote.estimated_end_date}</span>
            </div>
          </div>
          
          <div className="border-t border-gray-200 mt-4 pt-4">
            <div className="flex justify-between text-lg font-semibold">
              <span>Toplam Tutar:</span>
              <span className="text-green-600">{quote.quoted_price} TL</span>
            </div>
          </div>
        </div>

        {/* Payment Method */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Ödeme Yöntemi</h3>
          
          <div className="space-y-3">
            <label className="flex items-center p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50">
              <input type="radio" name="payment" className="mr-3" defaultChecked />
              <div className="flex items-center">
                <span className="text-2xl mr-3">💳</span>
                <div>
                  <div className="font-medium">Kredi/Banka Kartı</div>
                  <div className="text-sm text-gray-600">Güvenli ödeme</div>
                </div>
              </div>
            </label>
            
            <label className="flex items-center p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50 opacity-50">
              <input type="radio" name="payment" className="mr-3" disabled />
              <div className="flex items-center">
                <span className="text-2xl mr-3">🏦</span>
                <div>
                  <div className="font-medium">Havale/EFT</div>
                  <div className="text-sm text-gray-600">Yakında...</div>
                </div>
              </div>
            </label>
          </div>
        </div>

        {/* Payment Info */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div className="flex items-start">
            <span className="text-blue-500 text-xl mr-3">ℹ️</span>
            <div className="text-sm text-blue-800">
              <p className="font-medium mb-1">Güvenli Ödeme</p>
              <p>Ödemeniz güvenli bir şekilde işlenecek ve usta işi tamamladıktan sonra hesabına aktarılacaktır.</p>
            </div>
          </div>
        </div>

        {/* Pay Button */}
        <button
          onClick={handlePayment}
          disabled={processing}
          className="w-full bg-green-500 text-white py-4 rounded-lg font-semibold text-lg hover:bg-green-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {processing ? (
            <div className="flex items-center justify-center">
              <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
              İşleniyor...
            </div>
          ) : (
            `💰 ${quote.quoted_price} TL Öde`
          )}
        </button>
      </div>

      {/* Mock Payment Modal */}
      {showMockPayment && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-sm w-full p-6">
            <div className="text-center mb-6">
              <div className="text-4xl mb-4">💳</div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">
                Mock Ödeme Sistemi
              </h3>
              <p className="text-gray-600 text-sm">
                Gerçek ödeme sistemi henüz entegre edilmemiştir
              </p>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <div className="text-center">
                <p className="font-semibold text-gray-800">Ödenecek Tutar</p>
                <p className="text-2xl font-bold text-green-600">{quote.quoted_price} TL</p>
              </div>
            </div>

            <div className="flex space-x-3">
              <button
                onClick={() => setShowMockPayment(false)}
                disabled={processing}
                className="flex-1 px-4 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400 transition-colors disabled:opacity-50"
              >
                İptal
              </button>
              <button
                onClick={handleMockPaymentConfirm}
                disabled={processing}
                className="flex-1 px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors disabled:opacity-50"
              >
                {processing ? (
                  <div className="flex items-center justify-center">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    İşleniyor...
                  </div>
                ) : (
                  'Öde (Mock)'
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default QuotePaymentPage;