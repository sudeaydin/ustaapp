"""
CSRF Protection Utilities

This module provides CSRF protection utilities for the USTAM app.

IMPORTANT: This app uses JWT authentication with tokens in Authorization headers,
which is inherently CSRF-safe. CSRF protection is configured but disabled by default.

Enable CSRF protection:
1. Set environment variable: WTF_CSRF_ENABLED=true
2. For web forms (non-API), use @csrf.exempt decorator on JWT endpoints
3. For web forms that need CSRF, Flask-WTF will automatically validate

Why JWT APIs don't need CSRF:
- Browsers don't automatically send Authorization headers
- Attackers can't force users to make authenticated requests with JWT
- CSRF only affects cookie-based authentication

When to use CSRF:
- Web forms using session-based authentication
- Endpoints that use cookies for authentication
- Any state-changing operation not protected by JWT

Usage Examples:
    from app.utils.csrf_utils import csrf_protect, csrf_exempt

    # Protect a web form endpoint
    @app.route('/web-form', methods=['POST'])
    @csrf_protect
    def handle_form():
        return render_template('form.html')

    # Exempt JWT API endpoint (already exempt by default)
    @app.route('/api/resource', methods=['POST'])
    @jwt_required()
    @csrf_exempt
    def api_endpoint():
        return jsonify({'data': 'ok'})
"""

from functools import wraps
from flask import current_app, request
from flask_wtf.csrf import generate_csrf, validate_csrf
from werkzeug.exceptions import BadRequest


def csrf_protect(f):
    """
    Decorator to enforce CSRF protection on a specific endpoint.

    Use this for web forms that need CSRF protection.
    Note: JWT-protected API endpoints don't need this.
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if current_app.config.get('WTF_CSRF_ENABLED', False):
            try:
                validate_csrf(request.headers.get('X-CSRF-Token'))
            except Exception as e:
                raise BadRequest('CSRF validation failed')
        return f(*args, **kwargs)
    return decorated_function


def csrf_exempt(f):
    """
    Decorator to exempt an endpoint from CSRF protection.

    Use this for JWT-protected API endpoints (though they're exempt by default).
    This is mainly for documentation purposes.
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        return f(*args, **kwargs)
    # Mark the function as CSRF-exempt for documentation
    decorated_function._csrf_exempt = True
    return decorated_function


def get_csrf_token():
    """
    Generate and return a CSRF token for web forms.

    Returns:
        str: CSRF token, or None if CSRF is disabled
    """
    if current_app.config.get('WTF_CSRF_ENABLED', False):
        return generate_csrf()
    return None


# Configuration note:
# To enable CSRF protection, set these environment variables:
# - WTF_CSRF_ENABLED=true (enables CSRF protection)
# - WTF_CSRF_CHECK_DEFAULT=false (manual opt-in per endpoint)
# - WTF_CSRF_TIME_LIMIT=None (no token expiration for APIs)
