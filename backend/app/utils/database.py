from sqlalchemy import create_engine, event, or_
from sqlalchemy.pool import QueuePool
from sqlalchemy.orm import sessionmaker
from flask import current_app
import logging

class DatabaseManager:
    """Database connection and optimization manager"""
    
    @staticmethod
    def configure_engine(app):
        """Configure database engine with optimizations"""
        
        # Database URL from config
        database_url = app.config.get('SQLALCHEMY_DATABASE_URI', 'sqlite:///ustam.db')
        
        # Engine configuration for better performance
        engine_config = {
            'poolclass': QueuePool,
            'pool_size': 10,
            'max_overflow': 20,
            'pool_pre_ping': True,
            'pool_recycle': 3600,  # 1 hour
            'echo': app.config.get('SQLALCHEMY_ECHO', False),
        }
        
        # SQLite specific optimizations
        if database_url.startswith('sqlite'):
            engine_config.update({
                'pool_size': 1,
                'max_overflow': 0,
                'poolclass': None,
            })
        
        return engine_config
    
    @staticmethod
    def setup_sqlite_optimizations(dbapi_connection, connection_record):
        """Optimize SQLite for better performance"""
        with dbapi_connection.cursor() as cursor:
            # Enable WAL mode for better concurrency
            cursor.execute("PRAGMA journal_mode=WAL")
            
            # Increase cache size (default is usually too small)
            cursor.execute("PRAGMA cache_size=10000")
            
            # Enable foreign key constraints
            cursor.execute("PRAGMA foreign_keys=ON")
            
            # Optimize synchronous mode for better performance
            cursor.execute("PRAGMA synchronous=NORMAL")
            
            # Set busy timeout for concurrent access
            cursor.execute("PRAGMA busy_timeout=30000")
    
    @staticmethod
    def register_sqlite_events(engine):
        """Register SQLite optimization events"""
        if engine.url.drivername == 'sqlite':
            event.listen(engine, "connect", DatabaseManager.setup_sqlite_optimizations)

class QueryOptimizer:
    """Query optimization utilities"""
    
    @staticmethod
    def add_search_indexes():
        """Add search-specific indexes"""
        from app import db
        
        # Text search indexes for better LIKE queries
        indexes = [
            "CREATE INDEX IF NOT EXISTS idx_craftsman_search_text ON craftsmen(business_name, description, specialties)",
            "CREATE INDEX IF NOT EXISTS idx_user_search_text ON users(first_name, last_name)",
            "CREATE INDEX IF NOT EXISTS idx_quote_status_dates ON quotes(status, created_at, updated_at)",
            "CREATE INDEX IF NOT EXISTS idx_message_conversation ON messages(conversation_id, created_at)",
        ]
        
        for index_sql in indexes:
            try:
                db.session.execute(index_sql)
                db.session.commit()
            except Exception as e:
                logging.warning(f"Could not create index: {e}")
                db.session.rollback()
    
    @staticmethod
    def optimize_search_query(query, search_term):
        """Optimize search queries with proper indexing"""
        if not search_term:
            return query

        # Use bound parameters instead of interpolating user input to avoid SQL injection
        from app.models.craftsman import Craftsman  # imported here to avoid circular deps

        search_pattern = f"%{search_term}%"

        return query.filter(
            or_(
                Craftsman.business_name.ilike(search_pattern),
                Craftsman.description.ilike(search_pattern),
                Craftsman.specialties.ilike(search_pattern),
            )
        )

class CacheManager:
    """Simple caching for frequently accessed data"""
    
    _cache = {}
    _cache_ttl = {}
    
    @classmethod
    def get(cls, key):
        """Get cached value if not expired"""
        import time
        
        if key not in cls._cache:
            return None
            
        if key in cls._cache_ttl and time.time() > cls._cache_ttl[key]:
            cls.delete(key)
            return None
            
        return cls._cache[key]
    
    @classmethod
    def set(cls, key, value, ttl=300):  # 5 minutes default
        """Set cached value with TTL"""
        import time
        
        cls._cache[key] = value
        cls._cache_ttl[key] = time.time() + ttl
    
    @classmethod
    def delete(cls, key):
        """Delete cached value"""
        cls._cache.pop(key, None)
        cls._cache_ttl.pop(key, None)
    
    @classmethod
    def clear(cls):
        """Clear all cache"""
        cls._cache.clear()
        cls._cache_ttl.clear()

# Decorator for caching API responses
def cache_response(ttl=300):
    """Decorator to cache API responses"""
    def decorator(f):
        from functools import wraps
        
        @wraps(f)
        def decorated_function(*args, **kwargs):
            # Create cache key from function name and args
            cache_key = f"{f.__name__}:{hash(str(args) + str(kwargs))}"
            
            # Try to get from cache
            cached_result = CacheManager.get(cache_key)
            if cached_result:
                return cached_result
            
            # Execute function and cache result
            result = f(*args, **kwargs)
            CacheManager.set(cache_key, result, ttl)
            
            return result
        
        return decorated_function
    return decorator

# Database health check
def check_database_health():
    """Check database connection and performance"""
    from app.extensions import db
    import time
    
    try:
        start_time = time.time()
        
        # Simple query to test connection
        db.session.execute("SELECT 1")
        
        query_time = (time.time() - start_time) * 1000  # ms
        
        return {
            'status': 'healthy',
            'query_time_ms': round(query_time, 2),
            'connection_pool_size': db.engine.pool.size(),
            'checked_out_connections': db.engine.pool.checkedout(),
        }
    except Exception as e:
        return {
            'status': 'unhealthy',
            'error': str(e)
        }
