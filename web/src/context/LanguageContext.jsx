import React, { createContext, useContext, useState, useEffect } from 'react';

const LanguageContext = createContext();

export const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
};

// Language translations
const translations = {
  tr: {
    // Navigation
    'nav.home': 'Ana Sayfa',
    'nav.findCraftsman': 'Usta Bul',
    'nav.categories': 'Kategoriler',
    'nav.about': 'Hakkımızda',
    'nav.messages': 'Mesajlar',
    'nav.profile': 'Profil',
    'nav.dashboard': 'Dashboard',
    'nav.logout': 'Çıkış Yap',
    'nav.login': 'Giriş Yap',
    'nav.register': 'Kayıt Ol',
    
    // Common
    'common.save': 'Kaydet',
    'common.cancel': 'İptal',
    'common.delete': 'Sil',
    'common.edit': 'Düzenle',
    'common.view': 'Görüntüle',
    'common.search': 'Ara',
    'common.filter': 'Filtrele',
    'common.loading': 'Yükleniyor...',
    'common.error': 'Hata',
    'common.success': 'Başarılı',
    'common.confirm': 'Onayla',
    'common.yes': 'Evet',
    'common.no': 'Hayır',
    'common.close': 'Kapat',
    'common.back': 'Geri',
    'common.next': 'İleri',
    'common.previous': 'Önceki',
    'common.finish': 'Bitir',
    'common.start': 'Başla',
    'common.stop': 'Durdur',
    'common.pause': 'Duraklat',
    'common.resume': 'Devam Et',
    'common.complete': 'Tamamla',
    'common.pending': 'Beklemede',
    'common.approved': 'Onaylandı',
    'common.rejected': 'Reddedildi',
    'common.active': 'Aktif',
    'common.inactive': 'Pasif',
    'common.online': 'Çevrimiçi',
    'common.offline': 'Çevrimdışı',
    
    // Forms
    'form.name': 'Ad',
    'form.surname': 'Soyad',
    'form.email': 'E-posta',
    'form.phone': 'Telefon',
    'form.password': 'Şifre',
    'form.confirmPassword': 'Şifre Tekrar',
    'form.address': 'Adres',
    'form.city': 'Şehir',
    'form.district': 'İlçe',
    'form.description': 'Açıklama',
    'form.title': 'Başlık',
    'form.category': 'Kategori',
    'form.budget': 'Bütçe',
    'form.date': 'Tarih',
    'form.time': 'Saat',
    'form.required': 'Zorunlu',
    'form.optional': 'İsteğe bağlı',
    'form.selectOption': 'Seçenek seçin',
    'form.uploadImage': 'Resim Yükle',
    'form.selectFile': 'Dosya Seç',
    
    // Jobs
    'job.title': 'İş Başlığı',
    'job.description': 'İş Açıklaması',
    'job.status': 'Durum',
    'job.priority': 'Öncelik',
    'job.category': 'Kategori',
    'job.budget': 'Bütçe',
    'job.deadline': 'Teslim Tarihi',
    'job.location': 'Konum',
    'job.materials': 'Malzemeler',
    'job.timeTracking': 'Zaman Takibi',
    'job.progress': 'İlerleme',
    'job.warranty': 'Garanti',
    'job.emergency': 'Acil',
    'job.completed': 'Tamamlandı',
    'job.inProgress': 'Devam Ediyor',
    'job.pending': 'Beklemede',
    'job.cancelled': 'İptal Edildi',
    
    // Quotes
    'quote.request': 'Teklif İste',
    'quote.give': 'Teklif Ver',
    'quote.accept': 'Kabul Et',
    'quote.reject': 'Reddet',
    'quote.pending': 'Beklemede',
    'quote.accepted': 'Kabul Edildi',
    'quote.rejected': 'Reddedildi',
    'quote.details': 'Detaylar',
    'quote.price': 'Fiyat',
    'quote.deadline': 'Teslim Tarihi',
    
    // Messages
    'message.send': 'Gönder',
    'message.typing': 'yazıyor...',
    'message.online': 'çevrimiçi',
    'message.lastSeen': 'son görülme',
    'message.newMessage': 'Yeni Mesaj',
    'message.noMessages': 'Henüz mesaj yok',
    
    // Settings
    'settings.title': 'Ayarlar',
    'settings.profile': 'Profil Ayarları',
    'settings.notifications': 'Bildirim Ayarları',
    'settings.privacy': 'Gizlilik Ayarları',
    'settings.language': 'Dil',
    'settings.theme': 'Tema',
    'settings.darkMode': 'Karanlık Mod',
    'settings.lightMode': 'Aydınlık Mod',
    
    // Error Messages
    'error.network': 'Ağ bağlantısı hatası',
    'error.server': 'Sunucu hatası',
    'error.notFound': 'Sayfa bulunamadı',
    'error.unauthorized': 'Yetkisiz erişim',
    'error.forbidden': 'Erişim yasak',
    'error.validation': 'Doğrulama hatası',
    'error.unknown': 'Bilinmeyen hata',
    
    // Success Messages
    'success.saved': 'Başarıyla kaydedildi',
    'success.updated': 'Başarıyla güncellendi',
    'success.deleted': 'Başarıyla silindi',
    'success.sent': 'Başarıyla gönderildi',
  },
  en: {
    // Navigation
    'nav.home': 'Home',
    'nav.findCraftsman': 'Find Craftsman',
    'nav.categories': 'Categories',
    'nav.about': 'About',
    'nav.messages': 'Messages',
    'nav.profile': 'Profile',
    'nav.dashboard': 'Dashboard',
    'nav.logout': 'Logout',
    'nav.login': 'Login',
    'nav.register': 'Register',
    
    // Common
    'common.save': 'Save',
    'common.cancel': 'Cancel',
    'common.delete': 'Delete',
    'common.edit': 'Edit',
    'common.view': 'View',
    'common.search': 'Search',
    'common.filter': 'Filter',
    'common.loading': 'Loading...',
    'common.error': 'Error',
    'common.success': 'Success',
    'common.confirm': 'Confirm',
    'common.yes': 'Yes',
    'common.no': 'No',
    'common.close': 'Close',
    'common.back': 'Back',
    'common.next': 'Next',
    'common.previous': 'Previous',
    'common.finish': 'Finish',
    'common.start': 'Start',
    'common.stop': 'Stop',
    'common.pause': 'Pause',
    'common.resume': 'Resume',
    'common.complete': 'Complete',
    'common.pending': 'Pending',
    'common.approved': 'Approved',
    'common.rejected': 'Rejected',
    'common.active': 'Active',
    'common.inactive': 'Inactive',
    'common.online': 'Online',
    'common.offline': 'Offline',
    
    // Forms
    'form.name': 'Name',
    'form.surname': 'Surname',
    'form.email': 'Email',
    'form.phone': 'Phone',
    'form.password': 'Password',
    'form.confirmPassword': 'Confirm Password',
    'form.address': 'Address',
    'form.city': 'City',
    'form.district': 'District',
    'form.description': 'Description',
    'form.title': 'Title',
    'form.category': 'Category',
    'form.budget': 'Budget',
    'form.date': 'Date',
    'form.time': 'Time',
    'form.required': 'Required',
    'form.optional': 'Optional',
    'form.selectOption': 'Select option',
    'form.uploadImage': 'Upload Image',
    'form.selectFile': 'Select File',
    
    // Jobs
    'job.title': 'Job Title',
    'job.description': 'Job Description',
    'job.status': 'Status',
    'job.priority': 'Priority',
    'job.category': 'Category',
    'job.budget': 'Budget',
    'job.deadline': 'Deadline',
    'job.location': 'Location',
    'job.materials': 'Materials',
    'job.timeTracking': 'Time Tracking',
    'job.progress': 'Progress',
    'job.warranty': 'Warranty',
    'job.emergency': 'Emergency',
    'job.completed': 'Completed',
    'job.inProgress': 'In Progress',
    'job.pending': 'Pending',
    'job.cancelled': 'Cancelled',
    
    // Quotes
    'quote.request': 'Request Quote',
    'quote.give': 'Give Quote',
    'quote.accept': 'Accept',
    'quote.reject': 'Reject',
    'quote.pending': 'Pending',
    'quote.accepted': 'Accepted',
    'quote.rejected': 'Rejected',
    'quote.details': 'Details',
    'quote.price': 'Price',
    'quote.deadline': 'Deadline',
    
    // Messages
    'message.send': 'Send',
    'message.typing': 'typing...',
    'message.online': 'online',
    'message.lastSeen': 'last seen',
    'message.newMessage': 'New Message',
    'message.noMessages': 'No messages yet',
    
    // Settings
    'settings.title': 'Settings',
    'settings.profile': 'Profile Settings',
    'settings.notifications': 'Notification Settings',
    'settings.privacy': 'Privacy Settings',
    'settings.language': 'Language',
    'settings.theme': 'Theme',
    'settings.darkMode': 'Dark Mode',
    'settings.lightMode': 'Light Mode',
    
    // Error Messages
    'error.network': 'Network connection error',
    'error.server': 'Server error',
    'error.notFound': 'Page not found',
    'error.unauthorized': 'Unauthorized access',
    'error.forbidden': 'Access forbidden',
    'error.validation': 'Validation error',
    'error.unknown': 'Unknown error',
    
    // Success Messages
    'success.saved': 'Successfully saved',
    'success.updated': 'Successfully updated',
    'success.deleted': 'Successfully deleted',
    'success.sent': 'Successfully sent',
  }
};

export const LanguageProvider = ({ children }) => {
  const [language, setLanguage] = useState(() => {
    const saved = localStorage.getItem('language');
    if (saved && ['tr', 'en'].includes(saved)) {
      return saved;
    }
    
    // Check browser language
    const browserLang = navigator.language.toLowerCase();
    if (browserLang.startsWith('tr')) {
      return 'tr';
    }
    
    return 'tr'; // Default to Turkish
  });

  useEffect(() => {
    localStorage.setItem('language', language);
    document.documentElement.lang = language;
  }, [language]);

  const t = (key, params = {}) => {
    let translation = translations[language]?.[key] || translations.tr[key] || key;
    
    // Simple parameter replacement
    Object.entries(params).forEach(([param, value]) => {
      translation = translation.replace(`{${param}}`, value);
    });
    
    return translation;
  };

  const changeLanguage = (newLanguage) => {
    if (['tr', 'en'].includes(newLanguage)) {
      setLanguage(newLanguage);
    }
  };

  const value = {
    language,
    changeLanguage,
    t,
    isRTL: false, // Turkish and English are LTR
    availableLanguages: [
      { code: 'tr', name: 'Türkçe', flag: '🇹🇷' },
      { code: 'en', name: 'English', flag: '🇺🇸' }
    ]
  };

  return (
    <LanguageContext.Provider value={value}>
      {children}
    </LanguageContext.Provider>
  );
};