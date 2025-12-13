# JWT Error Handling

This document describes the JWT (JSON Web Token) error handling implemented in the USTAM backend API.

## Overview

The application uses Flask-JWT-Extended for JWT authentication. All JWT-related errors are handled consistently with standardized error responses that the mobile app can parse and display appropriately.

## Error Response Format

All JWT errors return a JSON response with the following structure:

```json
{
  "success": false,
  "error": true,
  "message": "User-friendly error message in Turkish",
  "code": "ERROR_CODE"
}
```

## JWT Error Types

### 1. UNAUTHORIZED (401)
**Trigger**: Request to protected endpoint without JWT token
**Error Code**: `UNAUTHORIZED`
**HTTP Status**: `401`

**Example Request**:
```bash
GET /api/craftsman/profile
# Missing Authorization header
```

**Response**:
```json
{
  "success": false,
  "error": true,
  "message": "Yetkilendirme gerekli",
  "code": "UNAUTHORIZED"
}
```

**Mobile App Handling**: Redirect user to login screen

---

### 2. INVALID_TOKEN (422)
**Trigger**: JWT token is malformed, corrupted, or has invalid signature
**Error Code**: `INVALID_TOKEN`
**HTTP Status**: `422`

**Example Request**:
```bash
GET /api/craftsman/profile
Authorization: Bearer invalid_or_malformed_token
```

**Response**:
```json
{
  "success": false,
  "error": true,
  "message": "Geçersiz token",
  "code": "INVALID_TOKEN"
}
```

**Mobile App Handling**: Clear stored token and redirect to login

---

### 3. TOKEN_EXPIRED (401) ⭐ NEW
**Trigger**: JWT token has expired (exceeded JWT_ACCESS_TOKEN_EXPIRES)
**Error Code**: `TOKEN_EXPIRED`
**HTTP Status**: `401`

**Example Request**:
```bash
GET /api/craftsman/profile
Authorization: Bearer <expired_token>
```

**Response**:
```json
{
  "success": false,
  "error": true,
  "message": "Token süresi doldu. Lütfen tekrar giriş yapın",
  "code": "TOKEN_EXPIRED"
}
```

**Mobile App Handling**:
1. Attempt to refresh token using `/api/auth/refresh` endpoint with refresh token
2. If refresh fails, clear tokens and redirect to login
3. Show message: "Oturumunuz sonlanmıştır, lütfen tekrar giriş yapın"

---

### 4. TOKEN_REVOKED (401)
**Trigger**: JWT token has been explicitly revoked (requires token revocation to be implemented)
**Error Code**: `TOKEN_REVOKED`
**HTTP Status**: `401`

**Response**:
```json
{
  "success": false,
  "error": true,
  "message": "Token iptal edildi",
  "code": "TOKEN_REVOKED"
}
```

**Mobile App Handling**: Clear stored tokens and redirect to login with message about security

**Note**: Token revocation is not currently implemented but the handler is ready for future use.

---

### 5. TOKEN_VERIFICATION_FAILED (422)
**Trigger**: Token signature verification failed or custom verification checks failed
**Error Code**: `TOKEN_VERIFICATION_FAILED`
**HTTP Status**: `422`

**Response**:
```json
{
  "success": false,
  "error": true,
  "message": "Token doğrulama başarısız",
  "code": "TOKEN_VERIFICATION_FAILED"
}
```

**Mobile App Handling**: Clear stored token and redirect to login

---

## Token Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| `JWT_ACCESS_TOKEN_EXPIRES` | 3600 seconds (1 hour) | Access token lifetime |
| `JWT_SECRET_KEY` | Environment variable | Secret key for signing tokens |

## Mobile App Integration

### Recommended Token Flow

```
1. User logs in → Receive access_token and refresh_token
2. Store both tokens securely
3. Make API requests with access_token in Authorization header
4. If TOKEN_EXPIRED response:
   a. Try POST /api/auth/refresh with refresh_token
   b. If successful, update access_token
   c. Retry original request
   d. If refresh fails, redirect to login
5. If any other token error, clear tokens and redirect to login
```

### Example Mobile Code (Pseudo-code)

```dart
Future<Response> makeAuthenticatedRequest(String endpoint) async {
  try {
    final response = await http.get(
      endpoint,
      headers: {'Authorization': 'Bearer ${accessToken}'}
    );

    if (response.statusCode == 401) {
      final body = jsonDecode(response.body);

      if (body['code'] == 'TOKEN_EXPIRED') {
        // Try to refresh token
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Retry original request
          return await makeAuthenticatedRequest(endpoint);
        }
      }

      // Any auth error - redirect to login
      navigateToLogin();
      return null;
    }

    return response;
  } catch (e) {
    // Handle network errors
  }
}
```

## Testing JWT Error Handlers

You can test the error handlers using curl:

```bash
# Test missing token
curl -X GET http://localhost:5000/api/craftsman/profile

# Test invalid token
curl -X GET http://localhost:5000/api/craftsman/profile \
  -H "Authorization: Bearer invalid_token"

# Test expired token (create one in Python first)
python3 -c "
from app import create_app
from flask_jwt_extended import create_access_token
import datetime

app = create_app()
with app.app_context():
    token = create_access_token(
        identity='test',
        expires_delta=datetime.timedelta(seconds=-1)
    )
    print(token)
"

# Then use the printed token
curl -X GET http://localhost:5000/api/craftsman/profile \
  -H "Authorization: Bearer <expired_token>"
```

## Implementation Details

**File**: `backend/app/__init__.py` (lines 41-88)

All JWT error handlers are registered during app initialization using Flask-JWT-Extended decorators:
- `@jwt.unauthorized_loader`
- `@jwt.invalid_token_loader`
- `@jwt.expired_token_loader` ⭐ NEW
- `@jwt.revoked_token_loader` ⭐ NEW
- `@jwt.token_verification_failed_loader` ⭐ NEW

## Security Notes

1. **Error messages are in Turkish** for user-facing display
2. **Error codes are in English** for programmatic handling
3. **HTTP status codes follow REST conventions**:
   - `401` = Authentication required or failed
   - `422` = Token is syntactically valid but semantically invalid
4. **Token expiration is 1 hour** by default (configurable via `JWT_ACCESS_TOKEN_EXPIRES`)
5. **Refresh tokens** should be stored securely and used only for token refresh

## Future Enhancements

- [ ] Implement token revocation list (blacklist)
- [ ] Add token refresh rotation (one-time use refresh tokens)
- [ ] Implement sliding session expiration
- [ ] Add device-specific tokens for multi-device logout
- [ ] Log suspicious token activity (multiple failed attempts)
