import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';

const PaymentForm = ({ 
  amount, 
  jobId, 
  craftsman, 
  onSuccess, 
  onError,
  onCancel 
}) => {
  const { user } = useAuth();
  const [paymentData, setPaymentData] = useState({
    cardNumber: '',
    expiryMonth: '',
    expiryYear: '',
    cvc: '',
    cardHolderName: '',
    installment: '1'
  });
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [installmentOptions, setInstallmentOptions] = useState([]);
  const [paymentMethods, setPaymentMethods] = useState([
    { id: 'credit_card', name: 'Kredi Kartı', icon: '💳' },
    { id: 'debit_card', name: 'Banka Kartı', icon: '💳' },
    { id: 'wallet', name: 'Cüzdan', icon: '👛' }
  ]);
  const [selectedMethod, setSelectedMethod] = useState('credit_card');

  useEffect(() => {
    // Simulate installment options based on amount
    const options = [
      { value: '1', label: 'Tek Çekim', fee: 0 },
      { value: '2', label: '2 Taksit', fee: amount * 0.02 },
      { value: '3', label: '3 Taksit', fee: amount * 0.03 },
      { value: '6', label: '6 Taksit', fee: amount * 0.06 },
      { value: '9', label: '9 Taksit', fee: amount * 0.09 },
      { value: '12', label: '12 Taksit', fee: amount * 0.12 }
    ];
    setInstallmentOptions(options);
  }, [amount]);

  const validateCard = (cardNumber) => {
    // Luhn algorithm for card validation
    const digits = cardNumber.replace(/\D/g, '');
    let sum = 0;
    let isEven = false;
    
    for (let i = digits.length - 1; i >= 0; i--) {
      let digit = parseInt(digits[i]);
      
      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      isEven = !isEven;
    }
    
    return sum % 10 === 0;
  };

  const getCardType = (cardNumber) => {
    const number = cardNumber.replace(/\D/g, '');
    
    if (/^4/.test(number)) return 'visa';
    if (/^5[1-5]/.test(number)) return 'mastercard';
    if (/^3[47]/.test(number)) return 'amex';
    if (/^6/.test(number)) return 'discover';
    
    return 'unknown';
  };

  const formatCardNumber = (value) => {
    const v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
    const matches = v.match(/\d{4,16}/g);
    const match = matches && matches[0] || '';
    const parts = [];

    for (let i = 0, len = match.length; i < len; i += 4) {
      parts.push(match.substring(i, i + 4));
    }

    if (parts.length) {
      return parts.join(' ');
    } else {
      return v;
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!paymentData.cardNumber || paymentData.cardNumber.length < 16) {
      newErrors.cardNumber = 'Geçerli bir kart numarası giriniz';
    } else if (!validateCard(paymentData.cardNumber)) {
      newErrors.cardNumber = 'Kart numarası geçersiz';
    }

    if (!paymentData.expiryMonth || !paymentData.expiryYear) {
      newErrors.expiry = 'Son kullanma tarihi gerekli';
    }

    if (!paymentData.cvc || paymentData.cvc.length < 3) {
      newErrors.cvc = 'Geçerli CVC kodu giriniz';
    }

    if (!paymentData.cardHolderName.trim()) {
      newErrors.cardHolderName = 'Kart sahibi adı gerekli';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name === 'cardNumber') {
      const formatted = formatCardNumber(value);
      setPaymentData(prev => ({ ...prev, [name]: formatted }));
    } else if (name === 'cvc') {
      const cvc = value.replace(/\D/g, '').slice(0, 4);
      setPaymentData(prev => ({ ...prev, [name]: cvc }));
    } else {
      setPaymentData(prev => ({ ...prev, [name]: value }));
    }

    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const simulateIyzicoPayment = () => {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        // Simulate 90% success rate
        if (Math.random() > 0.1) {
          resolve({
            paymentId: `pay_${Date.now()}`,
            status: 'success',
            transactionId: `txn_${Math.random().toString(36).substr(2, 9)}`,
            amount,
            installment: paymentData.installment,
            cardType: getCardType(paymentData.cardNumber),
            timestamp: new Date().toISOString()
          });
        } else {
          reject(new Error('Ödeme işlemi başarısız. Lütfen tekrar deneyiniz.'));
        }
      }, 2000);
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;

    setLoading(true);

    try {
      // In real implementation, this would integrate with iyzico API
      const paymentResult = await simulateIyzicoPayment();
      
      // Save payment to local storage (in real app, this would be API call)
      const payment = {
        id: paymentResult.paymentId,
        jobId,
        customerId: user.id,
        craftsmanId: craftsman.id,
        amount,
        installment: paymentData.installment,
        status: 'completed',
        cardType: paymentResult.cardType,
        transactionId: paymentResult.transactionId,
        createdAt: paymentResult.timestamp,
        cardLastFour: paymentData.cardNumber.slice(-4)
      };

      const existingPayments = JSON.parse(localStorage.getItem('payments') || '[]');
      existingPayments.push(payment);
      localStorage.setItem('payments', JSON.stringify(existingPayments));

      onSuccess(paymentResult);
    } catch (error) {
      onError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const selectedInstallment = installmentOptions.find(opt => opt.value === paymentData.installment);
  const totalAmount = amount + (selectedInstallment?.fee || 0);
  const monthlyAmount = totalAmount / parseInt(paymentData.installment);

  return (
    <div className="max-w-md mx-auto bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
      <div className="mb-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
          Ödeme Bilgileri
        </h3>
        <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
          <div className="flex justify-between items-center mb-2">
            <span className="text-sm text-gray-600 dark:text-gray-300">İş Tutarı:</span>
            <span className="font-semibold text-gray-900 dark:text-white">
              ₺{amount.toLocaleString()}
            </span>
          </div>
          {selectedInstallment?.fee > 0 && (
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm text-gray-600 dark:text-gray-300">Taksit Ücreti:</span>
              <span className="font-semibold text-red-600">
                +₺{selectedInstallment.fee.toLocaleString()}
              </span>
            </div>
          )}
          <div className="flex justify-between items-center border-t pt-2">
            <span className="font-semibold text-gray-900 dark:text-white">Toplam:</span>
            <span className="font-bold text-lg text-blue-600">
              ₺{totalAmount.toLocaleString()}
            </span>
          </div>
          {parseInt(paymentData.installment) > 1 && (
            <div className="text-center mt-2">
              <span className="text-sm text-gray-600 dark:text-gray-300">
                {paymentData.installment} taksit × ₺{monthlyAmount.toLocaleString()}
              </span>
            </div>
          )}
        </div>
      </div>

      {/* Payment Methods */}
      <div className="mb-6">
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Ödeme Yöntemi
        </label>
        <div className="grid grid-cols-3 gap-2">
          {paymentMethods.map((method) => (
            <button
              key={method.id}
              type="button"
              onClick={() => setSelectedMethod(method.id)}
              className={`p-3 rounded-lg border-2 transition-colors ${
                selectedMethod === method.id
                  ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/20'
                  : 'border-gray-200 dark:border-gray-600 hover:border-gray-300'
              }`}
            >
              <div className="text-2xl mb-1">{method.icon}</div>
              <div className="text-xs text-gray-600 dark:text-gray-300">
                {method.name}
              </div>
            </button>
          ))}
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        {/* Card Number */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Kart Numarası
          </label>
          <div className="relative">
            <input
              type="text"
              name="cardNumber"
              value={paymentData.cardNumber}
              onChange={handleInputChange}
              placeholder="1234 5678 9012 3456"
              maxLength="19"
              className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:border-gray-600 dark:text-white ${
                errors.cardNumber ? 'border-red-500' : 'border-gray-300'
              }`}
            />
            <div className="absolute right-3 top-2">
              <span className="text-2xl">
                {getCardType(paymentData.cardNumber) === 'visa' && '💳'}
                {getCardType(paymentData.cardNumber) === 'mastercard' && '💳'}
                {getCardType(paymentData.cardNumber) === 'amex' && '💳'}
              </span>
            </div>
          </div>
          {errors.cardNumber && (
            <p className="text-red-500 text-sm mt-1">{errors.cardNumber}</p>
          )}
        </div>

        {/* Expiry and CVC */}
        <div className="grid grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Ay
            </label>
            <select
              name="expiryMonth"
              value={paymentData.expiryMonth}
              onChange={handleInputChange}
              className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:border-gray-600 dark:text-white ${
                errors.expiry ? 'border-red-500' : 'border-gray-300'
              }`}
            >
              <option value="">Ay</option>
              {Array.from({ length: 12 }, (_, i) => (
                <option key={i + 1} value={String(i + 1).padStart(2, '0')}>
                  {String(i + 1).padStart(2, '0')}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Yıl
            </label>
            <select
              name="expiryYear"
              value={paymentData.expiryYear}
              onChange={handleInputChange}
              className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:border-gray-600 dark:text-white ${
                errors.expiry ? 'border-red-500' : 'border-gray-300'
              }`}
            >
              <option value="">Yıl</option>
              {Array.from({ length: 10 }, (_, i) => (
                <option key={i} value={String(new Date().getFullYear() + i)}>
                  {new Date().getFullYear() + i}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              CVC
            </label>
            <input
              type="text"
              name="cvc"
              value={paymentData.cvc}
              onChange={handleInputChange}
              placeholder="123"
              maxLength="4"
              className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:border-gray-600 dark:text-white ${
                errors.cvc ? 'border-red-500' : 'border-gray-300'
              }`}
            />
          </div>
        </div>
        {errors.expiry && (
          <p className="text-red-500 text-sm">{errors.expiry}</p>
        )}
        {errors.cvc && (
          <p className="text-red-500 text-sm">{errors.cvc}</p>
        )}

        {/* Card Holder Name */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Kart Sahibi Adı
          </label>
          <input
            type="text"
            name="cardHolderName"
            value={paymentData.cardHolderName}
            onChange={handleInputChange}
            placeholder="Ad Soyad"
            className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:border-gray-600 dark:text-white ${
              errors.cardHolderName ? 'border-red-500' : 'border-gray-300'
            }`}
          />
          {errors.cardHolderName && (
            <p className="text-red-500 text-sm mt-1">{errors.cardHolderName}</p>
          )}
        </div>

        {/* Installments */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Taksit Seçenekleri
          </label>
          <div className="grid grid-cols-2 gap-2">
            {installmentOptions.map((option) => (
              <label
                key={option.value}
                className={`flex items-center justify-between p-3 border-2 rounded-lg cursor-pointer transition-colors ${
                  paymentData.installment === option.value
                    ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/20'
                    : 'border-gray-200 dark:border-gray-600 hover:border-gray-300'
                }`}
              >
                <div>
                  <input
                    type="radio"
                    name="installment"
                    value={option.value}
                    checked={paymentData.installment === option.value}
                    onChange={handleInputChange}
                    className="sr-only"
                  />
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
                    {option.label}
                  </div>
                  {option.fee > 0 && (
                    <div className="text-xs text-red-600">
                      +₺{option.fee.toLocaleString()}
                    </div>
                  )}
                </div>
                {parseInt(option.value) > 1 && (
                  <div className="text-xs text-gray-600 dark:text-gray-300 text-right">
                    ₺{((amount + option.fee) / parseInt(option.value)).toLocaleString()}/ay
                  </div>
                )}
              </label>
            ))}
          </div>
        </div>

        {/* Security Info */}
        <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-3">
          <div className="flex items-center">
            <span className="text-yellow-600 text-lg mr-2">🔒</span>
            <div>
              <p className="text-sm font-medium text-yellow-800 dark:text-yellow-200">
                Güvenli Ödeme
              </p>
              <p className="text-xs text-yellow-700 dark:text-yellow-300">
                Ödemeniz 256-bit SSL şifreleme ile korunmaktadır.
              </p>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex space-x-3 pt-4">
          <button
            type="button"
            onClick={onCancel}
            className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
          >
            İptal
          </button>
          <button
            type="submit"
            disabled={loading}
            className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center justify-center"
          >
            {loading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                İşleniyor...
              </>
            ) : (
              `₺${totalAmount.toLocaleString()} Öde`
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default PaymentForm;