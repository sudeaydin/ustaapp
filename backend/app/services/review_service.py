from ..models.review import Review
from .. import db

class ReviewService:
    @staticmethod
    def get_by_id(review_id):
        return Review.query.get(review_id)
    
    @staticmethod
    def create(data):
        review = Review(**data)
        db.session.add(review)
        db.session.commit()
        return review
    
    @staticmethod
    def update(review, data):
        for key, value in data.items():
            if hasattr(review, key):
                setattr(review, key, value)
        db.session.commit()
        return review