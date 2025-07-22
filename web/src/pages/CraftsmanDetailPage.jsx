import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';

const mockCraftsman = {
  id: 1,
  name: 'Ahmet Usta',
  business: 'Ahmet Elektrik',
  category: 'Elektrikçi',
  rating: 4.8,
  reviewCount: 124,
  hourlyRate: 150,
  image: 'https://via.placeholder.com/120x120',
  distance: '2.3 km',
  isAvailable: true,
  description: '15 yıllık deneyim ile elektrik tesisatı ve onarım hizmetleri. Ev ve işyeri elektrik tesisatı, priz-anahtar montajı, elektrik panosu kurulumu ve bakımı konularında uzmanım.',
  address: 'Kadıköy, İstanbul',
  phone: '+90 532 123 45 67',
  workingHours: 'Pazartesi-Cumartesi: 08:00-18:00',
  services: [
    'Elektrik tesisatı kurulumu',
    'Priz ve anahtar montajı',
    'Elektrik panosu kurulumu',
    'Avize ve aydınlatma montajı',
    'Elektrik arıza tespiti ve onarımı'
  ],
  portfolio: [
    'https://via.placeholder.com/150x150',
    'https://via.placeholder.com/150x150',
    'https://via.placeholder.com/150x150',
    'https://via.placeholder.com/150x150'
  ],
  reviews: [
    {
      id: 1,
      customerName: 'Fatma K.',
      rating: 5,
      comment: 'Çok memnun kaldım. Zamanında geldi, işini çok güzel yaptı. Kesinlikle tavsiye ederim.',
      date: '2 gün önce'
    },
    {
      id: 2,
      customerName: 'Mehmet S.',
      rating: 4,
      comment: 'İşini bilen usta. Fiyatları da uygun.',
      date: '1 hafta önce'
    },
    {
      id: 3,
      customerName: 'Ayşe T.',
      rating: 5,
      comment: 'Çok titiz çalışıyor, temiz bırakıyor. Teşekkürler.',
      date: '2 hafta önce'
    }
  ]
};

export const CraftsmanDetailPage = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [activeTab, setActiveTab] = useState('about');

  const renderStars = (rating) => {
    return Array.from({ length: 5 }, (_, i) => (
      <svg
        key={i}
        className={`w-4 h-4 ${i < Math.floor(rating) ? 'text-yellow-400' : 'text-gray-300'}`}
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
    ));
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <button 
              onClick={() => navigate(-1)}
              className="p-2 hover:bg-gray-100 rounded-full"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h1 className="text-xl font-semibold text-gray-900">Usta Profili</h1>
            <button className="p-2 hover:bg-gray-100 rounded-full">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Profile Header */}
      <div className="bg-white border-b">
        <div className="max-w-md mx-auto px-4 py-6">
          <div className="flex items-start gap-4">
            <img 
              src={mockCraftsman.image} 
              alt={mockCraftsman.name}
              className="w-20 h-20 rounded-full object-cover"
            />
            <div className="flex-1">
              <div className="flex items-start justify-between">
                <div>
                  <h2 className="text-xl font-semibold text-gray-900">{mockCraftsman.name}</h2>
                  <p className="text-gray-600">{mockCraftsman.business}</p>
                  <span className="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full mt-1">
                    {mockCraftsman.category}
                  </span>
                </div>
                <div className="flex items-center gap-1">
                  {mockCraftsman.isAvailable ? (
                    <span className="w-3 h-3 bg-green-500 rounded-full"></span>
                  ) : (
                    <span className="w-3 h-3 bg-red-500 rounded-full"></span>
                  )}
                  <span className={`text-sm ${mockCraftsman.isAvailable ? 'text-green-600' : 'text-red-600'}`}>
                    {mockCraftsman.isAvailable ? 'Müsait' : 'Meşgul'}
                  </span>
                </div>
              </div>

              <div className="flex items-center gap-2 mt-2">
                <div className="flex items-center gap-1">
                  {renderStars(mockCraftsman.rating)}
                  <span className="text-sm font-medium">{mockCraftsman.rating}</span>
                </div>
                <span className="text-sm text-gray-500">({mockCraftsman.reviewCount} değerlendirme)</span>
              </div>

              <div className="flex items-center justify-between mt-3">
                <div className="flex items-center gap-1 text-sm text-gray-500">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  {mockCraftsman.distance}
                </div>
                <div className="text-right">
                  <span className="text-lg font-semibold text-gray-900">₺{mockCraftsman.hourlyRate}</span>
                  <span className="text-sm text-gray-500">/saat</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white border-b">
        <div className="max-w-md mx-auto px-4">
          <div className="flex">
            {['about', 'portfolio', 'reviews'].map(tab => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`flex-1 py-3 text-center text-sm font-medium border-b-2 transition-colors ${
                  activeTab === tab
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                {tab === 'about' && 'Hakkında'}
                {tab === 'portfolio' && 'Portfolyo'}
                {tab === 'reviews' && 'Yorumlar'}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Tab Content */}
      <div className="max-w-md mx-auto px-4 py-4">
        {activeTab === 'about' && (
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Açıklama</h3>
              <p className="text-gray-600 leading-relaxed">{mockCraftsman.description}</p>
            </div>

            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Hizmetler</h3>
              <div className="space-y-2">
                {mockCraftsman.services.map((service, index) => (
                  <div key={index} className="flex items-center gap-2">
                    <svg className="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                    <span className="text-gray-700">{service}</span>
                  </div>
                ))}
              </div>
            </div>

            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">İletişim</h3>
              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  <span className="text-gray-700">{mockCraftsman.address}</span>
                </div>
                <div className="flex items-center gap-3">
                  <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                  </svg>
                  <span className="text-gray-700">{mockCraftsman.phone}</span>
                </div>
                <div className="flex items-center gap-3">
                  <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span className="text-gray-700">{mockCraftsman.workingHours}</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'portfolio' && (
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Önceki İşler</h3>
            <div className="grid grid-cols-2 gap-3">
              {mockCraftsman.portfolio.map((image, index) => (
                <img
                  key={index}
                  src={image}
                  alt={`İş ${index + 1}`}
                  className="w-full h-32 object-cover rounded-lg"
                />
              ))}
            </div>
          </div>
        )}

        {activeTab === 'reviews' && (
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Yorumlar ({mockCraftsman.reviewCount})
            </h3>
            <div className="space-y-4">
              {mockCraftsman.reviews.map(review => (
                <div key={review.id} className="bg-white border rounded-lg p-4">
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <h4 className="font-medium text-gray-900">{review.customerName}</h4>
                      <div className="flex items-center gap-1 mt-1">
                        {renderStars(review.rating)}
                      </div>
                    </div>
                    <span className="text-sm text-gray-500">{review.date}</span>
                  </div>
                  <p className="text-gray-700 text-sm">{review.comment}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Bottom Actions */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t p-4">
        <div className="max-w-md mx-auto flex gap-3">
          <button className="flex-1 bg-gray-100 text-gray-700 py-3 rounded-lg font-medium hover:bg-gray-200 transition-colors">
            Mesaj Gönder
          </button>
          <button 
            onClick={() => navigate(`/quote-request/${mockCraftsman.id}`)}
            className="flex-1 bg-blue-500 text-white py-3 rounded-lg font-medium hover:bg-blue-600 transition-colors"
          >
            Teklif İste
          </button>
        </div>
      </div>

      {/* Bottom padding for fixed button */}
      <div className="h-20"></div>
    </div>
  );
};