#!/usr/bin/env python3
"""
Simplified database setup script
Creates tables and populates with basic test data
"""

from app import create_app, db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category
from app.models.quote import Quote
from werkzeug.security import generate_password_hash
from datetime import datetime
import os

def create_message_table():
    """Create messages table directly with SQL"""
    with db.engine.connect() as conn:
        # Drop existing table if exists
        conn.execute(db.text("DROP TABLE IF EXISTS messages"))
        
        # Create messages table
        create_table_sql = """
        CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender_id INTEGER NOT NULL,
            receiver_id INTEGER NOT NULL,
            content TEXT NOT NULL,
            is_read BOOLEAN DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sender_id) REFERENCES users (id),
            FOREIGN KEY (receiver_id) REFERENCES users (id)
        )
        """
        conn.execute(db.text(create_table_sql))
        conn.commit()
        print("✅ Messages table created successfully")

def setup_database():
    """Create all tables and populate with test data"""
    
    # Create Flask app
    app = create_app()
    
    with app.app_context():
        print("🔄 Setting up database...")
        
        # Drop all existing tables
        db.drop_all()
        print("🗑️  Dropped existing tables")
        
        # Create all tables
        db.create_all()
        print("🏗️  Created tables from models")
        
        # Create messages table manually
        create_message_table()
        
        # Create categories
        categories_data = [
            {'name': 'Elektrikçi', 'description': 'Elektrik tesisatı ve onarım', 'icon': '⚡', 'color': '#f59e0b', 'sort_order': 1, 'is_active': True},
            {'name': 'Tesisatçı', 'description': 'Su ve doğalgaz tesisatı', 'icon': '🔧', 'color': '#3b82f6', 'sort_order': 2, 'is_active': True},
            {'name': 'Boyacı', 'description': 'İç ve dış cephe boyama', 'icon': '🎨', 'color': '#10b981', 'sort_order': 3, 'is_active': True},
            {'name': 'Temizlik', 'description': 'Ev ve ofis temizliği', 'icon': '🧽', 'color': '#8b5cf6', 'sort_order': 4, 'is_active': True},
            {'name': 'Marangoz', 'description': 'Ahşap işleri ve mobilya', 'icon': '🔨', 'color': '#f97316', 'sort_order': 5, 'is_active': True},
            {'name': 'Bahçıvan', 'description': 'Bahçe bakımı ve peyzaj', 'icon': '🌱', 'color': '#22c55e', 'sort_order': 6, 'is_active': True},
            {'name': 'Klima Teknisyeni', 'description': 'Klima kurulum ve bakım', 'icon': '❄️', 'color': '#06b6d4', 'sort_order': 7, 'is_active': True},
            {'name': 'Cam Ustası', 'description': 'Cam kesim ve montaj', 'icon': '🪟', 'color': '#6366f1', 'sort_order': 8, 'is_active': True},
        ]
        
        for cat_data in categories_data:
            category = Category(**cat_data)
            db.session.add(category)
        
        print("📂 Created categories")
        
        # Create test users
        users_data = [
            # Customers
            {
                'email': 'customer1@test.com',
                'password': 'test123',
                'first_name': 'Ayşe',
                'last_name': 'Yılmaz',
                'phone': '0532 111 2233',
                'user_type': 'customer',
                'profile': {'address': 'Kadıköy, İstanbul'}
            },
            {
                'email': 'customer2@test.com',
                'password': 'test123',
                'first_name': 'Mehmet',
                'last_name': 'Demir',
                'phone': '0533 444 5566',
                'user_type': 'customer',
                'profile': {'address': 'Beşiktaş, İstanbul'}
            },
            
            # Craftsmen
            {
                'email': 'ahmet.elektrik@test.com',
                'password': 'test123',
                'first_name': 'Ahmet',
                'last_name': 'Yılmaz',
                'phone': '0534 123 4567',
                'user_type': 'craftsman',
                'profile': {
                    'business_name': 'Ahmet Usta Elektrik',
                    'description': 'Elektrik tesisatı, aydınlatma, pano montajı ve onarım hizmetleri. 15 yıllık deneyim.',
                    'address': 'Ataşehir, İstanbul',
                    'city': 'İstanbul',
                    'district': 'Ataşehir',
                    'hourly_rate': 150.00,
                    'average_rating': 4.8,
                    'total_reviews': 25,
                    'is_available': True,
                    'is_verified': True
                }
            },
            {
                'email': 'mehmet.tesisat@test.com',
                'password': 'test123',
                'first_name': 'Mehmet',
                'last_name': 'Öz',
                'phone': '0535 987 6543',
                'user_type': 'craftsman',
                'profile': {
                    'business_name': 'Mehmet Usta Tesisat',
                    'description': 'Su tesisatı, doğalgaz tesisatı, kombi bakım ve onarım. Acil servis mevcut.',
                    'address': 'Şişli, İstanbul',
                    'city': 'İstanbul',
                    'district': 'Şişli',
                    'hourly_rate': 120.00,
                    'average_rating': 4.6,
                    'total_reviews': 18,
                    'is_available': True,
                    'is_verified': True
                }
            },
            {
                'email': 'fatma.temizlik@test.com',
                'password': 'test123',
                'first_name': 'Fatma',
                'last_name': 'Kaya',
                'phone': '0536 555 7788',
                'user_type': 'craftsman',
                'profile': {
                    'business_name': 'Fatma Hanım Temizlik',
                    'description': 'Ev temizliği, ofis temizliği, cam silme, halı yıkama hizmetleri.',
                    'address': 'Bakırköy, İstanbul',
                    'city': 'İstanbul',
                    'district': 'Bakırköy',
                    'hourly_rate': 80.00,
                    'average_rating': 4.9,
                    'total_reviews': 42,
                    'is_available': True,
                    'is_verified': True
                }
            },
            {
                'email': 'ali.boyaci@test.com',
                'password': 'test123',
                'first_name': 'Ali',
                'last_name': 'Şen',
                'phone': '0537 333 9999',
                'user_type': 'craftsman',
                'profile': {
                    'business_name': 'Ali Usta Boyacılık',
                    'description': 'İç ve dış cephe boyama, dekoratif duvar kaplamaları, tadilat işleri.',
                    'address': 'Üsküdar, İstanbul',
                    'city': 'İstanbul',
                    'district': 'Üsküdar',
                    'hourly_rate': 100.00,
                    'average_rating': 4.7,
                    'total_reviews': 33,
                    'is_available': False,
                    'is_verified': True
                }
            }
        ]
        
        created_users = []
        for user_data in users_data:
            # Create user
            user = User(
                email=user_data['email'],
                password_hash=generate_password_hash(user_data['password']),
                first_name=user_data['first_name'],
                last_name=user_data['last_name'],
                phone=user_data['phone'],
                user_type=user_data['user_type'],
                is_active=True,
                created_at=datetime.now()
            )
            db.session.add(user)
            db.session.flush()  # Get the user ID
            created_users.append(user)
            
            # Create profile
            if user_data['user_type'] == 'customer':
                profile = Customer(
                    user_id=user.id,
                    address=user_data['profile']['address'],
                    created_at=datetime.now()
                )
                db.session.add(profile)
            elif user_data['user_type'] == 'craftsman':
                profile = Craftsman(
                    user_id=user.id,
                    business_name=user_data['profile']['business_name'],
                    description=user_data['profile']['description'],
                    address=user_data['profile']['address'],
                    city=user_data['profile']['city'],
                    district=user_data['profile']['district'],
                    hourly_rate=user_data['profile']['hourly_rate'],
                    average_rating=user_data['profile']['average_rating'],
                    total_reviews=user_data['profile']['total_reviews'],
                    is_available=user_data['profile']['is_available'],
                    is_verified=user_data['profile']['is_verified'],
                    created_at=datetime.now()
                )
                db.session.add(profile)
        
        print("👥 Created test users and profiles")
        
        # Create sample quotes
        quotes_data = [
            {
                'customer_id': created_users[0].id,  # Ayşe
                'craftsman_id': created_users[2].id,  # Ahmet Elektrik
                'title': 'Salon aydınlatması',
                'description': 'Salonda LED aydınlatma sistemi kurulumu istiyorum.',
                'location': 'Kadıköy, İstanbul',
                'budget': 1500.00,
                'status': 'pending'
            },
            {
                'customer_id': created_users[1].id,  # Mehmet
                'craftsman_id': created_users[4].id,  # Fatma Temizlik
                'title': 'Ev temizliği',
                'description': '3+1 daire genel temizlik hizmeti.',
                'location': 'Beşiktaş, İstanbul',
                'budget': 300.00,
                'status': 'accepted'
            }
        ]
        
        for quote_data in quotes_data:
            quote = Quote(
                customer_id=quote_data['customer_id'],
                craftsman_id=quote_data['craftsman_id'],
                title=quote_data['title'],
                description=quote_data['description'],
                location=quote_data['location'],
                budget=quote_data['budget'],
                status=quote_data['status'],
                created_at=datetime.now()
            )
            db.session.add(quote)
        
        print("📝 Created sample quotes")
        
        # Create sample messages
        messages_data = [
            {
                'sender_id': created_users[0].id,  # Ayşe (customer)
                'receiver_id': created_users[2].id,  # Ahmet Elektrik
                'content': 'Merhaba Ahmet Usta, salon aydınlatması için ne zaman müsaitsiniz?',
                'is_read': False
            },
            {
                'sender_id': created_users[2].id,  # Ahmet Elektrik
                'receiver_id': created_users[0].id,  # Ayşe
                'content': 'Merhaba, yarın öğleden sonra uygun olur. Saat 14:00 civarı gelebilirim.',
                'is_read': True
            },
            {
                'sender_id': created_users[1].id,  # Mehmet (customer)
                'receiver_id': created_users[4].id,  # Fatma Temizlik
                'content': 'Fatma Hanım, bu hafta temizlik için müsait misiniz?',
                'is_read': False
            }
        ]
        
        # Insert messages using raw SQL
        with db.engine.connect() as conn:
            for msg_data in messages_data:
                sql = """
                INSERT INTO messages (sender_id, receiver_id, content, is_read, created_at)
                VALUES (:sender_id, :receiver_id, :content, :is_read, :created_at)
                """
                conn.execute(db.text(sql), {
                    'sender_id': msg_data['sender_id'],
                    'receiver_id': msg_data['receiver_id'],
                    'content': msg_data['content'],
                    'is_read': msg_data['is_read'],
                    'created_at': datetime.now()
                })
            conn.commit()
        
        print("💬 Created sample messages")
        
        # Commit all changes
        db.session.commit()
        print("✅ Database setup completed successfully!")
        
        # Print summary
        print("\n" + "="*50)
        print("📊 DATABASE SUMMARY")
        print("="*50)
        print(f"Categories: {len(categories_data)}")
        print(f"Users: {len(users_data)}")
        print(f"- Customers: {len([u for u in users_data if u['user_type'] == 'customer'])}")
        print(f"- Craftsmen: {len([u for u in users_data if u['user_type'] == 'craftsman'])}")
        print(f"Quotes: {len(quotes_data)}")
        print(f"Messages: {len(messages_data)}")
        
        print("\n🔐 TEST LOGIN CREDENTIALS:")
        print("="*30)
        for user_data in users_data:
            print(f"Email: {user_data['email']}")
            print(f"Password: {user_data['password']}")
            print(f"Type: {user_data['user_type']}")
            print(f"Name: {user_data['first_name']} {user_data['last_name']}")
            print("-" * 30)

if __name__ == '__main__':
    setup_database()