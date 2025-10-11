import re
from functools import wraps
from flask import request, jsonify
from marshmallow import Schema, fields, ValidationError, validates, validates_schema

class ResponseHelper:
    """Helper class for standardized API responses"""
    
    @staticmethod
    def success(data=None, message="Success", status_code=200):
        """Return success response"""
        response = {
            'success': True,
            'message': message,
            'data': data
        }
        return jsonify(response), status_code
    
    @staticmethod
    def error(message="Error", status_code=400):
        """Return error response"""
        response = {
            'success': False,
            'message': message,
            'data': None
        }
        return jsonify(response), status_code
    
    @staticmethod
    def unauthorized(message="Unauthorized"):
        """Return unauthorized response"""
        return ResponseHelper.error(message, 401)
    
    @staticmethod
    def forbidden(message="Forbidden"):
        """Return forbidden response"""
        return ResponseHelper.error(message, 403)
    
    @staticmethod
    def not_found(message="Not found"):
        """Return not found response"""
        return ResponseHelper.error(message, 404)

class ValidationUtils:
    """Utility class for common validation functions"""
    
    @staticmethod
    def is_valid_email(email):
        """Validate email format"""
        pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
        return re.match(pattern, email) is not None
    
    @staticmethod
    def is_valid_phone(phone):
        """Validate Turkish phone number format"""
        # Remove spaces and special characters
        clean_phone = re.sub(r'[^\d]', '', phone)
        # Turkish phone: 10 or 11 digits (with or without country code)
        return len(clean_phone) in [10, 11] and clean_phone.isdigit()
    
    @staticmethod
    def is_strong_password(password):
        """Check if password meets strength requirements"""
        if len(password) < 6:
            return False, "Şifre en az 6 karakter olmalıdır"
        
        # Optional: Add more complex rules
        # has_upper = any(c.isupper() for c in password)
        # has_lower = any(c.islower() for c in password)
        # has_digit = any(c.isdigit() for c in password)
        
        return True, "Valid"
    
    @staticmethod
    def sanitize_string(text, max_length=None):
        """Sanitize and trim string input"""
        if not text:
            return ""
        
        sanitized = text.strip()
        if max_length and len(sanitized) > max_length:
            sanitized = sanitized[:max_length]
        
        return sanitized

# Marshmallow Schemas for API validation
class UserRegistrationSchema(Schema):
    first_name = fields.Str(required=True, validate=lambda x: len(x.strip()) >= 2)
    last_name = fields.Str(required=True, validate=lambda x: len(x.strip()) >= 2)
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=lambda x: len(x) >= 6)
    user_type = fields.Str(required=True, validate=lambda x: x in ['customer', 'craftsman'])
    phone = fields.Str(required=False)
    
    @validates('email')
    def validate_email(self, value):
        if not ValidationUtils.is_valid_email(value):
            raise ValidationError('Geçerli bir e-posta adresi girin')
    
    @validates('phone')
    def validate_phone(self, value):
        if value and not ValidationUtils.is_valid_phone(value):
            raise ValidationError('Geçerli bir telefon numarası girin')

class UserLoginSchema(Schema):
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=lambda x: len(x) >= 1)

class QuoteRequestSchema(Schema):
    craftsman_id = fields.Int(required=True)
    category = fields.Str(required=True, validate=lambda x: len(x.strip()) >= 2)
    area_type = fields.Str(required=True)
    square_meters = fields.Int(required=False, validate=lambda x: x > 0 if x else True)
    budget_range = fields.Str(required=True)
    description = fields.Str(required=True, validate=lambda x: len(x.strip()) >= 10)
    additional_details = fields.Str(required=False)
    
    @validates('description')
    def validate_description(self, value):
        if len(value.strip()) < 10:
            raise ValidationError('Açıklama en az 10 karakter olmalıdır')
        if len(value.strip()) > 1000:
            raise ValidationError('Açıklama en fazla 1000 karakter olabilir')

class QuoteResponseSchema(Schema):
    quote_id = fields.Int(required=True)
    action = fields.Str(required=True, validate=lambda x: x in ['give_quote', 'request_details', 'reject'])
    amount = fields.Float(required=False, validate=lambda x: x > 0 if x else True)
    details = fields.Str(required=False)
    estimated_start_date = fields.Date(required=False)
    estimated_end_date = fields.Date(required=False)
    
    @validates_schema
    def validate_quote_response(self, data, **kwargs):
        if data['action'] == 'give_quote':
            if not data.get('amount'):
                raise ValidationError({'amount': ['Teklif tutarı gereklidir']})
            if not data.get('details'):
                raise ValidationError({'details': ['Teklif detayları gereklidir']})

class SearchSchema(Schema):
    q = fields.Str(required=False)  # search query
    category = fields.Str(required=False)
    city = fields.Str(required=False)
    district = fields.Str(required=False)
    min_rating = fields.Float(required=False, validate=lambda x: 0 <= x <= 5)
    max_rating = fields.Float(required=False, validate=lambda x: 0 <= x <= 5)
    min_price = fields.Float(required=False, validate=lambda x: x >= 0)
    max_price = fields.Float(required=False, validate=lambda x: x >= 0)
    is_verified = fields.Bool(required=False)
    has_portfolio = fields.Bool(required=False)
    sort_by = fields.Str(required=False, validate=lambda x: x in ['rating', 'price', 'distance', 'reviews'], missing='rating')
    sort_order = fields.Str(required=False, validate=lambda x: x in ['asc', 'desc'], missing='desc')
    page = fields.Int(required=False, validate=lambda x: x > 0, missing=1)
    per_page = fields.Int(required=False, validate=lambda x: 1 <= x <= 50, missing=20)

# Decorator for request validation
def validate_json(schema_class):
    """Decorator to validate JSON request data using Marshmallow schema"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            try:
                schema = schema_class()
                
                # Get JSON data
                if not request.is_json:
                    return jsonify({
                        'success': False,
                        'error': True,
                        'message': 'Content-Type application/json gereklidir',
                        'code': 'INVALID_CONTENT_TYPE'
                    }), 400
                
                data = request.get_json()
                if not data:
                    return jsonify({
                        'success': False,
                        'error': True,
                        'message': 'JSON verisi gereklidir',
                        'code': 'MISSING_JSON_DATA'
                    }), 400
                
                # Validate data
                validated_data = schema.load(data)
                
                # Pass validated data to the route function
                return f(validated_data, *args, **kwargs)
                
            except ValidationError as err:
                return jsonify({
                    'success': False,
                    'error': True,
                    'message': 'Geçersiz veri formatı',
                    'details': err.messages,
                    'code': 'VALIDATION_ERROR'
                }), 400
            except Exception as e:
                return jsonify({
                    'success': False,
                    'error': True,
                    'message': 'Sunucu hatası',
                    'details': str(e),
                    'code': 'INTERNAL_ERROR'
                }), 500
        
        return decorated_function
    return decorator

def validate_query_params(schema_class):
    """Decorator to validate query parameters using Marshmallow schema"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            try:
                schema = schema_class()
                
                # Validate query parameters
                validated_data = schema.load(request.args)
                
                # Pass validated data to the route function
                return f(validated_data, *args, **kwargs)
                
            except ValidationError as err:
                return jsonify({
                    'success': False,
                    'error': True,
                    'message': 'Geçersiz sorgu parametreleri',
                    'details': err.messages,
                    'code': 'VALIDATION_ERROR'
                }), 400
        
        return decorated_function
    return decorator

# Response helpers
class ResponseHelper:
    """Helper class for consistent API responses"""
    
    @staticmethod
    def success(data=None, message="İşlem başarılı", status_code=200):
        """Return success response"""
        response = {
            'success': True,
            'error': False,
            'message': message,
            'data': data
        }
        return jsonify(response), status_code
    
    @staticmethod
    def error(message="Bir hata oluştu", details=None, code="ERROR", status_code=400):
        """Return error response"""
        response = {
            'success': False,
            'error': True,
            'message': message,
            'code': code
        }
        
        if details:
            response['details'] = details
            
        return jsonify(response), status_code
    
    @staticmethod
    def validation_error(details, message="Geçersiz veri"):
        """Return validation error response"""
        return ResponseHelper.error(
            message=message,
            details=details,
            code="VALIDATION_ERROR",
            status_code=400
        )
    
    @staticmethod
    def not_found(message="Kayıt bulunamadı"):
        """Return not found response"""
        return ResponseHelper.error(
            message=message,
            code="NOT_FOUND",
            status_code=404
        )
    
    @staticmethod
    def unauthorized(message="Yetkisiz erişim"):
        """Return unauthorized response"""
        return ResponseHelper.error(
            message=message,
            code="UNAUTHORIZED",
            status_code=401
        )
    
    @staticmethod
    def forbidden(message="Erişim yasak"):
        """Return forbidden response"""
        return ResponseHelper.error(
            message=message,
            code="FORBIDDEN",
            status_code=403
        )
    
    @staticmethod
    def server_error(message="Sunucu hatası", details=None):
        """Return server error response"""
        return ResponseHelper.error(
            message=message,
            details=details,
            code="INTERNAL_ERROR",
            status_code=500
        )

# Pagination helper
class PaginationHelper:
    """Helper for paginated responses"""
    
    @staticmethod
    def paginate_query(query, page=1, per_page=20):
        """Paginate a SQLAlchemy query"""
        total = query.count()
        items = query.offset((page - 1) * per_page).limit(per_page).all()
        
        return {
            'items': [item.to_dict() if hasattr(item, 'to_dict') else item for item in items],
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total': total,
                'pages': (total + per_page - 1) // per_page,
                'has_prev': page > 1,
                'has_next': page * per_page < total,
                'prev_page': page - 1 if page > 1 else None,
                'next_page': page + 1 if page * per_page < total else None,
            }
        }