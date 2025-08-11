from datetime import datetime, timezone
from urllib.parse import quote
from app.models.craftsman import Craftsman
from app.models.category import Category
from app.models.user import User
from app import db

class SEOManager:
    """SEO utilities for dynamic content generation"""
    
    @staticmethod
    def generate_sitemap():
        """Generate dynamic sitemap based on database content"""
        base_url = "https://ustamapp.com"
        urls = []
        
        # Static pages with high priority
        static_pages = [
            {"url": "/", "priority": 1.0, "changefreq": "daily"},
            {"url": "/landing", "priority": 0.9, "changefreq": "weekly"},
            {"url": "/search", "priority": 0.9, "changefreq": "daily"},
            {"url": "/craftsmen", "priority": 0.8, "changefreq": "daily"},
            {"url": "/about", "priority": 0.5, "changefreq": "monthly"},
            {"url": "/contact", "priority": 0.5, "changefreq": "monthly"},
            {"url": "/privacy", "priority": 0.3, "changefreq": "monthly"},
            {"url": "/terms", "priority": 0.3, "changefreq": "monthly"},
            {"url": "/help", "priority": 0.4, "changefreq": "monthly"},
        ]
        
        for page in static_pages:
            urls.append({
                "loc": f"{base_url}{page['url']}",
                "lastmod": datetime.now(timezone.utc).isoformat(),
                "changefreq": page["changefreq"],
                "priority": page["priority"]
            })
        
        # Dynamic craftsman pages
        try:
            craftsmen = Craftsman.query.join(User).filter(
                User.is_active == True
            ).limit(1000).all()
            
            for craftsman in craftsmen:
                urls.append({
                    "loc": f"{base_url}/craftsman/{craftsman.id}",
                    "lastmod": craftsman.updated_at.isoformat() if craftsman.updated_at else datetime.now(timezone.utc).isoformat(),
                    "changefreq": "weekly",
                    "priority": 0.7
                })
                
                # Business profile pages
                urls.append({
                    "loc": f"{base_url}/craftsman/{craftsman.id}/business-profile",
                    "lastmod": craftsman.updated_at.isoformat() if craftsman.updated_at else datetime.now(timezone.utc).isoformat(),
                    "changefreq": "weekly",
                    "priority": 0.6
                })
        except Exception as e:
            print(f"Error generating craftsman URLs: {e}")
        
        # Category pages
        categories = [
            "Elektrik", "Tesisat", "Boyama", "Temizlik", "Klima", 
            "Tamirat", "Montaj", "Tadilat", "Dekorasyon", "Bahçıvanlık"
        ]
        
        for category in categories:
            urls.append({
                "loc": f"{base_url}/search?category={quote(category)}",
                "lastmod": datetime.now(timezone.utc).isoformat(),
                "changefreq": "weekly",
                "priority": 0.8
            })
        
        # Location pages
        cities = [
            "Istanbul", "Ankara", "Izmir", "Bursa", "Antalya", "Adana", 
            "Konya", "Gaziantep", "Mersin", "Diyarbakır", "Kayseri", "Eskişehir"
        ]
        
        for city in cities:
            urls.append({
                "loc": f"{base_url}/search?city={quote(city)}",
                "lastmod": datetime.now(timezone.utc).isoformat(),
                "changefreq": "weekly",
                "priority": 0.7
            })
        
        # High-value combined pages (category + location)
        high_value_categories = ["Elektrik", "Tesisat", "Boyama", "Temizlik"]
        high_value_cities = ["Istanbul", "Ankara", "Izmir"]
        
        for category in high_value_categories:
            for city in high_value_cities:
                urls.append({
                    "loc": f"{base_url}/search?category={quote(category)}&city={quote(city)}",
                    "lastmod": datetime.now(timezone.utc).isoformat(),
                    "changefreq": "weekly",
                    "priority": 0.8
                })
        
        return urls
    
    @staticmethod
    def generate_sitemap_xml():
        """Generate XML sitemap"""
        urls = SEOManager.generate_sitemap()
        
        xml_content = '''<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"
        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
        http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
'''
        
        for url in urls:
            xml_content += f'''
  <url>
    <loc>{url["loc"]}</loc>
    <lastmod>{url["lastmod"]}</lastmod>
    <changefreq>{url["changefreq"]}</changefreq>
    <priority>{url["priority"]}</priority>
  </url>'''
        
        xml_content += '\n</urlset>'
        return xml_content
    
    @staticmethod
    def generate_robots_txt():
        """Generate robots.txt content"""
        return """User-agent: *
Allow: /

# Allow search engines to crawl public pages
Allow: /search
Allow: /craftsmen
Allow: /craftsman/*
Allow: /categories
Allow: /locations

# Disallow sensitive areas
Disallow: /api/
Disallow: /admin/
Disallow: /dashboard/
Disallow: /profile/
Disallow: /messages/
Disallow: /payment/
Disallow: /auth/
Disallow: /login
Disallow: /register
Disallow: /testing
Disallow: /analytics

# Allow important static files
Allow: /icons/
Allow: /images/
Allow: /uploads/
Allow: /manifest.json
Allow: /sw.js

# Sitemap location
Sitemap: https://ustamapp.com/sitemap.xml

# Crawl delay
Crawl-delay: 1

# Special rules for different bots
User-agent: Googlebot
Allow: /
Crawl-delay: 0

User-agent: Bingbot
Allow: /
Crawl-delay: 1

# Block unwanted bots
User-agent: AhrefsBot
Disallow: /

User-agent: SemrushBot
Disallow: /

User-agent: MJ12bot
Disallow: /"""

    @staticmethod
    def generate_craftsman_structured_data(craftsman):
        """Generate structured data for craftsman profile"""
        if not craftsman:
            return None
            
        data = {
            "@context": "https://schema.org",
            "@type": "LocalBusiness",
            "name": craftsman.business_name or f"{craftsman.user.first_name} {craftsman.user.last_name}",
            "description": craftsman.description or f"Profesyonel {craftsman.specialties} hizmeti",
            "url": f"https://ustamapp.com/craftsman/{craftsman.id}",
            "telephone": craftsman.user.phone,
            "address": {
                "@type": "PostalAddress",
                "addressLocality": craftsman.city,
                "addressRegion": craftsman.district,
                "addressCountry": "TR"
            },
            "priceRange": SEOManager.get_price_range(craftsman.hourly_rate),
            "paymentAccepted": "Cash, Credit Card, Bank Transfer",
            "currenciesAccepted": "TRY",
            "image": craftsman.avatar or "/icons/icon-512x512.png",
            "openingHours": craftsman.working_hours or "Mo-Fr 09:00-18:00"
        }
        
        # Add coordinates if available
        if craftsman.current_latitude and craftsman.current_longitude:
            data["geo"] = {
                "@type": "GeoCoordinates",
                "latitude": str(craftsman.current_latitude),
                "longitude": str(craftsman.current_longitude)
            }
        
        # Add rating if available
        if craftsman.average_rating and craftsman.average_rating > 0:
            data["aggregateRating"] = {
                "@type": "AggregateRating",
                "ratingValue": str(craftsman.average_rating),
                "ratingCount": str(max(craftsman.total_jobs, 1)),
                "bestRating": "5",
                "worstRating": "1"
            }
        
        # Add services
        if craftsman.specialties:
            specialties = [s.strip() for s in craftsman.specialties.split(',')]
            data["hasOfferCatalog"] = {
                "@type": "OfferCatalog",
                "name": "Hizmetler",
                "itemListElement": [
                    {
                        "@type": "Offer",
                        "itemOffered": {
                            "@type": "Service",
                            "name": specialty
                        },
                        "price": str(craftsman.hourly_rate) if craftsman.hourly_rate else "100",
                        "priceCurrency": "TRY"
                    }
                    for specialty in specialties
                ]
            }
        
        return data
    
    @staticmethod
    def get_price_range(hourly_rate):
        """Convert hourly rate to price range symbol"""
        if not hourly_rate:
            return "₺₺"
        
        rate = float(hourly_rate)
        if rate < 100:
            return "₺"
        elif rate < 200:
            return "₺₺"
        elif rate < 300:
            return "₺₺₺"
        else:
            return "₺₺₺₺"
    
    @staticmethod
    def generate_search_structured_data(results, query_params):
        """Generate structured data for search results"""
        return {
            "@context": "https://schema.org",
            "@type": "SearchResultsPage",
            "mainEntity": {
                "@type": "ItemList",
                "numberOfItems": len(results),
                "itemListElement": [
                    {
                        "@type": "ListItem",
                        "position": index + 1,
                        "item": {
                            "@type": "LocalBusiness",
                            "name": craftsman.get('business_name') or craftsman.get('name'),
                            "url": f"https://ustamapp.com/craftsman/{craftsman.get('id')}",
                            "address": {
                                "@type": "PostalAddress",
                                "addressLocality": craftsman.get('city'),
                                "addressRegion": craftsman.get('district'),
                                "addressCountry": "TR"
                            }
                        }
                    }
                    for index, craftsman in enumerate(results[:10])  # Limit to first 10
                ]
            },
            "potentialAction": {
                "@type": "SearchAction",
                "target": {
                    "@type": "EntryPoint",
                    "urlTemplate": "https://ustamapp.com/search?q={search_term_string}"
                },
                "query-input": "required name=search_term_string"
            }
        }
    
    @staticmethod
    def generate_breadcrumb_data(breadcrumbs):
        """Generate breadcrumb structured data"""
        return {
            "@context": "https://schema.org",
            "@type": "BreadcrumbList",
            "itemListElement": [
                {
                    "@type": "ListItem",
                    "position": index + 1,
                    "name": crumb["name"],
                    "item": crumb["url"]
                }
                for index, crumb in enumerate(breadcrumbs)
            ]
        }
    
    @staticmethod
    def get_meta_tags_for_page(page_type, data=None):
        """Generate meta tags for different page types"""
        base_tags = {
            "title": "UstamApp - Türkiye'nin En Güvenilir Usta Bulucu Platformu",
            "description": "Elektrikçi, tesisatçı, boyacı, temizlikçi ve 50+ kategoride profesyonel usta bulun. Güvenli ödeme, 7/24 destek, garanti ile hizmet.",
            "keywords": "usta, elektrikçi, tesisatçı, boyacı, temizlikçi, klima, tamir, tadilat, ev tamiri, usta bulucu",
            "image": "/icons/icon-512x512.png",
            "url": "https://ustamapp.com"
        }
        
        if page_type == "craftsman" and data:
            craftsman = data
            specialties = craftsman.specialties.split(',') if craftsman.specialties else []
            specialty_text = specialties[0] if specialties else 'Usta'
            
            return {
                "title": f"{craftsman.user.first_name} {craftsman.user.last_name} - {specialty_text} | UstamApp",
                "description": f"{craftsman.business_name or craftsman.user.first_name} - {craftsman.city} bölgesinde {', '.join(specialties)} hizmeti. {craftsman.experience_years or 0} yıl deneyim, {craftsman.average_rating or 0} puan.",
                "keywords": f"{craftsman.user.first_name} {craftsman.user.last_name}, {', '.join(specialties)}, {craftsman.city} usta, {craftsman.city} {specialty_text}",
                "image": craftsman.avatar or "/icons/icon-512x512.png",
                "url": f"https://ustamapp.com/craftsman/{craftsman.id}"
            }
        
        elif page_type == "search" and data:
            category = data.get('category')
            city = data.get('city')
            query = data.get('q')
            
            if category and city:
                return {
                    "title": f"{category} Ustası {city} | UstamApp",
                    "description": f"{city} bölgesinde profesyonel {category} ustası bulun. Güvenli ödeme, garanti ile hizmet.",
                    "keywords": f"{category} ustası {city}, {city} {category}, {category} hizmeti {city}",
                    "image": "/icons/icon-512x512.png",
                    "url": f"https://ustamapp.com/search?category={quote(category)}&city={quote(city)}"
                }
            elif category:
                return {
                    "title": f"{category} Ustası Bul | UstamApp",
                    "description": f"Türkiye genelinde profesyonel {category} ustası bulun. Güvenli ödeme, garanti ile hizmet.",
                    "keywords": f"{category} ustası, {category} hizmeti, profesyonel {category}",
                    "image": "/icons/icon-512x512.png",
                    "url": f"https://ustamapp.com/search?category={quote(category)}"
                }
            elif city:
                return {
                    "title": f"{city} Usta Bulucu | UstamApp",
                    "description": f"{city} bölgesinde tüm kategorilerde profesyonel usta bulun.",
                    "keywords": f"{city} usta, {city} tamirci, {city} hizmet",
                    "image": "/icons/icon-512x512.png",
                    "url": f"https://ustamapp.com/search?city={quote(city)}"
                }
            elif query:
                return {
                    "title": f'"{query}" için Usta Ara | UstamApp',
                    "description": f'"{query}" aramanız için en uygun ustaları bulun.',
                    "keywords": f"{query}, {query} ustası, {query} hizmeti",
                    "image": "/icons/icon-512x512.png",
                    "url": f"https://ustamapp.com/search?q={quote(query)}"
                }
        
        return base_tags
    
    @staticmethod
    def get_popular_search_terms():
        """Get popular search terms for SEO optimization"""
        # This could be enhanced with real analytics data
        return [
            {"term": "elektrikçi istanbul", "category": "Elektrik", "city": "Istanbul"},
            {"term": "tesisatçı ankara", "category": "Tesisat", "city": "Ankara"},
            {"term": "boyacı izmir", "category": "Boyama", "city": "Izmir"},
            {"term": "temizlikçi bursa", "category": "Temizlik", "city": "Bursa"},
            {"term": "klima montajı", "category": "Klima", "city": None},
            {"term": "ev tamiri", "category": "Tamirat", "city": None},
            {"term": "acil elektrikçi", "category": "Elektrik", "city": None},
            {"term": "uygun tesisatçı", "category": "Tesisat", "city": None},
        ]
    
    @staticmethod
    def generate_category_landing_content(category):
        """Generate SEO-optimized content for category pages"""
        category_info = {
            "Elektrik": {
                "title": "Elektrik Ustası Bul | Güvenli ve Hızlı Hizmet",
                "description": "Profesyonel elektrikçi bulun. Ev ve iş yeri elektrik tesisatı, arıza giderme, priz montajı ve daha fazlası.",
                "content": "Elektrik işleriniz için güvenilir ve deneyimli elektrikçiler. 7/24 acil servis, güvenli ödeme, garanti ile hizmet.",
                "services": ["Elektrik Tesisatı", "Arıza Giderme", "Priz Montajı", "Anahtar Montajı", "Elektrik Panosu"]
            },
            "Tesisat": {
                "title": "Tesisatçı Bul | Su ve Doğalgaz Tesisatı",
                "description": "Profesyonel tesisatçı bulun. Su tesisatı, doğalgaz tesisatı, kaçak tespiti ve onarım hizmetleri.",
                "content": "Tesisat işleriniz için uzman tesisatçılar. Su kaçağı, tıkanıklık, doğalgaz tesisatı ve daha fazlası.",
                "services": ["Su Tesisatı", "Doğalgaz Tesisatı", "Kaçak Tespiti", "Tıkanıklık Açma", "Musluk Tamiri"]
            },
            "Boyama": {
                "title": "Boyacı Bul | İç ve Dış Cephe Boyama",
                "description": "Profesyonel boyacı bulun. İç cephe, dış cephe, dekoratif boyama ve badana hizmetleri.",
                "content": "Boyama işleriniz için deneyimli boyacılar. Kaliteli malzeme, temiz işçilik, uygun fiyat.",
                "services": ["İç Cephe Boyama", "Dış Cephe Boyama", "Badana", "Dekoratif Boyama", "Duvar Kağıdı"]
            },
            "Temizlik": {
                "title": "Temizlik Görevlisi Bul | Ev ve Ofis Temizliği",
                "description": "Profesyonel temizlik görevlisi bulun. Ev temizliği, ofis temizliği, derin temizlik hizmetleri.",
                "content": "Temizlik işleriniz için güvenilir temizlik görevlileri. Düzenli temizlik, derin temizlik seçenekleri.",
                "services": ["Ev Temizliği", "Ofis Temizliği", "Derin Temizlik", "Cam Temizliği", "Halı Temizliği"]
            }
        }
        
        return category_info.get(category, {
            "title": f"{category} Ustası Bul | UstamApp",
            "description": f"Profesyonel {category} ustası bulun. Güvenli ödeme, garanti ile hizmet.",
            "content": f"{category} işleriniz için deneyimli ustalar.",
            "services": [f"{category} Hizmeti"]
        })
    
    @staticmethod
    def generate_location_landing_content(city):
        """Generate SEO-optimized content for location pages"""
        return {
            "title": f"{city} Usta Bulucu | Tüm Kategorilerde Hizmet",
            "description": f"{city} bölgesinde elektrikçi, tesisatçı, boyacı ve daha fazla kategoride usta bulun.",
            "content": f"{city} bölgesinde güvenilir ve deneyimli ustalar. Hızlı hizmet, uygun fiyat, garanti.",
            "popular_services": ["Elektrik", "Tesisat", "Boyama", "Temizlik", "Klima"]
        }

class SEOOptimizer:
    """SEO optimization utilities"""
    
    @staticmethod
    def optimize_url(text):
        """Create SEO-friendly URL slug"""
        import re
        import unicodedata
        
        # Convert to lowercase
        text = text.lower()
        
        # Turkish character mapping
        tr_chars = {
            'ç': 'c', 'ğ': 'g', 'ı': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
            'Ç': 'c', 'Ğ': 'g', 'İ': 'i', 'Ö': 'o', 'Ş': 's', 'Ü': 'u'
        }
        
        for tr_char, en_char in tr_chars.items():
            text = text.replace(tr_char, en_char)
        
        # Remove special characters
        text = re.sub(r'[^\w\s-]', '', text)
        
        # Replace spaces with hyphens
        text = re.sub(r'[\s_-]+', '-', text)
        
        # Remove leading/trailing hyphens
        text = text.strip('-')
        
        return text
    
    @staticmethod
    def generate_meta_description(content, max_length=160):
        """Generate optimized meta description"""
        if len(content) <= max_length:
            return content
        
        # Find last complete sentence within limit
        truncated = content[:max_length]
        last_sentence = truncated.rfind('.')
        
        if last_sentence > max_length * 0.7:  # If we can keep 70% of content
            return content[:last_sentence + 1]
        else:
            # Find last complete word
            last_space = truncated.rfind(' ')
            return content[:last_space] + '...'
    
    @staticmethod
    def extract_keywords(text, max_keywords=10):
        """Extract keywords from text content"""
        import re
        
        # Common Turkish stop words
        stop_words = {
            'bir', 'bu', 've', 'ile', 'için', 'olan', 'olan', 'olarak', 
            'den', 'dan', 'de', 'da', 'en', 'çok', 'daha', 'var', 'yok',
            'gibi', 'kadar', 'sonra', 'önce', 'üzere', 'göre', 'karşı'
        }
        
        # Clean text and extract words
        words = re.findall(r'\b\w+\b', text.lower())
        
        # Filter stop words and short words
        keywords = [word for word in words if len(word) > 3 and word not in stop_words]
        
        # Count frequency
        from collections import Counter
        word_freq = Counter(keywords)
        
        # Return most common keywords
        return [word for word, count in word_freq.most_common(max_keywords)]