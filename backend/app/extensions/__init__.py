"""
Flask Extensions Module

This module centralizes all Flask extension instances for the USTAM app.
Extensions are initialized here and configured in their respective modules.
"""

from flask_sqlalchemy import SQLAlchemy
from flask_socketio import SocketIO
from flask_wtf.csrf import CSRFProtect

from .jwt_extension import jwt, configure_jwt_handlers

# Database
db = SQLAlchemy(session_options={'expire_on_commit': False})

# WebSocket
socketio = SocketIO()

# CSRF Protection
csrf = CSRFProtect()

# JWT is imported from jwt_extension module
# jwt, configure_jwt_handlers


def init_extensions(app, cors_origins=None):
    """
    Initialize all Flask extensions with the app instance.

    This function initializes all extensions in the correct order and
    configures JWT error handlers.

    Args:
        app: Flask application instance
        cors_origins: Optional list of CORS origins for SocketIO (default: ['*'])

    Returns:
        None
    """
    # Initialize core extensions
    db.init_app(app)
    jwt.init_app(app)
    csrf.init_app(app)

    # Configure JWT error handlers and callbacks
    configure_jwt_handlers(app)

    # Initialize SocketIO with CORS configuration
    if cors_origins is None:
        cors_origins = ['*']
    socketio.init_app(app, cors_allowed_origins=cors_origins)


__all__ = [
    'db',
    'jwt',
    'socketio',
    'csrf',
    'configure_jwt_handlers',
    'init_extensions'
]
