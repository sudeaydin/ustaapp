from flask import Blueprint, Response, jsonify, request
from app.utils.seo import SEOManager, SEOOptimizer
from app.models.craftsman import Craftsman
from app.models.user import User
from app.utils.security import rate_limit

seo_bp = Blueprint('seo', __name__)

@seo_bp.route('/sitemap.xml', methods=['GET'])
@rate_limit(requests_per_minute=30)
def get_sitemap():
    """Generate and serve dynamic sitemap"""
    try:
        sitemap_xml = SEOManager.generate_sitemap_xml()
        return Response(
            sitemap_xml,
            mimetype='application/xml',
            headers={
                'Cache-Control': 'public, max-age=3600',  # Cache for 1 hour
                'Content-Type': 'application/xml; charset=utf-8'
            }
        )
    except Exception as e:
        print(f"Error generating sitemap: {e}")
        return Response(
            '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"></urlset>',
            mimetype='application/xml',
            status=500
        )

@seo_bp.route('/robots.txt', methods=['GET'])
@rate_limit(requests_per_minute=30)
def get_robots():
    """Generate and serve robots.txt"""
    try:
        robots_content = SEOManager.generate_robots_txt()
        return Response(
            robots_content,
            mimetype='text/plain',
            headers={
                'Cache-Control': 'public, max-age=86400',  # Cache for 24 hours
                'Content-Type': 'text/plain; charset=utf-8'
            }
        )
    except Exception as e:
        print(f"Error generating robots.txt: {e}")
        return Response(
            'User-agent: *\nAllow: /',
            mimetype='text/plain',
            status=500
        )

@seo_bp.route('/meta/<page_type>', methods=['GET'])
@rate_limit(requests_per_minute=60)
def get_meta_tags(page_type):
    """Get SEO meta tags for specific page types"""
    try:
        data = request.args.to_dict()
        
        # Get additional data based on page type
        if page_type == 'craftsman':
            craftsman_id = data.get('id')
            if craftsman_id:
                craftsman = Craftsman.query.get(craftsman_id)
                if craftsman:
                    meta_tags = SEOManager.get_meta_tags_for_page('craftsman', craftsman)
                    structured_data = SEOManager.generate_craftsman_structured_data(craftsman)
                    
                    return jsonify({
                        'success': True,
                        'data': {
                            'meta_tags': meta_tags,
                            'structured_data': structured_data
                        }
                    })
        
        elif page_type == 'search':
            meta_tags = SEOManager.get_meta_tags_for_page('search', data)
            return jsonify({
                'success': True,
                'data': {
                    'meta_tags': meta_tags
                }
            })
        
        # Default meta tags
        meta_tags = SEOManager.get_meta_tags_for_page(page_type, data)
        return jsonify({
            'success': True,
            'data': {
                'meta_tags': meta_tags
            }
        })
        
    except Exception as e:
        print(f"Error generating meta tags: {e}")
        return jsonify({
            'success': False,
            'message': 'Meta tag oluşturulamadı'
        }), 500

@seo_bp.route('/structured-data/<data_type>', methods=['GET'])
@rate_limit(requests_per_minute=60)
def get_structured_data(data_type):
    """Get structured data for specific content types"""
    try:
        if data_type == 'craftsman':
            craftsman_id = request.args.get('id')
            if craftsman_id:
                craftsman = Craftsman.query.get(craftsman_id)
                if craftsman:
                    structured_data = SEOManager.generate_craftsman_structured_data(craftsman)
                    return jsonify({
                        'success': True,
                        'data': structured_data
                    })
        
        elif data_type == 'search':
            # Get search results for structured data
            query_params = request.args.to_dict()
            # This would typically include search results
            # For now, return basic search schema
            structured_data = SEOManager.generate_search_structured_data([], query_params)
            return jsonify({
                'success': True,
                'data': structured_data
            })
        
        return jsonify({
            'success': False,
            'message': 'Geçersiz veri tipi'
        }), 400
        
    except Exception as e:
        print(f"Error generating structured data: {e}")
        return jsonify({
            'success': False,
            'message': 'Yapılandırılmış veri oluşturulamadı'
        }), 500

@seo_bp.route('/breadcrumbs', methods=['POST'])
@rate_limit(requests_per_minute=60)
def generate_breadcrumbs():
    """Generate breadcrumb structured data"""
    try:
        data = request.get_json()
        breadcrumbs = data.get('breadcrumbs', [])
        
        if not breadcrumbs:
            return jsonify({
                'success': False,
                'message': 'Breadcrumb verisi gerekli'
            }), 400
        
        structured_data = SEOManager.generate_breadcrumb_data(breadcrumbs)
        return jsonify({
            'success': True,
            'data': structured_data
        })
        
    except Exception as e:
        print(f"Error generating breadcrumbs: {e}")
        return jsonify({
            'success': False,
            'message': 'Breadcrumb oluşturulamadı'
        }), 500

@seo_bp.route('/popular-terms', methods=['GET'])
@rate_limit(requests_per_minute=30)
def get_popular_terms():
    """Get popular search terms for SEO"""
    try:
        terms = SEOManager.get_popular_search_terms()
        return jsonify({
            'success': True,
            'data': terms
        })
    except Exception as e:
        print(f"Error getting popular terms: {e}")
        return jsonify({
            'success': False,
            'message': 'Popüler terimler alınamadı'
        }), 500

@seo_bp.route('/category-content/<category>', methods=['GET'])
@rate_limit(requests_per_minute=60)
def get_category_content(category):
    """Get SEO-optimized content for category pages"""
    try:
        content = SEOManager.generate_category_landing_content(category)
        return jsonify({
            'success': True,
            'data': content
        })
    except Exception as e:
        print(f"Error generating category content: {e}")
        return jsonify({
            'success': False,
            'message': 'Kategori içeriği oluşturulamadı'
        }), 500

@seo_bp.route('/location-content/<city>', methods=['GET'])
@rate_limit(requests_per_minute=60)
def get_location_content(city):
    """Get SEO-optimized content for location pages"""
    try:
        content = SEOManager.generate_location_landing_content(city)
        return jsonify({
            'success': True,
            'data': content
        })
    except Exception as e:
        print(f"Error generating location content: {e}")
        return jsonify({
            'success': False,
            'message': 'Lokasyon içeriği oluşturulamadı'
        }), 500

@seo_bp.route('/optimize-url', methods=['POST'])
@rate_limit(requests_per_minute=60)
def optimize_url():
    """Create SEO-friendly URL slug"""
    try:
        data = request.get_json()
        text = data.get('text', '')
        
        if not text:
            return jsonify({
                'success': False,
                'message': 'Metin gerekli'
            }), 400
        
        optimized_url = SEOOptimizer.optimize_url(text)
        return jsonify({
            'success': True,
            'data': {
                'original': text,
                'optimized': optimized_url
            }
        })
        
    except Exception as e:
        print(f"Error optimizing URL: {e}")
        return jsonify({
            'success': False,
            'message': 'URL optimize edilemedi'
        }), 500