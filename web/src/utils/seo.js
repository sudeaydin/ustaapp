import { useEffect } from 'react';

/**
 * SEO Manager for dynamic meta tag and structured data management
 */
export class SEOManager {
  static updateTitle(title) {
    document.title = title;
    this.updateMetaTag('og:title', title);
    this.updateMetaTag('twitter:title', title);
  }

  static updateDescription(description) {
    this.updateMetaTag('description', description);
    this.updateMetaTag('og:description', description);
    this.updateMetaTag('twitter:description', description);
  }

  static updateCanonicalUrl(url) {
    const canonical = document.querySelector('link[rel="canonical"]');
    if (canonical) {
      canonical.href = url;
    } else {
      const link = document.createElement('link');
      link.rel = 'canonical';
      link.href = url;
      document.head.appendChild(link);
    }
    
    this.updateMetaTag('og:url', url);
  }

  static updateMetaTag(name, content) {
    let selector = `meta[name="${name}"]`;
    if (name.startsWith('og:') || name.startsWith('twitter:')) {
      selector = `meta[property="${name}"]`;
    }
    
    let meta = document.querySelector(selector);
    if (meta) {
      meta.content = content;
    } else {
      meta = document.createElement('meta');
      if (name.startsWith('og:') || name.startsWith('twitter:')) {
        meta.property = name;
      } else {
        meta.name = name;
      }
      meta.content = content;
      document.head.appendChild(meta);
    }
  }

  static addStructuredData(data) {
    const script = document.createElement('script');
    script.type = 'application/ld+json';
    script.text = JSON.stringify(data);
    document.head.appendChild(script);
  }

  static removeStructuredData(type) {
    const scripts = document.querySelectorAll('script[type="application/ld+json"]');
    scripts.forEach(script => {
      try {
        const data = JSON.parse(script.text);
        if (data['@type'] === type) {
          script.remove();
        }
      } catch (e) {
        // Ignore invalid JSON
      }
    });
  }

  static generateCraftsmanSchema(craftsman) {
    return {
      '@context': 'https://schema.org',
      '@type': 'LocalBusiness',
      'name': craftsman.business_name || `${craftsman.name} - ${craftsman.specialties?.[0]}`,
      'description': craftsman.description || `Profesyonel ${craftsman.specialties?.[0]} hizmeti`,
      'url': `https://ustamapp.com/craftsman/${craftsman.id}`,
      'telephone': craftsman.phone,
      'address': {
        '@type': 'PostalAddress',
        'addressLocality': craftsman.city,
        'addressRegion': craftsman.district,
        'addressCountry': 'TR'
      },
      'geo': craftsman.latitude && craftsman.longitude ? {
        '@type': 'GeoCoordinates',
        'latitude': craftsman.latitude.toString(),
        'longitude': craftsman.longitude.toString()
      } : undefined,
      'aggregateRating': craftsman.average_rating ? {
        '@type': 'AggregateRating',
        'ratingValue': craftsman.average_rating.toString(),
        'ratingCount': craftsman.total_reviews?.toString() || '1',
        'bestRating': '5',
        'worstRating': '1'
      } : undefined,
      'priceRange': this.getPriceRange(craftsman.hourly_rate),
      'paymentAccepted': 'Cash, Credit Card, Bank Transfer',
      'currenciesAccepted': 'TRY',
      'serviceType': craftsman.specialties || [],
      'image': craftsman.avatar || '/icons/icon-512x512.png',
      'openingHours': craftsman.working_hours || 'Mo-Fr 09:00-18:00',
      'hasOfferCatalog': {
        '@type': 'OfferCatalog',
        'name': 'Hizmetler',
        'itemListElement': (craftsman.specialties || []).map(specialty => ({
          '@type': 'Offer',
          'itemOffered': {
            '@type': 'Service',
            'name': specialty
          },
          'price': craftsman.hourly_rate?.toString() || '100',
          'priceCurrency': 'TRY'
        }))
      }
    };
  }

  static generateServiceSchema(service) {
    return {
      '@context': 'https://schema.org',
      '@type': 'Service',
      'name': service.name,
      'description': service.description,
      'provider': {
        '@type': 'Organization',
        'name': 'UstamApp'
      },
      'areaServed': {
        '@type': 'Country',
        'name': 'Turkey'
      },
      'category': service.category,
      'offers': {
        '@type': 'Offer',
        'price': service.price || '100',
        'priceCurrency': 'TRY',
        'availability': 'https://schema.org/InStock'
      }
    };
  }

  static generateBreadcrumbSchema(breadcrumbs) {
    return {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      'itemListElement': breadcrumbs.map((crumb, index) => ({
        '@type': 'ListItem',
        'position': index + 1,
        'name': crumb.name,
        'item': crumb.url
      }))
    };
  }

  static getPriceRange(hourlyRate) {
    if (!hourlyRate) return '₺₺';
    
    if (hourlyRate < 100) return '₺';
    if (hourlyRate < 200) return '₺₺';
    if (hourlyRate < 300) return '₺₺₺';
    return '₺₺₺₺';
  }

  static generatePageSchema(pageType, data = {}) {
    const baseSchema = {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      'name': document.title,
      'description': document.querySelector('meta[name="description"]')?.content,
      'url': window.location.href,
      'isPartOf': {
        '@type': 'WebSite',
        'name': 'UstamApp',
        'url': 'https://ustamapp.com'
      }
    };

    switch (pageType) {
      case 'search':
        return {
          ...baseSchema,
          '@type': 'SearchResultsPage',
          'mainEntity': {
            '@type': 'ItemList',
            'numberOfItems': data.resultsCount || 0,
            'itemListElement': (data.results || []).map((item, index) => ({
              '@type': 'ListItem',
              'position': index + 1,
              'item': {
                '@type': 'LocalBusiness',
                'name': item.business_name || item.name,
                'url': `https://ustamapp.com/craftsman/${item.id}`
              }
            }))
          }
        };
      
      case 'craftsman':
        return {
          ...baseSchema,
          '@type': 'ProfilePage',
          'mainEntity': this.generateCraftsmanSchema(data.craftsman)
        };
      
      default:
        return baseSchema;
    }
  }
}

/**
 * React hook for SEO management
 */
export function useSEO(config = {}) {
  useEffect(() => {
    const { 
      title, 
      description, 
      canonicalUrl, 
      structuredData,
      keywords,
      image,
      noIndex = false 
    } = config;

    // Update title
    if (title) {
      SEOManager.updateTitle(title);
    }

    // Update description
    if (description) {
      SEOManager.updateDescription(description);
    }

    // Update canonical URL
    if (canonicalUrl) {
      SEOManager.updateCanonicalUrl(canonicalUrl);
    }

    // Update keywords
    if (keywords) {
      SEOManager.updateMetaTag('keywords', keywords);
    }

    // Update image
    if (image) {
      SEOManager.updateMetaTag('og:image', image);
      SEOManager.updateMetaTag('twitter:image', image);
    }

    // Update robots
    if (noIndex) {
      SEOManager.updateMetaTag('robots', 'noindex, nofollow');
    } else {
      SEOManager.updateMetaTag('robots', 'index, follow');
    }

    // Add structured data
    if (structuredData) {
      SEOManager.addStructuredData(structuredData);
    }

    // Cleanup function
    return () => {
      if (structuredData && structuredData['@type']) {
        SEOManager.removeStructuredData(structuredData['@type']);
      }
    };
  }, [config]);
}

/**
 * SEO-optimized page wrapper component
 */
export function SEOPage({ 
  title, 
  description, 
  keywords,
  canonicalUrl,
  structuredData,
  image,
  noIndex = false,
  children 
}) {
  useSEO({
    title,
    description,
    keywords,
    canonicalUrl,
    structuredData,
    image,
    noIndex
  });

  return children;
}

/**
 * Generate sitemap dynamically
 */
export async function generateSitemap() {
  const baseUrl = 'https://ustamapp.com';
  const urls = [];

  // Static pages
  const staticPages = [
    { url: '/', priority: 1.0, changefreq: 'daily' },
    { url: '/landing', priority: 0.9, changefreq: 'weekly' },
    { url: '/search', priority: 0.9, changefreq: 'daily' },
    { url: '/craftsmen', priority: 0.8, changefreq: 'daily' },
    { url: '/about', priority: 0.5, changefreq: 'monthly' },
    { url: '/contact', priority: 0.5, changefreq: 'monthly' },
    { url: '/privacy', priority: 0.3, changefreq: 'monthly' },
    { url: '/terms', priority: 0.3, changefreq: 'monthly' },
    { url: '/help', priority: 0.4, changefreq: 'monthly' },
  ];

  staticPages.forEach(page => {
    urls.push({
      loc: `${baseUrl}${page.url}`,
      lastmod: new Date().toISOString(),
      changefreq: page.changefreq,
      priority: page.priority
    });
  });

  // Category pages
  const categories = ['Elektrik', 'Tesisat', 'Boyama', 'Temizlik', 'Klima', 'Tamirat'];
  categories.forEach(category => {
    urls.push({
      loc: `${baseUrl}/search?category=${encodeURIComponent(category)}`,
      lastmod: new Date().toISOString(),
      changefreq: 'weekly',
      priority: 0.8
    });
  });

  // Location pages
  const cities = ['Istanbul', 'Ankara', 'Izmir', 'Bursa', 'Antalya'];
  cities.forEach(city => {
    urls.push({
      loc: `${baseUrl}/search?city=${encodeURIComponent(city)}`,
      lastmod: new Date().toISOString(),
      changefreq: 'weekly',
      priority: 0.7
    });
  });

  // Combined category + location pages (high value)
  categories.slice(0, 2).forEach(category => {
    cities.slice(0, 2).forEach(city => {
      urls.push({
        loc: `${baseUrl}/search?category=${encodeURIComponent(category)}&city=${encodeURIComponent(city)}`,
        lastmod: new Date().toISOString(),
        changefreq: 'weekly',
        priority: 0.8
      });
    });
  });

  return urls;
}

/**
 * SEO constants and helpers
 */
export const SEO_CONSTANTS = {
  SITE_NAME: 'UstamApp',
  SITE_URL: 'https://ustamapp.com',
  DEFAULT_TITLE: 'UstamApp - Türkiye\'nin En Güvenilir Usta Bulucu Platformu',
  DEFAULT_DESCRIPTION: 'Elektrikçi, tesisatçı, boyacı, temizlikçi ve 50+ kategoride profesyonel usta bulun. Güvenli ödeme, 7/24 destek, garanti ile hizmet.',
  DEFAULT_IMAGE: '/icons/icon-512x512.png',
  DEFAULT_KEYWORDS: 'usta, elektrikçi, tesisatçı, boyacı, temizlikçi, klima, tamir, tadilat, ev tamiri, usta bulucu, profesyonel hizmet',
  SOCIAL_HANDLES: {
    twitter: '@ustamapp',
    linkedin: 'ustamapp'
  }
};

/**
 * Generate page-specific SEO config
 */
export function generatePageSEO(pageType, data = {}) {
  const baseConfig = {
    title: SEO_CONSTANTS.DEFAULT_TITLE,
    description: SEO_CONSTANTS.DEFAULT_DESCRIPTION,
    keywords: SEO_CONSTANTS.DEFAULT_KEYWORDS,
    image: SEO_CONSTANTS.DEFAULT_IMAGE,
    canonicalUrl: window.location.href
  };

  switch (pageType) {
    case 'craftsman':
      return {
        ...baseConfig,
        title: `${data.name} - ${data.specialties?.[0] || 'Usta'} | UstamApp`,
        description: `${data.name} - ${data.city} bölgesinde ${data.specialties?.join(', ')} hizmeti. ${data.experience_years || 0} yıl deneyim, ${data.average_rating || 0} puan.`,
        keywords: `${data.name}, ${data.specialties?.join(', ')}, ${data.city} usta, ${data.city} ${data.specialties?.[0]}`,
        canonicalUrl: `${SEO_CONSTANTS.SITE_URL}/craftsman/${data.id}`,
        structuredData: SEOManager.generateCraftsmanSchema(data)
      };

    case 'search':
      const { category, city, query } = data;
      let title = 'Usta Ara | UstamApp';
      let description = 'Profesyonel usta bulun ve güvenli şekilde iş yaptırın.';
      let keywords = SEO_CONSTANTS.DEFAULT_KEYWORDS;

      if (category && city) {
        title = `${category} Ustası ${city} | UstamApp`;
        description = `${city} bölgesinde profesyonel ${category} ustası bulun. Güvenli ödeme, garanti ile hizmet.`;
        keywords = `${category} ustası ${city}, ${city} ${category}, ${category} hizmeti ${city}`;
      } else if (category) {
        title = `${category} Ustası Bul | UstamApp`;
        description = `Türkiye genelinde profesyonel ${category} ustası bulun. Güvenli ödeme, garanti ile hizmet.`;
        keywords = `${category} ustası, ${category} hizmeti, profesyonel ${category}`;
      } else if (city) {
        title = `${city} Usta Bulucu | UstamApp`;
        description = `${city} bölgesinde tüm kategorilerde profesyonel usta bulun.`;
        keywords = `${city} usta, ${city} tamirci, ${city} hizmet`;
      } else if (query) {
        title = `"${query}" için Usta Ara | UstamApp`;
        description = `"${query}" aramanız için en uygun ustaları bulun.`;
        keywords = `${query}, ${query} ustası, ${query} hizmeti`;
      }

      return {
        ...baseConfig,
        title,
        description,
        keywords,
        canonicalUrl: `${SEO_CONSTANTS.SITE_URL}/search${window.location.search}`,
        structuredData: SEOManager.generatePageSchema('search', data)
      };

    case 'category':
      return {
        ...baseConfig,
        title: `${data.name} Ustası Bul | UstamApp`,
        description: `Türkiye genelinde profesyonel ${data.name} ustası bulun. Güvenli ödeme, garanti ile hizmet.`,
        keywords: `${data.name} ustası, ${data.name} hizmeti, profesyonel ${data.name}`,
        canonicalUrl: `${SEO_CONSTANTS.SITE_URL}/search?category=${encodeURIComponent(data.name)}`
      };

    case 'location':
      return {
        ...baseConfig,
        title: `${data.name} Usta Bulucu | UstamApp`,
        description: `${data.name} bölgesinde tüm kategorilerde profesyonel usta bulun.`,
        keywords: `${data.name} usta, ${data.name} tamirci, ${data.name} hizmet`,
        canonicalUrl: `${SEO_CONSTANTS.SITE_URL}/search?city=${encodeURIComponent(data.name)}`
      };

    default:
      return baseConfig;
  }
}

/**
 * React component for managing page SEO
 */
export function PageSEO({ pageType, data, children }) {
  const seoConfig = generatePageSEO(pageType, data);
  useSEO(seoConfig);
  
  return children;
}

/**
 * Generate rich snippets for search results
 */
export function generateRichSnippet(type, data) {
  switch (type) {
    case 'review':
      return {
        '@context': 'https://schema.org',
        '@type': 'Review',
        'itemReviewed': {
          '@type': 'LocalBusiness',
          'name': data.businessName
        },
        'author': {
          '@type': 'Person',
          'name': data.reviewerName
        },
        'reviewRating': {
          '@type': 'Rating',
          'ratingValue': data.rating,
          'bestRating': '5',
          'worstRating': '1'
        },
        'reviewBody': data.comment,
        'datePublished': data.date
      };

    case 'faq':
      return {
        '@context': 'https://schema.org',
        '@type': 'FAQPage',
        'mainEntity': data.questions.map(q => ({
          '@type': 'Question',
          'name': q.question,
          'acceptedAnswer': {
            '@type': 'Answer',
            'text': q.answer
          }
        }))
      };

    default:
      return null;
  }
}