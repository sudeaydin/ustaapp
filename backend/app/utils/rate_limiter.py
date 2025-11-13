"""
Rate limiting and account lockout utilities
"""
from datetime import datetime, timedelta
from functools import wraps
from flask import request, jsonify
import logging

# In-memory storage for failed login attempts
# In production, use Redis or database
failed_login_attempts = {}
locked_accounts = {}

# Configuration
MAX_LOGIN_ATTEMPTS = 5
LOCKOUT_DURATION = timedelta(minutes=15)
ATTEMPT_WINDOW = timedelta(minutes=5)

logger = logging.getLogger(__name__)


def get_client_ip():
    """Get client IP address from request"""
    if request.headers.get('X-Forwarded-For'):
        return request.headers.get('X-Forwarded-For').split(',')[0]
    return request.remote_addr


def record_failed_login(email: str):
    """
    Record a failed login attempt for an email address.
    
    Args:
        email: Email address that failed login
    """
    now = datetime.utcnow()
    ip = get_client_ip()
    key = f"{email}:{ip}"
    
    if key not in failed_login_attempts:
        failed_login_attempts[key] = []
    
    # Add current attempt
    failed_login_attempts[key].append(now)
    
    # Remove attempts outside the window
    cutoff = now - ATTEMPT_WINDOW
    failed_login_attempts[key] = [
        attempt for attempt in failed_login_attempts[key]
        if attempt > cutoff
    ]
    
    # Check if account should be locked
    if len(failed_login_attempts[key]) >= MAX_LOGIN_ATTEMPTS:
        lock_account(email, ip)
        logger.warning(f"Account locked due to failed login attempts: {email} from IP: {ip}")


def lock_account(email: str, ip: str):
    """
    Lock an account temporarily.
    
    Args:
        email: Email address to lock
        ip: IP address from which attempts were made
    """
    key = f"{email}:{ip}"
    locked_accounts[key] = datetime.utcnow() + LOCKOUT_DURATION


def is_account_locked(email: str) -> tuple[bool, str]:
    """
    Check if an account is locked.
    
    Args:
        email: Email address to check
        
    Returns:
        Tuple of (is_locked, message)
    """
    ip = get_client_ip()
    key = f"{email}:{ip}"
    
    if key in locked_accounts:
        unlock_time = locked_accounts[key]
        if datetime.utcnow() < unlock_time:
            remaining = (unlock_time - datetime.utcnow()).seconds // 60
            return True, f"Hesap geçici olarak kilitlendi. {remaining} dakika sonra tekrar deneyin."
        else:
            # Unlock expired lock
            del locked_accounts[key]
            if key in failed_login_attempts:
                del failed_login_attempts[key]
    
    return False, ""


def clear_failed_attempts(email: str):
    """
    Clear failed login attempts after successful login.
    
    Args:
        email: Email address to clear
    """
    ip = get_client_ip()
    key = f"{email}:{ip}"
    
    if key in failed_login_attempts:
        del failed_login_attempts[key]
    if key in locked_accounts:
        del locked_accounts[key]


def get_remaining_attempts(email: str) -> int:
    """
    Get number of remaining login attempts.
    
    Args:
        email: Email address to check
        
    Returns:
        Number of remaining attempts
    """
    ip = get_client_ip()
    key = f"{email}:{ip}"
    
    if key not in failed_login_attempts:
        return MAX_LOGIN_ATTEMPTS
    
    # Clean old attempts
    now = datetime.utcnow()
    cutoff = now - ATTEMPT_WINDOW
    failed_login_attempts[key] = [
        attempt for attempt in failed_login_attempts[key]
        if attempt > cutoff
    ]
    
    attempts_used = len(failed_login_attempts[key])
    return max(0, MAX_LOGIN_ATTEMPTS - attempts_used)


def rate_limit_login(f):
    """
    Decorator to add rate limiting to login endpoints.
    
    Usage:
        @rate_limit_login
        @auth_bp.route('/login', methods=['POST'])
        def login():
            ...
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        data = request.get_json()
        email = data.get('email', '')
        
        # Check if account is locked
        is_locked, message = is_account_locked(email)
        if is_locked:
            logger.warning(f"Login attempt on locked account: {email} from IP: {get_client_ip()}")
            return jsonify({
                'success': False,
                'error': message
            }), 429  # Too Many Requests
        
        return f(*args, **kwargs)
    
    return decorated_function


# Cleanup function to be called periodically
def cleanup_old_data():
    """Clean up old failed attempts and expired locks"""
    now = datetime.utcnow()
    cutoff = now - ATTEMPT_WINDOW
    
    # Clean failed attempts
    keys_to_remove = []
    for key, attempts in failed_login_attempts.items():
        failed_login_attempts[key] = [
            attempt for attempt in attempts if attempt > cutoff
        ]
        if not failed_login_attempts[key]:
            keys_to_remove.append(key)
    
    for key in keys_to_remove:
        del failed_login_attempts[key]
    
    # Clean expired locks
    keys_to_remove = []
    for key, unlock_time in locked_accounts.items():
        if now >= unlock_time:
            keys_to_remove.append(key)
    
    for key in keys_to_remove:
        del locked_accounts[key]
    
    logger.info(f"Cleaned up {len(keys_to_remove)} expired entries")
