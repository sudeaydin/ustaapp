import re
import hashlib
import secrets
from functools import wraps
from flask import request, jsonify, current_app
from datetime import datetime, timedelta
import bleach
from urllib.parse import urlparse

class RateLimiter:
    """Simple in-memory rate limiter"""
    
    _requests = {}
    _blocked_ips = {}
    
    @classmethod
    def is_allowed(cls, identifier, max_requests=60, window_minutes=1):
        """Check if request is allowed based on rate limit"""
        now = datetime.utcnow()
        window_start = now - timedelta(minutes=window_minutes)
        
        # Clean old requests
        cls._cleanup_old_requests(window_start)
        
        # Check if IP is blocked
        if identifier in cls._blocked_ips:
            if cls._blocked_ips[identifier] > now:
                return False
            else:
                del cls._blocked_ips[identifier]
        
        # Count requests in current window
        if identifier not in cls._requests:
            cls._requests[identifier] = []
        
        # Remove old requests
        cls._requests[identifier] = [
            req_time for req_time in cls._requests[identifier] 
            if req_time > window_start
        ]
        
        # Check limit
        if len(cls._requests[identifier]) >= max_requests:
            # Block IP for 15 minutes on rate limit exceed
            cls._blocked_ips[identifier] = now + timedelta(minutes=15)
            return False
        
        # Add current request
        cls._requests[identifier].append(now)
        return True
    
    @classmethod
    def _cleanup_old_requests(cls, cutoff_time):
        """Clean up old request records"""
        for identifier in list(cls._requests.keys()):
            cls._requests[identifier] = [
                req_time for req_time in cls._requests[identifier] 
                if req_time > cutoff_time
            ]
            if not cls._requests[identifier]:
                del cls._requests[identifier]

def rate_limit(max_requests=60, window_minutes=1):
    """Rate limiting decorator"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            # Get client identifier (IP + User-Agent for better uniqueness)
            client_ip = request.environ.get('HTTP_X_FORWARDED_FOR', request.remote_addr)
            user_agent = request.headers.get('User-Agent', '')
            identifier = hashlib.md5(f"{client_ip}:{user_agent}".encode()).hexdigest()
            
            if not RateLimiter.is_allowed(identifier, max_requests, window_minutes):
                return jsonify({
                    'success': False,
                    'error': True,
                    'message': 'Çok fazla istek gönderdiniz. Lütfen biraz bekleyin.',
                    'code': 'RATE_LIMIT_EXCEEDED'
                }), 429
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

class InputSanitizer:
    """Input sanitization utilities"""
    
    @staticmethod
    def sanitize_html(text, allowed_tags=None):
        """Sanitize HTML content"""
        if not text:
            return ""
        
        if allowed_tags is None:
            allowed_tags = ['b', 'i', 'u', 'em', 'strong', 'p', 'br']
        
        return bleach.clean(text, tags=allowed_tags, strip=True)
    
    @staticmethod
    def sanitize_string(text, max_length=None, allow_html=False):
        """Sanitize string input"""
        if not text:
            return ""
        
        # Remove null bytes and control characters
        text = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', text)
        
        # Trim whitespace
        text = text.strip()
        
        # Remove HTML if not allowed
        if not allow_html:
            text = InputSanitizer.sanitize_html(text, allowed_tags=[])
        
        # Limit length
        if max_length and len(text) > max_length:
            text = text[:max_length]
        
        return text
    
    @staticmethod
    def sanitize_filename(filename):
        """Sanitize filename for secure file uploads"""
        if not filename:
            return ""
        
        # Remove path components
        filename = filename.split('/')[-1].split('\\')[-1]
        
        # Remove dangerous characters
        filename = re.sub(r'[^\w\-_\.]', '_', filename)
        
        # Ensure it's not empty and has extension
        if not filename or '.' not in filename:
            filename = f"file_{secrets.token_hex(8)}.txt"
        
        return filename
    
    @staticmethod
    def validate_url(url, allowed_domains=None):
        """Validate URL for safety"""
        if not url:
            return False
        
        try:
            parsed = urlparse(url)
            
            # Must have scheme and netloc
            if not parsed.scheme or not parsed.netloc:
                return False
            
            # Only allow http/https
            if parsed.scheme not in ['http', 'https']:
                return False
            
            # Check allowed domains if specified
            if allowed_domains:
                if parsed.netloc not in allowed_domains:
                    return False
            
            return True
        except:
            return False

class SecurityHeaders:
    """Security headers for Flask responses"""
    
    @staticmethod
    def add_security_headers(response):
        """Add security headers to response"""
        
        # Content Security Policy
        csp = (
            "default-src 'self'; "
            "script-src 'self' 'unsafe-inline' 'unsafe-eval'; "
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; "
            "font-src 'self' https://fonts.gstatic.com; "
            "img-src 'self' data: https: http:; "
            "connect-src 'self' ws: wss:; "
            "frame-ancestors 'none';"
        )
        response.headers['Content-Security-Policy'] = csp
        
        # Other security headers
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        
        # Remove server information
        response.headers.pop('Server', None)
        
        return response

def require_auth(f):
    """Enhanced auth decorator with better error handling"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        from flask_jwt_extended import jwt_required, get_jwt_identity, verify_jwt_in_request
        
        try:
            verify_jwt_in_request()
            user_id = get_jwt_identity()
            
            if not user_id:
                return jsonify({
                    'success': False,
                    'error': True,
                    'message': 'Geçersiz token',
                    'code': 'INVALID_TOKEN'
                }), 401
            
            # Check if user still exists and is active
            from app.models.user import User
            user = User.query.get(user_id)
            if not user or not user.is_active:
                return jsonify({
                    'success': False,
                    'error': True,
                    'message': 'Hesap bulunamadı veya deaktif',
                    'code': 'USER_NOT_FOUND'
                }), 401
            
            return f(*args, **kwargs)
            
        except Exception as e:
            return jsonify({
                'success': False,
                'error': True,
                'message': 'Kimlik doğrulama hatası',
                'code': 'AUTH_ERROR'
            }), 401
    
    return decorated_function

class PasswordSecurity:
    """Password security utilities"""
    
    @staticmethod
    def generate_secure_password(length=12):
        """Generate a secure random password"""
        import string
        
        characters = string.ascii_letters + string.digits + "!@#$%^&*"
        return ''.join(secrets.choice(characters) for _ in range(length))
    
    @staticmethod
    def hash_password(password):
        """Hash password securely"""
        from werkzeug.security import generate_password_hash
        return generate_password_hash(password, method='pbkdf2:sha256', salt_length=16)
    
    @staticmethod
    def verify_password(password, password_hash):
        """Verify password against hash"""
        from werkzeug.security import check_password_hash
        return check_password_hash(password_hash, password)
    
    @staticmethod
    def is_password_compromised(password):
        """Check if password is commonly used (basic check)"""
        common_passwords = [
            '123456', 'password', '123456789', '12345678', '12345',
            '1234567', '1234567890', 'qwerty', 'abc123', 'password123'
        ]
        return password.lower() in common_passwords

class FileUploadSecurity:
    """File upload security utilities"""
    
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
    MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
    
    @staticmethod
    def is_allowed_file(filename):
        """Check if file extension is allowed"""
        return '.' in filename and \
               filename.rsplit('.', 1)[1].lower() in FileUploadSecurity.ALLOWED_EXTENSIONS
    
    @staticmethod
    def is_valid_file_size(file_size):
        """Check if file size is within limits"""
        return file_size <= FileUploadSecurity.MAX_FILE_SIZE
    
    @staticmethod
    def scan_file_content(file_path):
        """Basic file content validation"""
        try:
            import imghdr
            
            # Verify it's actually an image
            image_type = imghdr.what(file_path)
            return image_type in ['jpeg', 'png', 'gif', 'webp']
        except:
            return False
    
    @staticmethod
    def generate_secure_filename(original_filename):
        """Generate secure filename"""
        extension = original_filename.rsplit('.', 1)[1].lower() if '.' in original_filename else 'jpg'
        secure_name = f"{secrets.token_hex(16)}.{extension}"
        return secure_name

# CORS configuration
def configure_cors(app):
    """Configure CORS with security considerations"""
    from flask_cors import CORS
    
    # Production CORS settings
    if app.config.get('ENV') == 'production':
        allowed_origins = [
            'https://ustamapp.com',
            'https://www.ustamapp.com',
            'https://app.ustamapp.com'
        ]
    else:
        # Development settings
        allowed_origins = [
            'http://localhost:3000',
            'http://localhost:5173',
            'http://127.0.0.1:3000',
            'http://127.0.0.1:5173'
        ]
    
    CORS(app, 
         origins=allowed_origins,
         methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
         allow_headers=['Content-Type', 'Authorization'],
         supports_credentials=True,
         max_age=86400)  # 24 hours

# Security middleware
def init_security_middleware(app):
    """Initialize security middleware"""
    
    @app.before_request
    def security_before_request():
        """Apply security checks before each request"""
        
        # Block suspicious user agents
        user_agent = request.headers.get('User-Agent', '').lower()
        suspicious_agents = ['bot', 'crawler', 'spider', 'scraper']
        
        # Allow legitimate bots but block suspicious ones
        if any(agent in user_agent for agent in suspicious_agents):
            if not any(legitimate in user_agent for legitimate in ['googlebot', 'bingbot']):
                return jsonify({
                    'success': False,
                    'error': True,
                    'message': 'Access denied',
                    'code': 'BLOCKED_USER_AGENT'
                }), 403
    
    @app.after_request
    def security_after_request(response):
        """Apply security headers after each request"""
        return SecurityHeaders.add_security_headers(response)