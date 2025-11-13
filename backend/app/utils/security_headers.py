"""
Security headers middleware
"""
from flask import Flask


def add_security_headers(response):
    """
    Add security headers to all responses.
    
    Args:
        response: Flask response object
        
    Returns:
        Response with security headers
    """
    # Prevent clickjacking
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    
    # Prevent MIME type sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
    
    # Enable XSS protection
    response.headers['X-XSS-Protection'] = '1; mode=block'
    
    # Content Security Policy
    # TODO: Customize this for your application
    csp = (
        "default-src 'self'; "
        "script-src 'self' 'unsafe-inline' 'unsafe-eval'; "
        "style-src 'self' 'unsafe-inline'; "
        "img-src 'self' data: https:; "
        "font-src 'self' data:; "
        "connect-src 'self'; "
        "frame-ancestors 'self';"
    )
    response.headers['Content-Security-Policy'] = csp
    
    # Referrer Policy
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    
    # Permissions Policy (formerly Feature Policy)
    response.headers['Permissions-Policy'] = (
        "geolocation=(), "
        "microphone=(), "
        "camera=(), "
        "payment=(), "
        "usb=(), "
        "magnetometer=(), "
        "gyroscope=()"
    )
    
    return response


def add_hsts_header(response, max_age=31536000, include_subdomains=True):
    """
    Add HTTP Strict Transport Security header.
    Only use in production with HTTPS!
    
    Args:
        response: Flask response object
        max_age: Max age in seconds (default 1 year)
        include_subdomains: Include subdomains
        
    Returns:
        Response with HSTS header
    """
    hsts_value = f'max-age={max_age}'
    if include_subdomains:
        hsts_value += '; includeSubDomains'
    
    response.headers['Strict-Transport-Security'] = hsts_value
    return response


def init_security_headers(app: Flask):
    """
    Initialize security headers for Flask app.
    
    Args:
        app: Flask application
    """
    @app.after_request
    def apply_security_headers(response):
        """Apply security headers to all responses"""
        response = add_security_headers(response)
        
        # Only add HSTS in production with HTTPS
        if not app.config.get('DEBUG', False) and app.config.get('ENABLE_HSTS', False):
            response = add_hsts_header(response)
        
        return response
    
    app.logger.info('Security headers configured')
