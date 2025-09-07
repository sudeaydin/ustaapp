#!/usr/bin/env python3
"""
Basic Flask app for App Engine testing
"""

from flask import Flask, jsonify
import os

# Create Flask app
app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({
        'message': 'Ustam App API',
        'status': 'running',
        'version': '1.0',
        'environment': os.environ.get('GAE_ENV', 'local')
    })

@app.route('/api/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'service': 'ustam-api',
        'timestamp': '2025-09-07'
    })

@app.route('/api/test')
def test():
    return jsonify({
        'message': 'Test endpoint working!',
        'success': True
    })

if __name__ == '__main__':
    # This is used when running locally
    app.run(host='127.0.0.1', port=8080, debug=True)