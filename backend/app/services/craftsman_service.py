from sqlalchemy import and_, or_
import os
import json
import logging
from werkzeug.utils import secure_filename
from ..models.craftsman import Craftsman
from ..models.user import User
from ..models.category import Category
from ..models.review import Review
from .. import db

class CraftsmanService:
    logger = logging.getLogger(__name__)

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

    @staticmethod
    def upload_portfolio_image(user_id, file_storage, upload_folder):
        """Handle portfolio image upload for craftsmen."""
        CraftsmanService.logger.debug("upload_portfolio_image:start user_id=%s", user_id)
        user = User.query.get(user_id)
        if not user or getattr(user.user_type, 'value', user.user_type) != 'craftsman':
            return None, 'Sadece ustalar görsel yükleyebilir', 403

        craftsman = Craftsman.query.filter_by(user_id=user_id).first()
        if not craftsman:
            return None, 'Usta profili bulunamadı', 404

        try:
            os.makedirs(upload_folder, exist_ok=True)
            filename = file_storage.filename
            from time import time
            timestamp = str(int(time()))
            filename = f"{user_id}_{timestamp}_{secure_filename(filename)}"
            file_path = os.path.join(upload_folder, filename)
            file_storage.save(file_path)

            current_images = json.loads(craftsman.portfolio_images) if craftsman.portfolio_images else []
            image_url = f"/uploads/portfolio/{filename}"
            current_images.append(image_url)
            if len(current_images) > 10:
                oldest = current_images.pop(0)
                old_path = os.path.join(upload_folder, os.path.basename(oldest))
                if os.path.exists(old_path):
                    os.remove(old_path)

            craftsman.portfolio_images = json.dumps(current_images)
            db.session.commit()
            CraftsmanService.logger.debug("upload_portfolio_image:success user_id=%s", user_id)
            return {
                'image_url': image_url,
                'portfolio_images': current_images
            }, None, 200
        except Exception:
            CraftsmanService.logger.exception("upload_portfolio_image:error user_id=%s", user_id)
            db.session.rollback()
            return None, 'Görsel yükleme başarısız oldu', 500

    @staticmethod
    def delete_portfolio_image(user_id, image_url, upload_folder):
        """Delete portfolio image for craftsmen."""
        CraftsmanService.logger.debug("delete_portfolio_image:start user_id=%s", user_id)
        user = User.query.get(user_id)
        if not user or getattr(user.user_type, 'value', user.user_type) != 'craftsman':
            return None, 'Sadece ustalar görsel silebilir', 403

        craftsman = Craftsman.query.filter_by(user_id=user_id).first()
        if not craftsman:
            return None, 'Usta profili bulunamadı', 404

        current_images = json.loads(craftsman.portfolio_images) if craftsman.portfolio_images else []
        if image_url not in current_images:
            return None, 'Görsel bulunamadı', 404

        try:
            current_images.remove(image_url)
            craftsman.portfolio_images = json.dumps(current_images)
            file_path = os.path.join(upload_folder, os.path.basename(image_url))
            if os.path.exists(file_path):
                os.remove(file_path)
            db.session.commit()
            CraftsmanService.logger.debug("delete_portfolio_image:success user_id=%s", user_id)
            return {'portfolio_images': current_images}, None, 200
        except Exception:
            CraftsmanService.logger.exception("delete_portfolio_image:error user_id=%s", user_id)
            db.session.rollback()
            return None, 'Görsel silme başarısız oldu', 500
