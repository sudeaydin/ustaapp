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

# Health check endpoint for App Engine
@app.route('/api/health')
def health_check():
    """Health check endpoint for App Engine"""
    return {
        'status': 'healthy',
        'service': 'ustam-api',
        'version': '1.0.0',
        'environment': os.environ.get('GAE_ENV', 'local')
    }, 200

if __name__ == '__main__':
    # This is used when running locally only. When deploying to Google App
    # Engine, a webserver process such as Gunicorn will serve the app.
    app.run(host='127.0.0.1', port=8080, debug=True)