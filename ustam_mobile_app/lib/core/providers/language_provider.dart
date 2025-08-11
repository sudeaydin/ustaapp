import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('tr', 'TR')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'tr';
    final countryCode = prefs.getString('country_code') ?? 'TR';
    state = Locale(languageCode, countryCode);
  }

  Future<void> setLanguage(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
  }

  String get currentLanguageCode => state.languageCode;
  bool get isTurkish => state.languageCode == 'tr';
  bool get isEnglish => state.languageCode == 'en';
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

// Translation maps
class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'tr': {
      // Navigation
      'nav_home': 'Ana Sayfa',
      'nav_search': 'Ara',
      'nav_messages': 'Mesajlar',
      'nav_profile': 'Profil',
      'nav_dashboard': 'Dashboard',
      'nav_jobs': 'İşlerim',
      'nav_quotes': 'Teklifler',
      'nav_settings': 'Ayarlar',
      
      // Common
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'logout': 'Çıkış Yap',
      'save': 'Kaydet',
      'cancel': 'İptal',
      'delete': 'Sil',
      'edit': 'Düzenle',
      'view': 'Görüntüle',
      'search': 'Ara',
      'filter': 'Filtrele',
      'loading': 'Yükleniyor...',
      'error': 'Hata',
      'success': 'Başarılı',
      'confirm': 'Onayla',
      'yes': 'Evet',
      'no': 'Hayır',
      'close': 'Kapat',
      'back': 'Geri',
      'next': 'İleri',
      'finish': 'Bitir',
      'start': 'Başla',
      'complete': 'Tamamla',
      'pending': 'Beklemede',
      
      // Auth
      'email': 'E-posta',
      'password': 'Şifre',
      'confirm_password': 'Şifre Tekrar',
      'first_name': 'Ad',
      'last_name': 'Soyad',
      'phone': 'Telefon',
      'user_type': 'Kullanıcı Tipi',
      'customer': 'Müşteri',
      'craftsman': 'Usta',
      'login_title': 'Giriş Yap',
      'register_title': 'Kayıt Ol',
      'forgot_password': 'Şifremi Unuttum',
      'dont_have_account': 'Hesabınız yok mu?',
      'already_have_account': 'Zaten hesabınız var mı?',
      
      // Settings
      'settings': 'Ayarlar',
      'theme': 'Tema',
      'language': 'Dil',
      'dark_mode': 'Karanlık Mod',
      'light_mode': 'Aydınlık Mod',
      'system_mode': 'Sistem',
      'notifications': 'Bildirimler',
      'privacy': 'Gizlilik',
      
      // Jobs
      'jobs': 'İşler',
      'job_title': 'İş Başlığı',
      'job_description': 'İş Açıklaması',
      'job_status': 'Durum',
      'job_category': 'Kategori',
      'job_budget': 'Bütçe',
      'create_job': 'İş Oluştur',
      'my_jobs': 'İşlerim',
      
      // Emergency
      'emergency': 'Acil',
      'emergency_service': 'Acil Servis',
      'emergency_request': 'Acil Talep',
      'emergency_level': 'Aciliyet Seviyesi',
      'high_priority': 'Yüksek Öncelik',
      'medium_priority': 'Orta Öncelik',
      'low_priority': 'Düşük Öncelik',
      
      // Tutorial
      'step': 'Adım',
      'skip': 'Atla',
      'previous': 'Önceki',
    },
    'en': {
      // Navigation
      'nav_home': 'Home',
      'nav_search': 'Search',
      'nav_messages': 'Messages',
      'nav_profile': 'Profile',
      'nav_dashboard': 'Dashboard',
      'nav_jobs': 'My Jobs',
      'nav_quotes': 'Quotes',
      'nav_settings': 'Settings',
      
      // Common
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'view': 'View',
      'search': 'Search',
      'filter': 'Filter',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'finish': 'Finish',
      'start': 'Start',
      'complete': 'Complete',
      'pending': 'Pending',
      
      // Auth
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'phone': 'Phone',
      'user_type': 'User Type',
      'customer': 'Customer',
      'craftsman': 'Craftsman',
      'login_title': 'Login',
      'register_title': 'Register',
      'forgot_password': 'Forgot Password',
      'dont_have_account': 'Don\'t have an account?',
      'already_have_account': 'Already have an account?',
      
      // Settings
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_mode': 'System',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      
      // Jobs
      'jobs': 'Jobs',
      'job_title': 'Job Title',
      'job_description': 'Job Description',
      'job_status': 'Status',
      'job_category': 'Category',
      'job_budget': 'Budget',
      'create_job': 'Create Job',
      'my_jobs': 'My Jobs',
      
      // Emergency
      'emergency': 'Emergency',
      'emergency_service': 'Emergency Service',
      'emergency_request': 'Emergency Request',
      'emergency_level': 'Emergency Level',
      'high_priority': 'High Priority',
      'medium_priority': 'Medium Priority',
      'low_priority': 'Low Priority',
      
      // Tutorial
      'step': 'Step',
      'skip': 'Skip',
      'previous': 'Previous',
      
      // Common
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'view': 'View',
      'search': 'Search',
      'filter': 'Filter',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'finish': 'Finish',
      'start': 'Start',
      'complete': 'Complete',
      'pending': 'Pending',
      
      // Auth
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'phone': 'Phone',
      'user_type': 'User Type',
      'customer': 'Customer',
      'craftsman': 'Craftsman',
      'login_title': 'Login',
      'register_title': 'Register',
      'forgot_password': 'Forgot Password',
      'dont_have_account': 'Don\'t have an account?',
      'already_have_account': 'Already have an account?',
      
      // Settings
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_mode': 'System',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      
      // Jobs
      'jobs': 'Jobs',
      'job_title': 'Job Title',
      'job_description': 'Job Description',
      'job_status': 'Status',
      'job_category': 'Category',
      'job_budget': 'Budget',
      'create_job': 'Create Job',
      'my_jobs': 'My Jobs',
      
      // Emergency
      'emergency': 'Emergency',
      'emergency_service': 'Emergency Service',
      'emergency_request': 'Emergency Request',
      'emergency_level': 'Emergency Level',
      'high_priority': 'High Priority',
      'medium_priority': 'Medium Priority',
      'low_priority': 'Low Priority',
      
      // Tutorial
      'step': 'Step',
      'skip': 'Skip',
      'previous': 'Previous',
    },
  };

  static String translate(String key, String languageCode) {
    return _translations[languageCode]?[key] ?? 
           _translations['tr']?[key] ?? 
           key;
  }
}

// Helper extension for easy translation
extension StringTranslation on String {
  String tr(Locale locale) {
    return AppTranslations.translate(this, locale.languageCode);
  }
}