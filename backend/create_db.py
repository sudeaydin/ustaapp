#!/usr/bin/env python3
"""
Simple database creation script
"""

from app import create_app, db

def create_database():
    """Create database tables"""
    app = create_app()
    
    with app.app_context():
        print("Creating database tables...")
        try:
            # Drop all tables first
            db.drop_all()
            print("Dropped existing tables")
            
            # Create all tables
            db.create_all()
            print("✅ Database tables created successfully!")
            
            # Add some sample data
            from app.models.user import User
            from app.models.customer import Customer
            from app.models.craftsman import Craftsman
            from app.models.category import Category
            
            # Create categories
            categories_data = [
                {'name': 'Elektrikçi', 'description': 'Elektrik tesisatı ve onarım'},
                {'name': 'Tesisatçı', 'description': 'Su ve doğalgaz tesisatı'},
                {'name': 'Boyacı', 'description': 'Duvar boyama ve badana'},
                {'name': 'Marangoz', 'description': 'Ahşap işleri ve mobilya'},
                {'name': 'Temizlik', 'description': 'Ev ve ofis temizliği'},
            ]
            
            for cat_data in categories_data:
                category = Category(**cat_data)
                db.session.add(category)
            
            # Create test customer
            customer_user = User(
                email='musteri@test.com',
                first_name='Test',
                last_name='Müşteri',
                phone='5551112233',
                user_type='customer'
            )
            customer_user.set_password('123456')
            db.session.add(customer_user)
            db.session.flush()
            
            customer = Customer(user_id=customer_user.id)
            db.session.add(customer)
            
            # Create test craftsman
            craftsman_user = User(
                email='usta@test.com',
                first_name='Test',
                last_name='Usta',
                phone='5552223344',
                user_type='craftsman'
            )
            craftsman_user.set_password('123456')
            db.session.add(craftsman_user)
            db.session.flush()
            
            craftsman = Craftsman(
                user_id=craftsman_user.id,
                business_name='Test Elektrik',
                description='Test ustası',
                city='İstanbul',
                district='Kadıköy'
            )
            db.session.add(craftsman)
            
            db.session.commit()
            print("✅ Sample data created!")
            
        except Exception as e:
            print(f"❌ Error: {e}")
            db.session.rollback()
            return False
    
    return True

if __name__ == '__main__':
    success = create_database()
    if success:
        print("🎉 Database setup completed!")
    else:
        print("💥 Database setup failed!")