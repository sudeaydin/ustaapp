from sqlalchemy import and_, or_
from ..models.craftsman import Craftsman
from ..models.user import User
from ..models.category import Category
from ..models.review import Review
from .. import db

class CraftsmanService:
    @staticmethod
    def get_all(page=1, per_page=10, filters=None):
        """Get all craftsmen with pagination and filters"""
        query = Craftsman.query.join(User).filter(User.is_active == True)
        
        if filters:
            if filters.get('category_id'):
                query = query.filter(Craftsman.categories.any(Category.id == filters['category_id']))
            
            if filters.get('city'):
                query = query.filter(Craftsman.city.ilike(f"%{filters['city']}%"))
            
            if filters.get('district'):
                query = query.filter(Craftsman.district.ilike(f"%{filters['district']}%"))
            
            if filters.get('is_available'):
                query = query.filter(Craftsman.is_available == filters['is_available'])
            
            if filters.get('min_rating'):
                query = query.filter(Craftsman.average_rating >= filters['min_rating'])
            
            if filters.get('search'):
                search_term = f"%{filters['search']}%"
                query = query.filter(
                    or_(
                        Craftsman.business_name.ilike(search_term),
                        Craftsman.description.ilike(search_term),
                        User.first_name.ilike(search_term),
                        User.last_name.ilike(search_term)
                    )
                )
        
        return query.paginate(page=page, per_page=per_page, error_out=False)
    
    @staticmethod
    def get_by_id(craftsman_id):
        """Get craftsman by ID"""
        return Craftsman.query.filter_by(id=craftsman_id).first()
    
    @staticmethod
    def get_by_user_id(user_id):
        """Get craftsman by user ID"""
        return Craftsman.query.filter_by(user_id=user_id).first()
    
    @staticmethod
    def create(user_id, data):
        """Create new craftsman profile"""
        craftsman = Craftsman(
            user_id=user_id,
            business_name=data['business_name'],
            description=data['description'],
            address=data['address'],
            city=data['city'],
            district=data['district'],
            hourly_rate=data.get('hourly_rate'),
            is_available=data.get('is_available', True)
        )
        
        # Add categories
        if 'category_ids' in data:
            categories = Category.query.filter(Category.id.in_(data['category_ids'])).all()
            craftsman.categories.extend(categories)
        
        db.session.add(craftsman)
        db.session.commit()
        return craftsman
    
    @staticmethod
    def update(craftsman, data):
        """Update craftsman profile"""
        for key, value in data.items():
            if key == 'category_ids':
                # Update categories
                categories = Category.query.filter(Category.id.in_(value)).all()
                craftsman.categories = categories
            elif hasattr(craftsman, key):
                setattr(craftsman, key, value)
        
        db.session.commit()
        return craftsman
    
    @staticmethod
    def delete(craftsman):
        """Delete craftsman profile"""
        db.session.delete(craftsman)
        db.session.commit()
    
    @staticmethod
    def get_reviews(craftsman_id, page=1, per_page=10):
        """Get craftsman reviews with pagination"""
        return Review.query.filter_by(craftsman_id=craftsman_id)\
                          .order_by(Review.created_at.desc())\
                          .paginate(page=page, per_page=per_page, error_out=False)
    
    @staticmethod
    def update_rating(craftsman_id):
        """Update craftsman's average rating"""
        reviews = Review.query.filter_by(craftsman_id=craftsman_id).all()
        if reviews:
            total_rating = sum(review.rating for review in reviews)
            average_rating = total_rating / len(reviews)
            
            craftsman = Craftsman.query.get(craftsman_id)
            craftsman.average_rating = round(average_rating, 2)
            craftsman.total_reviews = len(reviews)
            db.session.commit()