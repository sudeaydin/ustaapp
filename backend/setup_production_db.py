#!/usr/bin/env python3
"""
Production Database Setup Script
Creates and initializes production database with essential data
"""

import os
import sys
from datetime import datetime
from werkzeug.security import generate_password_hash

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def setup_production_database():
    """Setup production database with essential data"""
    
    print("🚀 Setting up production database...")
    
    # Load production environment
    from dotenv import load_dotenv
    env_path = os.path.join(os.path.dirname(__file__), '.env.production')
    if os.path.exists(env_path):
        load_dotenv(env_path)
        print(f"✅ Loaded environment from: {env_path}")
    else:
        print(f"⚠️  Warning: .env.production not found at {env_path}")
        print("   Using default development settings")
    
    # Create Flask app
    from app import create_app, db
    app = create_app()
    
    with app.app_context():
        print("\n📊 Creating database tables...")
        db.create_all()
        print("✅ Database tables created")
        
        # Import models
        from app.models.user import User
        from app.models.customer import Customer
        from app.models.craftsman import Craftsman
        from app.models.category import Category
        
        # Check if database is already populated
        if User.query.count() > 0:
            print("\n⚠️  Database already contains data!")
            response = input("Do you want to continue? This will add more data (y/N): ")
            if response.lower() != 'y':
                print("❌ Aborted")
                return
        
        print("\n👤 Creating admin user...")
        # Create admin user
        admin_email = os.environ.get('ADMIN_EMAIL', 'admin@ustam.com')
        admin_password = os.environ.get('ADMIN_PASSWORD', 'admin123!Change')
        
        admin = User.query.filter_by(email=admin_email).first()
        if not admin:
            admin = User(
                email=admin_email,
                password_hash=generate_password_hash(admin_password),
                first_name='Admin',
                last_name='User',
                phone='05551234567',
                user_type='admin',
                is_active=True,
                is_verified=True,
                email_verified=True,
                phone_verified=True,
                created_at=datetime.utcnow()
            )
            db.session.add(admin)
            print(f"✅ Admin user created: {admin_email}")
            print(f"   ⚠️  Password: {admin_password} (CHANGE THIS IMMEDIATELY!)")
        else:
            print(f"ℹ️  Admin user already exists: {admin_email}")
        
        print("\n📂 Creating categories...")
        # Create categories
        categories_data = [
            {'name': 'Elektrik', 'description': 'Elektrik işleri ve tamiratı', 'icon': 'electrical_services'},
            {'name': 'Tesisat', 'description': 'Su ve gaz tesisatı işleri', 'icon': 'plumbing'},
            {'name': 'Boya', 'description': 'İç ve dış boya badana işleri', 'icon': 'format_paint'},
            {'name': 'Tadilat', 'description': 'Ev ve işyeri tadilat hizmetleri', 'icon': 'construction'},
            {'name': 'Dekorasyon', 'description': 'İç mekan dekorasyon hizmetleri', 'icon': 'design_services'},
            {'name': 'Beyaz Eşya', 'description': 'Beyaz eşya tamir ve bakım', 'icon': 'kitchen'},
            {'name': 'Klima', 'description': 'Klima montaj, tamir ve bakım', 'icon': 'ac_unit'},
            {'name': 'Nakliyat', 'description': 'Ev ve ofis taşıma hizmetleri', 'icon': 'local_shipping'},
            {'name': 'Temizlik', 'description': 'Ev ve ofis temizlik hizmetleri', 'icon': 'cleaning_services'},
            {'name': 'Bahçe', 'description': 'Bahçe bakım ve peyzaj hizmetleri', 'icon': 'yard'},
        ]
        
        categories_created = 0
        for cat_data in categories_data:
            existing_cat = Category.query.filter_by(name=cat_data['name']).first()
            if not existing_cat:
                category = Category(
                    name=cat_data['name'],
                    description=cat_data['description'],
                    icon=cat_data['icon'],
                    is_active=True,
                    created_at=datetime.utcnow()
                )
                db.session.add(category)
                categories_created += 1
        
        print(f"✅ Created {categories_created} new categories")
        
        print("\n👷 Creating sample craftsman (for testing)...")
        # Create a sample craftsman
        craftsman_email = 'usta@test.com'
        craftsman_user = User.query.filter_by(email=craftsman_email).first()
        
        if not craftsman_user:
            craftsman_user = User(
                email=craftsman_email,
                password_hash=generate_password_hash('test123!'),
                first_name='Mehmet',
                last_name='Yılmaz',
                phone='05559876543',
                user_type='craftsman',
                is_active=True,
                is_verified=True,
                email_verified=True,
                phone_verified=True,
                city='İstanbul',
                district='Kadıköy',
                created_at=datetime.utcnow()
            )
            db.session.add(craftsman_user)
            db.session.flush()
            
            craftsman_profile = Craftsman(
                user_id=craftsman_user.id,
                business_name='Yılmaz Elektrik',
                description='15 yıllık tecrübeli elektrikçi. Tüm elektrik işleriniz için hizmetinizdeyim.',
                city='İstanbul',
                district='Kadıköy',
                hourly_rate=150.00,
                experience_years=15,
                is_available=True,
                is_verified=True,
                average_rating=4.8,
                total_reviews=42,
                created_at=datetime.utcnow()
            )
            db.session.add(craftsman_profile)
            print(f"✅ Sample craftsman created: {craftsman_email} / test123!")
        else:
            print(f"ℹ️  Sample craftsman already exists: {craftsman_email}")
        
        print("\n👤 Creating sample customer (for testing)...")
        # Create a sample customer
        customer_email = 'musteri@test.com'
        customer_user = User.query.filter_by(email=customer_email).first()
        
        if not customer_user:
            customer_user = User(
                email=customer_email,
                password_hash=generate_password_hash('test123!'),
                first_name='Ayşe',
                last_name='Demir',
                phone='05551112233',
                user_type='customer',
                is_active=True,
                is_verified=True,
                email_verified=True,
                phone_verified=True,
                city='İstanbul',
                district='Beşiktaş',
                created_at=datetime.utcnow()
            )
            db.session.add(customer_user)
            db.session.flush()
            
            customer_profile = Customer(
                user_id=customer_user.id,
                address='Barbaros Bulvarı No:123',
                created_at=datetime.utcnow()
            )
            db.session.add(customer_profile)
            print(f"✅ Sample customer created: {customer_email} / test123!")
        else:
            print(f"ℹ️  Sample customer already exists: {customer_email}")
        
        # Commit all changes
        print("\n💾 Saving changes to database...")
        db.session.commit()
        print("✅ All changes saved successfully!")
        
        # Summary
        print("\n" + "="*60)
        print("📊 DATABASE SETUP COMPLETE!")
        print("="*60)
        print(f"Total Users: {User.query.count()}")
        print(f"Total Categories: {Category.query.count()}")
        print(f"Total Craftsmen: {Craftsman.query.count()}")
        print(f"Total Customers: {Customer.query.count()}")
        print("\n🔐 TEST ACCOUNTS:")
        print(f"  Admin: {admin_email} / {admin_password}")
        print(f"  Craftsman: usta@test.com / test123!")
        print(f"  Customer: musteri@test.com / test123!")
        print("\n⚠️  IMPORTANT: Change admin password immediately!")
        print("="*60)

if __name__ == '__main__':
    try:
        setup_production_database()
    except Exception as e:
        print(f"\n❌ Error setting up database: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
