import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

const OnboardingPage = () => {
  const [currentSlide, setCurrentSlide] = useState(0);
  const navigate = useNavigate();

  const slides = [
    {
      id: 1,
      title: "Güvenilir Usta Bulun",
      subtitle: "Binlerce kalifiye usta arasından ihtiyacınıza en uygun olanı kolayca bulun",
      image: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      color: "from-blue-500 to-indigo-600"
    },
    {
      id: 2,
      title: "Anlık İletişim",
      subtitle: "Usta ile doğrudan mesajlaşın ve işinizin durumunu takip edin",
      image: "https://images.unsplash.com/photo-1551434678-e076c223a692?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      color: "from-green-500 to-emerald-600"
    },
    {
      id: 3,
      title: "Güvenli Ödeme",
      subtitle: "İş tamamlandıktan sonra güvenli ödeme sistemiyle kolayca ödeyin",
      image: "https://images.unsplash.com/photo-1563013544-824ae1b704d3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      color: "from-purple-500 to-pink-600"
    }
  ];

  const nextSlide = () => {
    if (currentSlide < slides.length - 1) {
      setCurrentSlide(currentSlide + 1);
    } else {
      navigate('/auth-choice');
    }
  };

  const skipOnboarding = () => {
    navigate('/auth-choice');
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Skip Button */}
      <div className="absolute top-8 right-8 z-10">
        <button
          onClick={skipOnboarding}
          className="text-gray-500 hover:text-gray-700 font-medium text-sm"
        >
          Geç
        </button>
      </div>

      {/* Main Content */}
      <div className="relative h-screen flex flex-col">
        {/* Image Section */}
        <div className="flex-1 relative overflow-hidden">
          <div className={`absolute inset-0 bg-gradient-to-br ${slides[currentSlide].color} opacity-90`}></div>
          <img
            src={slides[currentSlide].image}
            alt={slides[currentSlide].title}
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-black bg-opacity-20"></div>
        </div>

        {/* Content Section */}
        <div className="absolute bottom-0 left-0 right-0 bg-white rounded-t-3xl p-8">
          <div className="text-center">
            <h1 className="text-3xl font-bold text-gray-900 mb-4">
              {slides[currentSlide].title}
            </h1>
            <p className="text-lg text-gray-600 mb-8 leading-relaxed">
              {slides[currentSlide].subtitle}
            </p>

            {/* Dots */}
            <div className="flex justify-center space-x-2 mb-8">
              {slides.map((_, index) => (
                <div
                  key={index}
                  className={`w-2 h-2 rounded-full transition-all duration-300 ${
                    index === currentSlide ? 'bg-blue-600 w-8' : 'bg-gray-300'
                  }`}
                ></div>
              ))}
            </div>

            {/* Action Buttons */}
            <div className="space-y-4">
              <button
                onClick={nextSlide}
                className="w-full bg-blue-600 text-white py-4 rounded-2xl font-semibold text-lg hover:bg-blue-700 transition-colors"
              >
                {currentSlide === slides.length - 1 ? 'Başla' : 'Devam Et'}
              </button>
              
              {currentSlide === slides.length - 1 && (
                <div className="flex space-x-4">
                  <Link
                    to="/register?type=customer"
                    className="flex-1 bg-gray-100 text-gray-700 py-4 rounded-2xl font-semibold text-lg hover:bg-gray-200 transition-colors"
                  >
                    Müşteri
                  </Link>
                  <Link
                    to="/register?type=craftsman"
                    className="flex-1 bg-gray-100 text-gray-700 py-4 rounded-2xl font-semibold text-lg hover:bg-gray-200 transition-colors"
                  >
                    Usta
                  </Link>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default OnboardingPage;