"""
Secure logging with sensitive data filtering
"""
import logging
import re
from logging.handlers import RotatingFileHandler
import os


class SensitiveDataFilter(logging.Filter):
    """Filter to remove sensitive data from logs"""
    
    # Patterns to detect and redact sensitive data
    SENSITIVE_PATTERNS = [
        # Password patterns
        (r'password["\']?\s*[:=]\s*["\']([^"\']+)["\']', r'password":"***"'),
        (r'passwd["\']?\s*[:=]\s*["\']([^"\']+)["\']', r'passwd":"***"'),
        (r'pwd["\']?\s*[:=]\s*["\']([^"\']+)["\']', r'pwd":"***"'),
        
        # Token patterns
        (r'token["\']?\s*[:=]\s*["\']([^"\']+)["\']', r'token":"***"'),
        (r'bearer\s+([a-zA-Z0-9\-._~+/]+)', r'bearer ***'),
        (r'jwt["\']?\s*[:=]\s*["\']([^"\']+)["\']', r'jwt":"***"'),
        
        # Credit card patterns (PAN)
        (r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b', r'****-****-****-****'),
        
        # API keys
        (r'api[_-]?key["\']?\s*[:=]\s*["\']([^"\']+)["\']', r'api_key":"***"'),
        (r'secret[_-]?key["\']?\s*[:=]\s*["\']([^"\']+)["\']', r'secret_key":"***"'),
        
        # Email addresses (partial redaction)
        (r'([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})', r'\1***@***.\2'),
        
        # Phone numbers (partial redaction)
        (r'(\+?90[\s-]?)?(\d{3})[\s-]?(\d{3})[\s-]?(\d{4})', r'+90-***-***-\4'),
        
        # SSN / TC Kimlik No (Turkish ID)
        (r'\b\d{11}\b', r'***********'),
        
        # Authorization headers
        (r'authorization:\s*bearer\s+([a-zA-Z0-9\-._~+/]+)', r'authorization: bearer ***'),
    ]
    
    def filter(self, record):
        """
        Filter log record to remove sensitive data.
        
        Args:
            record: LogRecord to filter
            
        Returns:
            True (always pass through, but with redacted message)
        """
        if isinstance(record.msg, str):
            record.msg = self.redact_sensitive_data(record.msg)
        
        # Also filter args if present
        if record.args:
            if isinstance(record.args, dict):
                record.args = {
                    k: self.redact_sensitive_data(str(v)) if isinstance(v, str) else v
                    for k, v in record.args.items()
                }
            elif isinstance(record.args, (list, tuple)):
                record.args = tuple(
                    self.redact_sensitive_data(str(arg)) if isinstance(arg, str) else arg
                    for arg in record.args
                )
        
        return True
    
    @classmethod
    def redact_sensitive_data(cls, text: str) -> str:
        """
        Redact sensitive data from text.
        
        Args:
            text: Text that may contain sensitive data
            
        Returns:
            Text with sensitive data redacted
        """
        for pattern, replacement in cls.SENSITIVE_PATTERNS:
            text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)
        
        return text


def setup_secure_logging(app, log_level=logging.INFO):
    """
    Setup secure logging with sensitive data filtering.
    
    Args:
        app: Flask application
        log_level: Logging level
    """
    # Create logs directory if it doesn't exist
    log_dir = 'logs'
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    
    # Create formatter
    formatter = logging.Formatter(
        '[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
    )
    
    # Main application log
    app_handler = RotatingFileHandler(
        os.path.join(log_dir, 'app.log'),
        maxBytes=10485760,  # 10MB
        backupCount=10
    )
    app_handler.setFormatter(formatter)
    app_handler.setLevel(log_level)
    app_handler.addFilter(SensitiveDataFilter())
    
    # Security events log (separate file for security events)
    security_handler = RotatingFileHandler(
        os.path.join(log_dir, 'security.log'),
        maxBytes=10485760,  # 10MB
        backupCount=10
    )
    security_handler.setFormatter(formatter)
    security_handler.setLevel(logging.WARNING)
    security_handler.addFilter(SensitiveDataFilter())
    
    # Error log
    error_handler = RotatingFileHandler(
        os.path.join(log_dir, 'error.log'),
        maxBytes=10485760,  # 10MB
        backupCount=10
    )
    error_handler.setFormatter(formatter)
    error_handler.setLevel(logging.ERROR)
    error_handler.addFilter(SensitiveDataFilter())
    
    # Console handler for development
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    console_handler.setLevel(logging.DEBUG)
    console_handler.addFilter(SensitiveDataFilter())
    
    # Add handlers to app logger
    app.logger.addHandler(app_handler)
    app.logger.addHandler(security_handler)
    app.logger.addHandler(error_handler)
    
    if app.config.get('DEBUG', False):
        app.logger.addHandler(console_handler)
    
    app.logger.setLevel(log_level)
    
    app.logger.info('Secure logging configured')


def log_security_event(event_type: str, details: dict, severity: str = 'WARNING'):
    """
    Log a security event.
    
    Args:
        event_type: Type of security event
        details: Event details (will be filtered for sensitive data)
        severity: Log severity (INFO, WARNING, ERROR, CRITICAL)
    """
    logger = logging.getLogger('security')
    
    # Filter sensitive data from details
    safe_details = {
        k: SensitiveDataFilter.redact_sensitive_data(str(v)) if isinstance(v, str) else v
        for k, v in details.items()
    }
    
    message = f"SECURITY EVENT: {event_type} | Details: {safe_details}"
    
    if severity == 'CRITICAL':
        logger.critical(message)
    elif severity == 'ERROR':
        logger.error(message)
    elif severity == 'WARNING':
        logger.warning(message)
    else:
        logger.info(message)


def log_failed_login(email: str, ip_address: str, reason: str):
    """Log failed login attempt"""
    log_security_event(
        'FAILED_LOGIN',
        {
            'email': email,
            'ip': ip_address,
            'reason': reason
        },
        'WARNING'
    )


def log_account_locked(email: str, ip_address: str):
    """Log account lockout"""
    log_security_event(
        'ACCOUNT_LOCKED',
        {
            'email': email,
            'ip': ip_address
        },
        'WARNING'
    )


def log_suspicious_activity(activity_type: str, details: dict):
    """Log suspicious activity"""
    log_security_event(
        f'SUSPICIOUS_ACTIVITY_{activity_type}',
        details,
        'ERROR'
    )
