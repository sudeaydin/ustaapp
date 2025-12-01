import os
from typing import List

from dotenv import load_dotenv

load_dotenv()

from .cloud_sql import CloudSQLConfigError, CloudSQLSettings, load_cloud_sql_config


def _comma_separated_list(value: str, default: List[str]) -> List[str]:
    """Convert a comma separated string to a list of trimmed values."""
    if not value:
        return default
    items = [item.strip() for item in value.split(',') if item.strip()]
    return items or default
 

def _build_production_db_uri() -> str:
    """Construct a SQLAlchemy URI for Cloud SQL Postgres if credentials exist."""

    default_uri = os.environ.get('DATABASE_URL') or 'sqlite:///ustalar_prod.db'

    settings: CloudSQLSettings = load_cloud_sql_config(validate=False)

    if not all([settings.db_user, settings.db_password, settings.db_name]):
        return default_uri

    if settings.db_host:
        return (
            "postgresql+psycopg2://"
            f"{settings.db_user}:{settings.db_password}"
            f"@{settings.db_host}:{settings.db_port}/{settings.db_name}"
        )

    try:
        unix_socket = settings.resolve_unix_socket()
    except CloudSQLConfigError:
        return default_uri

    return (
        "postgresql+psycopg2://"
        f"{settings.db_user}:{settings.db_password}"
        f"@/{settings.db_name}?host={unix_socket}"
    )

 
class Config:
    """Base configuration"""

    ENVIRONMENT_NAME = os.environ.get('FLASK_CONFIG') or os.environ.get('APP_ENV') or 'development'

    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-this'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///ustalar.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_EXPIRE_ON_COMMIT = False

    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-change-this'
    JWT_ACCESS_TOKEN_EXPIRES = int(os.environ.get('JWT_ACCESS_TOKEN_EXPIRES', 3600))

    # Feature toggles
    RUN_DB_CREATE_ALL = os.environ.get('RUN_DB_CREATE_ALL', 'false').lower() == 'true'
    ENABLE_INIT_DB_ENDPOINT = os.environ.get('ENABLE_INIT_DB_ENDPOINT', 'false').lower() == 'true'
    RATE_LIMIT_REDIS_URL = os.environ.get('RATE_LIMIT_REDIS_URL') or os.environ.get('REDIS_URL')
    RATE_LIMIT_DEFAULT_REQUESTS = int(os.environ.get('RATE_LIMIT_DEFAULT_REQUESTS', 100))
    RATE_LIMIT_DEFAULT_WINDOW = int(os.environ.get('RATE_LIMIT_DEFAULT_WINDOW', 60))

    # CORS
    CORS_ALLOWED_ORIGINS = _comma_separated_list(
        os.environ.get('CORS_ALLOWED_ORIGINS'), ['*']
    )

    # File Upload
    UPLOAD_FOLDER = os.environ.get('UPLOAD_FOLDER') or 'uploads'
    MAX_CONTENT_LENGTH = int(os.environ.get('MAX_CONTENT_LENGTH') or 16_777_216)

    # External Services
    TWILIO_ACCOUNT_SID = os.environ.get('TWILIO_ACCOUNT_SID')
    TWILIO_AUTH_TOKEN = os.environ.get('TWILIO_AUTH_TOKEN')
    IYZICO_API_KEY = os.environ.get('IYZICO_API_KEY')
    IYZICO_SECRET_KEY = os.environ.get('IYZICO_SECRET_KEY')


class DevelopmentConfig(Config):
    """Development configuration"""

    DEBUG = True
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///ustalar_dev.db'
    RUN_DB_CREATE_ALL = True
    ENABLE_INIT_DB_ENDPOINT = True


class TestingConfig(Config):
    """Testing configuration"""

    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    RUN_DB_CREATE_ALL = False
    ENABLE_INIT_DB_ENDPOINT = False


class ProductionConfig(Config):
    """Production configuration"""

    DEBUG = False
    SQLALCHEMY_DATABASE_URI = _build_production_db_uri()
    RUN_DB_CREATE_ALL = False
    ENABLE_INIT_DB_ENDPOINT = False
    CORS_ALLOWED_ORIGINS = _comma_separated_list(
        os.environ.get('CORS_ALLOWED_ORIGINS'),
        [
            'https://ustaapp.com',
            'https://www.ustaapp.com',
            'https://app.ustaapp.com',
        ],
    )


config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig,
}
