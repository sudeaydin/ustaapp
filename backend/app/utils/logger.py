import os
import logging
from flask import current_app

class Logger:
    """Production-safe logger utility"""
    
    @staticmethod
    def is_development():
        """Check if we're in development mode"""
        return os.environ.get('FLASK_ENV') == 'development' or current_app.debug
    
    @staticmethod
    def debug(message, *args, **kwargs):
        """Debug level logging - only in development"""
        if Logger.is_development():
            current_app.logger.debug(message, *args, **kwargs)
    
    @staticmethod
    def info(message, *args, **kwargs):
        """Info level logging"""
        current_app.logger.info(message, *args, **kwargs)
    
    @staticmethod
    def warning(message, *args, **kwargs):
        """Warning level logging"""
        current_app.logger.warning(message, *args, **kwargs)
    
    @staticmethod
    def error(message, *args, **kwargs):
        """Error level logging - always logged"""
        current_app.logger.error(message, *args, **kwargs)
    
    @staticmethod
    def print_debug(message):
        """Development-only print statements"""
        if Logger.is_development():
            print(f"[DEBUG] {message}")