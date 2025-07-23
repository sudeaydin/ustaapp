from ..models.customer import Customer
from ..models.user import User
from .. import db

class CustomerService:
    @staticmethod
    def get_by_id(customer_id):
        """Get customer by ID"""
        return Customer.query.filter_by(id=customer_id).first()
    
    @staticmethod
    def get_by_user_id(user_id):
        """Get customer by user ID"""
        return Customer.query.filter_by(user_id=user_id).first()
    
    @staticmethod
    def update(customer, data):
        """Update customer profile"""
        for key, value in data.items():
            if hasattr(customer, key):
                setattr(customer, key, value)
        
        db.session.commit()
        return customer