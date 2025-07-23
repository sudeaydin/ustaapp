# Ustalar API Dokümantasyonu

## Base URL
- **Development**: `http://localhost:5000/api`
- **Production**: `https://api.ustalar.com/api`

## Authentication

Tüm korumalı endpoint'ler için Authorization header'ında JWT token gereklidir:

```
Authorization: Bearer <your-jwt-token>
```

## Error Responses

Tüm hata yanıtları şu formatta döner:

```json
{
  "error": true,
  "message": "Hata mesajı",
  "code": "ERROR_CODE",
  "details": {}
}
```

## Success Responses

Başarılı yanıtlar şu formatta döner:

```json
{
  "success": true,
  "data": {},
  "message": "İşlem başarılı"
}
```

## Endpoints

### Authentication

#### POST /auth/register
Yeni kullanıcı kaydı

**Request Body:**
```json
{
  "email": "user@example.com",
  "phone": "+905551234567",
  "password": "password123",
  "first_name": "Ahmet",
  "last_name": "Yılmaz",
  "user_type": "customer"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "phone": "+905551234567",
      "user_type": "customer",
      "first_name": "Ahmet",
      "last_name": "Yılmaz",
      "is_verified": false
    },
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

#### POST /auth/login
Kullanıcı girişi

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "user_type": "customer",
      "first_name": "Ahmet",
      "last_name": "Yılmaz"
    },
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

### Categories

#### GET /categories
Hizmet kategorilerini listele

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Fayans",
      "description": "Banyo ve mutfak fayans işleri",
      "icon": "tiles",
      "color": "#3498db",
      "is_active": true
    }
  ]
}
```

### Services

#### GET /services
Hizmetleri listele/ara

**Query Parameters:**
- `category_id`: Kategori ID'si
- `city`: Şehir
- `search`: Arama terimi
- `page`: Sayfa numarası (default: 1)
- `limit`: Sayfa başına kayıt (default: 20)

**Response:**
```json
{
  "success": true,
  "data": {
    "services": [
      {
        "id": 1,
        "title": "Banyo Fayans Döşeme",
        "description": "Profesyonel banyo fayans döşeme hizmeti",
        "price_min": 50,
        "price_max": 100,
        "price_unit": "per_m2",
        "craftsman": {
          "id": 1,
          "first_name": "Mehmet",
          "last_name": "Usta",
          "rating": 4.8,
          "review_count": 156
        },
        "category": {
          "id": 1,
          "name": "Fayans",
          "icon": "tiles"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "pages": 5,
      "per_page": 20,
      "total": 95
    }
  }
}
```

#### GET /services/:id
Hizmet detayı

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Banyo Fayans Döşeme",
    "description": "Profesyonel banyo fayans döşeme hizmeti. 15 yıllık deneyim.",
    "price_min": 50,
    "price_max": 100,
    "price_unit": "per_m2",
    "images": [
      "https://example.com/image1.jpg",
      "https://example.com/image2.jpg"
    ],
    "craftsman": {
      "id": 1,
      "first_name": "Mehmet",
      "last_name": "Usta",
      "profile_image": "https://example.com/profile.jpg",
      "rating": 4.8,
      "review_count": 156,
      "experience_years": 15,
      "location": "İstanbul, Kadıköy"
    }
  }
}
```

### Quotes

#### POST /quotes
Teklif talebi gönder

**Request Body:**
```json
{
  "service_id": 1,
  "description": "20m2 banyo fayans döşemesi gerekiyor",
  "budget_min": 800,
  "budget_max": 1200,
  "preferred_date": "2024-02-15",
  "address": "Kadıköy, İstanbul",
  "phone": "+905551234567"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "service_id": 1,
    "status": "pending",
    "description": "20m2 banyo fayans döşemesi gerekiyor",
    "budget_min": 800,
    "budget_max": 1200,
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

#### GET /quotes
Kullanıcının tekliflerini listele

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "service": {
        "id": 1,
        "title": "Banyo Fayans Döşeme"
      },
      "craftsman": {
        "id": 1,
        "first_name": "Mehmet",
        "last_name": "Usta"
      },
      "status": "pending",
      "description": "20m2 banyo fayans döşemesi",
      "price": null,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

#### PUT /quotes/:id
Teklifi güncelle (usta tarafından)

**Request Body:**
```json
{
  "status": "accepted",
  "price": 1000,
  "notes": "İş 2 gün içinde tamamlanacak"
}
```

### Craftsman Profile

#### GET /craftsman/profile
Usta profil bilgisi (korumalı)

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "first_name": "Mehmet",
    "last_name": "Usta",
    "email": "mehmet@example.com",
    "phone": "+905551234567",
    "profile_image": "https://example.com/profile.jpg",
    "bio": "15 yıllık deneyimli fayans ustası",
    "experience_years": 15,
    "location": "İstanbul, Kadıköy",
    "rating": 4.8,
    "review_count": 156,
    "subscription_status": "active",
    "subscription_expires_at": "2024-02-15T00:00:00Z",
    "categories": [
      {
        "id": 1,
        "name": "Fayans"
      }
    ]
  }
}
```

#### PUT /craftsman/profile
Usta profil güncelleme (korumalı)

**Request Body:**
```json
{
  "bio": "20 yıllık deneyimli fayans ustası",
  "experience_years": 20,
  "location": "İstanbul, Üsküdar"
}
```

### Messages

#### GET /messages/conversations
Konuşma listesi (korumalı)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "other_user": {
        "id": 2,
        "first_name": "Ahmet",
        "last_name": "Müşteri",
        "profile_image": "https://example.com/profile.jpg"
      },
      "last_message": {
        "content": "Merhaba, ne zaman başlayabiliriz?",
        "created_at": "2024-01-15T14:30:00Z"
      },
      "unread_count": 2
    }
  ]
}
```

#### GET /messages/conversations/:id
Konuşma detayı (korumalı)

**Response:**
```json
{
  "success": true,
  "data": {
    "conversation_id": 1,
    "messages": [
      {
        "id": 1,
        "sender_id": 1,
        "content": "Merhaba, teklif için teşekkürler",
        "created_at": "2024-01-15T14:25:00Z"
      },
      {
        "id": 2,
        "sender_id": 2,
        "content": "Merhaba, ne zaman başlayabiliriz?",
        "created_at": "2024-01-15T14:30:00Z"
      }
    ]
  }
}
```

#### POST /messages
Mesaj gönder (korumalı)

**Request Body:**
```json
{
  "recipient_id": 2,
  "content": "Yarın sabah başlayabiliriz"
}
```

## Status Codes

- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `500` - Internal Server Error

## Rate Limiting

- Genel API: 1000 request/saat
- Authentication: 10 request/dakika
- Message: 100 request/dakika
