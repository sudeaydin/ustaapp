#!/usr/bin/env python3
"""
Database initialization script with sample data
"""

import os
import sys
from datetime import datetime, timedelta
from decimal import Decimal

# Add the backend directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category
from app.models.quote import Quote
from app.models.payment import Payment
from app.models.notification import Notification
from werkzeug.security import generate_password_hash

def create_sample_data():
    """Create sample data for testing"""
    
    print("Creating sample data...")
    
    # Create categories
    categories = [
        {'name': 'Elektrikçi', 'description': 'Elektrik tesisatı ve onarım', 'icon': '⚡', 'color': '#f59e0b'},
        {'name': 'Tesisatçı', 'description': 'Su ve doğalgaz tesisatı', 'icon': '🔧', 'color': '#3b82f6'},
        {'name': 'Boyacı', 'description': 'İç ve dış cephe boyama', 'icon': '🎨', 'color': '#ef4444'},
        {'name': 'Marangoz', 'description': 'Ahşap işleri ve mobilya', 'icon': '🔨', 'color': '#8b5cf6'},
        {'name': 'Temizlik', 'description': 'Ev ve ofis temizlik hizmetleri', 'icon': '🧹', 'color': '#10b981'},
        {'name': 'Bahçıvan', 'description': 'Bahçe düzenleme ve bakım', 'icon': '🌱', 'color': '#22c55e'},
    ]
    
    for i, cat_data in enumerate(categories):
        category = Category(
            name=cat_data['name'],
            description=cat_data['description'],
            icon=cat_data['icon'],
            color=cat_data['color'],
            sort_order=i,
            is_active=True
        )
        db.session.add(category)
    
    db.session.commit()
    print("Categories created.")
    
    # Create test users
    users_data = [
        # Customers
        {
            'email': 'musteri@test.com',
            'password': '123456',
            'first_name': 'Test',
            'last_name': 'Müşteri',
            'phone': '05551234567',
            'user_type': 'customer'
        },
        {
            'email': 'ali@test.com',
            'password': '123456',
            'first_name': 'Ali',
            'last_name': 'Yılmaz',
            'phone': '05551234568',
            'user_type': 'customer'
        },
        # Craftsmen
        {
            'email': 'usta@test.com',
            'password': '123456',
            'first_name': 'Ahmet',
            'last_name': 'Usta',
            'phone': '05551234569',
            'user_type': 'craftsman'
        },
        {
            'email': 'mehmet@test.com',
            'password': '123456',
            'first_name': 'Mehmet',
            'last_name': 'Elektrikçi',
            'phone': '05551234570',
            'user_type': 'craftsman'
        },
        {
            'email': 'fatma@test.com',
            'password': '123456',
            'first_name': 'Fatma',
            'last_name': 'Temizlik',
            'phone': '05551234571',
            'user_type': 'craftsman'
        },
        {
            'email': 'kemal@test.com',
            'password': '123456',
            'first_name': 'Kemal',
            'last_name': 'Boyacı',
            'phone': '05551234572',
            'user_type': 'craftsman'
        }
    ]
    
    created_users = {}
    for user_data in users_data:
        user = User(
            email=user_data['email'],
            password_hash=generate_password_hash(user_data['password']),
            first_name=user_data['first_name'],
            last_name=user_data['last_name'],
            phone=user_data['phone'],
            user_type=user_data['user_type'],
            is_active=True,
            created_at=datetime.utcnow()
        )
        db.session.add(user)
        db.session.flush()  # Get the ID
        created_users[user_data['email']] = user
    
    db.session.commit()
    print("Users created.")
    
    # Create customer profiles
    customers_data = [
        {'email': 'musteri@test.com', 'address': 'Kadıköy, İstanbul'},
        {'email': 'ali@test.com', 'address': 'Beşiktaş, İstanbul'},
    ]
    
    for customer_data in customers_data:
        user = created_users[customer_data['email']]
        customer = Customer(
            user_id=user.id,
            address=customer_data['address'],
            created_at=datetime.utcnow()
        )
        db.session.add(customer)
    
    db.session.commit()
    print("Customers created.")
    
    # Create craftsman profiles
    craftsmen_data = [
        {
            'email': 'usta@test.com',
            'business_name': 'Ahmet Elektrik',
            'description': '15 yıllık deneyim ile elektrik tesisatı ve onarım hizmetleri',
            'address': 'Atatürk Mah. Elektrik Sok. No:5 Kadıköy/İstanbul',
            'city': 'İstanbul',
            'district': 'Kadıköy',
            'hourly_rate': Decimal('150.00'),
            'average_rating': 4.8,
            'total_reviews': 124,
            'is_available': True,
            'is_verified': True
        },
        {
            'email': 'mehmet@test.com',
            'business_name': 'Mehmet Elektrik Servisi',
            'description': 'Hızlı ve güvenilir elektrik hizmetleri',
            'address': 'Cumhuriyet Mah. Işık Cad. No:12 Şişli/İstanbul',
            'city': 'İstanbul',
            'district': 'Şişli',
            'hourly_rate': Decimal('120.00'),
            'average_rating': 4.5,
            'total_reviews': 87,
            'is_available': True,
            'is_verified': True
        },
        {
            'email': 'fatma@test.com',
            'business_name': 'Fatma Temizlik',
            'description': 'Profesyonel ev ve ofis temizlik hizmetleri',
            'address': 'Yeşil Mah. Temiz Sok. No:8 Beşiktaş/İstanbul',
            'city': 'İstanbul',
            'district': 'Beşiktaş',
            'hourly_rate': Decimal('80.00'),
            'average_rating': 4.9,
            'total_reviews': 156,
            'is_available': True,
            'is_verified': True
        },
        {
            'email': 'kemal@test.com',
            'business_name': 'Kemal Boya',
            'description': 'İç ve dış cephe boyama, dekoratif duvar kaplamaları',
            'address': 'Sanat Mah. Renk Cad. No:15 Üsküdar/İstanbul',
            'city': 'İstanbul',
            'district': 'Üsküdar',
            'hourly_rate': Decimal('100.00'),
            'average_rating': 4.3,
            'total_reviews': 67,
            'is_available': False,
            'is_verified': True
        }
    ]
    
    created_craftsmen = {}
    for craftsman_data in craftsmen_data:
        user = created_users[craftsman_data['email']]
        craftsman = Craftsman(
            user_id=user.id,
            business_name=craftsman_data['business_name'],
            description=craftsman_data['description'],
            address=craftsman_data['address'],
            city=craftsman_data['city'],
            district=craftsman_data['district'],
            hourly_rate=craftsman_data['hourly_rate'],
            average_rating=craftsman_data['average_rating'],
            total_reviews=craftsman_data['total_reviews'],
            is_available=craftsman_data['is_available'],
            is_verified=craftsman_data['is_verified'],
            created_at=datetime.utcnow()
        )
        db.session.add(craftsman)
        db.session.flush()
        created_craftsmen[craftsman_data['email']] = craftsman
    
    db.session.commit()
    print("Craftsmen created.")
    
    # Create sample quotes
    customer = Customer.query.filter_by(user_id=created_users['musteri@test.com'].id).first()
    craftsman = created_craftsmen['usta@test.com']
    
    quote = Quote(
        customer_id=customer.id,
        craftsman_id=craftsman.id,
        title='Elektrik Panosu Onarımı',
        description='Evimizde elektrik panosu arızalı, sürekli sigortalar atıyor. Kontrol edilip onarılmasını istiyorum.',
        location='Kadıköy, İstanbul',
        preferred_date=datetime.now() + timedelta(days=2),
        budget_min=Decimal('200.00'),
        budget_max=Decimal('500.00'),
        status='pending',
        created_at=datetime.now()
    )
    db.session.add(quote)
    
    db.session.commit()
    print("Sample quotes created.")
    
    print("Sample data creation completed!")

def main():
    """Main function"""
    app = create_app()
    
    with app.app_context():
        # Drop all tables
        print("Dropping existing tables...")
        db.drop_all()
        
        # Create all tables
        print("Creating tables...")
        db.create_all()
        
        # Create sample data
        create_sample_data()
        
        print("Database setup completed successfully!")

if __name__ == '__main__':
    main()