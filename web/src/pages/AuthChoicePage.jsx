import React from 'react';
import { Link } from 'react-router-dom';

const AuthChoicePage = () => {
  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="w-20 h-20 bg-airbnb-500 rounded-full flex items-center justify-center mx-auto mb-4 shadow-airbnb">
            <span className="text-3xl text-white">🔨</span>
          </div>
          <h1 className="text-3xl font-bold text-airbnb-dark-900 mb-2">ustam'a Hoş Geldiniz</h1>
          <p className="text-airbnb-dark-600">Hesabınıza giriş yapın veya yeni hesap oluşturun</p>
        </div>

        {/* Auth Options */}
        <div className="space-y-4">
          {/* Login Button */}
          <Link
            to="/login"
            className="block w-full bg-white text-airbnb-dark-900 py-4 px-6 rounded-2xl font-semibold text-lg shadow-airbnb hover:shadow-airbnb-hover transition-all duration-300 border-2 border-airbnb-light-200 hover:border-airbnb-500"
          >
            <div className="flex items-center justify-center space-x-3">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
              </svg>
              <span>Giriş Yap</span>
            </div>
          </Link>

          {/* Register Options */}
          <div className="bg-white rounded-2xl p-6 shadow-airbnb border border-airbnb-light-200">
            <h3 className="text-lg font-semibold text-airbnb-dark-900 mb-4 text-center">Yeni Hesap Oluştur</h3>
            
            <div className="space-y-3">
              <Link
                to="/register?type=customer"
                className="block w-full bg-airbnb-500 text-white py-4 px-6 rounded-xl font-semibold text-lg hover:bg-airbnb-600 transition-colors shadow-airbnb hover:shadow-airbnb-hover"
              >
                <div className="flex items-center justify-center space-x-3">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                  <span>Müşteri Olarak Kayıt Ol</span>
                </div>
              </Link>

              <Link
                to="/register?type=craftsman"
                className="block w-full bg-airbnb-teal-500 text-white py-4 px-6 rounded-xl font-semibold text-lg hover:bg-airbnb-teal-600 transition-colors shadow-airbnb hover:shadow-airbnb-hover"
              >
                <div className="flex items-center justify-center space-x-3">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                  </svg>
                  <span>Usta Olarak Kayıt Ol</span>
                </div>
              </Link>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center mt-8">
          <p className="text-airbnb-light-500 text-sm">
            Devam ederek{' '}
            <Link to="/terms" className="text-airbnb-500 hover:text-airbnb-600 hover:underline">
              Kullanım Şartları
            </Link>
            {' '}ve{' '}
            <Link to="/privacy" className="text-airbnb-500 hover:text-airbnb-600 hover:underline">
              Gizlilik Politikası
            </Link>
            'nı kabul etmiş olursunuz.
          </p>
        </div>
      </div>
    </div>
  );
};

export default AuthChoicePage;