from app import db
from datetime import datetime

class Review(db.Model):
    """Reviews for craftsmen"""
    __tablename__ = 'reviews'
    
    id = db.Column(db.Integer, primary_key=True)
    customer_id = db.Column(db.Integer, db.ForeignKey('customers.id'), nullable=False)
    craftsman_id = db.Column(db.Integer, db.ForeignKey('craftsmen.id'), nullable=False)
    quote_id = db.Column(db.Integer, db.ForeignKey('quotes.id'), nullable=False, unique=True)
    
    # Review content
    rating = db.Column(db.Integer, nullable=False)  # 1-5 stars
    title = db.Column(db.String(255))
    comment = db.Column(db.Text)
    
    # Review aspects
    quality_rating = db.Column(db.Integer)  # 1-5
    punctuality_rating = db.Column(db.Integer)  # 1-5
    communication_rating = db.Column(db.Integer)  # 1-5
    cleanliness_rating = db.Column(db.Integer)  # 1-5
    
    # Media
    images = db.Column(db.JSON)  # List of image URLs
    
    # Status
    is_verified = db.Column(db.Boolean, default=False)  # Verified purchase
    is_visible = db.Column(db.Boolean, default=True)
    
    # Response from craftsman
    craftsman_response = db.Column(db.Text)
    response_date = db.Column(db.DateTime)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    customer = db.relationship('Customer', backref='reviews_given')
    craftsman = db.relationship('Craftsman', backref='reviews_received')
    quote = db.relationship('Quote', backref=db.backref('review', uselist=False))
    
    def to_dict(self, include_customer=True):
        data = {
            'id': self.id,
            'customer_id': self.customer_id,
            'craftsman_id': self.craftsman_id,
            'quote_id': self.quote_id,
            'rating': self.rating,
            'title': self.title,
            'comment': self.comment,
            'quality_rating': self.quality_rating,
            'punctuality_rating': self.punctuality_rating,
            'communication_rating': self.communication_rating,
            'cleanliness_rating': self.cleanliness_rating,
            'images': self.images or [],
            'is_verified': self.is_verified,
            'is_visible': self.is_visible,
            'craftsman_response': self.craftsman_response,
            'response_date': self.response_date.isoformat() if self.response_date else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if include_customer and self.customer:
            data['customer'] = {
                'id': self.customer.id,
                'user': {
                    'first_name': self.customer.user.first_name,
                    'last_name': self.customer.user.last_name,
                    'profile_image': self.customer.user.profile_image
                }
            }
            
        if hasattr(self, 'quote') and self.quote and self.quote.service:
            data['service'] = {
                'id': self.quote.service.id,
                'title': self.quote.service.title,
                'category': self.quote.service.category.to_dict() if self.quote.service.category else None
            }
        
        return data
    
    @property
    def average_rating(self):
        """Calculate average rating from all aspects"""
        ratings = [r for r in [
            self.quality_rating,
            self.punctuality_rating, 
            self.communication_rating,
            self.cleanliness_rating
        ] if r is not None]
        
        if ratings:
            return sum(ratings) / len(ratings)
        return self.rating
    
    def __repr__(self):
        return f'<Review {self.id} - {self.rating} stars>'


# Helper function to update craftsman rating
def update_craftsman_rating(craftsman_id):
    """Update craftsman's overall rating based on reviews"""
    from app.models.craftsman import Craftsman
    
    craftsman = Craftsman.query.get(craftsman_id)
    if not craftsman:
        return
    
    reviews = Review.query.filter_by(
        craftsman_id=craftsman_id,
        is_visible=True
    ).all()
    
    if reviews:
        total_rating = sum(review.rating for review in reviews)
        craftsman.rating = round(total_rating / len(reviews), 1)
        craftsman.review_count = len(reviews)
    else:
        craftsman.rating = 0.0
        craftsman.review_count = 0
    
    db.session.commit()
