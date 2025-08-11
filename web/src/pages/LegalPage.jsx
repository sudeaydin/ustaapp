import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { 
  AccessibleTabs, 
  AccessibleButton, 
  ScreenReaderOnly,
  useAccessibility 
} from '../utils/accessibility';
import { PageSEO } from '../utils/seo';
import api from '../utils/api';

const LegalPage = () => {
  const { user } = useAuth();
  const { announce } = useAccessibility();
  const [activeTab, setActiveTab] = useState('terms');
  const [documents, setDocuments] = useState({});
  const [consents, setConsents] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchLegalDocuments();
    if (user) {
      fetchUserConsents();
    }
  }, [user]);

  const fetchLegalDocuments = async () => {
    try {
      const [terms, privacy, cookies, agreement] = await Promise.all([
        api.get('/legal/documents/terms-of-service'),
        api.get('/legal/documents/privacy-policy'),
        api.get('/legal/documents/cookie-policy'),
        api.get('/legal/documents/user-agreement')
      ]);

      setDocuments({
        terms: terms.success ? terms.data : null,
        privacy: privacy.success ? privacy.data : null,
        cookies: cookies.success ? cookies.data : null,
        agreement: agreement.success ? agreement.data : null
      });
    } catch (error) {
      console.error('Failed to fetch legal documents:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchUserConsents = async () => {
    try {
      const response = await api.get('/legal/consent/status');
      if (response.success) {
        setConsents(response.data.consents);
      }
    } catch (error) {
      console.error('Failed to fetch user consents:', error);
    }
  };

  const handleConsentUpdate = async (consentType, value) => {
    try {
      await api.post('/legal/consent/record', {
        consent_type: consentType,
        consent_given: value,
        version: '1.0'
      });

      setConsents(prev => ({
        ...prev,
        [consentType]: {
          given: value,
          date: new Date().toISOString(),
          version: '1.0'
        }
      }));

      announce(`${consentType} onayı ${value ? 'verildi' : 'geri çekildi'}`);
    } catch (error) {
      console.error('Failed to update consent:', error);
      announce('Onay güncelleme başarısız', 'assertive');
    }
  };

  const exportUserData = async () => {
    try {
      announce('Veri dışa aktarma başlatıldı');
      
      const response = await fetch('/api/legal/data/export', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      });

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `ustamapp_data_export_${new Date().getTime()}.json`;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
        
        announce('Veri dışa aktarma tamamlandı');
      } else {
        throw new Error('Export failed');
      }
    } catch (error) {
      console.error('Data export failed:', error);
      announce('Veri dışa aktarma başarısız', 'assertive');
    }
  };

  const tabs = [
    {
      id: 'terms',
      label: 'Hizmet Şartları',
      content: documents.terms ? (
        <DocumentSection document={documents.terms} />
      ) : (
        <div>Yükleniyor...</div>
      )
    },
    {
      id: 'privacy',
      label: 'Gizlilik Politikası',
      content: documents.privacy ? (
        <DocumentSection document={documents.privacy} />
      ) : (
        <div>Yükleniyor...</div>
      )
    },
    {
      id: 'cookies',
      label: 'Çerez Politikası',
      content: documents.cookies ? (
        <DocumentSection document={documents.cookies} />
      ) : (
        <div>Yükleniyor...</div>
      )
    },
    {
      id: 'agreement',
      label: 'Kullanıcı Sözleşmesi',
      content: documents.agreement ? (
        <DocumentSection document={documents.agreement} />
      ) : (
        <div>Yükleniyor...</div>
      )
    }
  ];

  if (user) {
    tabs.push({
      id: 'consents',
      label: 'Onay Yönetimi',
      content: <ConsentManagement consents={consents} onConsentUpdate={handleConsentUpdate} />
    });

    tabs.push({
      id: 'gdpr',
      label: 'KVKK Hakları',
      content: <GDPRRights onExportData={exportUserData} />
    });
  }

  const seoConfig = {
    title: 'Yasal Belgeler - UstamApp',
    description: 'UstamApp hizmet şartları, gizlilik politikası, çerez politikası ve KVKK hakları.',
    keywords: 'hizmet şartları, gizlilik politikası, çerez politikası, KVKK, GDPR, kullanıcı hakları',
    canonicalUrl: 'https://ustamapp.com/legal'
  };

  return (
    <PageSEO pageType="legal" data={seoConfig}>
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-4xl mx-auto px-4">
          <header className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-4">
              Yasal Belgeler ve Gizlilik
            </h1>
            <p className="text-lg text-gray-600">
              UstamApp'in yasal belgeleri, gizlilik politikası ve kullanıcı hakları
            </p>
            
            <ScreenReaderOnly>
              Bu sayfa UstamApp'in tüm yasal belgelerini içerir. Sekme navigasyonu ile 
              farklı belgelere erişebilirsiniz.
            </ScreenReaderOnly>
          </header>

          {loading ? (
            <div className="text-center py-12">
              <div className="loading-spinner mx-auto mb-4"></div>
              <p>Yasal belgeler yükleniyor...</p>
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow-sm">
              <AccessibleTabs
                tabs={tabs}
                activeTab={activeTab}
                onTabChange={(tabId) => {
                  setActiveTab(tabId);
                  announce(`${tabs.find(t => t.id === tabId)?.label} sekmesine geçildi`);
                }}
                ariaLabel="Yasal belgeler sekmeleri"
                className="p-6"
              />
            </div>
          )}
        </div>
      </div>
    </PageSEO>
  );
};

// Document Section Component
const DocumentSection = ({ document }) => {
  if (!document) return <div>Belge bulunamadı</div>;

  return (
    <div className="prose max-w-none">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          {document.title}
        </h2>
        <div className="text-sm text-gray-600 mb-4">
          <p>Versiyon: {document.version}</p>
          <p>Yürürlük Tarihi: {document.effective_date}</p>
        </div>
      </div>

      {document.sections.map((section, index) => (
        <section key={index} className="mb-8">
          <h3 className="text-xl font-semibold text-gray-800 mb-4">
            {section.title}
          </h3>
          <div className="space-y-3">
            {section.content.map((paragraph, pIndex) => (
              <p key={pIndex} className={`text-gray-700 leading-relaxed ${
                paragraph.startsWith('✓') ? 'text-green-700 font-medium pl-4' :
                paragraph === '' ? 'h-2' :
                paragraph.includes(':') && paragraph.length < 100 ? 'font-semibold text-gray-800' :
                ''
              }`}>
                {paragraph}
              </p>
            ))}
          </div>
        </section>
      ))}
    </div>
  );
};

// Consent Management Component
const ConsentManagement = ({ consents, onConsentUpdate }) => {
  const consentTypes = [
    {
      type: 'marketing_communications',
      title: 'Pazarlama İletişimi',
      description: 'Kampanya, duyuru ve özel teklifler hakkında bilgilendirme',
      required: false
    },
    {
      type: 'analytics_tracking',
      title: 'Analitik Takibi',
      description: 'Platform kullanım analizi ve iyileştirme çalışmaları',
      required: false
    },
    {
      type: 'location_tracking',
      title: 'Konum Takibi',
      description: 'Yakınınızdaki ustaları bulmak için konum bilgisi kullanımı',
      required: false
    }
  ];

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-4">
          Onay Yönetimi
        </h2>
        <p className="text-gray-600 mb-6">
          Verdiğiniz onayları buradan yönetebilirsiniz. Zorunlu onaylar platform kullanımı için gereklidir.
        </p>
      </div>

      {/* Required Consents */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h3 className="font-semibold text-blue-900 mb-3">Zorunlu Onaylar</h3>
        <div className="space-y-2 text-sm text-blue-800">
          <div className="flex items-center space-x-2">
            <span className="text-green-600">✓</span>
            <span>Hizmet Şartları ve Kullanım Koşulları</span>
          </div>
          <div className="flex items-center space-x-2">
            <span className="text-green-600">✓</span>
            <span>Gizlilik Politikası</span>
          </div>
          <div className="flex items-center space-x-2">
            <span className="text-green-600">✓</span>
            <span>KVKK Kişisel Veri İşleme Onayı</span>
          </div>
        </div>
        <p className="text-xs text-blue-700 mt-3">
          Bu onaylar platform kullanımı için zorunludur ve geri çekilemez.
        </p>
      </div>

      {/* Optional Consents */}
      <div>
        <h3 className="font-semibold text-gray-900 mb-4">İsteğe Bağlı Onaylar</h3>
        <div className="space-y-4">
          {consentTypes.map((consentType) => {
            const currentConsent = consents[consentType.type];
            const isGiven = currentConsent?.given || false;

            return (
              <div key={consentType.type} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h4 className="font-medium text-gray-900">
                      {consentType.title}
                    </h4>
                    <p className="text-sm text-gray-600 mt-1">
                      {consentType.description}
                    </p>
                    {currentConsent?.date && (
                      <p className="text-xs text-gray-500 mt-2">
                        Son güncelleme: {new Date(currentConsent.date).toLocaleDateString('tr-TR')}
                      </p>
                    )}
                  </div>
                  
                  <div className="ml-4">
                    <label className="flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={isGiven}
                        onChange={(e) => onConsentUpdate(consentType.type, e.target.checked)}
                        className="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                        aria-describedby={`${consentType.type}-help`}
                      />
                      <span className="ml-2 text-sm font-medium">
                        {isGiven ? 'Onaylı' : 'Onaysız'}
                      </span>
                    </label>
                    <div id={`${consentType.type}-help`} className="sr-only">
                      {consentType.description}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

// GDPR Rights Component
const GDPRRights = ({ onExportData }) => {
  const [requestType, setRequestType] = useState('');
  const [loading, setLoading] = useState(false);

  const gdprRights = [
    {
      type: 'access',
      title: 'Bilgi Alma Hakkı',
      description: 'Hangi kişisel verilerinizin işlendiği hakkında bilgi alın',
      action: 'Bilgi Al'
    },
    {
      type: 'portability',
      title: 'Veri Taşınabilirliği',
      description: 'Kişisel verilerinizi yapılandırılmış formatta indirin',
      action: 'Verileri İndir'
    },
    {
      type: 'rectification',
      title: 'Düzeltme Hakkı',
      description: 'Yanlış veya eksik kişisel verilerinizi düzeltin',
      action: 'Düzeltme Talebi'
    },
    {
      type: 'erasure',
      title: 'Silme Hakkı',
      description: 'Kişisel verilerinizin silinmesini talep edin',
      action: 'Silme Talebi'
    }
  ];

  const handleGDPRRequest = async (type) => {
    if (type === 'portability') {
      onExportData();
      return;
    }

    setLoading(true);
    setRequestType(type);
    
    try {
      const response = await api.post('/legal/gdpr/data-request', {
        request_type: type
      });

      if (response.success) {
        alert(`${type} talebi işlendi: ${response.message}`);
      }
    } catch (error) {
      console.error('GDPR request failed:', error);
      alert('Talep işlenemedi. Lütfen tekrar deneyin.');
    } finally {
      setLoading(false);
      setRequestType('');
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-4">
          KVKK Hakları
        </h2>
        <p className="text-gray-600 mb-6">
          6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında sahip olduğunuz haklar.
        </p>
      </div>

      <div className="grid md:grid-cols-2 gap-4">
        {gdprRights.map((right) => (
          <div key={right.type} className="border border-gray-200 rounded-lg p-6">
            <h3 className="font-semibold text-gray-900 mb-2">
              {right.title}
            </h3>
            <p className="text-sm text-gray-600 mb-4">
              {right.description}
            </p>
            
            <AccessibleButton
              onClick={() => handleGDPRRequest(right.type)}
              disabled={loading && requestType === right.type}
              loading={loading && requestType === right.type}
              variant="secondary"
              ariaLabel={`${right.title} - ${right.description}`}
              className="w-full"
            >
              {right.action}
            </AccessibleButton>
          </div>
        ))}
      </div>

      {/* Contact Information */}
      <div className="bg-gray-50 border border-gray-200 rounded-lg p-6">
        <h3 className="font-semibold text-gray-900 mb-3">
          İletişim Bilgileri
        </h3>
        <div className="space-y-2 text-sm text-gray-700">
          <p><strong>Veri Sorumlusu:</strong> UstamApp</p>
          <p><strong>E-posta:</strong> privacy@ustamapp.com</p>
          <p><strong>Telefon:</strong> 0850 123 45 67</p>
          <p><strong>Yanıt Süresi:</strong> 30 gün</p>
        </div>
        
        <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded">
          <p className="text-xs text-blue-800">
            <strong>Önemli:</strong> KVKK haklarınızı kullanmak için kimlik doğrulama gerekebilir. 
            Talepleriniz 30 gün içinde değerlendirilir.
          </p>
        </div>
      </div>
    </div>
  );
};

export default LegalPage;