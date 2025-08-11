import React, { useState, useEffect } from 'react';
import { AccessibleModal, AccessibleButton, ScreenReaderOnly } from '../../utils/accessibility';
import api from '../../utils/api';

const UserAgreementModal = ({ isOpen, onAccept, onDecline, mandatory = true }) => {
  const [agreement, setAgreement] = useState(null);
  const [loading, setLoading] = useState(false);
  const [hasScrolledToBottom, setHasScrolledToBottom] = useState(false);
  const [acceptedSections, setAcceptedSections] = useState({
    terms: false,
    privacy: false,
    kvkk: false,
    service: false
  });

  useEffect(() => {
    if (isOpen) {
      fetchUserAgreement();
    }
  }, [isOpen]);

  const fetchUserAgreement = async () => {
    setLoading(true);
    try {
      const response = await api.get('/legal/documents/user-agreement');
      if (response.success) {
        setAgreement(response.data);
      }
    } catch (error) {
      console.error('Failed to fetch user agreement:', error);
      // Fallback to default agreement
      setAgreement({
        title: 'Kullanıcı Sözleşmesi',
        version: '1.0',
        sections: [{
          title: 'Kullanıcı Sözleşmesi',
          content: [
            'Bu sözleşme, UstamApp platformunu kullanımınızı düzenler.',
            '',
            'KABUL ETTİKLERİM:',
            '',
            '✓ Platform kurallarına uymayı kabul ediyorum',
            '✓ Doğru ve güncel bilgiler sağlayacağımı taahhüt ediyorum',
            '✓ Diğer kullanıcılara saygılı davranacağımı kabul ediyorum',
            '✓ Hizmet şartlarını okuduğumu ve anladığımı onaylıyorum',
            '✓ Gizlilik politikasını kabul ediyorum',
            '✓ Yasal sorumluluklarımı bildiğimi kabul ediyorum'
          ]
        }]
      });
    } finally {
      setLoading(false);
    }
  };

  const handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const isScrolledToBottom = scrollTop + clientHeight >= scrollHeight - 10;
    setHasScrolledToBottom(isScrolledToBottom);
  };

  const handleSectionAccept = (section) => {
    setAcceptedSections(prev => ({
      ...prev,
      [section]: !prev[section]
    }));
  };

  const allSectionsAccepted = Object.values(acceptedSections).every(Boolean);
  const canAccept = hasScrolledToBottom && allSectionsAccepted;

  const handleAccept = async () => {
    if (!canAccept) return;

    try {
      // Record consent
      await api.post('/legal/compliance/mandatory-consent', {
        user_agreement: true,
        terms_of_service: true,
        privacy_policy: true,
        data_processing: true
      });

      onAccept();
    } catch (error) {
      console.error('Failed to record consent:', error);
      // Still allow acceptance for UX, but log the error
      onAccept();
    }
  };

  if (!agreement) return null;

  return (
    <AccessibleModal
      isOpen={isOpen}
      onClose={mandatory ? undefined : onDecline}
      title="Kullanıcı Sözleşmesi ve KVKK Onayı"
      ariaDescribedBy="agreement-content"
      className="user-agreement-modal"
    >
      <div id="agreement-content" className="max-w-2xl max-h-96">
        {loading ? (
          <div className="text-center py-8">
            <div className="loading-spinner"></div>
            <p>Sözleşme yükleniyor...</p>
          </div>
        ) : (
          <>
            <ScreenReaderOnly>
              Kullanıcı sözleşmesi ve KVKK onay modalı. Bu sözleşmeyi kabul etmeniz platformu kullanmak için gereklidir.
              Lütfen tüm maddeleri okuyun ve aşağıdaki onay kutularını işaretleyin.
            </ScreenReaderOnly>

            {/* Agreement Content */}
            <div 
              className="agreement-content overflow-y-auto max-h-80 border rounded-lg p-4 mb-6 bg-gray-50"
              onScroll={handleScroll}
              tabIndex={0}
              role="region"
              aria-label="Sözleşme içeriği"
            >
              {agreement.sections.map((section, index) => (
                <div key={index} className="mb-6">
                  <h3 className="text-lg font-semibold mb-3 text-gray-800">
                    {section.title}
                  </h3>
                  <div className="space-y-2">
                    {section.content.map((paragraph, pIndex) => (
                      <p key={pIndex} className={`text-sm ${
                        paragraph.startsWith('✓') ? 'text-green-700 font-medium' : 
                        paragraph === '' ? 'h-2' :
                        paragraph.includes(':') ? 'font-semibold text-gray-800' :
                        'text-gray-700'
                      }`}>
                        {paragraph}
                      </p>
                    ))}
                  </div>
                </div>
              ))}
            </div>

            {/* Scroll indicator */}
            {!hasScrolledToBottom && (
              <div className="text-center mb-4">
                <p className="text-sm text-orange-600 font-medium" role="alert">
                  ⚠️ Devam etmek için lütfen tüm sözleşmeyi okuyun
                </p>
                <ScreenReaderOnly>
                  Sözleşmenin tamamını okumak için yukarıdaki içeriği sonuna kadar kaydırın.
                </ScreenReaderOnly>
              </div>
            )}

            {/* Consent Checkboxes */}
            <div className="space-y-4 mb-6">
              <h4 className="font-semibold text-gray-800">Onay Verdiğim Konular:</h4>
              
              <label className="flex items-start space-x-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={acceptedSections.terms}
                  onChange={() => handleSectionAccept('terms')}
                  className="mt-1 w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                  aria-describedby="terms-help"
                />
                <div>
                  <span className="text-sm font-medium">
                    Hizmet Şartları ve Kullanım Koşullarını kabul ediyorum
                  </span>
                  <div id="terms-help" className="text-xs text-gray-600 mt-1">
                    Platform kullanım kurallarını ve sorumluluklarımı kabul ediyorum
                  </div>
                </div>
              </label>

              <label className="flex items-start space-x-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={acceptedSections.privacy}
                  onChange={() => handleSectionAccept('privacy')}
                  className="mt-1 w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                  aria-describedby="privacy-help"
                />
                <div>
                  <span className="text-sm font-medium">
                    Gizlilik Politikasını kabul ediyorum
                  </span>
                  <div id="privacy-help" className="text-xs text-gray-600 mt-1">
                    Kişisel verilerimin işlenmesi ve korunması hakkında bilgilendirildim
                  </div>
                </div>
              </label>

              <label className="flex items-start space-x-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={acceptedSections.kvkk}
                  onChange={() => handleSectionAccept('kvkk')}
                  className="mt-1 w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                  aria-describedby="kvkk-help"
                />
                <div>
                  <span className="text-sm font-medium">
                    KVKK kapsamında kişisel verilerimin işlenmesine onay veriyorum
                  </span>
                  <div id="kvkk-help" className="text-xs text-gray-600 mt-1">
                    Hizmet sunumu için gerekli kişisel veri işleme faaliyetlerini onaylıyorum
                  </div>
                </div>
              </label>

              <label className="flex items-start space-x-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={acceptedSections.service}
                  onChange={() => handleSectionAccept('service')}
                  className="mt-1 w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                  aria-describedby="service-help"
                />
                <div>
                  <span className="text-sm font-medium">
                    18 yaşından büyük olduğumu ve hizmet koşullarını anladığımı beyan ediyorum
                  </span>
                  <div id="service-help" className="text-xs text-gray-600 mt-1">
                    Yasal sorumluluk ve hizmet kullanım koşullarını kabul ediyorum
                  </div>
                </div>
              </label>
            </div>

            {/* Action Buttons */}
            <div className="flex flex-col sm:flex-row gap-3 justify-end">
              {!mandatory && (
                <AccessibleButton
                  onClick={onDecline}
                  variant="secondary"
                  ariaLabel="Sözleşmeyi reddet ve çık"
                >
                  Reddet
                </AccessibleButton>
              )}
              
              <AccessibleButton
                onClick={handleAccept}
                disabled={!canAccept}
                variant="primary"
                ariaLabel={
                  !hasScrolledToBottom 
                    ? "Sözleşmeyi okumadan kabul edemezsiniz"
                    : !allSectionsAccepted
                    ? "Tüm onayları vermeden devam edemezsiniz"
                    : "Sözleşmeyi kabul et ve devam et"
                }
                ariaDescribedBy="accept-help"
              >
                Kabul Et ve Devam Et
              </AccessibleButton>
            </div>

            <div id="accept-help" className="text-xs text-gray-600 mt-2">
              {!hasScrolledToBottom && "Önce sözleşmenin tamamını okuyun"}
              {hasScrolledToBottom && !allSectionsAccepted && "Tüm onay kutularını işaretleyin"}
              {canAccept && "Sözleşmeyi kabul etmeye hazırsınız"}
            </div>

            {/* Legal Notice */}
            <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
              <p className="text-xs text-blue-800">
                <strong>Yasal Bildirim:</strong> Bu sözleşmeyi kabul ederek KVKK kapsamında 
                kişisel verilerinizin işlenmesine açık rıza vermiş olursunuz. 
                Verdiğiniz onayları istediğiniz zaman geri çekebilirsiniz.
              </p>
            </div>

            {/* Document Info */}
            <div className="mt-4 text-xs text-gray-500 border-t pt-3">
              <p>Sözleşme Versiyonu: {agreement.version}</p>
              <p>Yürürlük Tarihi: {agreement.effective_date}</p>
              <p>Son Güncelleme: {new Date().toLocaleDateString('tr-TR')}</p>
            </div>
          </>
        )}
      </div>
    </AccessibleModal>
  );
};

export default UserAgreementModal;