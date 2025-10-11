#!/usr/bin/env python3
"""
Simple Database Creation Script
Creates database without complex analytics imports
"""

import os
import sys
from datetime import datetime

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Set environment
os.environ['FLASK_ENV'] = 'production'

def create_simple_db():
    """Create database with minimal imports"""
    try:
        # Import Flask app components
        from flask import Flask
        from flask_sqlalchemy import SQLAlchemy
        from flask_jwt_extended import JWTManager
        from flask_cors import CORS
        
        # Create simple Flask app
        app = Flask(__name__)
        
        # Configure app
        app.config['SECRET_KEY'] = 'simple-setup-key'
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'
        app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
        app.config['JWT_SECRET_KEY'] = 'simple-jwt-key'
        
        # Initialize extensions
        db = SQLAlchemy(app)
        jwt = JWTManager(app)
        CORS(app)
        
        # Import models
        with app.app_context():
            from app.models.user import User
            from app.models.category import Category
            from app.models.customer import Customer
            from app.models.craftsman import Craftsman
            
            # Create all tables
            db.create_all()
            
            # Create sample admin user
            admin_user = User.query.filter_by(email='admin@ustam.app').first()
            if not admin_user:
                from werkzeug.security import generate_password_hash
                
                admin_user = User(
                    email='admin@ustam.app',
                    password_hash=generate_password_hash('admin123'),
                    first_name='Admin',
                    last_name='User',
                    phone='05551234567',
                    user_type='admin',
                    is_active=True,
                    created_at=datetime.utcnow()
                )
                db.session.add(admin_user)
            
            # Create sample categories
            categories = [
                {'name': 'Elektrikçi', 'description': 'Elektrik işleri', 'icon': 'electrical_services'},
                {'name': 'Tesisatçı', 'description': 'Tesisat işleri', 'icon': 'plumbing'},
                {'name': 'Boyacı', 'description': 'Boyama işleri', 'icon': 'format_paint'},
                {'name': 'Marangoz', 'description': 'Ahşap işleri', 'icon': 'carpenter'},
                {'name': 'Temizlik', 'description': 'Temizlik hizmetleri', 'icon': 'cleaning_services'}
            ]
            
            for cat_data in categories:
                category = Category.query.filter_by(name=cat_data['name']).first()
                if not category:
                    category = Category(
                        name=cat_data['name'],
                        description=cat_data['description'],
                        icon=cat_data['icon'],
                        is_active=True,
                        created_at=datetime.utcnow()
                    )
                    db.session.add(category)
            
            # Commit changes
            db.session.commit()
            
            print("✅ Database created successfully!")
            print(f"✅ Admin user: admin@ustam.app / admin123")
            print(f"✅ Categories: {len(categories)} created")
            print(f"✅ Database file: {app.config['SQLALCHEMY_DATABASE_URI']}")
            
            return True
            
    except Exception as e:
        print(f"❌ Database creation failed: {e}")
        return False

if __name__ == '__main__':
    success = create_simple_db()
    sys.exit(0 if success else 1)