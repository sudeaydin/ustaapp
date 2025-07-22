// API Configuration
export const API_CONFIG = {
  BASE_URL: process.env.NODE_ENV === 'production' 
    ? 'https://api.ustalar.com' 
    : 'http://localhost:5000',
  TIMEOUT: 10000,
  RETRY_ATTEMPTS: 3
}

// App Configuration
export const APP_CONFIG = {
  NAME: 'Ustalar',
  VERSION: '1.0.0',
  SUPPORT_EMAIL: 'destek@ustalar.com',
  SUPPORT_PHONE: '+90 (212) 123 45 67'
}

// Turkish Cities (Major ones)
export const TURKISH_CITIES = [
  'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 
  'Adana', 'Konya', 'Şanlıurfa', 'Gaziantep', 'Kocaeli',
  'Mersin', 'Diyarbakır', 'Hatay', 'Manisa', 'Kayseri',
  'Samsun', 'Balıkesir', 'Kahramanmaraş', 'Van', 'Aydın'
]

// Service Categories with Turkish names
export const SERVICE_CATEGORIES = [
  {
    id: 1,
    name: 'Fayans',
    icon: 'tiles',
    color: '#3498db',
    description: 'Banyo ve mutfak fayans işleri'
  },
  {
    id: 2,
    name: 'Badana',
    icon: 'paint-brush',
    color: '#e74c3c',
    description: 'Duvar boyama ve badana işleri'
  },
  {
    id: 3,
    name: 'Elektrik',
    icon: 'bolt',
    color: '#f39c12',
    description: 'Elektrik tesisatı ve onarım'
  },
  {
    id: 4,
    name: 'Su Tesisatı',
    icon: 'wrench',
    color: '#2980b9',
    description: 'Su ve doğalgaz tesisatı'
  },
  {
    id: 5,
    name: 'Marangozluk',
    icon: 'hammer',
    color: '#8e44ad',
    description: 'Ahşap işleri ve mobilya'
  },
  {
    id: 6,
    name: 'Cam',
    icon: 'window',
    color: '#1abc9c',
    description: 'Cam kesimi ve montajı'
  },
  {
    id: 7,
    name: 'Klima',
    icon: 'snowflake',
    color: '#16a085',
    description: 'Klima montaj ve bakım'
  },
  {
    id: 8,
    name: 'Temizlik',
    icon: 'broom',
    color: '#27ae60',
    description: 'Ev ve ofis temizlik hizmetleri'
  },
  {
    id: 9,
    name: 'Bahçıvanlık',
    icon: 'leaf',
    color: '#2ecc71',
    description: 'Bahçe düzenleme ve bakım'
  },
  {
    id: 10,
    name: 'Nakliye',
    icon: 'truck',
    color: '#34495e',
    description: 'Ev ve ofis taşıma hizmetleri'
  }
]

// Form Validation Rules
export const VALIDATION = {
  EMAIL_REGEX: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  PHONE_REGEX: /^(\+90|0)?[5][0-9]{9}$/,
  PASSWORD_MIN_LENGTH: 6,
  NAME_MIN_LENGTH: 2,
  NAME_MAX_LENGTH: 50
}

// Local Storage Keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: 'ustalar_auth_token',
  USER_DATA: 'ustalar_user_data',
  LANGUAGE: 'ustalar_language',
  THEME: 'ustalar_theme'
}

// Error Messages (Turkish)
export const ERROR_MESSAGES = {
  NETWORK_ERROR: 'İnternet bağlantınızı kontrol edin',
  SERVER_ERROR: 'Sunucu hatası. Lütfen daha sonra tekrar deneyin',
  INVALID_CREDENTIALS: 'E-posta veya şifre hatalı',
  REQUIRED_FIELD: 'Bu alan zorunludur',
  INVALID_EMAIL: 'Geçerli bir e-posta adresi girin',
  INVALID_PHONE: 'Geçerli bir telefon numarası girin',
  PASSWORD_TOO_SHORT: 'Şifre en az 6 karakter olmalıdır',
  PASSWORDS_NOT_MATCH: 'Şifreler eşleşmiyor'
}

// Success Messages (Turkish)
export const SUCCESS_MESSAGES = {
  LOGIN_SUCCESS: 'Başarıyla giriş yapıldı',
  REGISTER_SUCCESS: 'Hesabınız oluşturuldu',
  PROFILE_UPDATED: 'Profiliniz güncellendi',
  QUOTE_SENT: 'Teklif talebiniz gönderildi',
  QUOTE_ACCEPTED: 'Teklif kabul edildi',
  MESSAGE_SENT: 'Mesajınız gönderildi'
}
