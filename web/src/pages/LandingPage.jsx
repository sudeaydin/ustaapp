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
      <nav className="fixed top-0 left-0 right-0 bg-white/95 backdrop-blur-sm z-50 border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <div className="flex items-center space-x-2">
              <div className="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-lg">U</span>
              </div>
              <span className="text-2xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                Ustam
              </span>
            </div>

            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center space-x-8">
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
            </div>

            {/* CTA Buttons */}
            <div className="hidden md:flex items-center space-x-4">
              <button
                onClick={handleLogin}
                className="px-4 py-2 text-gray-700 hover:text-blue-600 transition-colors"
              >
                {user ? 'Dashboard' : 'Giriş Yap'}
              </button>
              <button
                onClick={handleGetStarted}
                className="px-6 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg hover:from-blue-600 hover:to-purple-700 transition-all transform hover:scale-105"
              >
                {user ? 'Dashboard' : 'Başla'}
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
      <section className="pt-20 pb-16 bg-gradient-to-br from-blue-50 via-white to-purple-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            {/* Left Column - Content */}
            <div>
              <div className="inline-flex items-center px-4 py-2 bg-blue-100 text-blue-800 rounded-full text-sm font-medium mb-6">
                🚀 Türkiye'nin #1 Usta Bulma Platformu
              </div>
              
              <h1 className="text-4xl lg:text-6xl font-bold text-gray-900 mb-6 leading-tight">
                <span className="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                  Güvenilir Usta
                </span>
                <br />
                Bulmak Artık
                <br />
                <span className="bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
                  Çok Kolay!
                </span>
              </h1>
              
              <p className="text-xl text-gray-600 mb-8 leading-relaxed">
                Elektrikçiden tesisatçıya, boyacıdan temizlikçiye kadar 
                <strong> binlerce uzman usta</strong> ile tanışın. 
                Güvenli ödeme, anlık mesajlaşma ve gerçek yorumlarla 
                <strong> en kaliteli hizmeti</strong> alın.
              </p>

              <div className="flex flex-col sm:flex-row gap-4 mb-8">
                <button
                  onClick={handleGetStarted}
                  className="px-8 py-4 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-xl font-semibold text-lg hover:from-blue-600 hover:to-purple-700 transition-all transform hover:scale-105 shadow-lg"
                >
                  🚀 Hemen Başla
                </button>
                <button
                  onClick={() => document.getElementById('how-it-works').scrollIntoView({ behavior: 'smooth' })}
                  className="px-8 py-4 border-2 border-gray-300 text-gray-700 rounded-xl font-semibold text-lg hover:border-blue-500 hover:text-blue-600 transition-all"
                >
                  📺 Nasıl Çalışır?
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
                <div className="bg-white rounded-2xl shadow-2xl p-6 transform rotate-3 hover:rotate-0 transition-transform duration-500">
                  <div className="flex items-center space-x-3 mb-4">
                    <div className="w-3 h-3 bg-red-500 rounded-full"></div>
                    <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
                    <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                  </div>
                  <div className="space-y-4">
                    <div className="flex items-center space-x-3">
                      <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                        <span className="text-2xl">⚡</span>
                      </div>
                      <div>
                        <h4 className="font-semibold text-gray-900">Ahmet Elektrikçi</h4>
                        <div className="flex items-center space-x-1">
                          <span className="text-yellow-500">⭐⭐⭐⭐⭐</span>
                          <span className="text-sm text-gray-600">(4.9)</span>
                        </div>
                      </div>
                    </div>
                    <div className="bg-gray-50 rounded-lg p-3">
                      <p className="text-sm text-gray-700">
                        "Elektrik arızanızı 24 saat içinde çözerim. 15 yıllık deneyim!"
                      </p>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-lg font-bold text-green-600">150₺/saat</span>
                      <button className="px-4 py-2 bg-blue-500 text-white rounded-lg text-sm">
                        💬 Mesaj Gönder
                      </button>
                    </div>
                  </div>
                </div>

                {/* Floating elements */}
                <div className="absolute -top-4 -left-4 bg-green-500 text-white p-3 rounded-full shadow-lg animate-bounce">
                  <span className="text-xl">✅</span>
                </div>
                <div className="absolute -bottom-4 -right-4 bg-purple-500 text-white p-3 rounded-full shadow-lg animate-pulse">
                  <span className="text-xl">💬</span>
                </div>
                <div className="absolute top-1/2 -left-8 bg-yellow-500 text-white p-2 rounded-full shadow-lg">
                  <span className="text-sm">⭐</span>
                </div>
              </div>

              {/* Background decorations */}
              <div className="absolute inset-0 bg-gradient-to-r from-blue-400 to-purple-600 rounded-2xl transform rotate-6 opacity-20"></div>
              <div className="absolute inset-0 bg-gradient-to-r from-purple-400 to-pink-600 rounded-2xl transform -rotate-3 opacity-10"></div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
            {stats.map((stat, index) => (
              <div key={index} className="text-center">
                <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full text-white text-2xl mb-4">
                  {stat.icon}
                </div>
                <div className="text-3xl lg:text-4xl font-bold text-gray-900 mb-2">
                  {stat.number}
                </div>
                <div className="text-gray-600 font-medium">
                  {stat.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Categories Section */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              🎯 Popüler Hizmet Kategorileri
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              İhtiyacınız olan her alanda uzman ustalar sizi bekliyor
            </p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {categories.map((category, index) => (
              <div
                key={index}
                className="bg-white rounded-xl p-6 text-center hover:shadow-lg transition-all transform hover:scale-105 cursor-pointer"
              >
                <div className="text-4xl mb-3">{category.icon}</div>
                <h3 className="font-semibold text-gray-900 mb-2">{category.name}</h3>
                <p className="text-sm text-gray-600">{category.jobs} aktif usta</p>
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