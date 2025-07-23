import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import PaymentForm from '../components/PaymentForm';

const PaymentPage = () => {
  const { jobId } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [job, setJob] = useState(null);
  const [craftsman, setCraftsman] = useState(null);
  const [loading, setLoading] = useState(true);
  const [paymentStep, setPaymentStep] = useState('form'); // form, processing, success, error
  const [paymentResult, setPaymentResult] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    loadJobDetails();
  }, [jobId]);

  const loadJobDetails = () => {
    try {
      // Load job details
      const jobs = JSON.parse(localStorage.getItem('jobs') || '[]');
      const foundJob = jobs.find(j => j.id === jobId);
      
      if (!foundJob) {
        setError('İş bulunamadı');
        setLoading(false);
        return;
      }

      // Verify user is the customer for this job
      if (foundJob.customerId !== user.id) {
        setError('Bu işe ödeme yapmaya yetkiniz yok');
        setLoading(false);
        return;
      }

      // Check if job is in payable state
      if (foundJob.status !== 'completed' && foundJob.status !== 'approved') {
        setError('Bu iş henüz ödeme için hazır değil');
        setLoading(false);
        return;
      }

      setJob(foundJob);

      // Load craftsman details
      const users = JSON.parse(localStorage.getItem('users') || '[]');
      const foundCraftsman = users.find(u => u.id === foundJob.craftsmanId);
      setCraftsman(foundCraftsman);

    } catch (error) {
      setError('İş detayları yüklenirken hata oluştu');
    } finally {
      setLoading(false);
    }
  };

  const handlePaymentSuccess = (result) => {
    setPaymentResult(result);
    setPaymentStep('success');

    // Update job status to paid
    const jobs = JSON.parse(localStorage.getItem('jobs') || '[]');
    const updatedJobs = jobs.map(j => 
      j.id === jobId 
        ? { ...j, status: 'paid', paymentId: result.paymentId, paidAt: new Date().toISOString() }
        : j
    );
    localStorage.setItem('jobs', JSON.stringify(updatedJobs));

    // Create notification for craftsman
    const notifications = JSON.parse(localStorage.getItem('notifications') || '[]');
    notifications.push({
      id: `notif_${Date.now()}`,
      userId: craftsman.id,
      type: 'payment',
      title: 'Ödeme Alındı',
      message: `${job.title} işi için ₺${job.budget.toLocaleString()} ödeme aldınız.`,
      isRead: false,
      createdAt: new Date().toISOString(),
      priority: 'high'
    });
    localStorage.setItem('notifications', JSON.stringify(notifications));
  };

  const handlePaymentError = (errorMessage) => {
    setError(errorMessage);
    setPaymentStep('error');
  };

  const handleCancel = () => {
    navigate(-1);
  };

  const handleRetry = () => {
    setPaymentStep('form');
    setError('');
    setPaymentResult(null);
  };

  const handleBackToDashboard = () => {
    navigate('/customer-dashboard');
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-300">Ödeme sayfası yükleniyor...</p>
        </div>
      </div>
    );
  }

  if (error && paymentStep !== 'error') {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="max-w-md mx-auto text-center">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
            <div className="text-red-500 text-6xl mb-4">❌</div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
              Hata Oluştu
            </h2>
            <p className="text-gray-600 dark:text-gray-300 mb-6">
              {error}
            </p>
            <button
              onClick={() => navigate(-1)}
              className="w-full bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
            >
              Geri Dön
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-8">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => navigate(-1)}
            className="flex items-center text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 mb-4"
          >
            <span className="mr-2">←</span>
            Geri Dön
          </button>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
            Ödeme İşlemi
          </h1>
          <p className="text-gray-600 dark:text-gray-300">
            Güvenli ödeme ile işinizi tamamlayın
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Job Details */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
            <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
              İş Detayları
            </h2>
            
            {job && (
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-gray-900 dark:text-white mb-2">
                    {job.title}
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300 text-sm">
                    {job.description}
                  </p>
                </div>

                <div className="border-t pt-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm text-gray-600 dark:text-gray-300">Kategori:</span>
                    <span className="text-sm font-medium text-gray-900 dark:text-white">
                      {job.category}
                    </span>
                  </div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm text-gray-600 dark:text-gray-300">Konum:</span>
                    <span className="text-sm font-medium text-gray-900 dark:text-white">
                      {job.location}
                    </span>
                  </div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm text-gray-600 dark:text-gray-300">Aciliyet:</span>
                    <span className={`text-sm font-medium px-2 py-1 rounded-full ${
                      job.urgency === 'urgent' 
                        ? 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400'
                        : job.urgency === 'normal'
                        ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400'
                        : 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
                    }`}>
                      {job.urgency === 'urgent' ? 'Acil' : 
                       job.urgency === 'normal' ? 'Normal' : 'Esnek'}
                    </span>
                  </div>
                </div>

                {craftsman && (
                  <div className="border-t pt-4">
                    <h4 className="font-medium text-gray-900 dark:text-white mb-2">
                      Usta Bilgileri
                    </h4>
                    <div className="flex items-center">
                      <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900/20 rounded-full flex items-center justify-center mr-3">
                        <span className="text-xl">{craftsman.name.charAt(0)}</span>
                      </div>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">
                          {craftsman.name}
                        </p>
                        <p className="text-sm text-gray-600 dark:text-gray-300">
                          {craftsman.skills?.join(', ')}
                        </p>
                        <div className="flex items-center">
                          <span className="text-yellow-400 mr-1">⭐</span>
                          <span className="text-sm text-gray-600 dark:text-gray-300">
                            {craftsman.rating || 4.5} ({craftsman.reviewCount || 0} değerlendirme)
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                )}

                <div className="border-t pt-4">
                  <div className="flex items-center justify-between">
                    <span className="text-lg font-semibold text-gray-900 dark:text-white">
                      Toplam Tutar:
                    </span>
                    <span className="text-2xl font-bold text-blue-600">
                      ₺{job.budget.toLocaleString()}
                    </span>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Payment Form or Result */}
          <div>
            {paymentStep === 'form' && job && craftsman && (
              <PaymentForm
                amount={job.budget}
                jobId={jobId}
                craftsman={craftsman}
                onSuccess={handlePaymentSuccess}
                onError={handlePaymentError}
                onCancel={handleCancel}
              />
            )}

            {paymentStep === 'success' && (
              <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 text-center">
                <div className="text-green-500 text-6xl mb-4">✅</div>
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  Ödeme Başarılı!
                </h2>
                <p className="text-gray-600 dark:text-gray-300 mb-6">
                  ₺{job?.budget.toLocaleString()} tutarındaki ödemeniz başarıyla işleme alındı.
                </p>
                
                {paymentResult && (
                  <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 mb-6 text-left">
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-2">
                      İşlem Detayları
                    </h3>
                    <div className="space-y-1 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-600 dark:text-gray-300">İşlem ID:</span>
                        <span className="font-mono text-gray-900 dark:text-white">
                          {paymentResult.transactionId}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600 dark:text-gray-300">Ödeme ID:</span>
                        <span className="font-mono text-gray-900 dark:text-white">
                          {paymentResult.paymentId}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600 dark:text-gray-300">Taksit:</span>
                        <span className="text-gray-900 dark:text-white">
                          {paymentResult.installment}x
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600 dark:text-gray-300">Kart Tipi:</span>
                        <span className="text-gray-900 dark:text-white">
                          {paymentResult.cardType.toUpperCase()}
                        </span>
                      </div>
                    </div>
                  </div>
                )}

                <div className="space-y-3">
                  <button
                    onClick={handleBackToDashboard}
                    className="w-full bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Dashboard'a Dön
                  </button>
                  <button
                    onClick={() => navigate('/payment-history')}
                    className="w-full border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                  >
                    Ödeme Geçmişi
                  </button>
                </div>
              </div>
            )}

            {paymentStep === 'error' && (
              <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 text-center">
                <div className="text-red-500 text-6xl mb-4">❌</div>
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  Ödeme Başarısız
                </h2>
                <p className="text-gray-600 dark:text-gray-300 mb-6">
                  {error}
                </p>
                
                <div className="space-y-3">
                  <button
                    onClick={handleRetry}
                    className="w-full bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Tekrar Dene
                  </button>
                  <button
                    onClick={handleCancel}
                    className="w-full border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                  >
                    İptal Et
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Security Notice */}
        <div className="mt-8 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
          <div className="flex items-start">
            <span className="text-blue-600 text-xl mr-3">🔒</span>
            <div>
              <h3 className="font-semibold text-blue-800 dark:text-blue-200 mb-1">
                Güvenli Ödeme Garantisi
              </h3>
              <p className="text-blue-700 dark:text-blue-300 text-sm">
                Tüm ödemeleriniz 256-bit SSL şifreleme ile korunmaktadır. Kart bilgileriniz hiçbir zaman saklanmaz 
                ve güvenli ödeme altyapısı iyzico tarafından sağlanmaktadır.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PaymentPage;