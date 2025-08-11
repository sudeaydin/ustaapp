# 📚 UstamApp API Dokümantasyonu

## 🌐 **Base URL**
- **Development**: `http://localhost:5000/api`
- **Production**: `https://api.ustamapp.com/api`

## 🔐 **Kimlik Doğrulama**

Tüm korumalı endpoint'ler için JWT token gereklidir:
```
Authorization: Bearer <your_jwt_token>
```

## 📋 **Standart Yanıt Formatı**

### Başarılı Yanıt
```json
{
  "success": true,
  "data": {
    // Endpoint'e özel veri
  }
}
```

### Hata Yanıtı
```json
{
  "success": false,
  "error": true,
  "message": "Hata mesajı",
  "code": "ERROR_CODE"
}
```

## 🔑 **Kimlik Doğrulama Endpoints**

### POST `/auth/register`
Yeni kullanıcı kaydı oluşturur.

**Request Body:**
```json
{
  "email": "user@example.com",
  "phone": "+905551234567",
  "password": "securepassword",
  "first_name": "Ad",
  "last_name": "Soyad",
  "user_type": "customer|craftsman",
  
  // Customer için ek alanlar
  "billing_address": "Fatura adresi",
  "city": "İstanbul",
  "district": "Kadıköy",
  
  // Craftsman için ek alanlar
  "business_name": "İşletme Adı",
  "description": "İşletme açıklaması",
  "specialties": "Elektrik, Tesisatçılık",
  "experience_years": 5,
  "hourly_rate": 150.0
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "first_name": "Ad",
      "last_name": "Soyad",
      "user_type": "customer",
      "is_active": true
    },
    "profile": {
      // Customer veya Craftsman profil bilgileri
    }
  }
}
```

### POST `/auth/login`
Kullanıcı girişi yapar.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "user_type": "customer"
    }
  }
}
```

### GET `/auth/profile`
Kullanıcı profil bilgilerini getirir.

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "first_name": "Ad",
      "last_name": "Soyad",
      "user_type": "customer"
    },
    "profile": {
      // Customer veya Craftsman profil detayları
    }
  }
}
```

### DELETE `/auth/delete-account`
Kullanıcı hesabını kalıcı olarak siler.

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Hesabınız başarıyla silindi"
  }
}
```

## 🔍 **Arama Endpoints**

### GET `/search/craftsmen`
Usta arama ve filtreleme yapar.

**Query Parameters:**
- `query` (string): Arama terimi
- `city` (string): Şehir filtresi
- `category` (string): Kategori filtresi
- `min_rating` (float): Minimum rating (0-5)
- `max_rate` (float): Maksimum saat ücreti
- `is_available` (boolean): Müsaitlik durumu
- `is_verified` (boolean): Doğrulanmış ustalar
- `page` (int): Sayfa numarası (default: 1)
- `per_page` (int): Sayfa başına sonuç (default: 20, max: 100)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "craftsmen": [
      {
        "id": 1,
        "business_name": "Ahmet Elektrik",
        "description": "Profesyonel elektrik hizmetleri",
        "specialties": "Elektrik, Aydınlatma",
        "city": "İstanbul",
        "district": "Şişli",
        "average_rating": 4.5,
        "total_jobs": 25,
        "hourly_rate": 150.0,
        "is_available": true,
        "is_verified": true,
        "portfolio_images": [
          "https://example.com/image1.jpg"
        ],
        "user": {
          "first_name": "Ahmet",
          "last_name": "Yılmaz"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 45,
      "pages": 3,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

### GET `/search/craftsmen/{craftsman_id}`
Belirli bir ustanın detay bilgilerini getirir.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "craftsman": {
      // Craftsman detay bilgileri
      "id": 1,
      "business_name": "Ahmet Elektrik",
      "description": "Detaylı açıklama",
      "experience_years": 10,
      "completed_jobs": [
        {
          "id": 1,
          "title": "Salon elektrik tesisatı",
          "completion_date": "2024-01-15",
          "customer_rating": 5
        }
      ]
    }
  }
}
```

### GET `/search/categories`
Mevcut kategorileri listeler.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "categories": [
      "Elektrik",
      "Tesisatçılık",
      "Boyacılık",
      "Marangozluk",
      "Temizlik"
    ]
  }
}
```

### GET `/search/locations`
Mevcut şehirleri listeler.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "locations": [
      {
        "city": "İstanbul",
        "districts": ["Kadıköy", "Beşiktaş", "Şişli"]
      },
      {
        "city": "Ankara",
        "districts": ["Çankaya", "Keçiören", "Yenimahalle"]
      }
    ]
  }
}
```

## 💬 **Teklif Sistemi Endpoints**

### POST `/quotes/create-request`
Yeni teklif talebi oluşturur.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "craftsman_id": 1,
  "category": "Elektrik",
  "area_type": "salon|mutfak|banyo|yatak_odasi|balkon|teras|bahce|ofis|diger",
  "square_meters": 50,
  "budget_range": "0-1000|1000-3000|3000-5000|5000-10000|10000+",
  "description": "İş açıklaması",
  "additional_details": "Ek detaylar (opsiyonel)"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "quote": {
      "id": 1,
      "status": "PENDING",
      "category": "Elektrik",
      "area_type": "salon",
      "budget_range": "1000-3000",
      "description": "İş açıklaması",
      "created_at": "2024-01-20T10:30:00Z"
    },
    "message": "Teklif talebiniz başarıyla gönderildi"
  }
}
```

### POST `/quotes/{quote_id}/respond`
Usta teklif talebine yanıt verir.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "response_type": "give_quote|request_details|reject",
  "quoted_amount": 2500.0,
  "response_details": "Detaylı açıklama",
  "estimated_start_date": "2024-02-01",
  "estimated_end_date": "2024-02-03"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "quote": {
      "id": 1,
      "status": "QUOTED|DETAILS_REQUESTED|REJECTED",
      "quoted_amount": 2500.0,
      "response_details": "Detaylı açıklama",
      "updated_at": "2024-01-20T11:00:00Z"
    }
  }
}
```

### POST `/quotes/{quote_id}/decision`
Müşteri teklif kararı verir.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "decision": "accept|reject|request_revision",
  "revision_notes": "Revizyon notları (opsiyonel)"
}
```

### GET `/quotes/my-quotes`
Kullanıcının tekliflerini listeler.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `status`: Durum filtresi
- `page`: Sayfa numarası
- `per_page`: Sayfa başına sonuç

**Response (200):**
```json
{
  "success": true,
  "data": {
    "quotes": [
      {
        "id": 1,
        "status": "PENDING",
        "category": "Elektrik",
        "quoted_amount": 2500.0,
        "craftsman": {
          "business_name": "Ahmet Elektrik",
          "user": {
            "first_name": "Ahmet",
            "last_name": "Yılmaz"
          }
        }
      }
    ]
  }
}
```

## 📤 **Dosya Yükleme Endpoints**

### POST `/auth/upload-portfolio-image`
Portfolio resmi yükler (sadece ustalar için).

**Headers:** 
- `Authorization: Bearer <token>`
- `Content-Type: multipart/form-data`

**Request Body:**
- `image`: Resim dosyası (PNG, JPG, JPEG, GIF, WEBP - Max 5MB)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "image_url": "/uploads/portfolio/abc123def456.jpg",
    "message": "Resim başarıyla yüklendi"
  }
}
```

### DELETE `/auth/delete-portfolio-image`
Portfolio resmini siler.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "image_url": "/uploads/portfolio/abc123def456.jpg"
}
```

## ⚠️ **Hata Kodları**

| Kod | Açıklama |
|-----|----------|
| `VALIDATION_ERROR` | Giriş verisi doğrulama hatası |
| `INVALID_CREDENTIALS` | Geçersiz email/şifre |
| `USER_NOT_FOUND` | Kullanıcı bulunamadı |
| `UNAUTHORIZED` | Yetkisiz erişim |
| `RATE_LIMIT_EXCEEDED` | İstek sınırı aşıldı |
| `FILE_TOO_LARGE` | Dosya boyutu fazla |
| `INVALID_FILE_TYPE` | Geçersiz dosya tipi |
| `QUOTE_NOT_FOUND` | Teklif bulunamadı |
| `INVALID_QUOTE_STATUS` | Geçersiz teklif durumu |
| `SERVER_ERROR` | Sunucu hatası |

## 🔄 **Teklif Durum Akışı**

```
PENDING → DETAILS_REQUESTED → PENDING
PENDING → QUOTED → ACCEPTED → COMPLETED
PENDING → QUOTED → REJECTED
PENDING → QUOTED → REVISION_REQUESTED → QUOTED
PENDING → REJECTED
```

## 📊 **Pagination**

Sayfalama destekleyen endpoint'ler için:

**Query Parameters:**
- `page`: Sayfa numarası (1'den başlar)
- `per_page`: Sayfa başına öğe sayısı (default: 20, max: 100)

**Response:**
```json
{
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "pages": 8,
    "has_next": true,
    "has_prev": false
  }
}
```

## 🔧 **Rate Limiting**

| Endpoint Grubu | Limit |
|----------------|-------|
| Auth endpoints | 10 req/min |
| Search endpoints | 60 req/min |
| Quote endpoints | 30 req/min |
| Upload endpoints | 5 req/min |
| General | 100 req/min |

## 🎯 **Örnek Kullanım**

### JavaScript ile Teklif Talebi
```javascript
const response = await fetch('/api/quotes/create-request', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    craftsman_id: 1,
    category: 'Elektrik',
    area_type: 'salon',
    square_meters: 50,
    budget_range: '1000-3000',
    description: 'Salon elektrik tesisatı yenilenmesi'
  })
})

const result = await response.json()
if (result.success) {
  console.log('Teklif talebi gönderildi:', result.data.quote)
}
```

### Flutter ile Usta Arama
```dart
final response = await ApiService().searchCraftsmen(
  query: 'elektrik',
  city: 'İstanbul',
  page: 1,
  perPage: 20
);

if (response.isSuccess) {
  final craftsmen = response.data['craftsmen'];
  // Usta listesini göster
}
```

## 🐛 **Hata Ayıklama**

### Yaygın Hatalar ve Çözümleri

**401 Unauthorized**
- Token'ın süresi dolmuş olabilir
- Token format'ı yanlış olabilir
- `Authorization` header'ı eksik olabilir

**400 Bad Request**
- Request body format'ı yanlış
- Gerekli alanlar eksik
- Veri tipleri uyumsuz

**429 Too Many Requests**
- Rate limit aşıldı
- 15 dakika bekleyip tekrar deneyin

**500 Internal Server Error**
- Sunucu hatası
- Loglara bakın veya destek ekibi ile iletişime geçin

## 📞 **Destek**

API ile ilgili sorularınız için:
- **Email**: api-support@ustamapp.com
- **GitHub Issues**: [github.com/sudeaydin/ustaapp/issues](https://github.com/sudeaydin/ustaapp/issues)
- **API Status**: [status.ustamapp.com](https://status.ustamapp.com)
