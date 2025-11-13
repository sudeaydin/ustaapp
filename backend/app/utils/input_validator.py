"""
Input validation and XSS protection utilities
"""
import re
import bleach
from typing import Any, Dict, List
from html import escape


# Allowed HTML tags for rich text (very limited)
ALLOWED_TAGS = ['b', 'i', 'u', 'strong', 'em']
ALLOWED_ATTRIBUTES = {}


def sanitize_html(text: str) -> str:
    """
    Remove potentially dangerous HTML/JavaScript.
    
    Args:
        text: Input text that may contain HTML
        
    Returns:
        Sanitized text
    """
    if not text:
        return ""
    
    # Use bleach to clean HTML
    clean_text = bleach.clean(
        text,
        tags=ALLOWED_TAGS,
        attributes=ALLOWED_ATTRIBUTES,
        strip=True
    )
    
    return clean_text


def sanitize_sql_like(text: str) -> str:
    """
    Escape special characters for SQL LIKE queries.
    
    Args:
        text: Input text for LIKE query
        
    Returns:
        Escaped text
    """
    if not text:
        return ""
    
    # Escape special LIKE characters
    text = text.replace('\\', '\\\\')
    text = text.replace('%', '\\%')
    text = text.replace('_', '\\_')
    
    return text


def validate_email(email: str) -> bool:
    """
    Validate email format.
    
    Args:
        email: Email address to validate
        
    Returns:
        True if valid email
    """
    if not email:
        return False
    
    # RFC 5322 compliant regex (simplified)
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    if not re.match(pattern, email):
        return False
    
    # Additional checks
    if len(email) > 254:  # RFC 5321
        return False
    
    local, domain = email.rsplit('@', 1)
    if len(local) > 64:  # RFC 5321
        return False
    
    return True


def validate_phone(phone: str) -> bool:
    """
    Validate Turkish phone number.
    
    Args:
        phone: Phone number to validate
        
    Returns:
        True if valid phone
    """
    if not phone:
        return False
    
    # Remove spaces and special characters
    phone = re.sub(r'[\s\-\(\)]', '', phone)
    
    # Turkish phone patterns
    patterns = [
        r'^(\+90|0)?[5][0-9]{9}$',  # Mobile
        r'^(\+90|0)?[2-4][0-9]{8}$'  # Landline
    ]
    
    return any(re.match(pattern, phone) for pattern in patterns)


def validate_url(url: str) -> bool:
    """
    Validate URL format.
    
    Args:
        url: URL to validate
        
    Returns:
        True if valid URL
    """
    if not url:
        return False
    
    # Simple URL validation
    pattern = r'^https?://[a-zA-Z0-9-._~:/?#[\]@!$&\'()*+,;=]+$'
    
    if not re.match(pattern, url):
        return False
    
    # Block localhost and private IPs in production
    dangerous_patterns = [
        r'localhost',
        r'127\.0\.0\.1',
        r'0\.0\.0\.0',
        r'192\.168\.',
        r'10\.',
        r'172\.(1[6-9]|2[0-9]|3[01])\.'
    ]
    
    for pattern in dangerous_patterns:
        if re.search(pattern, url.lower()):
            return False
    
    return True


def sanitize_filename(filename: str) -> str:
    """
    Sanitize filename to prevent path traversal.
    
    Args:
        filename: Original filename
        
    Returns:
        Safe filename
    """
    if not filename:
        return ""
    
    # Remove path separators
    filename = os.path.basename(filename)
    
    # Remove special characters
    filename = re.sub(r'[^a-zA-Z0-9._-]', '_', filename)
    
    # Remove leading dots (hidden files)
    filename = filename.lstrip('.')
    
    return filename


def validate_integer(value: Any, min_val: int = None, max_val: int = None) -> tuple:
    """
    Validate integer with optional range check.
    
    Args:
        value: Value to validate
        min_val: Minimum allowed value
        max_val: Maximum allowed value
        
    Returns:
        Tuple of (is_valid, error_message, value)
    """
    try:
        int_val = int(value)
        
        if min_val is not None and int_val < min_val:
            return False, f"Değer en az {min_val} olmalıdır", None
        
        if max_val is not None and int_val > max_val:
            return False, f"Değer en fazla {max_val} olabilir", None
        
        return True, "", int_val
        
    except (ValueError, TypeError):
        return False, "Geçersiz sayı formatı", None


def validate_string(value: str, min_length: int = None, max_length: int = None, 
                    pattern: str = None) -> tuple:
    """
    Validate string with length and pattern checks.
    
    Args:
        value: String to validate
        min_length: Minimum length
        max_length: Maximum length
        pattern: Regex pattern to match
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    if not isinstance(value, str):
        return False, "Metin formatı gerekli"
    
    if min_length is not None and len(value) < min_length:
        return False, f"En az {min_length} karakter gerekli"
    
    if max_length is not None and len(value) > max_length:
        return False, f"En fazla {max_length} karakter olabilir"
    
    if pattern and not re.match(pattern, value):
        return False, "Geçersiz format"
    
    return True, ""


def validate_json_input(data: Dict, schema: Dict) -> tuple:
    """
    Validate JSON input against schema.
    
    Args:
        data: Input data dictionary
        schema: Validation schema
        
    Returns:
        Tuple of (is_valid, errors)
    """
    errors = {}
    
    # Check required fields
    for field, rules in schema.items():
        if rules.get('required', False) and field not in data:
            errors[field] = f"{field} gereklidir"
            continue
        
        if field not in data:
            continue
        
        value = data[field]
        
        # Type validation
        field_type = rules.get('type')
        if field_type == 'string' and not isinstance(value, str):
            errors[field] = "Metin formatı gerekli"
        elif field_type == 'integer':
            is_valid, error, _ = validate_integer(value, 
                                                  rules.get('min'), 
                                                  rules.get('max'))
            if not is_valid:
                errors[field] = error
        elif field_type == 'email' and not validate_email(value):
            errors[field] = "Geçersiz e-posta adresi"
        elif field_type == 'phone' and not validate_phone(value):
            errors[field] = "Geçersiz telefon numarası"
        elif field_type == 'url' and not validate_url(value):
            errors[field] = "Geçersiz URL"
        
        # String validation
        if field_type == 'string':
            is_valid, error = validate_string(value,
                                             rules.get('min_length'),
                                             rules.get('max_length'),
                                             rules.get('pattern'))
            if not is_valid:
                errors[field] = error
        
        # XSS protection
        if rules.get('sanitize', False) and isinstance(value, str):
            data[field] = sanitize_html(value)
    
    return len(errors) == 0, errors


# Common validation schemas
USER_REGISTER_SCHEMA = {
    'email': {'required': True, 'type': 'email'},
    'password': {'required': True, 'type': 'string', 'min_length': 8},
    'first_name': {'required': True, 'type': 'string', 'min_length': 2, 'max_length': 50},
    'last_name': {'required': True, 'type': 'string', 'min_length': 2, 'max_length': 50},
    'phone': {'required': True, 'type': 'phone'},
}

QUOTE_CREATE_SCHEMA = {
    'description': {'required': True, 'type': 'string', 'min_length': 10, 'max_length': 1000, 'sanitize': True},
    'budget_range': {'required': True, 'type': 'string'},
    'category': {'required': True, 'type': 'string'},
}
