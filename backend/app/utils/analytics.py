import json
import logging
from datetime import datetime, timedelta
from flask import request, current_app
from sqlalchemy import func, desc, and_, text
from app import db
from app.models.user import User, UserType
from app.models.quote import Quote, QuoteStatus
from app.models.message import Message
from app.models.craftsman import Craftsman
from app.models.customer import Customer

class AnalyticsTracker:
    """Analytics tracking and metrics collection"""
    
    @staticmethod
    def track_user_action(user_id, action, details=None, page=None):
        """Track user actions for analytics"""
        try:
            event_data = {
                'user_id': user_id,
                'action': action,
                'details': details or {},
                'page': page,
                'timestamp': datetime.utcnow().isoformat(),
                'ip_address': request.environ.get('HTTP_X_FORWARDED_FOR', request.remote_addr),
                'user_agent': request.headers.get('User-Agent', ''),
                'session_id': request.headers.get('X-Session-ID', '')
            }
            
            # In production, send to analytics service (Google Analytics, Mixpanel, etc.)
            logging.info(f"Analytics event: {json.dumps(event_data)}")
            
            # Store in database for internal analytics
            AnalyticsTracker._store_event(event_data)
            
        except Exception as e:
            logging.error(f"Analytics tracking error: {e}")
    
    @staticmethod
    def _store_event(event_data):
        """Store analytics event in database"""
        try:
            # Create analytics table if needed (simplified storage)
            db.session.execute(text("""
                CREATE TABLE IF NOT EXISTS analytics_events (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER,
                    action TEXT,
                    details TEXT,
                    page TEXT,
                    timestamp DATETIME,
                    ip_address TEXT,
                    user_agent TEXT,
                    session_id TEXT
                )
            """))
            
            # Insert event
            db.session.execute(text("""
                INSERT INTO analytics_events 
                (user_id, action, details, page, timestamp, ip_address, user_agent, session_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """), (
                event_data['user_id'],
                event_data['action'],
                json.dumps(event_data['details']),
                event_data['page'],
                event_data['timestamp'],
                event_data['ip_address'],
                event_data['user_agent'],
                event_data['session_id']
            ))
            
            db.session.commit()
            
        except Exception as e:
            logging.error(f"Analytics storage error: {e}")
            db.session.rollback()

class BusinessMetrics:
    """Business intelligence and metrics calculation"""
    
    @staticmethod
    def get_platform_overview():
        """Get overall platform metrics"""
        try:
            # User metrics
            total_users = User.query.filter_by(is_active=True).count()
            total_customers = User.query.filter_by(user_type=UserType.CUSTOMER, is_active=True).count()
            total_craftsmen = User.query.filter_by(user_type=UserType.CRAFTSMAN, is_active=True).count()
            
            # Registration trends (last 30 days)
            thirty_days_ago = datetime.utcnow() - timedelta(days=30)
            new_users_30d = User.query.filter(
                User.created_at >= thirty_days_ago,
                User.is_active == True
            ).count()
            
            # Quote metrics
            total_quotes = Quote.query.count()
            active_quotes = Quote.query.filter(
                Quote.status.in_([QuoteStatus.PENDING, QuoteStatus.QUOTED, QuoteStatus.DETAILS_REQUESTED])
            ).count()
            completed_quotes = Quote.query.filter_by(status=QuoteStatus.COMPLETED).count()
            
            # Success rate
            total_responses = Quote.query.filter(
                Quote.status != QuoteStatus.PENDING
            ).count()
            success_rate = (completed_quotes / total_responses * 100) if total_responses > 0 else 0
            
            # Revenue metrics (mock calculation)
            commission_rate = 0.10
            avg_quote_amount = db.session.query(func.avg(Quote.quoted_amount)).filter(
                Quote.status == QuoteStatus.COMPLETED
            ).scalar() or 0
            estimated_revenue = completed_quotes * avg_quote_amount * commission_rate
            
            return {
                'users': {
                    'total': total_users,
                    'customers': total_customers,
                    'craftsmen': total_craftsmen,
                    'new_30d': new_users_30d,
                    'growth_rate': (new_users_30d / max(total_users - new_users_30d, 1)) * 100
                },
                'quotes': {
                    'total': total_quotes,
                    'active': active_quotes,
                    'completed': completed_quotes,
                    'success_rate': round(success_rate, 2),
                    'avg_amount': round(avg_quote_amount, 2)
                },
                'revenue': {
                    'estimated_total': round(estimated_revenue, 2),
                    'commission_rate': commission_rate * 100,
                    'avg_per_job': round(avg_quote_amount * commission_rate, 2)
                }
            }
            
        except Exception as e:
            logging.error(f"Platform overview error: {e}")
            return {}
    
    @staticmethod
    def get_craftsman_metrics(craftsman_id):
        """Get metrics for specific craftsman"""
        try:
            craftsman = Craftsman.query.get(craftsman_id)
            if not craftsman:
                return None
            
            # Quote metrics
            total_quotes = Quote.query.filter_by(craftsman_id=craftsman_id).count()
            pending_quotes = Quote.query.filter_by(
                craftsman_id=craftsman_id, 
                status=QuoteStatus.PENDING
            ).count()
            completed_quotes = Quote.query.filter_by(
                craftsman_id=craftsman_id, 
                status=QuoteStatus.COMPLETED
            ).count()
            
            # Response time (average time to respond to quotes)
            avg_response_time = db.session.query(
                func.avg(
                    func.julianday(Quote.updated_at) - func.julianday(Quote.created_at)
                )
            ).filter(
                Quote.craftsman_id == craftsman_id,
                Quote.status != QuoteStatus.PENDING
            ).scalar() or 0
            
            # Revenue metrics
            total_revenue = db.session.query(func.sum(Quote.quoted_amount)).filter(
                Quote.craftsman_id == craftsman_id,
                Quote.status == QuoteStatus.COMPLETED
            ).scalar() or 0
            
            # Monthly breakdown (last 12 months)
            monthly_stats = []
            for i in range(12):
                month_start = datetime.utcnow().replace(day=1) - timedelta(days=30*i)
                month_end = month_start + timedelta(days=30)
                
                month_quotes = Quote.query.filter(
                    Quote.craftsman_id == craftsman_id,
                    Quote.created_at >= month_start,
                    Quote.created_at < month_end
                ).count()
                
                month_completed = Quote.query.filter(
                    Quote.craftsman_id == craftsman_id,
                    Quote.status == QuoteStatus.COMPLETED,
                    Quote.updated_at >= month_start,
                    Quote.updated_at < month_end
                ).count()
                
                month_revenue = db.session.query(func.sum(Quote.quoted_amount)).filter(
                    Quote.craftsman_id == craftsman_id,
                    Quote.status == QuoteStatus.COMPLETED,
                    Quote.updated_at >= month_start,
                    Quote.updated_at < month_end
                ).scalar() or 0
                
                monthly_stats.append({
                    'month': month_start.strftime('%Y-%m'),
                    'quotes_received': month_quotes,
                    'jobs_completed': month_completed,
                    'revenue': float(month_revenue)
                })
            
            return {
                'craftsman_id': craftsman_id,
                'business_name': craftsman.business_name,
                'quotes': {
                    'total': total_quotes,
                    'pending': pending_quotes,
                    'completed': completed_quotes,
                    'success_rate': (completed_quotes / max(total_quotes, 1)) * 100
                },
                'performance': {
                    'avg_response_time_hours': round(avg_response_time * 24, 2),
                    'total_revenue': float(total_revenue),
                    'avg_job_value': float(total_revenue / max(completed_quotes, 1)),
                    'current_rating': float(craftsman.average_rating or 0)
                },
                'monthly_stats': list(reversed(monthly_stats))
            }
            
        except Exception as e:
            logging.error(f"Craftsman metrics error: {e}")
            return None
    
    @staticmethod
    def get_customer_metrics(customer_id):
        """Get metrics for specific customer"""
        try:
            customer = Customer.query.get(customer_id)
            if not customer:
                return None
            
            # Quote metrics
            total_quotes = Quote.query.filter_by(customer_id=customer_id).count()
            completed_jobs = Quote.query.filter_by(
                customer_id=customer_id, 
                status=QuoteStatus.COMPLETED
            ).count()
            
            # Spending metrics
            total_spent = db.session.query(func.sum(Quote.quoted_amount)).filter(
                Quote.customer_id == customer_id,
                Quote.status == QuoteStatus.COMPLETED
            ).scalar() or 0
            
            # Favorite categories
            category_stats = db.session.query(
                Quote.category, 
                func.count(Quote.id).label('count')
            ).filter(
                Quote.customer_id == customer_id
            ).group_by(Quote.category).order_by(desc('count')).limit(5).all()
            
            return {
                'customer_id': customer_id,
                'quotes': {
                    'total_requested': total_quotes,
                    'jobs_completed': completed_jobs,
                    'completion_rate': (completed_jobs / max(total_quotes, 1)) * 100
                },
                'spending': {
                    'total_spent': float(total_spent),
                    'avg_per_job': float(total_spent / max(completed_jobs, 1)),
                    'currency': 'TRY'
                },
                'preferences': {
                    'favorite_categories': [
                        {'category': cat, 'count': count} 
                        for cat, count in category_stats
                    ]
                }
            }
            
        except Exception as e:
            logging.error(f"Customer metrics error: {e}")
            return None
    
    @staticmethod
    def get_trend_analysis():
        """Get platform trend analysis"""
        try:
            # Popular categories
            popular_categories = db.session.query(
                Quote.category,
                func.count(Quote.id).label('count'),
                func.avg(Quote.quoted_amount).label('avg_price')
            ).group_by(Quote.category).order_by(desc('count')).limit(10).all()
            
            # Popular cities
            popular_cities = db.session.query(
                Craftsman.city,
                func.count(Quote.id).label('quote_count')
            ).join(Quote, Quote.craftsman_id == Craftsman.id)\
             .group_by(Craftsman.city)\
             .order_by(desc('quote_count')).limit(10).all()
            
            # Peak hours analysis
            hourly_activity = db.session.query(
                func.strftime('%H', Quote.created_at).label('hour'),
                func.count(Quote.id).label('count')
            ).group_by('hour').order_by('hour').all()
            
            # Price trends by category
            price_trends = db.session.query(
                Quote.category,
                func.min(Quote.quoted_amount).label('min_price'),
                func.max(Quote.quoted_amount).label('max_price'),
                func.avg(Quote.quoted_amount).label('avg_price'),
                func.count(Quote.id).label('sample_size')
            ).filter(
                Quote.quoted_amount.isnot(None)
            ).group_by(Quote.category).all()
            
            return {
                'popular_categories': [
                    {
                        'category': cat,
                        'quote_count': count,
                        'avg_price': float(avg_price or 0)
                    }
                    for cat, count, avg_price in popular_categories
                ],
                'popular_cities': [
                    {
                        'city': city,
                        'quote_count': count
                    }
                    for city, count in popular_cities
                ],
                'hourly_activity': [
                    {
                        'hour': int(hour),
                        'activity_count': count
                    }
                    for hour, count in hourly_activity
                ],
                'price_trends': [
                    {
                        'category': cat,
                        'min_price': float(min_price or 0),
                        'max_price': float(max_price or 0),
                        'avg_price': float(avg_price or 0),
                        'sample_size': sample_size
                    }
                    for cat, min_price, max_price, avg_price, sample_size in price_trends
                ]
            }
            
        except Exception as e:
            logging.error(f"Trend analysis error: {e}")
            return {}

class PerformanceMonitor:
    """Monitor application performance metrics"""
    
    @staticmethod
    def track_api_performance(endpoint, duration, status_code, user_id=None):
        """Track API endpoint performance"""
        try:
            perf_data = {
                'endpoint': endpoint,
                'duration_ms': round(duration * 1000, 2),
                'status_code': status_code,
                'user_id': user_id,
                'timestamp': datetime.utcnow().isoformat(),
                'method': request.method,
                'ip_address': request.environ.get('HTTP_X_FORWARDED_FOR', request.remote_addr)
            }
            
            # Log performance data
            logging.info(f"API Performance: {json.dumps(perf_data)}")
            
            # Store in database
            db.session.execute(text("""
                CREATE TABLE IF NOT EXISTS api_performance (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    endpoint TEXT,
                    method TEXT,
                    duration_ms REAL,
                    status_code INTEGER,
                    user_id INTEGER,
                    timestamp DATETIME,
                    ip_address TEXT
                )
            """))
            
            db.session.execute(text("""
                INSERT INTO api_performance 
                (endpoint, method, duration_ms, status_code, user_id, timestamp, ip_address)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """), (
                perf_data['endpoint'],
                perf_data['method'],
                perf_data['duration_ms'],
                perf_data['status_code'],
                perf_data['user_id'],
                perf_data['timestamp'],
                perf_data['ip_address']
            ))
            
            db.session.commit()
            
        except Exception as e:
            logging.error(f"Performance tracking error: {e}")
            db.session.rollback()
    
    @staticmethod
    def get_performance_report(hours=24):
        """Get performance report for last N hours"""
        try:
            since = datetime.utcnow() - timedelta(hours=hours)
            
            # Average response times by endpoint
            endpoint_performance = db.session.execute(text("""
                SELECT 
                    endpoint,
                    AVG(duration_ms) as avg_duration,
                    COUNT(*) as request_count,
                    AVG(CASE WHEN status_code >= 400 THEN 1.0 ELSE 0.0 END) * 100 as error_rate
                FROM api_performance 
                WHERE timestamp >= ?
                GROUP BY endpoint
                ORDER BY avg_duration DESC
            """), (since,)).fetchall()
            
            # Overall stats
            overall_stats = db.session.execute(text("""
                SELECT 
                    AVG(duration_ms) as avg_duration,
                    COUNT(*) as total_requests,
                    AVG(CASE WHEN status_code >= 400 THEN 1.0 ELSE 0.0 END) * 100 as error_rate,
                    MAX(duration_ms) as max_duration,
                    MIN(duration_ms) as min_duration
                FROM api_performance 
                WHERE timestamp >= ?
            """), (since,)).fetchone()
            
            return {
                'period_hours': hours,
                'overall': {
                    'avg_response_time_ms': round(overall_stats[0] or 0, 2),
                    'total_requests': overall_stats[1] or 0,
                    'error_rate_percent': round(overall_stats[2] or 0, 2),
                    'max_response_time_ms': round(overall_stats[3] or 0, 2),
                    'min_response_time_ms': round(overall_stats[4] or 0, 2)
                },
                'endpoints': [
                    {
                        'endpoint': ep[0],
                        'avg_duration_ms': round(ep[1], 2),
                        'request_count': ep[2],
                        'error_rate_percent': round(ep[3], 2)
                    }
                    for ep in endpoint_performance
                ]
            }
            
        except Exception as e:
            logging.error(f"Performance report error: {e}")
            return {}

class UserBehaviorAnalytics:
    """Analyze user behavior patterns"""
    
    @staticmethod
    def get_user_journey_analysis():
        """Analyze user journey and conversion funnel"""
        try:
            # Conversion funnel
            total_visitors = db.session.execute(text("""
                SELECT COUNT(DISTINCT user_id) FROM analytics_events 
                WHERE action = 'page_view' AND page = '/'
            """).scalar() or 0
            
            registered_users = User.query.filter_by(is_active=True).count()
            quote_requesters = db.session.query(func.count(func.distinct(Quote.customer_id))).scalar() or 0
            paying_customers = db.session.query(func.count(func.distinct(Quote.customer_id))).filter(
                Quote.status == QuoteStatus.COMPLETED
            ).scalar() or 0
            
            # User engagement
            avg_session_duration = db.session.execute(text("""
                SELECT AVG(session_duration) FROM (
                    SELECT 
                        user_id,
                        session_id,
                        (MAX(julianday(timestamp)) - MIN(julianday(timestamp))) * 24 * 60 as session_duration
                    FROM analytics_events 
                    WHERE session_id IS NOT NULL AND session_id != ''
                    GROUP BY user_id, session_id
                    HAVING session_duration > 0
                )
            """).scalar() or 0
            
            # Most visited pages
            popular_pages = db.session.execute(text("""
                SELECT page, COUNT(*) as visits
                FROM analytics_events 
                WHERE action = 'page_view' AND page IS NOT NULL
                GROUP BY page
                ORDER BY visits DESC
                LIMIT 10
            """).fetchall()
            
            return {
                'conversion_funnel': {
                    'visitors': total_visitors,
                    'registrations': registered_users,
                    'quote_requests': quote_requesters,
                    'paying_customers': paying_customers,
                    'visitor_to_registration': (registered_users / max(total_visitors, 1)) * 100,
                    'registration_to_quote': (quote_requesters / max(registered_users, 1)) * 100,
                    'quote_to_payment': (paying_customers / max(quote_requesters, 1)) * 100
                },
                'engagement': {
                    'avg_session_duration_minutes': round(avg_session_duration, 2),
                    'popular_pages': [
                        {'page': page, 'visits': visits}
                        for page, visits in popular_pages
                    ]
                }
            }
            
        except Exception as e:
            logging.error(f"User journey analysis error: {e}")
            return {}
    
    @staticmethod
    def get_search_analytics():
        """Analyze search behavior and patterns"""
        try:
            # Most searched terms (from analytics events)
            search_terms = db.session.execute(text("""
                SELECT 
                    JSON_EXTRACT(details, '$.query') as search_term,
                    COUNT(*) as search_count
                FROM analytics_events 
                WHERE action = 'search' 
                    AND JSON_EXTRACT(details, '$.query') IS NOT NULL
                    AND JSON_EXTRACT(details, '$.query') != ''
                GROUP BY search_term
                ORDER BY search_count DESC
                LIMIT 20
            """).fetchall()
            
            # Search to quote conversion
            search_to_quote = db.session.execute(text("""
                SELECT 
                    COUNT(DISTINCT user_id) as searchers,
                    (SELECT COUNT(DISTINCT customer_id) FROM quotes) as quote_makers
            """).fetchone()
            
            conversion_rate = 0
            if search_to_quote and search_to_quote[0] > 0:
                conversion_rate = (search_to_quote[1] / search_to_quote[0]) * 100
            
            return {
                'popular_searches': [
                    {'term': term, 'count': count}
                    for term, count in search_terms if term
                ],
                'conversion': {
                    'search_to_quote_rate': round(conversion_rate, 2),
                    'total_searchers': search_to_quote[0] if search_to_quote else 0,
                    'total_quote_makers': search_to_quote[1] if search_to_quote else 0
                }
            }
            
        except Exception as e:
            logging.error(f"Search analytics error: {e}")
            return {}

# Decorator for tracking API performance
def track_performance(f):
    """Decorator to track API endpoint performance"""
    from functools import wraps
    import time
    from flask_jwt_extended import get_jwt_identity
    
    @wraps(f)
    def decorated_function(*args, **kwargs):
        start_time = time.time()
        
        try:
            result = f(*args, **kwargs)
            duration = time.time() - start_time
            status_code = getattr(result, 'status_code', 200)
            
            # Get user ID if available
            user_id = None
            try:
                user_id = get_jwt_identity()
            except:
                pass
            
            # Track performance
            PerformanceMonitor.track_api_performance(
                endpoint=request.endpoint or request.path,
                duration=duration,
                status_code=status_code,
                user_id=user_id
            )
            
            return result
            
        except Exception as e:
            duration = time.time() - start_time
            PerformanceMonitor.track_api_performance(
                endpoint=request.endpoint or request.path,
                duration=duration,
                status_code=500,
                user_id=None
            )
            raise e
    
    return decorated_function

# Analytics middleware
def init_analytics_middleware(app):
    """Initialize analytics middleware"""
    
    @app.before_request
    def before_request():
        """Track request start time"""
        request.start_time = time.time()
    
    @app.after_request
    def after_request(response):
        """Track request completion"""
        try:
            if hasattr(request, 'start_time'):
                duration = time.time() - request.start_time
                
                # Skip static files and health checks
                if not request.path.startswith('/static') and request.path != '/health':
                    user_id = None
                    try:
                        from flask_jwt_extended import get_jwt_identity
                        user_id = get_jwt_identity()
                    except:
                        pass
                    
                    PerformanceMonitor.track_api_performance(
                        endpoint=request.endpoint or request.path,
                        duration=duration,
                        status_code=response.status_code,
                        user_id=user_id
                    )
        except Exception as e:
            logging.error(f"Analytics middleware error: {e}")
        
        return response

# Cost calculator utilities
class CostCalculator:
    """Calculate job costs and estimates"""
    
    # Base rates by category (TRY per hour)
    BASE_RATES = {
        'Elektrik': 150,
        'Tesisatçılık': 140,
        'Boyacılık': 120,
        'Marangozluk': 160,
        'Temizlik': 80,
        'Tamir': 130,
        'Tadilat': 180,
        'Bahçıvanlık': 100
    }
    
    # Complexity multipliers
    COMPLEXITY_MULTIPLIERS = {
        'basit': 1.0,
        'orta': 1.3,
        'karmaşık': 1.8,
        'çok_karmaşık': 2.5
    }
    
    # Area multipliers
    AREA_MULTIPLIERS = {
        'salon': 1.2,
        'mutfak': 1.5,
        'banyo': 1.8,
        'yatak_odasi': 1.0,
        'balkon': 0.8,
        'teras': 0.9,
        'bahce': 1.1,
        'ofis': 1.3,
        'diger': 1.0
    }
    
    @staticmethod
    def estimate_job_cost(category, area_type, square_meters=None, complexity='orta', city='İstanbul'):
        """Estimate job cost based on parameters"""
        try:
            # Get base rate
            base_rate = CostCalculator.BASE_RATES.get(category, 130)
            
            # Apply area multiplier
            area_multiplier = CostCalculator.AREA_MULTIPLIERS.get(area_type, 1.0)
            
            # Apply complexity multiplier
            complexity_multiplier = CostCalculator.COMPLEXITY_MULTIPLIERS.get(complexity, 1.3)
            
            # City multiplier (Istanbul is more expensive)
            city_multiplier = 1.2 if city == 'İstanbul' else 1.0
            
            # Calculate base cost (assuming 4-8 hours average)
            estimated_hours = 6
            if square_meters:
                # Adjust hours based on area
                estimated_hours = max(2, min(16, square_meters / 10))
            
            base_cost = base_rate * estimated_hours
            
            # Apply all multipliers
            final_cost = base_cost * area_multiplier * complexity_multiplier * city_multiplier
            
            # Add material cost estimate (20-40% of labor)
            material_cost = final_cost * 0.3
            total_cost = final_cost + material_cost
            
            return {
                'labor_cost': round(final_cost, 2),
                'material_cost': round(material_cost, 2),
                'total_cost': round(total_cost, 2),
                'estimated_hours': round(estimated_hours, 1),
                'hourly_rate': base_rate,
                'breakdown': {
                    'base_rate': base_rate,
                    'area_multiplier': area_multiplier,
                    'complexity_multiplier': complexity_multiplier,
                    'city_multiplier': city_multiplier
                }
            }
            
        except Exception as e:
            logging.error(f"Cost estimation error: {e}")
            return {
                'labor_cost': 0,
                'material_cost': 0,
                'total_cost': 0,
                'estimated_hours': 0,
                'hourly_rate': 130
            }

# Real-time dashboard data
class DashboardData:
    """Generate real-time dashboard data"""
    
    @staticmethod
    def get_live_stats():
        """Get live platform statistics"""
        try:
            # Current active users (from socket connections)
            from app.utils.socketio_events import active_connections
            online_users = len(active_connections)
            
            # Today's stats
            today = datetime.utcnow().date()
            today_start = datetime.combine(today, datetime.min.time())
            
            today_quotes = Quote.query.filter(Quote.created_at >= today_start).count()
            today_registrations = User.query.filter(User.created_at >= today_start).count()
            today_completions = Quote.query.filter(
                Quote.updated_at >= today_start,
                Quote.status == QuoteStatus.COMPLETED
            ).count()
            
            # Revenue today
            today_revenue = db.session.query(func.sum(Quote.quoted_amount)).filter(
                Quote.updated_at >= today_start,
                Quote.status == QuoteStatus.COMPLETED
            ).scalar() or 0
            
            # Active quotes by status
            quote_status_counts = db.session.query(
                Quote.status, func.count(Quote.id)
            ).group_by(Quote.status).all()
            
            return {
                'live': {
                    'online_users': online_users,
                    'timestamp': datetime.utcnow().isoformat()
                },
                'today': {
                    'new_quotes': today_quotes,
                    'new_registrations': today_registrations,
                    'completed_jobs': today_completions,
                    'revenue': float(today_revenue)
                },
                'quote_status_distribution': {
                    status.value: count for status, count in quote_status_counts
                }
            }
            
        except Exception as e:
            logging.error(f"Live stats error: {e}")
            return {}

import time