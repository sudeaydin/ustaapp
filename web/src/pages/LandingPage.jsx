import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const LandingPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [currentTestimonial, setCurrentTestimonial] = useState(0);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // Auto-rotate testimonials
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentTestimonial(prev => (prev + 1) % testimonials.length);
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  // Mock data
  const stats = [
    { number: '15,000+', label: 'Aktif Kullanıcı', icon: '👥' },
    { number: '50,000+', label: 'Tamamlanan İş', icon: '✅' },
    { number: '98%', label: 'Memnuniyet Oranı', icon: '⭐' },
    { number: '24/7', label: 'Destek Hizmeti', icon: '🛟' }
  ];

  const features = [
    {
      icon: '🔍',
      title: 'Kolay Usta Bulma',
      description: 'Bulunduğunuz bölgedeki en iyi ustaları kolayca bulun ve karşılaştırın.',
      color: 'bg-blue-500'
    },
    {
      icon: '💬',
      title: 'Anlık Mesajlaşma',
      description: 'Ustalarla doğrudan iletişim kurun, fiyat alın ve detayları konuşun.',
      color: 'bg-green-500'
    },
    {
      icon: '🛡️',
      title: 'Güvenli Ödeme',
      description: 'Güvenli ödeme sistemi ile paranız iş tamamlanana kadar korunur.',
      color: 'bg-purple-500'
    },
    {
      icon: '⭐',
      title: 'Puanlama Sistemi',
      description: 'Gerçek kullanıcı yorumları ile en kaliteli hizmeti alın.',
      color: 'bg-yellow-500'
    },
    {
      icon: '📱',
      title: 'Mobil Uyumlu',
      description: 'Her yerden, her cihazdan kolayca erişim sağlayın.',
      color: 'bg-pink-500'
    },
    {
      icon: '🚀',
      title: 'Hızlı Çözüm',
      description: 'Acil ihtiyaçlarınız için 24 saat içinde usta bulun.',
      color: 'bg-red-500'
    }
  ];

  const howItWorks = [
    {
      step: '1',
      title: 'İhtiyacınızı Belirtin',
      description: 'Hangi alanda hizmet almak istediğinizi seçin ve detayları yazın.',
      icon: '📝',
      color: 'bg-blue-100 text-blue-600'
    },
    {
      step: '2',
      title: 'Usta Seçin',
      description: 'Size en yakın ustaları görün, puanlarını inceleyin ve seçin.',
      icon: '👨‍🔧',
      color: 'bg-green-100 text-green-600'
    },
    {
      step: '3',
      title: 'Anlaşma Yapın',
      description: 'Fiyat ve detayları konuşun, randevu alın.',
      icon: '🤝',
      color: 'bg-purple-100 text-purple-600'
    },
    {
      step: '4',
      title: 'İşiniz Tamamlansın',
      description: 'Usta işinizi tamamlasın, ödeme yapın ve değerlendirin.',
      icon: '✨',
      color: 'bg-yellow-100 text-yellow-600'
    }
  ];

  const testimonials = [
    {
      name: 'Ayşe Kaya',
      role: 'Ev Sahibi',
      image: '👩‍💼',
      comment: 'Elektrik arızam vardı, 2 saat içinde usta buldum. Çok memnun kaldım, kesinlikle tavsiye ederim!',
      rating: 5,
      location: 'İstanbul'
    },
    {
      name: 'Mehmet Yılmaz',
      role: 'İşletme Sahibi',
      image: '👨‍💻',
      comment: 'Ofisimizin boyasını yaptırdık. Kaliteli işçilik ve uygun fiyat. Ustam sayesinde çok kolay oldu.',
      rating: 5,
      location: 'Ankara'
    },
    {
      name: 'Fatma Özkan',
      role: 'Ev Hanımı',
      image: '👩‍🏫',
      comment: 'Mutfak dolabımı monte ettirdim. Usta çok titiz çalıştı, evim hiç kirletmedi. Süper hizmet!',
      rating: 5,
      location: 'İzmir'
    },
    {
      name: 'Ali Demir',
      role: 'Mimar',
      image: '👨‍🎨',
      comment: 'Projelerimde sürekli Ustam kullanıyorum. Güvenilir ustalar, kaliteli işçilik. Harika platform!',
      rating: 5,
      location: 'Bursa'
    }
  ];

  const categories = [
    { name: 'Elektrik', icon: '⚡', jobs: '2,500+' },
    { name: 'Tesisatçı', icon: '🔧', jobs: '1,800+' },
    { name: 'Boyacı', icon: '🎨', jobs: '3,200+' },
    { name: 'Marangoz', icon: '🪚', jobs: '1,200+' },
    { name: 'Temizlik', icon: '🧹', jobs: '5,000+' },
    { name: 'Nakliye', icon: '🚚', jobs: '900+' },
    { name: 'Bahçıvan', icon: '🌱', jobs: '600+' },
    { name: 'Klima', icon: '❄️', jobs: '1,100+' }
  ];

  const handleGetStarted = () => {
    if (user) {
      // Already logged in, go to appropriate dashboard
      if (user.user_type === 'customer') {
        navigate('/dashboard/customer');
      } else {
        navigate('/dashboard/craftsman');
      }
    } else {
      // Not logged in, go to register
      navigate('/register');
    }
  };

  const handleLogin = () => {
    if (user) {
      // Already logged in, go to dashboard
      if (user.user_type === 'customer') {
        navigate('/dashboard/customer');
      } else {
        navigate('/dashboard/craftsman');
      }
    } else {
      navigate('/login');
    }
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 bg-white/90 backdrop-blur-md z-50 border-b border-gray-100 shadow-lg shadow-gray-900/5">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-18">
            {/* Logo */}
            <div className="flex items-center space-x-3">
              <div className="relative">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 rounded-xl flex items-center justify-center shadow-lg shadow-blue-500/25 transform rotate-3 hover:rotate-0 transition-all duration-300">
                  <span className="text-white font-bold text-xl">U</span>
                </div>
                <div className="absolute -top-1 -right-1 w-4 h-4 bg-gradient-to-r from-yellow-400 to-orange-500 rounded-full animate-pulse"></div>
              </div>
              <div>
                <span className="text-2xl font-black bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent">
                  Ustam
                </span>
                <div className="text-xs text-gray-500 font-medium -mt-1">Platform</div>
              </div>
            </div>

            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center space-x-8">
              <a href="#features" className="relative text-gray-700 hover:text-blue-600 transition-all duration-300 font-medium group">
                <span>Özellikler</span>
                <div className="absolute -bottom-1 left-0 w-0 h-0.5 bg-gradient-to-r from-blue-500 to-purple-500 group-hover:w-full transition-all duration-300"></div>
              </a>
              <a href="#how-it-works" className="relative text-gray-700 hover:text-blue-600 transition-all duration-300 font-medium group">
                <span>Nasıl Çalışır</span>
                <div className="absolute -bottom-1 left-0 w-0 h-0.5 bg-gradient-to-r from-blue-500 to-purple-500 group-hover:w-full transition-all duration-300"></div>
              </a>
              <a href="#testimonials" className="relative text-gray-700 hover:text-blue-600 transition-all duration-300 font-medium group">
                <span>Yorumlar</span>
                <div className="absolute -bottom-1 left-0 w-0 h-0.5 bg-gradient-to-r from-blue-500 to-purple-500 group-hover:w-full transition-all duration-300"></div>
              </a>
              <a href="#contact" className="relative text-gray-700 hover:text-blue-600 transition-all duration-300 font-medium group">
                <span>İletişim</span>
                <div className="absolute -bottom-1 left-0 w-0 h-0.5 bg-gradient-to-r from-blue-500 to-purple-500 group-hover:w-full transition-all duration-300"></div>
              </a>
            </div>

            {/* CTA Buttons */}
            <div className="hidden md:flex items-center space-x-4">
              <button
                onClick={handleLogin}
                className="px-5 py-2.5 text-gray-700 hover:text-blue-600 transition-all duration-300 font-medium relative group"
              >
                <span>{user ? 'Dashboard' : 'Giriş Yap'}</span>
                <div className="absolute inset-0 rounded-lg bg-gray-100 opacity-0 group-hover:opacity-100 transition-all duration-300 -z-10"></div>
              </button>
              <button
                onClick={handleGetStarted}
                className="relative px-8 py-3 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 text-white rounded-xl font-semibold hover:from-blue-600 hover:via-purple-600 hover:to-pink-600 transition-all duration-300 transform hover:scale-105 hover:shadow-2xl hover:shadow-purple-500/25 group overflow-hidden"
              >
                <div className="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                <span className="relative z-10">{user ? '🚀 Dashboard' : '✨ Başla'}</span>
              </button>
            </div>

            {/* Mobile menu button */}
            <div className="md:hidden">
              <button
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                className="p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100"
              >
                <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  {mobileMenuOpen ? (
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  ) : (
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                  )}
                </svg>
              </button>
            </div>
          </div>

          {/* Mobile Navigation */}
          {mobileMenuOpen && (
            <div className="md:hidden border-t border-gray-200 py-4">
              <div className="flex flex-col space-y-4">
                <a href="#features" className="text-gray-700 hover:text-blue-600 transition-colors">
                  Özellikler
                </a>
                <a href="#how-it-works" className="text-gray-700 hover:text-blue-600 transition-colors">
                  Nasıl Çalışır
                </a>
                <a href="#testimonials" className="text-gray-700 hover:text-blue-600 transition-colors">
                  Yorumlar
                </a>
                <a href="#contact" className="text-gray-700 hover:text-blue-600 transition-colors">
                  İletişim
                </a>
                <div className="flex flex-col space-y-2 pt-4 border-t border-gray-200">
                  <button
                    onClick={handleLogin}
                    className="px-4 py-2 text-gray-700 hover:text-blue-600 transition-colors text-left"
                  >
                    {user ? 'Dashboard' : 'Giriş Yap'}
                  </button>
                  <button
                    onClick={handleGetStarted}
                    className="px-6 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg hover:from-blue-600 hover:to-purple-700 transition-all"
                  >
                    {user ? 'Dashboard' : 'Başla'}
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative pt-24 pb-20 overflow-hidden">
        {/* Animated Background */}
        <div className="absolute inset-0 bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
          <div className="absolute top-0 left-0 w-full h-full">
            <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-gradient-to-r from-blue-400/20 to-purple-400/20 rounded-full blur-3xl animate-pulse"></div>
            <div className="absolute top-3/4 right-1/4 w-80 h-80 bg-gradient-to-r from-pink-400/20 to-yellow-400/20 rounded-full blur-3xl animate-pulse animation-delay-1000"></div>
            <div className="absolute top-1/2 left-1/2 w-64 h-64 bg-gradient-to-r from-indigo-400/20 to-cyan-400/20 rounded-full blur-3xl animate-pulse animation-delay-2000"></div>
          </div>
        </div>
        
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
            {/* Left Column - Content */}
            <div>
              <div className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-blue-100 via-purple-100 to-pink-100 border border-blue-200/50 text-blue-800 rounded-full text-sm font-semibold mb-8 shadow-lg shadow-blue-500/10 animate-bounce">
                <div className="w-2 h-2 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full mr-3 animate-pulse"></div>
                🚀 Türkiye'nin #1 Usta Bulma Platformu
                <div className="w-2 h-2 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full ml-3 animate-pulse"></div>
              </div>
              
              <h1 className="text-5xl lg:text-7xl font-black text-gray-900 mb-8 leading-tight tracking-tight">
                <span className="bg-gradient-to-r from-blue-600 via-purple-600 to-blue-800 bg-clip-text text-transparent drop-shadow-sm">
                  Güvenilir
                </span>
                <br />
                <span className="bg-gradient-to-r from-purple-600 via-pink-600 to-purple-800 bg-clip-text text-transparent drop-shadow-sm">
                  Usta Bulmak
                </span>
                <br />
                <span className="bg-gradient-to-r from-pink-600 via-red-500 to-orange-500 bg-clip-text text-transparent drop-shadow-sm">
                  Artık Çok Kolay!
                </span>
              </h1>
              
              <p className="text-xl text-gray-600 mb-8 leading-relaxed">
                Elektrikçiden tesisatçıya, boyacıdan temizlikçiye kadar 
                <strong> binlerce uzman usta</strong> ile tanışın. 
                Güvenli ödeme, anlık mesajlaşma ve gerçek yorumlarla 
                <strong> en kaliteli hizmeti</strong> alın.
              </p>

              <div className="flex flex-col sm:flex-row gap-6 mb-10">
                <button
                  onClick={handleGetStarted}
                  className="group relative px-10 py-5 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 text-white rounded-2xl font-bold text-lg hover:from-blue-600 hover:via-purple-600 hover:to-pink-600 transition-all duration-500 transform hover:scale-105 shadow-2xl shadow-purple-500/25 hover:shadow-purple-500/40 overflow-hidden"
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                  <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-1000"></div>
                  <span className="relative z-10 flex items-center justify-center space-x-2">
                    <span>🚀</span>
                    <span>Hemen Başla</span>
                    <svg className="w-5 h-5 group-hover:translate-x-1 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                    </svg>
                  </span>
                </button>
                <button
                  onClick={() => document.getElementById('how-it-works').scrollIntoView({ behavior: 'smooth' })}
                  className="group px-10 py-5 border-2 border-gray-300 bg-white/80 backdrop-blur-sm text-gray-700 rounded-2xl font-semibold text-lg hover:border-purple-500 hover:text-purple-600 hover:bg-white transition-all duration-300 shadow-lg hover:shadow-xl"
                >
                  <span className="flex items-center justify-center space-x-2">
                    <span>📺</span>
                    <span>Nasıl Çalışır?</span>
                    <svg className="w-5 h-5 group-hover:translate-y-1 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                    </svg>
                  </span>
                </button>
              </div>

              {/* Trust Indicators */}
              <div className="flex items-center space-x-6 text-sm text-gray-600">
                <div className="flex items-center space-x-2">
                  <svg className="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                  </svg>
                  <span>%100 Güvenli</span>
                </div>
                <div className="flex items-center space-x-2">
                  <svg className="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                  </svg>
                  <span>Ücretsiz Kayıt</span>
                </div>
                <div className="flex items-center space-x-2">
                  <svg className="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                  </svg>
                  <span>24/7 Destek</span>
                </div>
              </div>
            </div>

            {/* Right Column - Visual */}
            <div className="relative">
              <div className="relative z-10">
                {/* Main mockup */}
                <div className="bg-white/90 backdrop-blur-sm rounded-3xl shadow-2xl shadow-purple-500/20 p-8 transform rotate-2 hover:rotate-0 transition-all duration-700 border border-white/20 hover:shadow-3xl hover:shadow-purple-500/30">
                  <div className="flex items-center space-x-3 mb-6">
                    <div className="w-4 h-4 bg-gradient-to-r from-red-400 to-red-500 rounded-full shadow-sm"></div>
                    <div className="w-4 h-4 bg-gradient-to-r from-yellow-400 to-yellow-500 rounded-full shadow-sm"></div>
                    <div className="w-4 h-4 bg-gradient-to-r from-green-400 to-green-500 rounded-full shadow-sm"></div>
                    <div className="flex-1 h-2 bg-gray-100 rounded-full ml-4">
                      <div className="h-full w-3/4 bg-gradient-to-r from-blue-400 to-purple-400 rounded-full"></div>
                    </div>
                  </div>
                  <div className="space-y-6">
                    <div className="flex items-center space-x-4">
                      <div className="relative">
                        <div className="w-16 h-16 bg-gradient-to-br from-blue-100 via-purple-100 to-pink-100 rounded-2xl flex items-center justify-center shadow-lg">
                          <span className="text-3xl">⚡</span>
                        </div>
                        <div className="absolute -top-1 -right-1 w-6 h-6 bg-gradient-to-r from-green-400 to-green-500 rounded-full flex items-center justify-center shadow-lg">
                          <span className="text-xs text-white">✓</span>
                        </div>
                      </div>
                      <div className="flex-1">
                        <h4 className="font-bold text-gray-900 text-lg">Ahmet Elektrikçi</h4>
                        <div className="flex items-center space-x-2 mt-1">
                          <div className="flex space-x-1">
                            {[...Array(5)].map((_, i) => (
                              <div key={i} className="w-4 h-4 bg-gradient-to-r from-yellow-400 to-yellow-500 rounded-sm"></div>
                            ))}
                          </div>
                          <span className="text-sm text-gray-600 font-medium">(4.9)</span>
                          <span className="px-2 py-1 bg-green-100 text-green-700 text-xs rounded-full font-medium">Aktif</span>
                        </div>
                      </div>
                    </div>
                    <div className="bg-gradient-to-r from-gray-50 to-blue-50 rounded-2xl p-4 border border-gray-100">
                      <p className="text-gray-700 font-medium leading-relaxed">
                        "Elektrik arızanızı 24 saat içinde çözerim. 15 yıllık deneyim ile güvenilir hizmet!"
                      </p>
                    </div>
                    <div className="flex justify-between items-center">
                      <div className="flex items-center space-x-2">
                        <span className="text-2xl font-black bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">150₺</span>
                        <span className="text-gray-600 font-medium">/saat</span>
                      </div>
                      <button className="px-6 py-3 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-xl font-semibold hover:from-blue-600 hover:to-purple-600 transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-xl">
                        💬 Mesaj Gönder
                      </button>
                    </div>
                  </div>
                </div>

                {/* Enhanced floating elements */}
                <div className="absolute -top-6 -left-6 bg-gradient-to-r from-green-400 to-emerald-500 text-white p-4 rounded-2xl shadow-2xl shadow-green-500/30 animate-bounce">
                  <span className="text-2xl">✅</span>
                </div>
                <div className="absolute -bottom-6 -right-6 bg-gradient-to-r from-purple-500 to-pink-500 text-white p-4 rounded-2xl shadow-2xl shadow-purple-500/30 animate-pulse">
                  <span className="text-2xl">💬</span>
                </div>
                <div className="absolute top-1/2 -left-10 bg-gradient-to-r from-yellow-400 to-orange-500 text-white p-3 rounded-xl shadow-2xl shadow-yellow-500/30 animate-bounce animation-delay-500">
                  <span className="text-lg">⭐</span>
                </div>
                <div className="absolute top-1/4 -right-8 bg-gradient-to-r from-blue-400 to-cyan-500 text-white p-3 rounded-xl shadow-2xl shadow-blue-500/30 animate-pulse animation-delay-1000">
                  <span className="text-lg">🚀</span>
                </div>
              </div>

              {/* Enhanced background decorations */}
              <div className="absolute inset-0 bg-gradient-to-br from-blue-400 via-purple-500 to-pink-500 rounded-3xl transform rotate-6 opacity-10 blur-sm"></div>
              <div className="absolute inset-0 bg-gradient-to-br from-purple-400 via-pink-500 to-red-400 rounded-3xl transform -rotate-3 opacity-5 blur-sm"></div>
              <div className="absolute inset-0 bg-gradient-to-br from-cyan-400 via-blue-500 to-purple-500 rounded-3xl transform rotate-1 opacity-5 blur-lg"></div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-20 bg-gradient-to-r from-gray-50 via-white to-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
            {stats.map((stat, index) => (
              <div key={index} className="group text-center">
                <div className="relative mb-6">
                  <div className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 rounded-2xl text-white text-3xl shadow-2xl shadow-purple-500/25 group-hover:shadow-purple-500/40 transition-all duration-300 group-hover:scale-110 group-hover:rotate-6">
                    {stat.icon}
                  </div>
                  <div className="absolute -inset-2 bg-gradient-to-r from-blue-400 to-purple-400 rounded-2xl opacity-0 group-hover:opacity-20 transition-opacity duration-300 blur-xl"></div>
                </div>
                <div className="text-4xl lg:text-5xl font-black bg-gradient-to-r from-gray-900 to-gray-700 bg-clip-text text-transparent mb-3 group-hover:from-blue-600 group-hover:to-purple-600 transition-all duration-300">
                  {stat.number}
                </div>
                <div className="text-gray-600 font-semibold text-lg group-hover:text-gray-800 transition-colors duration-300">
                  {stat.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Categories Section */}
      <section className="py-20 bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 relative overflow-hidden">
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-5">
          <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-r from-blue-600 to-purple-600" style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23000000' fill-opacity='0.1'%3E%3Ccircle cx='30' cy='30' r='2'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`
          }}></div>
        </div>
        
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <div className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-blue-100 via-purple-100 to-pink-100 border border-blue-200/50 text-blue-800 rounded-full text-sm font-semibold mb-6 shadow-lg shadow-blue-500/10">
              <span className="w-2 h-2 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full mr-3 animate-pulse"></span>
              Popüler Kategoriler
              <span className="w-2 h-2 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full ml-3 animate-pulse"></span>
            </div>
            <h2 className="text-4xl lg:text-6xl font-black text-gray-900 mb-6 leading-tight">
              <span className="bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent">
                🎯 Hizmet Kategorileri
              </span>
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto font-medium">
              İhtiyacınız olan her alanda <strong>uzman ustalar</strong> sizi bekliyor
            </p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {categories.map((category, index) => (
              <div
                key={index}
                className="group bg-white/80 backdrop-blur-sm rounded-2xl p-8 text-center hover:shadow-2xl hover:shadow-purple-500/20 transition-all duration-500 transform hover:scale-110 hover:-translate-y-2 cursor-pointer border border-white/20 relative overflow-hidden"
              >
                {/* Hover gradient overlay */}
                <div className="absolute inset-0 bg-gradient-to-br from-blue-500/5 via-purple-500/5 to-pink-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl"></div>
                
                <div className="relative z-10">
                  <div className="text-5xl mb-4 group-hover:scale-125 transition-transform duration-300 group-hover:rotate-12">
                    {category.icon}
                  </div>
                  <h3 className="font-bold text-gray-900 mb-3 text-lg group-hover:text-purple-600 transition-colors duration-300">
                    {category.name}
                  </h3>
                  <div className="flex items-center justify-center space-x-2">
                    <div className="w-2 h-2 bg-gradient-to-r from-green-400 to-emerald-500 rounded-full animate-pulse"></div>
                    <p className="text-sm text-gray-600 font-semibold group-hover:text-gray-800 transition-colors duration-300">
                      {category.jobs} aktif usta
                    </p>
                  </div>
                  
                  {/* Animated border */}
                  <div className="absolute inset-0 rounded-2xl border-2 border-transparent group-hover:border-gradient-to-r group-hover:from-blue-400 group-hover:via-purple-400 group-hover:to-pink-400 transition-all duration-300"></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              ⚡ Neden Ustam'ı Seçmelisiniz?
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Teknoloji ile geleneksel ustalığı buluşturan platform
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => (
              <div
                key={index}
                className="bg-white rounded-xl p-8 shadow-lg hover:shadow-xl transition-all transform hover:scale-105"
              >
                <div className={`inline-flex items-center justify-center w-16 h-16 ${feature.color} rounded-full text-white text-2xl mb-6`}>
                  {feature.icon}
                </div>
                <h3 className="text-xl font-bold text-gray-900 mb-4">
                  {feature.title}
                </h3>
                <p className="text-gray-600 leading-relaxed">
                  {feature.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="py-16 bg-gradient-to-br from-blue-50 to-purple-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              🚀 Nasıl Çalışır?
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              4 basit adımda ustanızı bulun ve işinizi hallettirin
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {howItWorks.map((step, index) => (
              <div key={index} className="text-center">
                <div className="relative mb-8">
                  <div className={`inline-flex items-center justify-center w-20 h-20 ${step.color} rounded-full text-3xl mb-4`}>
                    {step.icon}
                  </div>
                  <div className="absolute -top-2 -right-2 w-8 h-8 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-bold text-sm">
                    {step.step}
                  </div>
                  {index < howItWorks.length - 1 && (
                    <div className="hidden lg:block absolute top-10 left-full w-full h-0.5 bg-gradient-to-r from-blue-200 to-purple-200 transform -translate-x-4"></div>
                  )}
                </div>
                <h3 className="text-xl font-bold text-gray-900 mb-4">
                  {step.title}
                </h3>
                <p className="text-gray-600 leading-relaxed">
                  {step.description}
                </p>
              </div>
            ))}
          </div>

          <div className="text-center mt-12">
            <button
              onClick={handleGetStarted}
              className="px-8 py-4 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-xl font-semibold text-lg hover:from-blue-600 hover:to-purple-700 transition-all transform hover:scale-105 shadow-lg"
            >
              ✨ Şimdi Deneyin - Ücretsiz!
            </button>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section id="testimonials" className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              💬 Kullanıcılarımız Ne Diyor?
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Binlerce memnun kullanıcımızın gerçek deneyimleri
            </p>
          </div>

          <div className="relative">
            <div className="bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl p-8 lg:p-12">
              <div className="max-w-4xl mx-auto">
                <div className="text-center">
                  <div className="text-6xl mb-6">
                    {testimonials[currentTestimonial].image}
                  </div>
                  
                  <div className="flex justify-center mb-4">
                    {[...Array(testimonials[currentTestimonial].rating)].map((_, i) => (
                      <svg key={i} className="w-6 h-6 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                      </svg>
                    ))}
                  </div>

                  <blockquote className="text-xl lg:text-2xl text-gray-900 font-medium mb-6 leading-relaxed">
                    "{testimonials[currentTestimonial].comment}"
                  </blockquote>

                  <div>
                    <div className="font-bold text-gray-900 text-lg">
                      {testimonials[currentTestimonial].name}
                    </div>
                    <div className="text-gray-600">
                      {testimonials[currentTestimonial].role} • {testimonials[currentTestimonial].location}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Testimonial Navigation */}
            <div className="flex justify-center mt-8 space-x-2">
              {testimonials.map((_, index) => (
                <button
                  key={index}
                  onClick={() => setCurrentTestimonial(index)}
                  className={`w-3 h-3 rounded-full transition-all ${
                    index === currentTestimonial
                      ? 'bg-gradient-to-r from-blue-500 to-purple-600'
                      : 'bg-gray-300 hover:bg-gray-400'
                  }`}
                />
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-gradient-to-r from-blue-600 to-purple-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl lg:text-5xl font-bold text-white mb-6">
            🚀 Hemen Başlayın!
          </h2>
          <p className="text-xl text-blue-100 mb-8 max-w-3xl mx-auto">
            Binlerce usta arasından size en uygununu bulun. 
            Güvenli, hızlı ve kaliteli hizmet garantisi ile.
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button
              onClick={() => navigate('/register?type=customer')}
              className="px-8 py-4 bg-white text-blue-600 rounded-xl font-semibold text-lg hover:bg-gray-100 transition-all transform hover:scale-105 shadow-lg"
            >
              👤 Müşteri Olarak Başla
            </button>
            <button
              onClick={() => navigate('/register?type=craftsman')}
              className="px-8 py-4 bg-yellow-500 text-white rounded-xl font-semibold text-lg hover:bg-yellow-600 transition-all transform hover:scale-105 shadow-lg"
            >
              🔨 Usta Olarak Katıl
            </button>
          </div>

          <div className="mt-8 text-blue-100">
            <p className="text-sm">
              ✅ Ücretsiz kayıt • ✅ Komisyon yok • ✅ 24/7 destek
            </p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer id="contact" className="bg-gray-900 text-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            {/* Company Info */}
            <div className="col-span-1 md:col-span-2">
              <div className="flex items-center space-x-2 mb-6">
                <div className="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-lg">U</span>
                </div>
                <span className="text-2xl font-bold">Ustam</span>
              </div>
              <p className="text-gray-400 mb-6 max-w-md">
                Türkiye'nin en güvenilir usta bulma platformu. 
                Teknoloji ile geleneksel ustalığı buluşturuyoruz.
              </p>
              <div className="flex space-x-4">
                <div className="w-10 h-10 bg-gray-800 rounded-full flex items-center justify-center hover:bg-blue-600 transition-colors cursor-pointer">
                  <span>📘</span>
                </div>
                <div className="w-10 h-10 bg-gray-800 rounded-full flex items-center justify-center hover:bg-blue-400 transition-colors cursor-pointer">
                  <span>🐦</span>
                </div>
                <div className="w-10 h-10 bg-gray-800 rounded-full flex items-center justify-center hover:bg-pink-600 transition-colors cursor-pointer">
                  <span>📷</span>
                </div>
                <div className="w-10 h-10 bg-gray-800 rounded-full flex items-center justify-center hover:bg-blue-700 transition-colors cursor-pointer">
                  <span>💼</span>
                </div>
              </div>
            </div>

            {/* Quick Links */}
            <div>
              <h3 className="text-lg font-semibold mb-6">Hızlı Linkler</h3>
              <ul className="space-y-3">
                <li><a href="#features" className="text-gray-400 hover:text-white transition-colors">Özellikler</a></li>
                <li><a href="#how-it-works" className="text-gray-400 hover:text-white transition-colors">Nasıl Çalışır</a></li>
                <li><a href="#testimonials" className="text-gray-400 hover:text-white transition-colors">Yorumlar</a></li>
                <li><button onClick={() => navigate('/register')} className="text-gray-400 hover:text-white transition-colors">Kayıt Ol</button></li>
                <li><button onClick={() => navigate('/login')} className="text-gray-400 hover:text-white transition-colors">Giriş Yap</button></li>
              </ul>
            </div>

            {/* Contact */}
            <div>
              <h3 className="text-lg font-semibold mb-6">İletişim</h3>
              <ul className="space-y-3">
                <li className="flex items-center space-x-2 text-gray-400">
                  <span>📧</span>
                  <span>info@ustam.com</span>
                </li>
                <li className="flex items-center space-x-2 text-gray-400">
                  <span>📞</span>
                  <span>0850 123 45 67</span>
                </li>
                <li className="flex items-center space-x-2 text-gray-400">
                  <span>📍</span>
                  <span>İstanbul, Türkiye</span>
                </li>
                <li className="flex items-center space-x-2 text-gray-400">
                  <span>🕒</span>
                  <span>7/24 Destek</span>
                </li>
              </ul>
            </div>
          </div>

          <div className="border-t border-gray-800 mt-12 pt-8">
            <div className="flex flex-col md:flex-row justify-between items-center">
              <p className="text-gray-400 text-sm">
                © 2025 Ustam. Tüm hakları saklıdır.
              </p>
              <div className="flex space-x-6 mt-4 md:mt-0">
                <a href="#" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Gizlilik Politikası
                </a>
                <a href="#" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Kullanım Şartları
                </a>
                <a href="#" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Çerezler
                </a>
              </div>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;