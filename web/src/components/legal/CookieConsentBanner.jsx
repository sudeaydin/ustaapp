import React, { useState, useEffect } from 'react';
import { AccessibleButton, ScreenReaderOnly } from '../../utils/accessibility';
import api from '../../utils/api';

const CookieConsentBanner = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [showDetails, setShowDetails] = useState(false);
  const [preferences, setPreferences] = useState({
    necessary: true,  // Always required
    analytics: true,
    marketing: false,
    functional: true
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Check if user has already given cookie consent
    const cookieConsent = localStorage.getItem('cookieConsent');
    if (!cookieConsent) {
      setIsVisible(true);
    }
  }, []);

  const handleAcceptAll = async () => {
    const allAccepted = {
      necessary: true,
      analytics: true,
      marketing: true,
      functional: true
    };
    
    await saveCookiePreferences(allAccepted);
  };

  const handleAcceptSelected = async () => {
    await saveCookiePreferences(preferences);
  };

  const handleRejectAll = async () => {
    const onlyNecessary = {
      necessary: true,
      analytics: false,
      marketing: false,
      functional: false
    };
    
    await saveCookiePreferences(onlyNecessary);
  };

  const saveCookiePreferences = async (prefs) => {
    setLoading(true);
    
    try {
      // Save to backend if user is logged in
      try {
        await api.post('/legal/compliance/cookie-preferences', {
          preferences: prefs
        });
      } catch (error) {
        // Continue even if backend fails
        console.warn('Failed to save cookie preferences to backend:', error);
      }
      
      // Save to localStorage
      localStorage.setItem('cookieConsent', JSON.stringify({
        preferences: prefs,
        timestamp: new Date().toISOString(),
        version: '1.0'
      }));
      
      // Apply cookie preferences
      applyCookiePreferences(prefs);
      
      setIsVisible(false);
      
    } finally {
      setLoading(false);
    }
  };

  const applyCookiePreferences = (prefs) => {
    // Enable/disable analytics
    if (prefs.analytics) {
      // Enable Google Analytics if available
      if (window.gtag) {
        window.gtag('consent', 'update', {
          'analytics_storage': 'granted'
        });
      }
    } else {
      // Disable analytics
      if (window.gtag) {
        window.gtag('consent', 'update', {
          'analytics_storage': 'denied'
        });
      }
    }

    // Enable/disable marketing cookies
    if (prefs.marketing) {
      if (window.gtag) {
        window.gtag('consent', 'update', {
          'ad_storage': 'granted'
        });
      }
    } else {
      if (window.gtag) {
        window.gtag('consent', 'update', {
          'ad_storage': 'denied'
        });
      }
    }

    // Store preferences for other scripts
    window.cookiePreferences = prefs;
  };

  const handlePreferenceChange = (type, value) => {
    if (type === 'necessary') return; // Can't change necessary cookies
    
    setPreferences(prev => ({
      ...prev,
      [type]: value
    }));
  };

  if (!isVisible) return null;

  return (
    <div 
      className="fixed bottom-0 left-0 right-0 bg-white border-t-2 border-gray-200 shadow-lg z-50"
      role="dialog"
      aria-modal="true"
      aria-labelledby="cookie-banner-title"
      aria-describedby="cookie-banner-description"
    >
      <div className="max-w-7xl mx-auto p-4">
        <ScreenReaderOnly>
          Çerez onay banner açıldı. Çerez tercihlerinizi seçebilir veya tümünü kabul edebilirsiniz.
        </ScreenReaderOnly>

        <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
          <div className="flex-1">
            <h2 id="cookie-banner-title" className="text-lg font-semibold text-gray-900 mb-2">
              🍪 Çerez Kullanımı
            </h2>
            <p id="cookie-banner-description" className="text-sm text-gray-600 mb-4 lg:mb-0">
              Web sitemizde deneyiminizi iyileştirmek için çerezler kullanıyoruz. 
              Çerez tercihlerinizi aşağıdan yönetebilirsiniz.
              <button
                onClick={() => setShowDetails(!showDetails)}
                className="text-blue-600 hover:text-blue-800 underline ml-1"
                aria-expanded={showDetails}
                aria-controls="cookie-details"
              >
                {showDetails ? 'Detayları gizle' : 'Detayları göster'}
              </button>
            </p>
          </div>

          {/* Action Buttons */}
          <div className="flex flex-col sm:flex-row gap-2 lg:ml-4">
            <AccessibleButton
              onClick={() => setShowDetails(!showDetails)}
              variant="secondary"
              size="small"
              ariaLabel="Çerez ayarlarını özelleştir"
            >
              Ayarlar
            </AccessibleButton>
            
            <AccessibleButton
              onClick={handleRejectAll}
              disabled={loading}
              variant="secondary"
              size="small"
              ariaLabel="Sadece gerekli çerezleri kabul et"
            >
              Reddet
            </AccessibleButton>
            
            <AccessibleButton
              onClick={handleAcceptAll}
              disabled={loading}
              loading={loading}
              variant="primary"
              size="small"
              ariaLabel="Tüm çerezleri kabul et"
            >
              Tümünü Kabul Et
            </AccessibleButton>
          </div>
        </div>

        {/* Detailed Cookie Settings */}
        {showDetails && (
          <div 
            id="cookie-details"
            className="mt-6 border-t border-gray-200 pt-6"
            role="region"
            aria-label="Çerez ayarları detayları"
          >
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Çerez Tercihlerinizi Yönetin
            </h3>
            
            <div className="grid md:grid-cols-2 gap-4 mb-6">
              {/* Necessary Cookies */}
              <div className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h4 className="font-medium text-gray-900">Gerekli Çerezler</h4>
                    <p className="text-sm text-gray-600 mt-1">
                      Platform işleyişi için zorunlu çerezler. Devre dışı bırakılamaz.
                    </p>
                  </div>
                  <div className="ml-4">
                    <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      Zorunlu
                    </span>
                  </div>
                </div>
              </div>

              {/* Analytics Cookies */}
              <div className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h4 className="font-medium text-gray-900">Analitik Çerezler</h4>
                    <p className="text-sm text-gray-600 mt-1">
                      Platform kullanım istatistikleri ve performans ölçümü.
                    </p>
                  </div>
                  <div className="ml-4">
                    <label className="flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={preferences.analytics}
                        onChange={(e) => handlePreferenceChange('analytics', e.target.checked)}
                        className="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                        aria-describedby="analytics-help"
                      />
                      <span className="sr-only" id="analytics-help">
                        Analitik çerezler platform kullanım istatistikleri toplar
                      </span>
                    </label>
                  </div>
                </div>
              </div>

              {/* Marketing Cookies */}
              <div className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h4 className="font-medium text-gray-900">Pazarlama Çerezleri</h4>
                    <p className="text-sm text-gray-600 mt-1">
                      Kişiselleştirilmiş reklamlar ve pazarlama içerikleri.
                    </p>
                  </div>
                  <div className="ml-4">
                    <label className="flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={preferences.marketing}
                        onChange={(e) => handlePreferenceChange('marketing', e.target.checked)}
                        className="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                        aria-describedby="marketing-help"
                      />
                      <span className="sr-only" id="marketing-help">
                        Pazarlama çerezleri kişiselleştirilmiş reklamlar sunar
                      </span>
                    </label>
                  </div>
                </div>
              </div>

              {/* Functional Cookies */}
              <div className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h4 className="font-medium text-gray-900">İşlevsel Çerezler</h4>
                    <p className="text-sm text-gray-600 mt-1">
                      Tercihlerinizi hatırlama ve gelişmiş özellikler.
                    </p>
                  </div>
                  <div className="ml-4">
                    <label className="flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={preferences.functional}
                        onChange={(e) => handlePreferenceChange('functional', e.target.checked)}
                        className="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                        aria-describedby="functional-help"
                      />
                      <span className="sr-only" id="functional-help">
                        İşlevsel çerezler platform tercihlerinizi hatırlar
                      </span>
                    </label>
                  </div>
                </div>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row gap-2 justify-end">
              <AccessibleButton
                onClick={handleAcceptSelected}
                disabled={loading}
                loading={loading}
                variant="primary"
                ariaLabel="Seçili çerez tercihlerini kaydet"
              >
                Seçilenleri Kaydet
              </AccessibleButton>
            </div>
          </div>
        )}

        {/* Legal Links */}
        <div className="mt-4 pt-4 border-t border-gray-200">
          <div className="flex flex-wrap gap-4 text-xs text-gray-500">
            <a 
              href="/legal" 
              className="hover:text-gray-700 underline"
              aria-label="Gizlilik politikası sayfasına git"
            >
              Gizlilik Politikası
            </a>
            <a 
              href="/legal" 
              className="hover:text-gray-700 underline"
              aria-label="Hizmet şartları sayfasına git"
            >
              Hizmet Şartları
            </a>
            <a 
              href="/legal" 
              className="hover:text-gray-700 underline"
              aria-label="Çerez politikası sayfasına git"
            >
              Çerez Politikası
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CookieConsentBanner;