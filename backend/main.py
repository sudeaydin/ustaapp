#!/usr/bin/env python3
"""
Google App Engine Main Entry Point
"""

import os
import logging

from app import create_app

# Configure logging for App Engine
if os.environ.get('GAE_ENV', '').startswith('standard'):
    # Production on App Engine
    logging.basicConfig(level=logging.INFO)
    try:
        import google.cloud.logging
        client = google.cloud.logging.Client()
        client.setup_logging()
    except ImportError:
        # Fallback to basic logging if google-cloud-logging not available
        logging.basicConfig(level=logging.INFO)

# Create Flask app
app = create_app()

if app.config.get('RUN_DB_CREATE_ALL'):
    # Initialize database tables for non-production environments
    with app.app_context():
        from app import db

        db.create_all()

# Health check endpoint for App Engine
@app.route('/api/health')
def health_check():
    """Health check endpoint for App Engine"""
    database_uri = app.config.get('SQLALCHEMY_DATABASE_URI', '')
    if database_uri.startswith('postgresql'):
        database_backend = 'postgresql'
    elif database_uri.startswith('mysql'):
        database_backend = 'mysql'
    elif database_uri.startswith('sqlite'):
        database_backend = 'sqlite'
    else:
        database_backend = 'unknown'

    return {
        'status': 'healthy',
        'service': 'ustam-api',
        'version': '1.0.0',
        'environment': app.config.get('ACTIVE_CONFIG_NAME', 'unknown'),
        'database': database_backend,
    }, 200

_is_dev_environment = (
    str(app.config.get('ENVIRONMENT_NAME', '')).lower() == 'development'
    or str(app.config.get('ACTIVE_CONFIG_NAME', '')).lower() in {'development', 'default'}
)

if app.config.get('ENABLE_INIT_DB_ENDPOINT') and _is_dev_environment:

    @app.route('/api/init-db')
    def init_database():
        """Initialize database with sample data"""
        try:
            from app import db
            from app.models.user import User
            from app.models.category import Category
            from datetime import datetime

            # Create sample data
            if User.query.count() == 0:
                # Create sample user
                from werkzeug.security import generate_password_hash

                sample_user = User(
                    email='admin@ustam.app',
                    password_hash=generate_password_hash('admin123'),
                    first_name='Admin',
                    last_name='User',
                    phone='05551234567',
                    user_type='admin',
                    is_active=True,
                    created_at=datetime.utcnow()
                )
                db.session.add(sample_user)

                # Create sample category
                sample_category = Category(
                    name='Elektrik',
                    description='Elektrik işleri',
                    icon='electrical_services',
                    is_active=True,
                    created_at=datetime.utcnow()
                )
                db.session.add(sample_category)

                db.session.commit()

            return {
                'status': 'success',
                'message': 'Database initialized with sample data',
                'users': User.query.count(),
                'categories': Category.query.count()
            }, 200

        except Exception as e:
            return {
                'status': 'error',
                'message': f'Database initialization failed: {str(e)}'
            }, 500
elif app.config.get('ENABLE_INIT_DB_ENDPOINT') and not _is_dev_environment:
    logging.info('ENABLE_INIT_DB_ENDPOINT is set but disabled outside development environment')

if __name__ == '__main__':
    # This is used when running locally only. When deploying to Google App
    # Engine, a webserver process such as Gunicorn will serve the app.
    app.run(
        host=os.environ.get('HOST', '127.0.0.1'),
        port=int(os.environ.get('PORT', 8080)),
        debug=bool(app.config.get('DEBUG')),
    )
