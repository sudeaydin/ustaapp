import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const LandingPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [stats, setStats] = useState({
    craftsmen: 1000,
    completedJobs: 5000,
    customers: 3000
  });

  // Redirect if already logged in
  useEffect(() => {
    if (user) {
      navigate(user.user_type === 'customer' ? '/dashboard/customer' : '/dashboard/craftsman');
    }
  }, [user, navigate]);

  const features = [
    {
      icon: '🔍',
      title: 'Kolay Usta Bulma',
      description: 'Binlerce kalifiye usta arasından ihtiyacınıza en uygun olanı kolayca bulun.'
    },
    {
      icon: '⭐',
      title: 'Güvenilir Değerlendirmeler',
      description: 'Gerçek müşteri yorumları ve puanlarıyla en iyi ustaları keşfedin.'
    },
    {
      icon: '💳',
      title: 'Güvenli Ödeme',
      description: 'İş tamamlandıktan sonra güvenli ödeme sistemiyle kolayca ödeyin.'
    },
    {
      icon: '📱',
      title: 'Anlık İletişim',
      description: 'Usta ile doğrudan mesajlaşın ve işinizin durumunu takip edin.'
    },
    {
      icon: '🏆',
      title: 'Kalite Garantisi',
      description: 'Tüm ustalarımız doğrulanmış ve kaliteli hizmet garantisi sunuyor.'
    },
    {
      icon: '⚡',
      title: 'Hızlı Hizmet',
      description: 'Acil işleriniz için 24/7 hizmet veren ustalar mevcut.'
    }
  ];

  const categories = [
    { name: 'Elektrikçi', icon: '⚡', color: 'bg-yellow-500' },
    { name: 'Tesisatçı', icon: '🔧', color: 'bg-blue-500' },
    { name: 'Boyacı', icon: '🎨', color: 'bg-red-500' },
    { name: 'Marangoz', icon: '🔨', color: 'bg-purple-500' },
    { name: 'Temizlik', icon: '🧹', color: 'bg-green-500' },
    { name: 'Bahçıvan', icon: '🌱', color: 'bg-emerald-500' }
  ];

  const howItWorks = [
    {
      step: '1',
      title: 'İhtiyacınızı Belirtin',
      description: 'Hangi hizmete ihtiyacınız olduğunu ve detaylarını belirtin.'
    },
    {
      step: '2',
      title: 'Usta Teklifleri Alın',
      description: 'Ustalar size teklif gönderir, fiyatları karşılaştırın.'
    },
    {
      step: '3',
      title: 'En İyi Ustayı Seçin',
      description: 'Yorumları inceleyin ve size en uygun ustayı seçin.'
    },
    {
      step: '4',
      title: 'İşinizi Tamamlayın',
      description: 'İş tamamlandıktan sonra güvenli şekilde ödeme yapın.'
    }
  ];

  return (
    <div className="min-h-screen bg-white">
      {/* Navigation */}
      <nav className="bg-white shadow-lg fixed w-full top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <Link to="/" className="flex-shrink-0 flex items-center">
                <span className="text-2xl font-bold text-blue-600">🔨 Ustam</span>
              </Link>
            </div>

            {/* Desktop Menu */}
            <div className="hidden md:flex items-center space-x-8">
              <a href="#features" className="text-gray-700 hover:text-blue-600 transition-colors">
                Özellikler
              </a>
              <a href="#how-it-works" className="text-gray-700 hover:text-blue-600 transition-colors">
                Nasıl Çalışır
              </a>
              <a href="#categories" className="text-gray-700 hover:text-blue-600 transition-colors">
                Kategoriler
              </a>
              <Link
                to="/login"
                className="text-blue-600 hover:text-blue-800 font-medium transition-colors"
              >
                Giriş Yap
              </Link>
              <Link
                to="/register"
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                Üye Ol
              </Link>
            </div>

            {/* Mobile menu button */}
            <div className="md:hidden flex items-center">
              <button
                onClick={() => setIsMenuOpen(!isMenuOpen)}
                className="text-gray-700 hover:text-blue-600 focus:outline-none"
              >
                <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              </button>
            </div>
          </div>

          {/* Mobile Menu */}
          {isMenuOpen && (
            <div className="md:hidden">
              <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3 bg-white border-t">
                <a href="#features" className="block px-3 py-2 text-gray-700 hover:text-blue-600">
                  Özellikler
                </a>
                <a href="#how-it-works" className="block px-3 py-2 text-gray-700 hover:text-blue-600">
                  Nasıl Çalışır
                </a>
                <a href="#categories" className="block px-3 py-2 text-gray-700 hover:text-blue-600">
                  Kategoriler
                </a>
                <Link to="/login" className="block px-3 py-2 text-blue-600 font-medium">
                  Giriş Yap
                </Link>
                <Link to="/register" className="block px-3 py-2 bg-blue-600 text-white rounded-lg text-center">
                  Üye Ol
                </Link>
              </div>
            </div>
          )}
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-20 pb-16 bg-gradient-to-br from-blue-50 to-indigo-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="lg:grid lg:grid-cols-12 lg:gap-8">
            <div className="sm:text-center md:max-w-2xl md:mx-auto lg:col-span-6 lg:text-left">
              <h1 className="text-4xl font-bold text-gray-900 tracking-tight sm:text-5xl md:text-6xl">
                <span className="block">Güvenilir</span>
                <span className="block text-blue-600">Usta Bulmanın</span>
                <span className="block">En Kolay Yolu</span>
              </h1>
              <p className="mt-3 text-base text-gray-500 sm:mt-5 sm:text-xl lg:text-lg xl:text-xl">
                Elektrikçiden tesisatçıya, boyacıdan temizlikçiye kadar tüm ev ve işyeri ihtiyaçlarınız için 
                güvenilir ve kalifiye ustalar. Hemen başlayın!
              </p>
              <div className="mt-8 sm:max-w-lg sm:mx-auto sm:text-center lg:text-left lg:mx-0">
                <div className="flex flex-col sm:flex-row gap-4">
                  <Link
                    to="/register?type=customer"
                    className="flex-1 bg-blue-600 text-white px-8 py-3 rounded-lg text-center font-medium hover:bg-blue-700 transition-colors"
                  >
                    Müşteri Olarak Başla
                  </Link>
                  <Link
                    to="/register?type=craftsman"
                    className="flex-1 bg-white text-blue-600 px-8 py-3 rounded-lg text-center font-medium border-2 border-blue-600 hover:bg-blue-50 transition-colors"
                  >
                    Usta Olarak Katıl
                  </Link>
                </div>
              </div>
            </div>
            <div className="mt-12 relative sm:max-w-lg sm:mx-auto lg:mt-0 lg:max-w-none lg:mx-0 lg:col-span-6 lg:flex lg:items-center">
              <div className="relative mx-auto w-full rounded-lg shadow-lg lg:max-w-md">
                <div className="relative block w-full bg-white rounded-lg overflow-hidden">
                  <img
                    className="w-full h-64 object-cover"
                    src="https://images.unsplash.com/photo-1581578731548-c64695cc6952?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80"
                    alt="Usta çalışırken"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent"></div>
                  <div className="absolute bottom-4 left-4 text-white">
                    <p className="text-sm font-medium">Profesyonel Hizmet</p>
                    <p className="text-xs opacity-90">Güvenilir Ustalar</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Stats */}
          <div className="mt-16">
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
              <div className="bg-white rounded-lg p-6 text-center shadow-md">
                <div className="text-3xl font-bold text-blue-600">{stats.craftsmen.toLocaleString()}+</div>
                <div className="text-gray-600">Kayıtlı Usta</div>
              </div>
              <div className="bg-white rounded-lg p-6 text-center shadow-md">
                <div className="text-3xl font-bold text-green-600">{stats.completedJobs.toLocaleString()}+</div>
                <div className="text-gray-600">Tamamlanan İş</div>
              </div>
              <div className="bg-white rounded-lg p-6 text-center shadow-md">
                <div className="text-3xl font-bold text-purple-600">{stats.customers.toLocaleString()}+</div>
                <div className="text-gray-600">Mutlu Müşteri</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Categories Section */}
      <section id="categories" className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-gray-900 sm:text-4xl">
              Popüler Kategoriler
            </h2>
            <p className="mt-4 text-xl text-gray-600">
              İhtiyacınız olan hizmeti seçin, en iyi ustaları bulun
            </p>
          </div>
          <div className="mt-12 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-6">
            {categories.map((category, index) => (
              <Link
                key={index}
                to={`/search?category=${encodeURIComponent(category.name)}`}
                className="group relative bg-white rounded-lg p-6 text-center shadow-md hover:shadow-lg transition-shadow"
              >
                <div className={`inline-flex items-center justify-center w-16 h-16 rounded-full ${category.color} text-white text-2xl mb-4 group-hover:scale-110 transition-transform`}>
                  {category.icon}
                </div>
                <h3 className="text-sm font-medium text-gray-900">{category.name}</h3>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-gray-900 sm:text-4xl">
              Neden Ustam'ı Seçmelisiniz?
            </h2>
            <p className="mt-4 text-xl text-gray-600">
              Size en iyi hizmeti sunmak için özenle tasarladığımız özellikler
            </p>
          </div>
          <div className="mt-12 grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
            {features.map((feature, index) => (
              <div key={index} className="bg-white rounded-lg p-6 shadow-md hover:shadow-lg transition-shadow">
                <div className="text-4xl mb-4">{feature.icon}</div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">{feature.title}</h3>
                <p className="text-gray-600">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-gray-900 sm:text-4xl">
              Nasıl Çalışır?
            </h2>
            <p className="mt-4 text-xl text-gray-600">
              4 basit adımda işinizi halledin
            </p>
          </div>
          <div className="mt-12">
            <div className="grid grid-cols-1 gap-8 md:grid-cols-2 lg:grid-cols-4">
              {howItWorks.map((step, index) => (
                <div key={index} className="text-center">
                  <div className="flex items-center justify-center w-16 h-16 mx-auto bg-blue-600 text-white rounded-full text-2xl font-bold mb-4">
                    {step.step}
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-2">{step.title}</h3>
                  <p className="text-gray-600">{step.description}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-blue-600">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold text-white sm:text-4xl">
            Hemen Başlayın!
          </h2>
          <p className="mt-4 text-xl text-blue-100">
            Güvenilir ustalar sadece bir tık uzağınızda
          </p>
          <div className="mt-8 flex flex-col sm:flex-row gap-4 justify-center max-w-md mx-auto">
            <Link
              to="/register?type=customer"
              className="bg-white text-blue-600 px-8 py-3 rounded-lg font-medium hover:bg-gray-100 transition-colors"
            >
              Müşteri Olarak Başla
            </Link>
            <Link
              to="/register?type=craftsman"
              className="bg-blue-700 text-white px-8 py-3 rounded-lg font-medium hover:bg-blue-800 transition-colors border-2 border-blue-500"
            >
              Usta Olarak Katıl
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="col-span-1 md:col-span-2">
              <div className="flex items-center mb-4">
                <span className="text-2xl font-bold">🔨 Ustam</span>
              </div>
              <p className="text-gray-400 mb-4">
                Türkiye'nin en güvenilir usta bulma platformu. 
                Ev ve işyeri ihtiyaçlarınız için profesyonel hizmet.
              </p>
            </div>
            <div>
              <h3 className="text-lg font-semibold mb-4">Hızlı Linkler</h3>
              <ul className="space-y-2">
                <li><a href="#features" className="text-gray-400 hover:text-white transition-colors">Özellikler</a></li>
                <li><a href="#how-it-works" className="text-gray-400 hover:text-white transition-colors">Nasıl Çalışır</a></li>
                <li><a href="#categories" className="text-gray-400 hover:text-white transition-colors">Kategoriler</a></li>
                <li><Link to="/login" className="text-gray-400 hover:text-white transition-colors">Giriş Yap</Link></li>
              </ul>
            </div>
            <div>
              <h3 className="text-lg font-semibold mb-4">İletişim</h3>
              <ul className="space-y-2 text-gray-400">
                <li>📧 info@ustam.com</li>
                <li>📞 0850 123 45 67</li>
                <li>📍 İstanbul, Türkiye</li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2025 Ustam. Tüm hakları saklıdır.</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;