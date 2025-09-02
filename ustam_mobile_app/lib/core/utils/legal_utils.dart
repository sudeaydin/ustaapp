import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../widgets/user_agreement_modal.dart';
import '../widgets/consent_preferences_sheet.dart';
import '../widgets/gdpr_rights_sheet.dart';

/// Types of consent that users can give
enum ConsentType {
  mandatory,
  marketing,
  analytics,
  cookies,
  location,
  notifications,
  dataSharing,
  thirdParty
}

/// Legal document types
enum LegalDocumentType {
  userAgreement,
  privacyPolicy,
  cookiePolicy,
  terms,
  kvkk,
  communicationRules
}

/// GDPR/KVKK rights
enum GDPRRight {
  access,
  rectification,
  erasure,
  portability,
  restriction,
  objection,
  withdraw
}

/// User consent record
class UserConsent {
  final String id;
  final ConsentType type;
  final bool granted;
  final DateTime timestamp;
  final String version;
  final String? ipAddress;
  final String? userAgent;

  UserConsent({
    required this.id,
    required this.type,
    required this.granted,
    required this.timestamp,
    required this.version,
    this.ipAddress,
    this.userAgent,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'granted': granted,
    'timestamp': timestamp.toIso8601String(),
    'version': version,
    'ip_address': ipAddress,
    'user_agent': userAgent,
  };

  factory UserConsent.fromJson(Map<String, dynamic> json) => UserConsent(
    id: json['id'],
    type: ConsentType.values.firstWhere((e) => e.name == json['type']),
    granted: json['granted'],
    timestamp: DateTime.parse(json['timestamp']),
    version: json['version'],
    ipAddress: json['ip_address'],
    userAgent: json['user_agent'],
  );
}

/// Legal document
class LegalDocument {
  final LegalDocumentType type;
  final String title;
  final String content;
  final String version;
  final DateTime lastUpdated;
  final bool mandatory;

  LegalDocument({
    required this.type,
    required this.title,
    required this.content,
    required this.version,
    required this.lastUpdated,
    required this.mandatory,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
    type: LegalDocumentType.values.firstWhere((e) => e.name == json['type']),
    title: json['title'],
    content: json['content'],
    version: json['version'],
    lastUpdated: DateTime.parse(json['last_updated']),
    mandatory: json['mandatory'],
  );
}

/// Legal compliance manager
class LegalManager {
  static final LegalManager _instance = LegalManager._internal();
  factory LegalManager() => _instance;
  LegalManager._internal();

  static const String _consentKey = 'user_consents';
  static const String _agreementKey = 'user_agreement_accepted';
  static const String _documentVersionsKey = 'legal_document_versions';

  /// Check if user has accepted mandatory agreements
  Future<bool> hasMandatoryConsents() async {
    final prefs = await SharedPreferences.getInstance();
    final agreementAccepted = prefs.getBool(_agreementKey) ?? false;
    
    if (!agreementAccepted) return false;

    // Check for mandatory consents
    final consentsJson = prefs.getString(_consentKey);
    if (consentsJson == null) return false;

    final consents = (json.decode(consentsJson) as List)
        .map((e) => UserConsent.fromJson(e))
        .toList();

    // Check if mandatory consents are granted
    final mandatoryTypes = [ConsentType.mandatory];
    for (final type in mandatoryTypes) {
      final consent = consents.where((c) => c.type == type).lastOrNull;
      if (consent == null || !consent.granted) return false;
    }

    return true;
  }

  /// Record user consent
  Future<void> recordConsent(ConsentType type, bool granted, {String version = '1.0'}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing consents
    final consentsJson = prefs.getString(_consentKey);
    List<UserConsent> consents = [];
    
    if (consentsJson != null) {
      consents = (json.decode(consentsJson) as List)
          .map((e) => UserConsent.fromJson(e))
          .toList();
    }

    // Add new consent
    final newConsent = UserConsent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      granted: granted,
      timestamp: DateTime.now(),
      version: version,
    );

    consents.add(newConsent);

    // Save to local storage
    await prefs.setString(_consentKey, json.encode(consents.map((c) => c.toJson()).toList()));

    // Send to backend
    try {
      await ApiService().recordConsent(type.name, granted, version);
    } catch (e) {
      debugPrint('Failed to record consent on backend: $e');
    }
  }

  /// Accept user agreement
  Future<void> acceptUserAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_agreementKey, true);
    await recordConsent(ConsentType.mandatory, true);
  }

  /// Get user consents
  Future<List<UserConsent>> getUserConsents() async {
    final prefs = await SharedPreferences.getInstance();
    final consentsJson = prefs.getString(_consentKey);
    
    if (consentsJson == null) return [];
    
    return (json.decode(consentsJson) as List)
        .map((e) => UserConsent.fromJson(e))
        .toList();
  }

  /// Get legal document from backend
  Future<LegalDocument?> getLegalDocument(LegalDocumentType type) async {
    try {
      final response = await ApiService().getLegalDocument(type.name);
      if (response.success && response.data != null) {
        return LegalDocument.fromJson(response.data!);
      }
    } catch (e) {
      debugPrint('Failed to fetch legal document: $e');
    }
    return null;
  }

  /// Request data export (GDPR)
  Future<bool> requestDataExport() async {
    try {
      final response = await ApiService().requestDataExport();
      return response.success;
    } catch (e) {
      debugPrint('Failed to request data export: $e');
      return false;
    }
  }

  /// Request account deletion (GDPR/KVKK)
  Future<bool> requestAccountDeletion() async {
    try {
      final response = await ApiService().requestAccountDeletion();
      return response.success;
    } catch (e) {
      debugPrint('Failed to request account deletion: $e');
      return false;
    }
  }

  /// Check if consent is required for a specific type
  bool isConsentRequired(ConsentType type) {
    switch (type) {
      case ConsentType.mandatory:
        return true;
      case ConsentType.marketing:
      case ConsentType.analytics:
      case ConsentType.cookies:
      case ConsentType.location:
      case ConsentType.notifications:
      case ConsentType.dataSharing:
      case ConsentType.thirdParty:
        return false;
    }
  }

  /// Get consent description
  String getConsentDescription(ConsentType type) {
    switch (type) {
      case ConsentType.mandatory:
        return 'Hizmet sözleşmesi ve yasal yükümlülükler için zorunlu veri işleme';
      case ConsentType.marketing:
        return 'Pazarlama ve tanıtım amaçlı iletişim için veri işleme';
      case ConsentType.analytics:
        return 'Uygulama performansı ve kullanıcı deneyimi analizi';
      case ConsentType.cookies:
        return 'Çerezler ve benzer teknolojiler kullanımı';
      case ConsentType.location:
        return 'Konum bilgisi paylaşımı ve işlenmesi';
      case ConsentType.notifications:
        return 'Bildirim gönderimi ve kişiselleştirme';
      case ConsentType.dataSharing:
        return 'Üçüncü taraf hizmet sağlayıcıları ile veri paylaşımı';
      case ConsentType.thirdParty:
        return 'Üçüncü taraf entegrasyonları ve hizmetler';
    }
  }

  /// Clear all stored consents (for testing)
  Future<void> clearConsents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentKey);
    await prefs.remove(_agreementKey);
    await prefs.remove(_documentVersionsKey);
  }
}

/// Legal compliance constants
class LegalConstants {
  static const String companyName = 'Ustam Platform';
  static const String companyAddress = 'İstanbul, Türkiye';
  static const String contactEmail = 'destek@ustamplatform.com';
  static const String dpoEmail = 'kvkk@ustamplatform.com';
  
  static const Map<LegalDocumentType, String> documentTitles = {
    LegalDocumentType.userAgreement: 'Kullanıcı Sözleşmesi',
    LegalDocumentType.privacyPolicy: 'Gizlilik Politikası',
    LegalDocumentType.cookiePolicy: 'Çerez Politikası',
    LegalDocumentType.terms: 'Hizmet Şartları',
    LegalDocumentType.kvkk: 'KVKK Aydınlatma Metni',
    LegalDocumentType.communicationRules: 'İletişim Kuralları',
  };

  static const Map<GDPRRight, String> gdprRightDescriptions = {
    GDPRRight.access: 'Kişisel verilerinize erişim hakkı',
    GDPRRight.rectification: 'Kişisel verilerinizi düzeltme hakkı',
    GDPRRight.erasure: 'Kişisel verilerinizi silme hakkı (unutulma hakkı)',
    GDPRRight.portability: 'Veri taşınabilirliği hakkı',
    GDPRRight.restriction: 'İşlemeyi kısıtlama hakkı',
    GDPRRight.objection: 'İşlemeye itiraz etme hakkı',
    GDPRRight.withdraw: 'Rızayı geri çekme hakkı',
  };

  static const Duration consentValidityPeriod = Duration(days: 365);
  static const Duration dataRetentionPeriod = Duration(days: 2555); // 7 years
  static const int minimumAge = 18;
}

/// Extensions for legal utilities
extension ConsentTypeExtension on ConsentType {
  String get displayName {
    switch (this) {
      case ConsentType.mandatory:
        return 'Zorunlu';
      case ConsentType.marketing:
        return 'Pazarlama';
      case ConsentType.analytics:
        return 'Analitik';
      case ConsentType.cookies:
        return 'Çerezler';
      case ConsentType.location:
        return 'Konum';
      case ConsentType.notifications:
        return 'Bildirimler';
      case ConsentType.dataSharing:
        return 'Veri Paylaşımı';
      case ConsentType.thirdParty:
        return 'Üçüncü Taraf';
    }
  }

  IconData get icon {
    switch (this) {
      case ConsentType.mandatory:
        return Icons.gavel;
      case ConsentType.marketing:
        return Icons.campaign;
      case ConsentType.analytics:
        return Icons.analytics;
      case ConsentType.cookies:
        return Icons.cookie;
      case ConsentType.location:
        return Icons.location_on;
      case ConsentType.notifications:
        return Icons.notifications;
      case ConsentType.dataSharing:
        return Icons.share;
      case ConsentType.thirdParty:
        return Icons.integration_instructions;
    }
  }
}

extension LegalDocumentTypeExtension on LegalDocumentType {
  String get displayName => LegalConstants.documentTitles[this] ?? name;
  
  IconData get icon {
    switch (this) {
      case LegalDocumentType.userAgreement:
        return Icons.assignment;
      case LegalDocumentType.privacyPolicy:
        return Icons.privacy_tip;
      case LegalDocumentType.cookiePolicy:
        return Icons.cookie;
      case LegalDocumentType.terms:
        return Icons.description;
      case LegalDocumentType.kvkk:
        return Icons.security;
      case LegalDocumentType.communicationRules:
        return Icons.forum;
    }
  }
}

/// Legal validator utility
class LegalValidator {
  /// Validate age requirement
  static bool validateAge(DateTime? birthDate) {
    if (birthDate == null) return false;
    
    final age = DateTime.now().difference(birthDate).inDays / 365;
    return age >= LegalConstants.minimumAge;
  }

  /// Check if consent is still valid
  static bool isConsentValid(UserConsent consent) {
    final now = DateTime.now();
    final expiryDate = consent.timestamp.add(LegalConstants.consentValidityPeriod);
    return now.isBefore(expiryDate);
  }

  /// Validate email format for legal communications
  static bool validateEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Check if phone number is valid for Turkey
  static bool validatePhoneNumber(String phone) {
    // Turkish phone number format: +90 5XX XXX XX XX
    return RegExp(r'^\+90\s?5\d{2}\s?\d{3}\s?\d{2}\s?\d{2}$').hasMatch(phone);
  }
}

/// Utility class for legal operations
class LegalUtils {
  static final LegalManager _manager = LegalManager();

  /// Record user consent
  static Future<void> recordConsent(Map<String, bool> consents) async {
    for (final entry in consents.entries) {
      ConsentType? type;
      switch (entry.key) {
        case 'analytics':
          type = ConsentType.analytics;
          break;
        case 'marketing':
          type = ConsentType.marketing;
          break;
        case 'functional':
          type = ConsentType.mandatory;
          break;
        case 'performance':
          type = ConsentType.dataSharing;
          break;
      }
      
      if (type != null) {
        await _manager.recordConsent(type, entry.value);
      }
    }
  }

  /// Request data export
  static Future<void> requestDataExport() async {
    await _manager.requestDataExport();
  }

  /// Request account deletion
  static Future<void> requestAccountDeletion() async {
    await _manager.requestAccountDeletion();
  }

  /// Get legal document
  static Future<LegalDocument?> getLegalDocument(LegalDocumentType type) async {
    return await _manager.getLegalDocument(type);
  }

  /// Check if user has mandatory consents
  static Future<bool> hasMandatoryConsents() async {
    return await _manager.hasMandatoryConsents();
  }
}

/// Legal compliance mixin for screens
mixin LegalComplianceMixin<T extends StatefulWidget> on State<T> {
  /// Show user agreement modal if not accepted
  Future<bool> checkAndShowUserAgreement() async {
    final hasConsents = await LegalManager().hasMandatoryConsents();
    
    if (!hasConsents) {
      final result = await showUserAgreementModal();
      return result ?? false;
    }
    
    return true;
  }

  /// Show user agreement modal
  Future<bool?> showUserAgreementModal() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UserAgreementModal(),
    );
  }

  /// Show consent preferences
  Future<void> showConsentPreferences() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ConsentPreferencesSheet(),
    );
  }

  /// Show GDPR rights options
  Future<void> showGDPRRights() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const GDPRRightsSheet(),
    );
  }
}