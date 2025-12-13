"""
JWT Extension and Error Handling

This module configures Flask-JWT-Extended for the USTAM app.
All JWT-related error handlers and callbacks are centralized here.

Error Response Format:
    All JWT errors return a consistent JSON structure:
    {
        "success": false,
        "error": true,
        "message": "User-friendly message in Turkish",
        "code": "ERROR_CODE"
    }

Usage:
    from app.extensions import jwt, configure_jwt_handlers

    # In app factory
    jwt.init_app(app)
    configure_jwt_handlers(app)
"""

from flask import jsonify
from flask_jwt_extended import JWTManager

# Initialize JWT extension
jwt = JWTManager()


def _jwt_error(message: str, code: str, status: int):
    """
    Helper function to create consistent JWT error responses.

    Args:
        message: User-friendly error message in Turkish
        code: Error code for programmatic handling
        status: HTTP status code

    Returns:
        Tuple of (JSON response, status code)
    """
    return jsonify({
        "success": False,
        "error": True,
        "message": message,
        "code": code
    }), status


def configure_jwt_handlers(app):
    """
    Configure all JWT error handlers and callbacks.

    This function registers error handlers for various JWT-related errors
    including missing tokens, invalid tokens, expired tokens, etc.

    Args:
        app: Flask application instance

    Returns:
        None
    """

    @jwt.unauthorized_loader
    def _missing_jwt_callback(error):
        """
        Handle requests to protected endpoints without a JWT token.

        Triggered when:
        - Authorization header is missing
        - Authorization header doesn't contain "Bearer" prefix

        Returns:
            JSON response with UNAUTHORIZED error code and 401 status
        """
        return _jwt_error('Yetkilendirme gerekli', 'UNAUTHORIZED', 401)

    @jwt.invalid_token_loader
    def _invalid_token_callback(error):
        """
        Handle requests with malformed or invalid JWT tokens.

        Triggered when:
        - Token structure is invalid
        - Token signature verification fails
        - Token is corrupted

        Returns:
            JSON response with INVALID_TOKEN error code and 422 status
        """
        return _jwt_error('Geçersiz token', 'INVALID_TOKEN', 422)

    @jwt.expired_token_loader
    def _expired_token_callback(jwt_header, jwt_payload):
        """
        Handle requests with expired JWT tokens.

        Triggered when:
        - Token expiration time (exp claim) has passed
        - Access token exceeds JWT_ACCESS_TOKEN_EXPIRES
        - Refresh token exceeds JWT_REFRESH_TOKEN_EXPIRES

        Mobile app should attempt to refresh the token using /api/auth/refresh
        endpoint with the refresh token.

        Args:
            jwt_header: Decoded JWT header
            jwt_payload: Decoded JWT payload (contains exp, identity, etc.)

        Returns:
            JSON response with TOKEN_EXPIRED error code and 401 status
        """
        return _jwt_error('Token süresi doldu. Lütfen tekrar giriş yapın', 'TOKEN_EXPIRED', 401)

    @jwt.revoked_token_loader
    def _revoked_token_callback(jwt_header, jwt_payload):
        """
        Handle requests with revoked JWT tokens.

        Triggered when:
        - Token has been explicitly revoked (e.g., logout, password change)
        - Token appears in revocation/blocklist

        Note: Token revocation is not currently implemented but this handler
        is ready for future use.

        Args:
            jwt_header: Decoded JWT header
            jwt_payload: Decoded JWT payload

        Returns:
            JSON response with TOKEN_REVOKED error code and 401 status
        """
        return _jwt_error('Token iptal edildi', 'TOKEN_REVOKED', 401)

    @jwt.token_verification_failed_loader
    def _token_verification_failed_callback(jwt_header, jwt_payload):
        """
        Handle custom token verification failures.

        Triggered when:
        - Custom verification callback returns False
        - Token claims don't meet application requirements
        - Additional verification checks fail

        Args:
            jwt_header: Decoded JWT header
            jwt_payload: Decoded JWT payload

        Returns:
            JSON response with TOKEN_VERIFICATION_FAILED error code and 422 status
        """
        return _jwt_error('Token doğrulama başarısız', 'TOKEN_VERIFICATION_FAILED', 422)

    @jwt.user_identity_loader
    def _user_identity_lookup(identity):
        """
        Convert identity to string for token encoding.

        This callback is called when creating JWT tokens to serialize
        the user identity into the token payload.

        Args:
            identity: User identity (typically user ID)

        Returns:
            String representation of identity, or None if identity is None
        """
        return str(identity) if identity is not None else identity


# Export for convenience
__all__ = ['jwt', 'configure_jwt_handlers']
