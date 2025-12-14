from app.extensions import db
from datetime import datetime
from sqlalchemy import Numeric, Index
import json

class Craftsman(db.Model):
    """Craftsman profile extending User"""
    __tablename__ = 'craftsmen'
    
    # Add indexes for search and filtering
    __table_args__ = (
        Index('idx_craftsman_city_available', 'city', 'is_available'),
        Index('idx_craftsman_rating', 'average_rating'),
        Index('idx_craftsman_verified_available', 'is_verified', 'is_available'),
        Index('idx_craftsman_hourly_rate', 'hourly_rate'),
        Index('idx_craftsman_created_at', 'created_at'),
    )

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, unique=True)
    
    # Professional info
    business_name = db.Column(db.String(255))
    description = db.Column(db.Text)
    address = db.Column(db.String(500))
    city = db.Column(db.String(100))
    district = db.Column(db.String(100))
    hourly_rate = db.Column(Numeric(10, 2))
    experience_years = db.Column(db.Integer, default=0)
    
    # Skills and certifications (stored as JSON)
    specialties = db.Column(db.String(255))  # Comma separated specialties for search
    skills = db.Column(db.Text)  # JSON string
    certifications = db.Column(db.Text)  # JSON string
    working_hours = db.Column(db.Text)  # JSON string
    service_areas = db.Column(db.Text)  # JSON string
    
    # Contact info
    website = db.Column(db.String(255))
    response_time = db.Column(db.String(100))
    
    # Ratings
    average_rating = db.Column(db.Float, default=0.0)
    total_reviews = db.Column(db.Integer, default=0)
    total_jobs = db.Column(db.Integer, default=0)
    
    # Status
    is_available = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)
    
    # Avatar
    avatar = db.Column(db.String(500))

    # Portfolio images for business profile
    portfolio_images = db.Column(db.Text)  # JSON array of image URLs

    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', back_populates='craftsman_profile', lazy='joined')
    
    def to_dict(self, include_user=True):
        data = {
            'id': self.id,
            'business_name': self.business_name,
            'description': self.description,
            'address': self.address,
            'city': self.city,
            'district': self.district,
            'hourly_rate': str(self.hourly_rate) if self.hourly_rate else None,
            'experience_years': self.experience_years,
            'specialties': self.specialties,
            'skills': self.skills,
            'certifications': self.certifications,
            'working_hours': self.working_hours,
            'service_areas': self.service_areas,
            'website': self.website,
            'response_time': self.response_time,
            'average_rating': self.average_rating,
            'total_reviews': self.total_reviews,
            'total_jobs': self.total_jobs,
            'is_available': self.is_available,
            'is_verified': self.is_verified,
            'avatar': self.avatar,
            'portfolio_images': json.loads(self.portfolio_images) if self.portfolio_images else [],
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if include_user and self.user:
            data['user'] = self.user.to_dict()
            
        return data
    
    def update_review_stats(self):
        """Update average rating and total reviews from Review model"""
        from app.models.review import Review
        
        reviews = Review.query.filter_by(
            craftsman_id=self.id,
            is_visible=True
        ).all()
        
        if reviews:
            total_rating = sum(review.rating for review in reviews)
            self.average_rating = round(total_rating / len(reviews), 1)
            self.total_reviews = len(reviews)
        else:
            self.average_rating = 0.0
            self.total_reviews = 0
        
        db.session.commit()
        return self.average_rating, self.total_reviews
    
    @property
    def review_stats(self):
        """Get current review statistics"""
        return {
            'average_rating': self.average_rating,
            'total_reviews': self.total_reviews,
            'rating_distribution': self._get_rating_distribution()
        }
    
    def _get_rating_distribution(self):
        """Get distribution of ratings (1-5 stars)"""
        from app.models.review import Review
        
        distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
        
        reviews = Review.query.filter_by(
            craftsman_id=self.id,
            is_visible=True
        ).all()
        
        for review in reviews:
            if 1 <= review.rating <= 5:
                distribution[review.rating] += 1
        
        return distribution
    
    def __repr__(self):
        return f'<Craftsman {self.business_name or self.id}>'


# Association table for many-to-many relationship between craftsmen and categories
craftsman_categories = db.Table('craftsman_categories',
    db.Column('craftsman_id', db.Integer, db.ForeignKey('craftsmen.id'), primary_key=True),
    db.Column('category_id', db.Integer, db.ForeignKey('categories.id'), primary_key=True),
    db.Column('created_at', db.DateTime, default=datetime.utcnow)
)
