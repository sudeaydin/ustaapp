#!/usr/bin/env python3
"""
Super simple database setup
"""

from app import create_app, db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category
from werkzeug.security import generate_password_hash
from datetime import datetime
from decimal import Decimal

def main():
    app = create_app()
    
    with app.app_context():
        # Drop and create tables
        print("🗑️  Dropping tables...")
        db.drop_all()
        
        print("🏗️  Creating tables...")
        db.create_all()
        
        print("📝 Creating sample data...")
        
        # Create categories
        elektrik = Category(name='Elektrikçi', description='Elektrik işleri', icon='⚡', color='#f59e0b', sort_order=1, is_active=True)
        tesisat = Category(name='Tesisatçı', description='Su ve doğalgaz', icon='🔧', color='#3b82f6', sort_order=2, is_active=True)
        boya = Category(name='Boyacı', description='Boya işleri', icon='🎨', color='#ef4444', sort_order=3, is_active=True)
        
        db.session.add_all([elektrik, tesisat, boya])
        
        # Create users
        musteri_user = User(
            email='musteri@test.com',
            password_hash=generate_password_hash('123456'),
            first_name='Test',
            last_name='Müşteri',
            phone='05551234567',
            user_type='customer',
            is_active=True,
            created_at=datetime.now()
        )
        
        usta_user = User(
            email='usta@test.com',
            password_hash=generate_password_hash('123456'),
            first_name='Ahmet',
            last_name='Usta',
            phone='05551234568',
            user_type='craftsman',
            is_active=True,
            created_at=datetime.now()
        )
        
        db.session.add_all([musteri_user, usta_user])
        db.session.commit()  # Commit to get IDs
        
        # Create customer
        customer = Customer(
            user_id=musteri_user.id,
            address='Kadıköy, İstanbul',
            created_at=datetime.now()
        )
        
        # Create craftsman
        craftsman = Craftsman(
            user_id=usta_user.id,
            business_name='Ahmet Elektrik',
            description='15 yıllık deneyim',
            address='Kadıköy, İstanbul',
            city='İstanbul',
            district='Kadıköy',
            hourly_rate=Decimal('150.00'),
            average_rating=4.8,
            total_reviews=124,
            is_available=True,
            is_verified=True,
            created_at=datetime.now()
        )
        
        db.session.add_all([customer, craftsman])
        db.session.commit()
        
        print("✅ Database setup complete!")
        print("📧 Test users:")
        print("   Customer: musteri@test.com / 123456")
        print("   Craftsman: usta@test.com / 123456")

if __name__ == '__main__':
    main()