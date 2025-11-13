# 🔒 Security Implementation Guide

## Overview
This document outlines the security features implemented in the application and how to configure them.

## ✅ Implemented Security Features

### 1. Password Security
- **Location**: `app/utils/password_validator.py`
- **Features**:
  - Minimum 8 characters, maximum 128 (DoS prevention)
  - Must contain uppercase, lowercase, number, and special character
  - Blocks 25+ common/weak passwords
  - Prevents sequential characters (123, abc, etc.)
  - Prevents excessive repeated characters (aaa, 111, etc.)
  - Password strength calculator with user feedback
  - Turkish and English error messages

### 2. Brute Force Protection
- **Location**: `app/utils/rate_limiter.py`
- **Features**:
  - Maximum 5 failed login attempts per 5 minutes
  - 15-minute temporary account lockout
  - IP-based tracking
  - Shows remaining attempts to users
  - Automatic cleanup of old data
  - Logging of suspicious activities

### 3. API Rate Limiting
- **Package**: Flask-Limiter
- **Default Limits**: 200 requests/day, 50 requests/hour
- **Storage**: Memory (ready for Redis migration)
- **Applied**: Globally to all endpoints

### 4. CORS Security
- **Configuration**: Environment-based
- **Development**: Allows localhost
- **Production**: Requires specific domain configuration
- **Preflight Caching**: 1 hour

### 5. Environment Variables
- **Files**: `.env.example`, `.env.production.example`
- **Protected**: All sensitive data moved to environment variables
- **Git**: .env files are gitignored

## 🚀 Setup Instructions

### Development Setup

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Update the values in `.env`:
```bash
SECRET_KEY=$(python -c 'import secrets; print(secrets.token_hex(32))')
JWT_SECRET_KEY=$(python -c 'import secrets; print(secrets.token_hex(32))')
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Run the application:
```bash
flask run
```

### Production Setup

1. Copy the production example:
```bash
cp .env.production.example .env
```

2. Generate secure keys:
```bash
# Generate SECRET_KEY
python -c 'import secrets; print("SECRET_KEY=" + secrets.token_urlsafe(32))'

# Generate JWT_SECRET_KEY
python -c 'import secrets; print("JWT_SECRET_KEY=" + secrets.token_urlsafe(32))'
```

3. Update critical values:
   - `DATABASE_URL`: PostgreSQL connection string
   - `ALLOWED_ORIGINS`: Your actual domain(s)
   - `RATE_LIMIT_STORAGE`: Redis connection string
   - `MAIL_*`: Email service credentials
   - All other sensitive credentials

4. Set environment variables (choose one method):

   **Option A: Export in shell**
   ```bash
   export $(cat .env | xargs)
   ```

   **Option B: Use systemd service**
   ```ini
   [Service]
   EnvironmentFile=/path/to/.env
   ```

   **Option C: Use Docker**
   ```yaml
   environment:
     - SECRET_KEY=${SECRET_KEY}
     - DATABASE_URL=${DATABASE_URL}
   ```

## 🔐 Security Checklist

### Before Production Deployment

- [ ] Generate new SECRET_KEY and JWT_SECRET_KEY
- [ ] Update DATABASE_URL to PostgreSQL
- [ ] Configure ALLOWED_ORIGINS with actual domains
- [ ] Set up Redis for rate limiting
- [ ] Configure email service (SendGrid, AWS SES, etc.)
- [ ] Enable HSTS (ENABLE_HSTS=True)
- [ ] Set FLASK_ENV=production and FLASK_DEBUG=False
- [ ] Set up SSL/TLS certificates
- [ ] Configure database backups
- [ ] Set up monitoring (Sentry, New Relic, etc.)
- [ ] Review and test all security features
- [ ] Remove all test/demo users from database
- [ ] Configure firewall rules
- [ ] Set up DDoS protection (Cloudflare, AWS Shield)
- [ ] Enable database connection pooling
- [ ] Configure proper logging
- [ ] Set up intrusion detection
- [ ] Review and update CORS origins
- [ ] Enable Content Security Policy headers
- [ ] Configure session timeout
- [ ] Test rate limiting
- [ ] Test account lockout mechanism
- [ ] Perform security audit
- [ ] Penetration testing

## 🛡️ Security Features in Detail

### Password Validation

**Registration Example:**
```python
from app.utils.password_validator import validate_password_strength

is_valid, error_message = validate_password_strength(password)
if not is_valid:
    return jsonify({'error': error_message}), 400
```

**Strength Calculator:**
```python
from app.utils.password_validator import calculate_password_strength

strength_info = calculate_password_strength(password)
# Returns: {'score': 85, 'strength': 'Çok Güçlü', 'color': 'green', 'feedback': []}
```

### Rate Limiting

**Login Protection:**
```python
from app.utils.rate_limiter import rate_limit_login

@auth_bp.route('/login', methods=['POST'])
@rate_limit_login  # Automatically blocks after 5 failed attempts
def login():
    # ... login logic
```

**Manual Usage:**
```python
from app.utils.rate_limiter import (
    record_failed_login,
    is_account_locked,
    clear_failed_attempts,
    get_remaining_attempts
)

# Check if account is locked
is_locked, message = is_account_locked(email)

# Record failed attempt
record_failed_login(email)

# Get remaining attempts
remaining = get_remaining_attempts(email)

# Clear attempts on successful login
clear_failed_attempts(email)
```

### Global Rate Limiting

```python
from app import limiter

# Apply custom rate limit to specific endpoint
@app.route('/api/expensive-operation')
@limiter.limit("10 per minute")
def expensive_operation():
    # ... operation logic
```

## 📊 Monitoring

### Failed Login Attempts
Monitor failed login attempts in your logs:
```bash
grep "LOGIN FAILED" logs/app.log
grep "Account locked" logs/app.log
```

### Rate Limit Hits
```bash
grep "rate limit" logs/app.log
```

### Suspicious Activity
```bash
grep "BLOCKED" logs/app.log
grep "suspicious" logs/app.log
```

## 🔧 Maintenance

### Cleanup Old Data
Rate limiter automatically cleans up old data. For manual cleanup:
```python
from app.utils.rate_limiter import cleanup_old_data

cleanup_old_data()
```

### Database Backups
```bash
# PostgreSQL backup
pg_dump -U username -d database_name > backup_$(date +%Y%m%d).sql

# Restore from backup
psql -U username -d database_name < backup_20250113.sql
```

## 🚨 Incident Response

### Account Compromise
1. Immediately lock the account
2. Force password reset
3. Invalidate all active sessions
4. Review access logs
5. Notify user via email

### Brute Force Attack Detected
1. Check source IPs in logs
2. Consider IP blocking
3. Review rate limiting settings
4. Enable additional security measures
5. Notify security team

### Data Breach
1. Follow incident response plan
2. Notify affected users (KVKK requirement)
3. Investigate breach vector
4. Patch vulnerabilities
5. Review and enhance security

## 📞 Security Contacts

- **Security Team**: security@yourdomain.com
- **Emergency**: +90 xxx xxx xxxx
- **Bug Bounty**: https://yourdomain.com/security

## 🔗 Related Documents

- [PRODUCTION_SECURITY_CHECKLIST.md](../PRODUCTION_SECURITY_CHECKLIST.md)
- [KVKK Compliance](../legal_documents/kvkk.md)
- [API Documentation](../docs/API.md)

## 📝 Version History

### v1.0.0 (2025-01-13)
- Initial security implementation
- Password validation
- Rate limiting
- Brute force protection
- CORS security
- Environment variable configuration

---

**Last Updated**: 2025-01-13  
**Security Contact**: security@yourdomain.com
