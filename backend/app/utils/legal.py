"""
Legal compliance utilities for GDPR/KVKK and legal document management
"""

from datetime import datetime, timezone
from typing import Dict, List, Optional, Any
from enum import Enum
import json
from app import db

class ConsentType(Enum):
    """Types of user consent"""
    TERMS_OF_SERVICE = "terms_of_service"
    PRIVACY_POLICY = "privacy_policy"
    COOKIE_POLICY = "cookie_policy"
    MARKETING_COMMUNICATIONS = "marketing_communications"
    DATA_PROCESSING = "data_processing"
    LOCATION_TRACKING = "location_tracking"
    ANALYTICS_TRACKING = "analytics_tracking"

class DataProcessingPurpose(Enum):
    """Purposes for data processing under GDPR/KVKK"""
    SERVICE_PROVISION = "service_provision"
    USER_AUTHENTICATION = "user_authentication"
    COMMUNICATION = "communication"
    PAYMENT_PROCESSING = "payment_processing"
    ANALYTICS = "analytics"
    MARKETING = "marketing"
    LEGAL_COMPLIANCE = "legal_compliance"
    SECURITY = "security"

class UserConsent(db.Model):
    """Track user consent for legal compliance"""
    __tablename__ = 'user_consents'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    consent_type = db.Column(db.Enum(ConsentType), nullable=False)
    consent_given = db.Column(db.Boolean, nullable=False)
    consent_date = db.Column(db.DateTime, default=datetime.utcnow)
    consent_version = db.Column(db.String(20), nullable=False)  # Version of terms/policy
    ip_address = db.Column(db.String(45))  # For legal proof
    user_agent = db.Column(db.Text)  # Browser/device info
    withdrawal_date = db.Column(db.DateTime)  # When consent was withdrawn
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'consent_type': self.consent_type.value,
            'consent_given': self.consent_given,
            'consent_date': self.consent_date.isoformat() if self.consent_date else None,
            'consent_version': self.consent_version,
            'withdrawal_date': self.withdrawal_date.isoformat() if self.withdrawal_date else None
        }

class DataProcessingRecord(db.Model):
    """Record data processing activities for GDPR compliance"""
    __tablename__ = 'data_processing_records'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    purpose = db.Column(db.Enum(DataProcessingPurpose), nullable=False)
    data_types = db.Column(db.Text)  # JSON array of data types processed
    processing_date = db.Column(db.DateTime, default=datetime.utcnow)
    legal_basis = db.Column(db.String(100))  # Legal basis for processing
    retention_period = db.Column(db.Integer)  # Days to retain data
    third_parties = db.Column(db.Text)  # JSON array of third parties data shared with
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'purpose': self.purpose.value,
            'data_types': json.loads(self.data_types) if self.data_types else [],
            'processing_date': self.processing_date.isoformat() if self.processing_date else None,
            'legal_basis': self.legal_basis,
            'retention_period': self.retention_period,
            'third_parties': json.loads(self.third_parties) if self.third_parties else []
        }

class LegalDocumentManager:
    """Manage legal documents and compliance"""
    
    @staticmethod
    def get_terms_of_service() -> Dict[str, Any]:
        """Get current terms of service"""
        return {
            "version": "1.0",
            "effective_date": "2024-01-15",
            "language": "tr",
            "title": "Hizmet Şartları ve Kullanım Koşulları",
            "sections": [
                {
                    "title": "1. Genel Hükümler",
                    "content": [
                        "Bu Hizmet Şartları ('Şartlar'), UstamApp platformunu ('Platform') kullanımınızı düzenler.",
                        "Platformu kullanarak bu şartları kabul etmiş sayılırsınız.",
                        "Bu şartlar, Platform üzerinden sunulan tüm hizmetler için geçerlidir."
                    ]
                },
                {
                    "title": "2. Tanımlar",
                    "content": [
                        "Platform: UstamApp web sitesi ve mobil uygulaması",
                        "Kullanıcı: Platformu kullanan gerçek veya tüzel kişiler",
                        "Usta: Platform üzerinden hizmet sunan kişiler",
                        "Müşteri: Platform üzerinden hizmet talep eden kişiler",
                        "Hizmet: Platform üzerinden sunulan tüm hizmetler"
                    ]
                },
                {
                    "title": "3. Kullanıcı Hesabı",
                    "content": [
                        "Platform kullanımı için hesap oluşturmanız gerekmektedir.",
                        "Hesap bilgilerinizin doğruluğundan ve güncelliğinden sorumlusunuz.",
                        "Hesap güvenliğinizi sağlamak için güçlü şifre kullanmalısınız.",
                        "Hesabınızın yetkisiz kullanımını derhal bildirmelisiniz."
                    ]
                },
                {
                    "title": "4. Hizmet Kullanımı",
                    "content": [
                        "Platform sadece yasal amaçlarla kullanılabilir.",
                        "Yanıltıcı, zararlı veya yasa dışı içerik paylaşamazsınız.",
                        "Diğer kullanıcıların haklarına saygı göstermelisiniz.",
                        "Platform kurallarına uymayan davranışlar hesap kapatılmasına yol açabilir."
                    ]
                },
                {
                    "title": "5. Ödeme ve Faturalandırma",
                    "content": [
                        "Hizmet bedelleri Platform üzerinden güvenli şekilde ödenir.",
                        "Ödeme işlemleri üçüncü taraf güvenli ödeme sağlayıcıları ile yapılır.",
                        "İade koşulları hizmet türüne göre değişiklik gösterebilir.",
                        "Fatura ve makbuzlar elektronik ortamda saklanır."
                    ]
                },
                {
                    "title": "6. Sorumluluk Sınırlaması",
                    "content": [
                        "Platform, kullanıcılar arasındaki hizmet kalitesinden sorumlu değildir.",
                        "Ustalar bağımsız çalışan profesyonellerdir.",
                        "Platform, teknik arızalar için sınırlı sorumluluk kabul eder.",
                        "Kullanıcılar kendi eylemlerinden sorumludur."
                    ]
                },
                {
                    "title": "7. Fikri Mülkiyet",
                    "content": [
                        "Platform içeriği telif hakkı ile korunmaktadır.",
                        "Kullanıcı içerikleri için gerekli izinlere sahip olmalısınız.",
                        "Platform logosu ve markası koruma altındadır.",
                        "İzinsiz kullanım yasal işlem gerektirir."
                    ]
                },
                {
                    "title": "8. Değişiklikler",
                    "content": [
                        "Bu şartlar zaman zaman güncellenebilir.",
                        "Önemli değişiklikler kullanıcılara bildirilir.",
                        "Güncel şartlar Platform üzerinde yayınlanır.",
                        "Değişikliklerden sonra Platform kullanımı kabul anlamına gelir."
                    ]
                },
                {
                    "title": "9. Hesap Kapatma",
                    "content": [
                        "Hesabınızı istediğiniz zaman kapatabilirsiniz.",
                        "Hesap kapatma işlemi geri alınamaz.",
                        "Kişisel verileriniz KVKK uyarınca silinir.",
                        "Ödeme yükümlülükleri devam eder."
                    ]
                },
                {
                    "title": "10. Uygulanacak Hukuk",
                    "content": [
                        "Bu şartlar Türkiye Cumhuriyeti hukukuna tabidir.",
                        "Uyuşmazlıklar İstanbul mahkemelerinde çözülür.",
                        "KVKK ve diğer ilgili mevzuat hükümleri geçerlidir."
                    ]
                }
            ]
        }
    
    @staticmethod
    def get_privacy_policy() -> Dict[str, Any]:
        """Get current privacy policy"""
        return {
            "version": "1.0",
            "effective_date": "2024-01-15",
            "language": "tr",
            "title": "Gizlilik Politikası ve Kişisel Verilerin Korunması",
            "sections": [
                {
                    "title": "1. Giriş",
                    "content": [
                        "UstamApp olarak kişisel verilerinizin korunmasını önemsiyoruz.",
                        "Bu politika, kişisel verilerinizin nasıl toplandığını, kullanıldığını ve korunduğunu açıklar.",
                        "6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında hazırlanmıştır."
                    ]
                },
                {
                    "title": "2. Veri Sorumlusu",
                    "content": [
                        "Veri Sorumlusu: UstamApp",
                        "Adres: [Şirket Adresi]",
                        "E-posta: privacy@ustamapp.com",
                        "Telefon: 0850 123 45 67"
                    ]
                },
                {
                    "title": "3. Toplanan Kişisel Veriler",
                    "content": [
                        "Kimlik Bilgileri: Ad, soyad, doğum tarihi",
                        "İletişim Bilgileri: E-posta, telefon, adres",
                        "Hesap Bilgileri: Kullanıcı adı, şifre (şifreli)",
                        "Hizmet Bilgileri: Uzmanlık alanları, deneyim, portfolio",
                        "Konum Bilgileri: Şehir, ilçe, GPS koordinatları",
                        "Ödeme Bilgileri: Kart bilgileri (güvenli saklama)",
                        "Kullanım Verileri: Platform kullanım istatistikleri"
                    ]
                },
                {
                    "title": "4. Veri Toplama Yöntemleri",
                    "content": [
                        "Hesap oluşturma sırasında sağladığınız bilgiler",
                        "Profil güncelleme ve hizmet kullanımı",
                        "Çerezler ve benzer teknolojiler",
                        "Otomatik log kayıtları",
                        "Müşteri hizmetleri iletişimi"
                    ]
                },
                {
                    "title": "5. Veri İşleme Amaçları",
                    "content": [
                        "Hizmet sunumu ve platform işletimi",
                        "Kullanıcı kimlik doğrulama ve güvenlik",
                        "Ödeme işlemlerinin gerçekleştirilmesi",
                        "Müşteri destek hizmetleri",
                        "Yasal yükümlülüklerin yerine getirilmesi",
                        "Platform iyileştirme ve analitik",
                        "Pazarlama iletişimi (onay ile)"
                    ]
                },
                {
                    "title": "6. Veri Paylaşımı",
                    "content": [
                        "Kişisel verileriniz üçüncü taraflarla paylaşılmaz.",
                        "Hizmet sağlayıcıları ile sınırlı paylaşım (ödeme, SMS, e-posta)",
                        "Yasal zorunluluklar halinde yetkili makamlarla",
                        "Açık rızanız ile belirttiğiniz durumlar",
                        "Anonim ve toplu veriler araştırma amaçlı paylaşılabilir"
                    ]
                },
                {
                    "title": "7. Veri Güvenliği",
                    "content": [
                        "Endüstri standardı şifreleme teknolojileri",
                        "Güvenli sunucu altyapısı ve erişim kontrolü",
                        "Düzenli güvenlik denetimleri",
                        "Personel eğitimi ve gizlilik sözleşmeleri",
                        "Veri ihlali durumunda derhal bildirim"
                    ]
                },
                {
                    "title": "8. KVKK Hakları",
                    "content": [
                        "Kişisel verilerinizin işlenip işlenmediğini öğrenme",
                        "İşlenen kişisel verileriniz hakkında bilgi talep etme",
                        "İşleme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme",
                        "Yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri bilme",
                        "Kişisel verilerin eksik veya yanlış işlenmiş olması halinde bunların düzeltilmesini isteme",
                        "Kişisel verilerin silinmesini veya yok edilmesini isteme",
                        "Düzeltme, silme ve yok edilme işlemlerinin paylaşıldığı üçüncü kişilere bildirilmesini isteme",
                        "İşlenen verilerin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle aleyhinize bir sonucun ortaya çıkmasına itiraz etme",
                        "Kişisel verilerin kanuna aykırı olarak işlenmesi sebebiyle zarara uğramanız halinde zararın giderilmesini talep etme"
                    ]
                },
                {
                    "title": "9. Çerezler",
                    "content": [
                        "Platform deneyimini iyileştirmek için çerezler kullanılır",
                        "Zorunlu çerezler: Platform işleyişi için gerekli",
                        "Analitik çerezler: Kullanım istatistikleri için",
                        "Pazarlama çerezleri: Kişiselleştirilmiş içerik için",
                        "Çerez tercihlerinizi ayarlayabilirsiniz"
                    ]
                },
                {
                    "title": "10. İletişim",
                    "content": [
                        "Gizlilik ile ilgili sorularınız için: privacy@ustamapp.com",
                        "Veri işleme talepleriniz için başvuru formu kullanın",
                        "30 gün içinde yanıtlanacaktır",
                        "Şikayet için Kişisel Verileri Koruma Kurulu'na başvurabilirsiniz"
                    ]
                }
            ]
        }
    
    @staticmethod
    def get_cookie_policy() -> Dict[str, Any]:
        """Get current cookie policy"""
        return {
            "version": "1.0",
            "effective_date": "2024-01-15",
            "language": "tr",
            "title": "Çerez Politikası",
            "sections": [
                {
                    "title": "1. Çerez Nedir?",
                    "content": [
                        "Çerezler, web sitelerinin bilgisayarınızda sakladığı küçük metin dosyalarıdır.",
                        "Platform deneyiminizi iyileştirmek ve kişiselleştirmek için kullanılır.",
                        "Çerezler kişisel olarak sizi tanımlamaz, sadece tarayıcınızı tanır."
                    ]
                },
                {
                    "title": "2. Çerez Türleri",
                    "content": [
                        "Zorunlu Çerezler: Platform işleyişi için gerekli",
                        "Performans Çerezleri: Platform performansını ölçer",
                        "İşlevsellik Çerezleri: Tercihlerinizi hatırlar",
                        "Hedefleme Çerezleri: İlginizi çekebilecek içerik sunar"
                    ]
                },
                {
                    "title": "3. Kullandığımız Çerezler",
                    "content": [
                        "Oturum çerezleri: Giriş durumunuzu korur",
                        "Tercih çerezleri: Dil ve tema seçimlerinizi saklar",
                        "Analitik çerezler: Platform kullanım istatistikleri",
                        "Güvenlik çerezleri: Güvenlik önlemlerini destekler"
                    ]
                },
                {
                    "title": "4. Çerez Yönetimi",
                    "content": [
                        "Tarayıcı ayarlarından çerezleri yönetebilirsiniz",
                        "Platform ayarlarından çerez tercihlerinizi değiştirebilirsiniz",
                        "Zorunlu çerezleri devre dışı bırakmanız Platform kullanımını etkileyebilir",
                        "Çerez tercihleriniz cihazınızda saklanır"
                    ]
                }
            ]
        }
    
    @staticmethod
    def get_user_agreement() -> Dict[str, Any]:
        """Get user agreement template"""
        return {
            "version": "1.0",
            "effective_date": "2024-01-15",
            "language": "tr",
            "title": "Kullanıcı Sözleşmesi",
            "mandatory": True,
            "sections": [
                {
                    "title": "Kullanıcı Sözleşmesi",
                    "content": [
                        "Bu sözleşme, UstamApp platformunu kullanımınızı düzenler.",
                        "",
                        "KABUL ETTİKLERİM:",
                        "",
                        "✓ Platform kurallarına uymayı kabul ediyorum",
                        "✓ Doğru ve güncel bilgiler sağlayacağımı taahhüt ediyorum", 
                        "✓ Diğer kullanıcılara saygılı davranacağımı kabul ediyorum",
                        "✓ Hizmet şartlarını okuduğumu ve anladığımı onaylıyorum",
                        "✓ Gizlilik politikasını kabul ediyorum",
                        "✓ Yasal sorumluluklarımı bildiğimi kabul ediyorum",
                        "",
                        "KVKK KAPSAMINDA:",
                        "",
                        "✓ Kişisel verilerimin işlenmesine onay veriyorum",
                        "✓ Hizmet sunumu için gerekli veri paylaşımını kabul ediyorum",
                        "✓ İletişim bilgilerimin kullanılmasına izin veriyorum",
                        "✓ Platform iyileştirme için analitik veri kullanımını onaylıyorum",
                        "",
                        "HİZMET KOŞULLARI:",
                        "",
                        "✓ Hizmet kalitesinden ustalar sorumludur",
                        "✓ Ödeme işlemleri güvenli sistemler ile yapılır",
                        "✓ Anlaşmazlık durumunda Platform arabuluculuk yapar",
                        "✓ Garanti koşulları hizmet türüne göre değişir",
                        "",
                        "Bu sözleşmeyi kabul ederek yukarıdaki tüm maddeleri okuduğunuzu, anladığınızı ve kabul ettiğinizi beyan edersiniz."
                    ]
                }
            ]
        }

class ConsentManager:
    """Manage user consent and GDPR compliance"""
    
    @staticmethod
    def record_consent(user_id: int, consent_type: ConsentType, consent_given: bool, 
                      version: str, ip_address: str = None, user_agent: str = None) -> UserConsent:
        """Record user consent"""
        # Check if consent already exists
        existing_consent = UserConsent.query.filter_by(
            user_id=user_id,
            consent_type=consent_type
        ).first()
        
        if existing_consent:
            # Update existing consent
            existing_consent.consent_given = consent_given
            existing_consent.consent_date = datetime.utcnow()
            existing_consent.consent_version = version
            existing_consent.ip_address = ip_address
            existing_consent.user_agent = user_agent
            
            if not consent_given:
                existing_consent.withdrawal_date = datetime.utcnow()
            else:
                existing_consent.withdrawal_date = None
                
            db.session.commit()
            return existing_consent
        else:
            # Create new consent record
            consent = UserConsent(
                user_id=user_id,
                consent_type=consent_type,
                consent_given=consent_given,
                consent_version=version,
                ip_address=ip_address,
                user_agent=user_agent
            )
            
            db.session.add(consent)
            db.session.commit()
            return consent
    
    @staticmethod
    def get_user_consents(user_id: int) -> List[UserConsent]:
        """Get all consents for a user"""
        return UserConsent.query.filter_by(user_id=user_id).all()
    
    @staticmethod
    def has_consent(user_id: int, consent_type: ConsentType) -> bool:
        """Check if user has given specific consent"""
        consent = UserConsent.query.filter_by(
            user_id=user_id,
            consent_type=consent_type,
            consent_given=True
        ).first()
        
        return consent is not None and consent.withdrawal_date is None
    
    @staticmethod
    def withdraw_consent(user_id: int, consent_type: ConsentType) -> bool:
        """Withdraw user consent"""
        consent = UserConsent.query.filter_by(
            user_id=user_id,
            consent_type=consent_type,
            consent_given=True
        ).first()
        
        if consent:
            consent.consent_given = False
            consent.withdrawal_date = datetime.utcnow()
            db.session.commit()
            return True
        
        return False

class DataProcessor:
    """Handle data processing requests under GDPR/KVKK"""
    
    @staticmethod
    def record_data_processing(user_id: int, purpose: DataProcessingPurpose, 
                             data_types: List[str], legal_basis: str,
                             retention_period: int = None, third_parties: List[str] = None):
        """Record data processing activity"""
        record = DataProcessingRecord(
            user_id=user_id,
            purpose=purpose,
            data_types=json.dumps(data_types),
            legal_basis=legal_basis,
            retention_period=retention_period,
            third_parties=json.dumps(third_parties or [])
        )
        
        db.session.add(record)
        db.session.commit()
        return record
    
    @staticmethod
    def get_user_data_summary(user_id: int) -> Dict[str, Any]:
        """Get summary of user's data processing"""
        from app.models.user import User
        from app.models.craftsman import Craftsman
        from app.models.customer import Customer
        
        user = User.query.get(user_id)
        if not user:
            return None
        
        # Get processing records
        processing_records = DataProcessingRecord.query.filter_by(user_id=user_id).all()
        
        # Get consent records
        consent_records = UserConsent.query.filter_by(user_id=user_id).all()
        
        # Compile data summary
        data_summary = {
            "user_id": user_id,
            "data_categories": {
                "identity": ["first_name", "last_name", "email", "phone"],
                "account": ["password_hash", "user_type", "created_at"],
                "profile": [],
                "usage": ["login_history", "search_history", "message_history"],
                "location": [],
                "payment": []
            },
            "processing_purposes": [record.purpose.value for record in processing_records],
            "consent_status": {
                consent.consent_type.value: {
                    "given": consent.consent_given,
                    "date": consent.consent_date.isoformat() if consent.consent_date else None,
                    "version": consent.consent_version
                }
                for consent in consent_records
            },
            "retention_periods": {
                "account_data": "Account lifetime + 1 year",
                "communication_data": "2 years",
                "payment_data": "10 years (legal requirement)",
                "analytics_data": "2 years (anonymized after 6 months)"
            }
        }
        
        # Add profile-specific data
        user_type = getattr(user.user_type, 'value', user.user_type)

        if user_type == 'craftsman' and user.craftsman:
            data_summary["data_categories"]["profile"].extend([
                "business_name", "description", "specialties", "experience_years",
                "hourly_rate", "city", "district", "portfolio_images"
            ])
            if user.craftsman.current_latitude:
                data_summary["data_categories"]["location"].append("current_coordinates")

        elif user_type == 'customer' and user.customer:
            data_summary["data_categories"]["profile"].extend([
                "preferred_categories", "budget_range", "location_preferences"
            ])
        
        return data_summary
    
    @staticmethod
    def export_user_data(user_id: int) -> Dict[str, Any]:
        """Export all user data for GDPR compliance"""
        from app.models.user import User
        from app.models.craftsman import Craftsman
        from app.models.customer import Customer
        from app.models.quote import Quote
        from app.models.message import Message
        
        user = User.query.get(user_id)
        if not user:
            return None
        
        export_data = {
            "export_date": datetime.utcnow().isoformat(),
            "user_data": user.to_dict(),
            "consents": [consent.to_dict() for consent in ConsentManager.get_user_consents(user_id)],
            "processing_records": [record.to_dict() for record in DataProcessingRecord.query.filter_by(user_id=user_id).all()]
        }
        
        # Add profile data
        if user.craftsman:
            export_data["craftsman_profile"] = user.craftsman.to_dict(include_user=False)
        
        if user.customer:
            export_data["customer_profile"] = user.customer.to_dict(include_user=False)
        
        # Add quotes (anonymize other party data)
        quotes = Quote.query.filter(
            (Quote.customer_id == user_id) | (Quote.craftsman_id == user_id)
        ).all()
        
        export_data["quotes"] = []
        for quote in quotes:
            quote_data = quote.to_dict()
            # Anonymize other party if not the requesting user
            if quote.customer_id != user_id:
                quote_data["customer"] = {"id": "anonymized"}
            if quote.craftsman_id != user_id:
                quote_data["craftsman"] = {"id": "anonymized"}
            export_data["quotes"].append(quote_data)
        
        # Add messages (anonymize other party)
        messages = Message.query.filter(
            (Message.sender_id == user_id) | (Message.receiver_id == user_id)
        ).all()
        
        export_data["messages"] = []
        for message in messages:
            message_data = message.to_dict()
            # Anonymize other party
            if message.sender_id != user_id:
                message_data["sender"] = {"id": "anonymized"}
            if message.receiver_id != user_id:
                message_data["receiver"] = {"id": "anonymized"}
            export_data["messages"].append(message_data)
        
        return export_data
    
    @staticmethod
    def delete_user_data(user_id: int, verification_code: str = None) -> Dict[str, Any]:
        """Permanently delete user data for GDPR compliance"""
        from app.models.user import User
        
        user = User.query.get(user_id)
        if not user:
            return {"success": False, "message": "Kullanıcı bulunamadı"}
        
        try:
            # Record data deletion
            DataProcessor.record_data_processing(
                user_id=user_id,
                purpose=DataProcessingPurpose.LEGAL_COMPLIANCE,
                data_types=["all_user_data"],
                legal_basis="KVKK Article 7 - Right to deletion",
                retention_period=0
            )
            
            # Delete user and all related data (cascade delete should handle this)
            db.session.delete(user)
            db.session.commit()
            
            return {
                "success": True,
                "message": "Kullanıcı verisi başarıyla silindi",
                "deletion_date": datetime.utcnow().isoformat(),
                "user_id": user_id
            }
            
        except Exception as e:
            db.session.rollback()
            return {
                "success": False,
                "message": f"Veri silme hatası: {str(e)}"
            }

class LegalValidator:
    """Validate legal compliance requirements"""
    
    @staticmethod
    def validate_age_requirement(birth_date: str) -> Dict[str, Any]:
        """Validate user meets age requirements"""
        try:
            birth = datetime.fromisoformat(birth_date.replace('Z', '+00:00'))
            today = datetime.now(timezone.utc)
            age = (today - birth).days // 365
            
            is_valid = age >= 18
            
            return {
                "valid": is_valid,
                "age": age,
                "requirement": 18,
                "message": "Kullanıcı 18 yaşından büyük olmalıdır" if not is_valid else "Yaş gereksinimi karşılanıyor"
            }
            
        except Exception as e:
            return {
                "valid": False,
                "message": f"Yaş doğrulama hatası: {str(e)}"
            }
    
    @staticmethod
    def validate_required_consents(user_id: int) -> Dict[str, Any]:
        """Validate user has given all required consents"""
        required_consents = [
            ConsentType.TERMS_OF_SERVICE,
            ConsentType.PRIVACY_POLICY,
            ConsentType.DATA_PROCESSING
        ]
        
        missing_consents = []
        
        for consent_type in required_consents:
            if not ConsentManager.has_consent(user_id, consent_type):
                missing_consents.append(consent_type.value)
        
        return {
            "valid": len(missing_consents) == 0,
            "missing_consents": missing_consents,
            "message": "Tüm gerekli onaylar alındı" if len(missing_consents) == 0 else f"Eksik onaylar: {', '.join(missing_consents)}"
        }

# Legal compliance constants
LEGAL_DOCUMENT_VERSIONS = {
    "terms_of_service": "1.0",
    "privacy_policy": "1.0", 
    "cookie_policy": "1.0",
    "user_agreement": "1.0"
}

DATA_RETENTION_PERIODS = {
    "account_data": 365,  # 1 year after account deletion
    "communication_data": 730,  # 2 years
    "payment_data": 3650,  # 10 years (legal requirement)
    "analytics_data": 730,  # 2 years (anonymized after 6 months)
    "log_data": 90,  # 3 months
    "session_data": 30  # 30 days
}

GDPR_RIGHTS = [
    "right_to_information",
    "right_of_access", 
    "right_to_rectification",
    "right_to_erasure",
    "right_to_restrict_processing",
    "right_to_data_portability",
    "right_to_object",
    "rights_related_to_automated_decision_making"
]