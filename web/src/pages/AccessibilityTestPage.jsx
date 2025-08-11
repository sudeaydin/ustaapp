import React, { useState, useRef } from 'react';
import { 
  AccessibleButton, 
  AccessibleInput, 
  AccessibleModal, 
  AccessibleTabs,
  AccessiblePagination,
  AccessibleBreadcrumb,
  AccessibleLoader,
  ScreenReaderOnly,
  useAccessibility,
  KEYBOARD_SHORTCUTS,
  CONTRAST_LEVELS
} from '../utils/accessibility';

const AccessibilityTestPage = () => {
  const [modalOpen, setModalOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [activeTab, setActiveTab] = useState('overview');
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: ''
  });
  const [formErrors, setFormErrors] = useState({});
  
  const { announce } = useAccessibility();

  // Demo data
  const breadcrumbItems = [
    { name: 'Ana Sayfa', url: '/' },
    { name: 'Test Sayfaları', url: '/testing' },
    { name: 'Erişilebilirlik Testi', url: '/accessibility-test' }
  ];

  const tabs = [
    {
      id: 'overview',
      label: 'Genel Bakış',
      content: (
        <div className="space-y-4">
          <h3>Erişilebilirlik Özellikleri</h3>
          <ul className="list-disc pl-6 space-y-2">
            <li>Klavye navigasyonu (Tab, Shift+Tab)</li>
            <li>Ekran okuyucu desteği</li>
            <li>ARIA etiketleri ve roller</li>
            <li>Renk kontrastı kontrolü</li>
            <li>Odak yönetimi</li>
            <li>Semantik HTML yapısı</li>
          </ul>
        </div>
      )
    },
    {
      id: 'keyboard',
      label: 'Klavye Kısayolları',
      content: (
        <div className="space-y-4">
          <h3>Klavye Kısayolları</h3>
          <dl className="space-y-2">
            {Object.entries(KEYBOARD_SHORTCUTS).map(([key, value]) => (
              <div key={key} className="flex">
                <dt className="font-semibold w-32">{value}:</dt>
                <dd>{key.replace(/_/g, ' ').toLowerCase()}</dd>
              </div>
            ))}
          </dl>
        </div>
      )
    },
    {
      id: 'contrast',
      label: 'Renk Kontrastı',
      content: (
        <div className="space-y-4">
          <h3>WCAG Kontrast Seviyeleri</h3>
          <dl className="space-y-2">
            {Object.entries(CONTRAST_LEVELS).map(([key, value]) => (
              <div key={key} className="flex">
                <dt className="font-semibold w-32">{key}:</dt>
                <dd>{value}:1</dd>
              </div>
            ))}
          </dl>
        </div>
      )
    }
  ];

  const handleFormSubmit = (e) => {
    e.preventDefault();
    
    // Validate form
    const errors = {};
    if (!formData.name.trim()) {
      errors.name = 'İsim gereklidir';
    }
    if (!formData.email.trim()) {
      errors.email = 'E-posta gereklidir';
    }
    if (!formData.message.trim()) {
      errors.message = 'Mesaj gereklidir';
    }

    setFormErrors(errors);

    if (Object.keys(errors).length === 0) {
      announce('Form başarıyla gönderildi', 'assertive');
      setFormData({ name: '', email: '', message: '' });
    } else {
      announce(`Form hatası: ${Object.keys(errors).length} alan eksik`, 'assertive');
    }
  };

  const handleLoadingDemo = () => {
    setLoading(true);
    announce('Yükleme başladı');
    
    setTimeout(() => {
      setLoading(false);
      announce('Yükleme tamamlandı');
    }, 3000);
  };

  const handleModalOpen = () => {
    setModalOpen(true);
  };

  const handleModalClose = () => {
    setModalOpen(false);
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4">
        {/* Page Header */}
        <header className="mb-8">
          <AccessibleBreadcrumb items={breadcrumbItems} />
          
          <h1 className="text-3xl font-bold text-gray-900 mb-4">
            Erişilebilirlik Test Sayfası
          </h1>
          
          <p className="text-lg text-gray-600 mb-4">
            Bu sayfa UstamApp'in erişilebilirlik özelliklerini test etmek için tasarlanmıştır.
          </p>
          
          <ScreenReaderOnly>
            Bu sayfa erişilebilirlik özelliklerini test etmek için çeşitli bileşenler içerir. 
            Klavye navigasyonu için Tab tuşunu kullanabilirsiniz.
          </ScreenReaderOnly>
        </header>

        {/* Accessibility Features Demo */}
        <section className="bg-white rounded-lg shadow-sm p-6 mb-8">
          <h2 className="text-2xl font-semibold mb-6">Erişilebilirlik Bileşenleri</h2>
          
          {/* Buttons Demo */}
          <div className="mb-8">
            <h3 className="text-lg font-medium mb-4">Erişilebilir Butonlar</h3>
            <div className="flex flex-wrap gap-4">
              <AccessibleButton
                onClick={() => announce('Birincil buton tıklandı')}
                ariaLabel="Birincil aksiyon butonu"
                variant="primary"
              >
                Birincil Buton
              </AccessibleButton>
              
              <AccessibleButton
                onClick={() => announce('İkincil buton tıklandı')}
                ariaLabel="İkincil aksiyon butonu"
                variant="secondary"
              >
                İkincil Buton
              </AccessibleButton>
              
              <AccessibleButton
                onClick={handleLoadingDemo}
                ariaLabel="Yükleme demo butonu"
                loading={loading}
                disabled={loading}
              >
                {loading ? 'Yükleniyor...' : 'Yükleme Demo'}
              </AccessibleButton>
              
              <AccessibleButton
                ariaLabel="Devre dışı buton örneği"
                disabled={true}
              >
                Devre Dışı
              </AccessibleButton>
            </div>
          </div>

          {/* Loading Demo */}
          {loading && (
            <div className="mb-8">
              <AccessibleLoader 
                message="Demo yükleme işlemi devam ediyor..." 
                size="medium"
              />
            </div>
          )}

          {/* Form Demo */}
          <div className="mb-8">
            <h3 className="text-lg font-medium mb-4">Erişilebilir Form</h3>
            <form onSubmit={handleFormSubmit} className="space-y-4 max-w-md">
              <AccessibleInput
                label="Ad Soyad"
                id="name"
                value={formData.name}
                onChange={(e) => setFormData({...formData, name: e.target.value})}
                error={formErrors.name}
                required={true}
                ariaDescribedBy="name-help"
              />
              <div id="name-help" className="text-sm text-gray-500">
                Tam adınızı giriniz
              </div>

              <AccessibleInput
                label="E-posta Adresi"
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({...formData, email: e.target.value})}
                error={formErrors.email}
                required={true}
              />

              <div className="accessible-input-group">
                <label htmlFor="message" className="input-label required">
                  Mesajınız
                  <span aria-label="gerekli alan" className="required-indicator"> *</span>
                </label>
                <textarea
                  id="message"
                  value={formData.message}
                  onChange={(e) => setFormData({...formData, message: e.target.value})}
                  aria-required="true"
                  aria-invalid={!!formErrors.message}
                  className={`accessible-input ${formErrors.message ? 'error' : ''}`}
                  rows="4"
                  placeholder="Mesajınızı buraya yazın..."
                />
                {formErrors.message && (
                  <div className="input-error" role="alert">
                    <span className="sr-only">Hata: </span>
                    {formErrors.message}
                  </div>
                )}
              </div>

              <AccessibleButton
                type="submit"
                ariaLabel="Formu gönder"
                variant="primary"
              >
                Gönder
              </AccessibleButton>
            </form>
          </div>

          {/* Modal Demo */}
          <div className="mb-8">
            <h3 className="text-lg font-medium mb-4">Erişilebilir Modal</h3>
            <AccessibleButton
              onClick={handleModalOpen}
              ariaLabel="Test modalını aç"
              variant="secondary"
            >
              Modal Aç
            </AccessibleButton>
          </div>

          {/* Tabs Demo */}
          <div className="mb-8">
            <h3 className="text-lg font-medium mb-4">Erişilebilir Sekmeler</h3>
            <AccessibleTabs
              tabs={tabs}
              activeTab={activeTab}
              onTabChange={setActiveTab}
              ariaLabel="Erişilebilirlik bilgileri sekmeleri"
            />
          </div>

          {/* Pagination Demo */}
          <div className="mb-8">
            <h3 className="text-lg font-medium mb-4">Erişilebilir Sayfalama</h3>
            <AccessiblePagination
              currentPage={currentPage}
              totalPages={10}
              onPageChange={(page) => {
                setCurrentPage(page);
                announce(`${page}. sayfaya geçildi`);
              }}
              ariaLabel="Test sayfalama navigasyonu"
            />
          </div>
        </section>

        {/* Accessibility Guidelines */}
        <section className="bg-white rounded-lg shadow-sm p-6 mb-8">
          <h2 className="text-2xl font-semibold mb-6">Erişilebilirlik Rehberi</h2>
          
          <div className="grid md:grid-cols-2 gap-6">
            <div>
              <h3 className="text-lg font-medium mb-3">Klavye Navigasyonu</h3>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>• <kbd className="bg-gray-100 px-2 py-1 rounded">Tab</kbd> - Sonraki öğe</li>
                <li>• <kbd className="bg-gray-100 px-2 py-1 rounded">Shift + Tab</kbd> - Önceki öğe</li>
                <li>• <kbd className="bg-gray-100 px-2 py-1 rounded">Enter</kbd> - Aktivasyon</li>
                <li>• <kbd className="bg-gray-100 px-2 py-1 rounded">Space</kbd> - Buton aktivasyonu</li>
                <li>• <kbd className="bg-gray-100 px-2 py-1 rounded">Escape</kbd> - Modal kapatma</li>
                <li>• <kbd className="bg-gray-100 px-2 py-1 rounded">Alt + M</kbd> - Ana içeriğe geç</li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-lg font-medium mb-3">Ekran Okuyucu</h3>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>• Tüm öğeler uygun etiketlere sahip</li>
                <li>• Dinamik içerik değişiklikleri duyurulur</li>
                <li>• Form hataları anında bildirilir</li>
                <li>• Sayfa yapısı semantik HTML ile tanımlanır</li>
                <li>• Alt metinler tüm görseller için mevcut</li>
              </ul>
            </div>
          </div>
        </section>

        {/* Color Contrast Demo */}
        <section className="bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-2xl font-semibold mb-6">Renk Kontrastı Örnekleri</h2>
          
          <div className="grid md:grid-cols-3 gap-4">
            <div className="p-4 bg-ucla-blue text-white rounded">
              <h4 className="font-medium">AA Uyumlu</h4>
              <p className="text-sm">Bu metin yeterli kontrasta sahip</p>
            </div>
            
            <div className="p-4 bg-delft-blue-500 text-white rounded">
              <h4 className="font-medium">AA Uyumlu</h4>
              <p className="text-sm">Bu metin de okunabilir</p>
            </div>
            
            <div className="p-4 bg-gray-200 text-gray-900 rounded">
              <h4 className="font-medium">Yüksek Kontrast</h4>
              <p className="text-sm">Maksimum okunabilirlik</p>
            </div>
          </div>
        </section>
      </div>

      {/* Accessible Modal */}
      <AccessibleModal
        isOpen={modalOpen}
        onClose={handleModalClose}
        title="Erişilebilir Modal Örneği"
        ariaDescribedBy="modal-description"
      >
        <div id="modal-description">
          <p className="mb-4">
            Bu modal erişilebilirlik özelliklerine sahiptir:
          </p>
          <ul className="list-disc pl-6 space-y-1 text-sm">
            <li>Odak modal içinde kalır</li>
            <li>Escape tuşu ile kapatılabilir</li>
            <li>Ekran okuyucu tarafından duyurulur</li>
            <li>Önceki odak konumu hatırlanır</li>
          </ul>
          
          <div className="mt-6 flex gap-4">
            <AccessibleButton
              onClick={() => {
                announce('Onay butonu tıklandı');
                handleModalClose();
              }}
              variant="primary"
              ariaLabel="Modalı onayla ve kapat"
            >
              Onayla
            </AccessibleButton>
            
            <AccessibleButton
              onClick={handleModalClose}
              variant="secondary"
              ariaLabel="Modalı iptal et ve kapat"
            >
              İptal
            </AccessibleButton>
          </div>
        </div>
      </AccessibleModal>

      {/* Screen Reader Announcements Demo */}
      <div className="fixed bottom-4 right-4 space-y-2">
        <AccessibleButton
          onClick={() => announce('Test duyurusu: Sayfa güncellendi')}
          variant="secondary"
          size="small"
          ariaLabel="Test duyurusu yap"
        >
          Test Duyurusu
        </AccessibleButton>
        
        <AccessibleButton
          onClick={() => announce('Acil duyuru: Önemli bilgi!', 'assertive')}
          variant="primary"
          size="small"
          ariaLabel="Acil test duyurusu yap"
        >
          Acil Duyuru
        </AccessibleButton>
      </div>

      {/* Hidden content for screen readers */}
      <ScreenReaderOnly>
        <h2>Sayfa Özeti</h2>
        <p>
          Bu sayfa UstamApp'in erişilebilirlik özelliklerini gösterir. 
          Klavye navigasyonu, ekran okuyucu desteği, ARIA etiketleri ve 
          renk kontrastı örnekleri bulunmaktadır.
        </p>
      </ScreenReaderOnly>
    </div>
  );
};

export default AccessibilityTestPage;