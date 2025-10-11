"""
Basic Analytics Middleware for ustam App
Handles basic analytics and logging (legacy support)
"""

import os
import logging
from flask import request, g
import time

logger = logging.getLogger(__name__)

def init_analytics_middleware(app):
    """Initialize basic analytics middleware"""
    
    @app.before_request
    def analytics_before_request():
        """Basic analytics before request"""
        g.analytics_start_time = time.time()
        g.request_count = getattr(g, 'request_count', 0) + 1
        
    @app.after_request  
    def analytics_after_request(response):
        """Basic analytics after request"""
        if hasattr(g, 'analytics_start_time'):
            duration = time.time() - g.analytics_start_time
            
            # Basic logging
            logger.info(f"Request: {request.method} {request.path} - "
                       f"Status: {response.status_code} - "
                       f"Duration: {duration:.3f}s")
        
        return response
    
    logger.info("Basic analytics middleware initialized")