from flask import Blueprint, request, jsonify, send_file
from flask_jwt_extended import get_jwt_identity
from app.utils.legal import (
    LegalDocumentManager, 
    ConsentManager, 
    DataProcessor,
    LegalValidator,
    ConsentType,
    DataProcessingPurpose,
    LEGAL_DOCUMENT_VERSIONS
)
from app.utils.security import rate_limit, require_auth
import io
import json
from datetime import datetime

legal_bp = Blueprint('legal', __name__)

@legal_bp.route('/documents/terms-of-service', methods=['GET'])
@rate_limit(max_requests=30)
def get_terms_of_service():
    """Get current terms of service"""
    try:
        # Read from file
        import os
        file_path = os.path.join(os.path.dirname(__file__), '../../legal_documents/kullanim_kosullari.md')
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return jsonify({
            'success': True,
            'data': {
                'title': 'Kullanım Koşulları',
                'content': content,
                'version': '1.0',
                'last_updated': '2025-01-01',
                'type': 'terms_of_service'
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Terms retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/documents/user-agreement', methods=['GET'])
@rate_limit(max_requests=30)
def get_user_agreement():
    """Get user agreement (bireysel hesap sözleşmesi)"""
    try:
        import os
        file_path = os.path.join(os.path.dirname(__file__), '../../legal_documents/bireysel_hesap_sozlesmesi.md')
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return jsonify({
            'success': True,
            'data': {
                'title': 'Bireysel Hesap Sözleşmesi',
                'content': content,
                'version': '1.0',
                'last_updated': '2025-01-01',
                'type': 'user_agreement'
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'User agreement retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/documents/cookie-policy', methods=['GET'])
@rate_limit(max_requests=30)
def get_cookie_policy():
    """Get cookie policy"""
    try:
        import os
        file_path = os.path.join(os.path.dirname(__file__), '../../legal_documents/cerez_politikasi.md')
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return jsonify({
            'success': True,
            'data': {
                'title': 'Çerez Politikası',
                'content': content,
                'version': '1.0',
                'last_updated': '2025-01-01',
                'type': 'cookie_policy'
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Cookie policy retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/documents/cookie-preferences', methods=['GET'])
@rate_limit(max_requests=30)
def get_cookie_preferences():
    """Get cookie preferences summary"""
    try:
        import os
        file_path = os.path.join(os.path.dirname(__file__), '../../legal_documents/cerez_tercihleri_ozet.md')
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return jsonify({
            'success': True,
            'data': {
                'title': 'Çerez Tercihleri',
                'content': content,
                'version': '1.0',
                'last_updated': '2025-01-01',
                'type': 'cookie_preferences'
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Cookie preferences retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/documents/privacy-policy', methods=['GET'])
@rate_limit(max_requests=30)
def get_privacy_policy():
    """Get current privacy policy"""
    try:
        import os
        file_path = os.path.join(os.path.dirname(__file__), '../../legal_documents/gizlilik_politikasi.md')
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return jsonify({
            'success': True,
            'data': {
                'title': 'Gizlilik Politikası',
                'content': content,
                'version': '1.0',
                'last_updated': '2025-01-01',
                'type': 'privacy_policy'
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Privacy policy retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/documents/corporate-agreement', methods=['GET'])
@rate_limit(max_requests=30)
def get_corporate_agreement():
    """Get corporate account agreement"""
    try:
        import os
        file_path = os.path.join(os.path.dirname(__file__), '../../legal_documents/kurumsal_hesap_sozlesmesi.md')
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return jsonify({
            'success': True,
            'data': {
                'title': 'Kurumsal Hesap Sözleşmesi',
                'content': content,
                'version': '1.0',
                'last_updated': '2025-01-01',
                'type': 'corporate_agreement'
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Corporate agreement retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/documents/listing-rules', methods=['GET'])
@rate_limit(max_requests=30)
def get_listing_rules():
    """Get listing rules and prohibited content"""
    try:
        import os
        file_path = os.path.join(os.path.dirname(__file__), '../../legal_documents/ilan_verme_kurallari.md')
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return jsonify({
            'success': True,
            'data': {
                'title': 'İlan Verme Kuralları ve Yasaklı İlanlar',
                'content': content,
                'version': '1.0',
                'last_updated': '2025-01-01',
                'type': 'listing_rules'
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Listing rules retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/documents/kvkk-summary', methods=['GET'])
@rate_limit(max_requests=30)
def get_kvkk_summary():
    """Get KVKK summary and data protection info"""
    try:
        import os
        file_path = os.path.join(os.path.dirname(__file__), '../../legal_documents/kvkk_aydinlatma_metni.md')
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return jsonify({
            'success': True,
            'data': {
                'title': 'KVKK Aydınlatma Metni',
                'content': content,
                'version': '1.0',
                'last_updated': '2025-01-01',
                'type': 'kvkk_summary'
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'KVKK summary retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/documents/all', methods=['GET'])
@rate_limit(max_requests=10)
def get_all_legal_documents():
    """Get all legal documents list"""
    try:
        documents = [
            {
                'id': 'terms_of_service',
                'title': 'Kullanım Koşulları',
                'description': 'Portal kullanım şartları ve kuralları',
                'endpoint': '/api/legal/documents/terms-of-service',
                'required_for': ['registration', 'usage'],
                'version': '1.0',
                'last_updated': '2025-01-01'
            },
            {
                'id': 'user_agreement',
                'title': 'Bireysel Hesap Sözleşmesi',
                'description': 'Bireysel kullanıcılar için hesap sözleşmesi',
                'endpoint': '/api/legal/documents/user-agreement',
                'required_for': ['individual_registration'],
                'version': '1.0',
                'last_updated': '2025-01-01'
            },
            {
                'id': 'corporate_agreement',
                'title': 'Kurumsal Hesap Sözleşmesi',
                'description': 'Hizmet veren ustalar için kurumsal sözleşme',
                'endpoint': '/api/legal/documents/corporate-agreement',
                'required_for': ['craftsman_registration'],
                'version': '1.0',
                'last_updated': '2025-01-01'
            },
            {
                'id': 'privacy_policy',
                'title': 'Gizlilik Politikası',
                'description': 'Kişisel verilerin işlenmesi ve gizlilik koşulları',
                'endpoint': '/api/legal/documents/privacy-policy',
                'required_for': ['registration', 'data_processing'],
                'version': '1.0',
                'last_updated': '2025-01-01'
            },
            {
                'id': 'cookie_policy',
                'title': 'Çerez Politikası',
                'description': 'Çerez kullanımı ve veri işleme detayları',
                'endpoint': '/api/legal/documents/cookie-policy',
                'required_for': ['website_usage', 'app_usage'],
                'version': '1.0',
                'last_updated': '2025-01-01'
            },
            {
                'id': 'cookie_preferences',
                'title': 'Çerez Tercihleri',
                'description': 'Çerez tercih yönetimi ve özet bilgi',
                'endpoint': '/api/legal/documents/cookie-preferences',
                'required_for': ['cookie_management'],
                'version': '1.0',
                'last_updated': '2025-01-01'
            },
            {
                'id': 'listing_rules',
                'title': 'İlan Verme Kuralları',
                'description': 'İlan yayınlama kuralları ve yasaklı içerikler',
                'endpoint': '/api/legal/documents/listing-rules',
                'required_for': ['job_posting', 'service_listing'],
                'version': '1.0',
                'last_updated': '2025-01-01'
            },
            {
                'id': 'kvkk_summary',
                'title': 'KVKK Aydınlatma Özeti',
                'description': 'Kişisel veri işleme özet bilgilendirmesi',
                'endpoint': '/api/legal/documents/kvkk-summary',
                'required_for': ['data_subject_rights'],
                'version': '1.0',
                'last_updated': '2025-01-01'
            }
        ]
        
        return jsonify({
            'success': True,
            'data': {
                'documents': documents,
                'total_count': len(documents),
                'compliance_framework': 'KVKK (Turkish GDPR)',
                'last_updated': '2025-01-01'
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to retrieve documents list: {str(e)}'
        }), 500

@legal_bp.route('/documents/cookie-policy', methods=['GET'])
@rate_limit(max_requests=30)
def get_cookie_policy():
    """Get current cookie policy"""
    try:
        policy = LegalDocumentManager.get_cookie_policy()
        return jsonify({
            'success': True,
            'data': policy
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Cookie policy retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/documents/user-agreement', methods=['GET'])
@rate_limit(max_requests=30)
def get_user_agreement():
    """Get user agreement template"""
    try:
        agreement = LegalDocumentManager.get_user_agreement()
        return jsonify({
            'success': True,
            'data': agreement
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'User agreement retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/consent/record', methods=['POST'])
@rate_limit(max_requests=60)
@require_auth
def record_consent():
    """Record user consent"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        consent_type_str = data.get('consent_type')
        consent_given = data.get('consent_given', False)
        version = data.get('version', '1.0')
        
        if not consent_type_str:
            return jsonify({
                'success': False,
                'message': 'Consent type is required'
            }), 400
        
        try:
            consent_type = ConsentType(consent_type_str)
        except ValueError:
            return jsonify({
                'success': False,
                'message': 'Invalid consent type'
            }), 400
        
        # Get client info for legal record
        ip_address = request.environ.get('REMOTE_ADDR')
        user_agent = request.headers.get('User-Agent')
        
        consent = ConsentManager.record_consent(
            user_id=user_id,
            consent_type=consent_type,
            consent_given=consent_given,
            version=version,
            ip_address=ip_address,
            user_agent=user_agent
        )
        
        return jsonify({
            'success': True,
            'data': consent.to_dict(),
            'message': 'Consent recorded successfully'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Consent recording failed: {str(e)}'
        }), 500

@legal_bp.route('/consent/status', methods=['GET'])
@rate_limit(max_requests=60)
@require_auth
def get_consent_status():
    """Get user's consent status"""
    try:
        user_id = get_jwt_identity()
        consents = ConsentManager.get_user_consents(user_id)
        
        consent_status = {}
        for consent in consents:
            consent_status[consent.consent_type.value] = {
                'given': consent.consent_given,
                'date': consent.consent_date.isoformat() if consent.consent_date else None,
                'version': consent.consent_version,
                'withdrawn': consent.withdrawal_date is not None
            }
        
        # Check required consents
        validation = LegalValidator.validate_required_consents(user_id)
        
        return jsonify({
            'success': True,
            'data': {
                'consents': consent_status,
                'validation': validation,
                'required_consents': [ct.value for ct in [
                    ConsentType.TERMS_OF_SERVICE,
                    ConsentType.PRIVACY_POLICY,
                    ConsentType.DATA_PROCESSING
                ]]
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Consent status retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/consent/withdraw', methods=['POST'])
@rate_limit(max_requests=30)
@require_auth
def withdraw_consent():
    """Withdraw user consent"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        consent_type_str = data.get('consent_type')
        
        if not consent_type_str:
            return jsonify({
                'success': False,
                'message': 'Consent type is required'
            }), 400
        
        try:
            consent_type = ConsentType(consent_type_str)
        except ValueError:
            return jsonify({
                'success': False,
                'message': 'Invalid consent type'
            }), 400
        
        success = ConsentManager.withdraw_consent(user_id, consent_type)
        
        if success:
            return jsonify({
                'success': True,
                'message': 'Consent withdrawn successfully'
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Consent not found or already withdrawn'
            }), 404
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Consent withdrawal failed: {str(e)}'
        }), 500

@legal_bp.route('/data/summary', methods=['GET'])
@rate_limit(max_requests=30)
@require_auth
def get_data_summary():
    """Get user's data processing summary"""
    try:
        user_id = get_jwt_identity()
        summary = DataProcessor.get_user_data_summary(user_id)
        
        if not summary:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        return jsonify({
            'success': True,
            'data': summary
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Data summary retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/data/export', methods=['POST'])
@rate_limit(max_requests=5)  # Limited due to resource intensity
@require_auth
def export_user_data():
    """Export all user data (GDPR Article 20)"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Optional verification for security
        verification_code = data.get('verification_code')
        
        export_data = DataProcessor.export_user_data(user_id)
        
        if not export_data:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        # Create downloadable file
        json_data = json.dumps(export_data, indent=2, ensure_ascii=False)
        
        # Create in-memory file
        file_buffer = io.BytesIO()
        file_buffer.write(json_data.encode('utf-8'))
        file_buffer.seek(0)
        
        filename = f"ustamapp_data_export_{user_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        return send_file(
            file_buffer,
            as_attachment=True,
            download_name=filename,
            mimetype='application/json'
        )
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Data export failed: {str(e)}'
        }), 500

@legal_bp.route('/data/delete-request', methods=['POST'])
@rate_limit(max_requests=3)  # Very limited for security
@require_auth
def request_data_deletion():
    """Request permanent data deletion (GDPR Article 17)"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        confirmation = data.get('confirmation', '').lower()
        verification_code = data.get('verification_code')
        
        if confirmation != 'hesabimi sil':
            return jsonify({
                'success': False,
                'message': 'Confirmation text must be exactly: "hesabimi sil"'
            }), 400
        
        # TODO: In production, send verification email/SMS before actual deletion
        # For now, proceed with deletion
        
        result = DataProcessor.delete_user_data(user_id, verification_code)
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Data deletion request failed: {str(e)}'
        }), 500

@legal_bp.route('/compliance/validate-user', methods=['GET'])
@rate_limit(max_requests=30)
@require_auth
def validate_user_compliance():
    """Validate user's legal compliance status"""
    try:
        user_id = get_jwt_identity()
        
        # Check required consents
        consent_validation = LegalValidator.validate_required_consents(user_id)
        
        # Get current consent status
        consents = ConsentManager.get_user_consents(user_id)
        
        return jsonify({
            'success': True,
            'data': {
                'compliance_status': consent_validation,
                'current_consents': [consent.to_dict() for consent in consents],
                'document_versions': LEGAL_DOCUMENT_VERSIONS
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Compliance validation failed: {str(e)}'
        }), 500

@legal_bp.route('/compliance/update-consent', methods=['POST'])
@rate_limit(max_requests=30)
@require_auth
def update_consent_preferences():
    """Update user consent preferences"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        consents = data.get('consents', {})
        
        if not consents:
            return jsonify({
                'success': False,
                'message': 'No consent data provided'
            }), 400
        
        # Get client info
        ip_address = request.environ.get('REMOTE_ADDR')
        user_agent = request.headers.get('User-Agent')
        
        updated_consents = []
        
        for consent_type_str, consent_given in consents.items():
            try:
                consent_type = ConsentType(consent_type_str)
                version = LEGAL_DOCUMENT_VERSIONS.get(consent_type_str, '1.0')
                
                consent = ConsentManager.record_consent(
                    user_id=user_id,
                    consent_type=consent_type,
                    consent_given=consent_given,
                    version=version,
                    ip_address=ip_address,
                    user_agent=user_agent
                )
                
                updated_consents.append(consent.to_dict())
                
            except ValueError:
                continue  # Skip invalid consent types
        
        return jsonify({
            'success': True,
            'data': {
                'updated_consents': updated_consents,
                'message': 'Consent preferences updated successfully'
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Consent update failed: {str(e)}'
        }), 500

@legal_bp.route('/gdpr/data-request', methods=['POST'])
@rate_limit(max_requests=10)
@require_auth
def handle_gdpr_request():
    """Handle GDPR data subject requests"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        request_type = data.get('request_type')
        
        if not request_type:
            return jsonify({
                'success': False,
                'message': 'Request type is required'
            }), 400
        
        if request_type == 'access':
            # Right of access - provide data summary
            summary = DataProcessor.get_user_data_summary(user_id)
            return jsonify({
                'success': True,
                'data': summary,
                'message': 'Data access request processed'
            })
            
        elif request_type == 'portability':
            # Right to data portability - export data
            export_data = DataProcessor.export_user_data(user_id)
            return jsonify({
                'success': True,
                'data': export_data,
                'message': 'Data portability request processed'
            })
            
        elif request_type == 'rectification':
            # Right to rectification - provide update instructions
            return jsonify({
                'success': True,
                'data': {
                    'instructions': 'You can update your data through your profile settings',
                    'profile_url': '/profile',
                    'contact_email': 'privacy@ustamapp.com'
                },
                'message': 'Rectification request guidance provided'
            })
            
        elif request_type == 'erasure':
            # Right to erasure - provide deletion instructions
            return jsonify({
                'success': True,
                'data': {
                    'instructions': 'Use the account deletion feature in your profile settings',
                    'deletion_url': '/profile/delete-account',
                    'warning': 'This action is permanent and cannot be undone',
                    'contact_email': 'privacy@ustamapp.com'
                },
                'message': 'Erasure request guidance provided'
            })
            
        else:
            return jsonify({
                'success': False,
                'message': 'Invalid request type'
            }), 400
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'GDPR request failed: {str(e)}'
        }), 500

@legal_bp.route('/compliance/check-age', methods=['POST'])
@rate_limit(max_requests=60)
def validate_age():
    """Validate user age requirement"""
    try:
        data = request.get_json()
        birth_date = data.get('birth_date')
        
        if not birth_date:
            return jsonify({
                'success': False,
                'message': 'Birth date is required'
            }), 400
        
        validation = LegalValidator.validate_age_requirement(birth_date)
        
        return jsonify({
            'success': True,
            'data': validation
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Age validation failed: {str(e)}'
        }), 500

@legal_bp.route('/compliance/mandatory-consent', methods=['POST'])
@rate_limit(max_requests=30)
@require_auth
def record_mandatory_consent():
    """Record mandatory consent during registration"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        user_agreement_accepted = data.get('user_agreement', False)
        terms_accepted = data.get('terms_of_service', False)
        privacy_accepted = data.get('privacy_policy', False)
        data_processing_accepted = data.get('data_processing', False)
        
        if not all([user_agreement_accepted, terms_accepted, privacy_accepted, data_processing_accepted]):
            return jsonify({
                'success': False,
                'message': 'All mandatory consents must be accepted'
            }), 400
        
        # Get client info
        ip_address = request.environ.get('REMOTE_ADDR')
        user_agent = request.headers.get('User-Agent')
        
        # Record all mandatory consents
        mandatory_consents = [
            ConsentType.TERMS_OF_SERVICE,
            ConsentType.PRIVACY_POLICY,
            ConsentType.DATA_PROCESSING
        ]
        
        recorded_consents = []
        
        for consent_type in mandatory_consents:
            version = LEGAL_DOCUMENT_VERSIONS.get(consent_type.value, '1.0')
            
            consent = ConsentManager.record_consent(
                user_id=user_id,
                consent_type=consent_type,
                consent_given=True,
                version=version,
                ip_address=ip_address,
                user_agent=user_agent
            )
            
            recorded_consents.append(consent.to_dict())
        
        # Record data processing for account creation
        DataProcessor.record_data_processing(
            user_id=user_id,
            purpose=DataProcessingPurpose.SERVICE_PROVISION,
            data_types=['identity', 'contact', 'account'],
            legal_basis='User consent (KVKK Article 5)',
            retention_period=None  # Lifetime + 1 year
        )
        
        return jsonify({
            'success': True,
            'data': {
                'recorded_consents': recorded_consents,
                'message': 'Mandatory consents recorded successfully'
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Mandatory consent recording failed: {str(e)}'
        }), 500

@legal_bp.route('/compliance/cookie-preferences', methods=['GET', 'POST'])
@rate_limit(max_requests=60)
def handle_cookie_preferences():
    """Handle cookie preferences"""
    try:
        if request.method == 'GET':
            # Return current cookie policy and default preferences
            policy = LegalDocumentManager.get_cookie_policy()
            
            return jsonify({
                'success': True,
                'data': {
                    'policy': policy,
                    'default_preferences': {
                        'necessary': True,  # Always required
                        'analytics': True,
                        'marketing': False,
                        'functional': True
                    }
                }
            })
            
        else:  # POST
            data = request.get_json()
            preferences = data.get('preferences', {})
            
            # Ensure necessary cookies are always enabled
            preferences['necessary'] = True
            
            # In a real implementation, you would store these preferences
            # For now, just return success
            
            return jsonify({
                'success': True,
                'data': {
                    'preferences': preferences,
                    'message': 'Cookie preferences updated'
                }
            })
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Cookie preferences handling failed: {str(e)}'
        }), 500

@legal_bp.route('/compliance/communication-rules', methods=['GET'])
@rate_limit(max_requests=30)
def get_communication_rules():
    """Get platform communication rules"""
    try:
        rules = {
            "version": "1.0",
            "effective_date": "2024-01-15",
            "title": "İletişim Kuralları",
            "rules": [
                {
                    "category": "Genel İletişim",
                    "rules": [
                        "Saygılı ve kibar bir dil kullanın",
                        "Kişisel saldırı ve hakaret yasaktır",
                        "Spam ve gereksiz mesajlar göndermeyin",
                        "Kişisel bilgilerinizi koruyun"
                    ]
                },
                {
                    "category": "Hizmet İletişimi",
                    "rules": [
                        "Hizmet detaylarını net şekilde belirtin",
                        "Fiyat tekliflerini açık ve anlaşılır yapın",
                        "Çalışma saatlerinizi belirtin",
                        "Acil durumları uygun şekilde işaretleyin"
                    ]
                },
                {
                    "category": "Güvenlik",
                    "rules": [
                        "Şüpheli davranışları bildirin",
                        "Platform dışı ödeme yapmayın",
                        "Kişisel bilgilerinizi paylaşmayın",
                        "Dolandırıcılık girişimlerini rapor edin"
                    ]
                },
                {
                    "category": "Yasaklanan İçerik",
                    "rules": [
                        "Yasa dışı hizmet reklamı",
                        "Yanıltıcı bilgi paylaşımı",
                        "Telif hakkı ihlali",
                        "Nefret söylemi ve ayrımcılık"
                    ]
                }
            ],
            "violations": {
                "warning": "İlk ihlal için uyarı",
                "suspension": "Tekrar ihlal için geçici askıya alma",
                "termination": "Ciddi ihlaller için hesap kapatma"
            },
            "reporting": {
                "email": "report@ustamapp.com",
                "in_app": "Profil > Şikayet Et",
                "response_time": "24 saat içinde"
            }
        }
        
        return jsonify({
            'success': True,
            'data': rules
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Communication rules retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/compliance/versions', methods=['GET'])
@rate_limit(max_requests=60)
def get_document_versions():
    """Get current versions of all legal documents"""
    try:
        return jsonify({
            'success': True,
            'data': {
                'versions': LEGAL_DOCUMENT_VERSIONS,
                'last_updated': '2024-01-15',
                'documents': {
                    'terms_of_service': 'Hizmet Şartları',
                    'privacy_policy': 'Gizlilik Politikası',
                    'cookie_policy': 'Çerez Politikası',
                    'user_agreement': 'Kullanıcı Sözleşmesi'
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Document versions retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/delete-account', methods=['POST'])
@rate_limit(max_requests=2)  # Very limited due to severity
@require_auth
def delete_account():
    """Request account deletion (GDPR/KVKK compliance)"""
    try:
        user_id = get_jwt_identity()
        
        # Process deletion request
        success = DataProcessor.delete_user_data(user_id)
        
        if success:
            return jsonify({
                'success': True,
                'message': 'Account deletion request processed. All data will be permanently deleted within 30 days.'
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Account deletion failed'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Account deletion failed: {str(e)}'
        }), 500

@legal_bp.route('/communication-rules', methods=['GET'])
@rate_limit(max_requests=60)
def get_communication_rules_document():
    """Get communication rules document"""
    try:
        document = LegalDocumentManager.get_document('communication_rules')
        
        if not document:
            return jsonify({
                'success': False,
                'message': 'Communication rules not found'
            }), 404
        
        return jsonify({
            'success': True,
            'data': document
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Communication rules retrieval failed: {str(e)}'
        }), 500

@legal_bp.route('/validate-age', methods=['POST'])
@rate_limit(max_requests=30)
def validate_user_age():
    """Validate user age for legal compliance"""
    try:
        data = request.get_json()
        birth_date_str = data.get('birth_date')
        
        if not birth_date_str:
            return jsonify({
                'success': False,
                'message': 'Birth date is required'
            }), 400
        
        # Parse birth date
        try:
            from datetime import datetime
            birth_date = datetime.fromisoformat(birth_date_str.replace('Z', '+00:00'))
        except ValueError:
            return jsonify({
                'success': False,
                'message': 'Invalid birth date format'
            }), 400
        
        # Validate age
        is_valid = LegalValidator.validate_age(birth_date)
        
        return jsonify({
            'success': True,
            'data': {
                'is_valid': is_valid,
                'minimum_age': 18,
                'birth_date': birth_date_str
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Age validation failed: {str(e)}'
        }), 500

@legal_bp.route('/document-versions', methods=['GET'])
@rate_limit(max_requests=60)
def get_all_document_versions():
    """Get current versions of all legal documents"""
    try:
        return jsonify({
            'success': True,
            'data': {
                'versions': LEGAL_DOCUMENT_VERSIONS,
                'documents': {
                    'communication_rules': 'İletişim Kuralları',
                    'terms_of_service': 'Hizmet Şartları',
                    'privacy_policy': 'Gizlilik Politikası',
                    'cookie_policy': 'Çerez Politikası',
                    'user_agreement': 'Kullanıcı Sözleşmesi',
                    'kvkk': 'KVKK Aydınlatma Metni'
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Document versions retrieval failed: {str(e)}'
        }), 500