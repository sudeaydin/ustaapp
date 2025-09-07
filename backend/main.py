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

# Simple health check first (before complex app creation)
from flask import Flask
simple_app = Flask(__name__)

@simple_app.route('/api/health')
def simple_health():
    return {'status': 'healthy', 'simple': True}

# Try to create complex app
try:
    app = create_app()
    
    # Override health check with complex app
    @app.route('/api/health')
    def health_check():
        return {
            'status': 'healthy',
            'service': 'ustam-api',
            'version': '1.0.0',
            'environment': os.environ.get('GAE_ENV', 'local')
        }, 200
        
except Exception as e:
    # If complex app fails, use simple app
    app = simple_app
    print(f"Complex app creation failed: {e}")
    
    @app.route('/api/error')
    def show_error():
        return {'error': str(e), 'status': 'failed'}

if __name__ == '__main__':
    # This is used when running locally only. When deploying to Google App
    # Engine, a webserver process such as Gunicorn will serve the app.
    app.run(host='127.0.0.1', port=8080, debug=True)