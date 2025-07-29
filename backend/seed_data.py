from app import create_app, db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category
from werkzeug.security import generate_password_hash
from datetime import datetime
import json

def seed_data():
    app = create_app()
    
    with app.app_context():
        # Clear existing data
        db.drop_all()
        db.create_all()
        
        # Create categories
        categories = [
            Category(name='Elektrikçi', description='Elektrik işleri', icon='⚡', color='#FFD700'),
            Category(name='Tesisatçı', description='Su ve doğalgaz tesisatı', icon='🔧', color='#00CED1'),
            Category(name='Boyacı', description='İç ve dış boyama', icon='🎨', color='#FF69B4'),
            Category(name='Marangoz', description='Ahşap işleri', icon='🔨', color='#8B4513'),
            Category(name='Temizlik', description='Ev ve ofis temizliği', icon='🧹', color='#32CD32'),
            Category(name='Bahçıvan', description='Bahçe ve peyzaj', icon='🌱', color='#228B22'),
        ]
        
        for category in categories:
            db.session.add(category)
        
        # Create test users
        users = [
            {
                'email': 'ahmet@test.com',
                'password': '123456',
                'first_name': 'Ahmet',
                'last_name': 'Yılmaz',
                'phone': '+90 555 123 4567',
                'user_type': 'craftsman',
                'craftsman_data': {
                    'business_name': 'Yılmaz Elektrik',
                    'description': '8 yıllık deneyimim ile ev ve işyeri elektrik tesisatı, LED aydınlatma sistemleri konularında profesyonel hizmet veriyorum.',
                    'city': 'İstanbul',
                    'district': 'Kadıköy',
                    'address': 'Kadıköy Merkez, İstanbul',
                    'hourly_rate': 150.0,
                    'experience_years': 8,
                    'skills': ['Elektrik Tesisatı', 'LED Aydınlatma', 'Panel Montajı', 'Ev Otomasyonu'],
                    'certifications': ['Elektrik Tesisatı Yeterlilik Belgesi', 'LED Aydınlatma Uzmanı'],
                    'working_hours': {'monday': '09:00-18:00', 'tuesday': '09:00-18:00', 'wednesday': '09:00-18:00'},
                    'service_areas': ['Kadıköy', 'Üsküdar', 'Ataşehir'],
                    'website': 'www.yilmazelektrik.com',
                    'response_time': '2 saat',
                    'is_available': True,
                    'average_rating': 4.8,
                    'total_reviews': 127,
                    'is_verified': True,
                    'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80'
                }
            },
            {
                'email': 'mehmet@test.com',
                'password': '123456',
                'first_name': 'Mehmet',
                'last_name': 'Kaya',
                'phone': '+90 555 234 5678',
                'user_type': 'craftsman',
                'craftsman_data': {
                    'business_name': 'Kaya Tesisat',
                    'description': '12 yıllık deneyimim ile su tesisatı, doğalgaz ve kombi servisi konularında uzman hizmet veriyorum.',
                    'city': 'İstanbul',
                    'district': 'Şişli',
                    'address': 'Şişli Merkez, İstanbul',
                    'hourly_rate': 120.0,
                    'experience_years': 12,
                    'skills': ['Su Tesisatı', 'Doğalgaz', 'Kombi Servisi', 'Su Kaçağı'],
                    'certifications': ['Tesisat Uzmanı Sertifikası', 'Doğalgaz Güvenlik Belgesi'],
                    'working_hours': {'monday': '08:00-17:00', 'tuesday': '08:00-17:00', 'wednesday': '08:00-17:00'},
                    'service_areas': ['Şişli', 'Beşiktaş', 'Beyoğlu'],
                    'website': 'www.kayatesisat.com',
                    'response_time': '1 saat',
                    'is_available': True,
                    'average_rating': 4.9,
                    'total_reviews': 89,
                    'is_verified': True,
                    'avatar': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80'
                }
            },
            {
                'email': 'ali@test.com',
                'password': '123456',
                'first_name': 'Ali',
                'last_name': 'Demir',
                'phone': '+90 555 345 6789',
                'user_type': 'craftsman',
                'craftsman_data': {
                    'business_name': 'Demir Boya',
                    'description': '15 yıllık deneyimim ile iç ve dış boyama, dekoratif boyama konularında kaliteli hizmet veriyorum.',
                    'city': 'İstanbul',
                    'district': 'Beşiktaş',
                    'address': 'Beşiktaş Merkez, İstanbul',
                    'hourly_rate': 100.0,
                    'experience_years': 15,
                    'skills': ['İç Boyama', 'Dış Boyama', 'Dekoratif Boyama', 'Fayans'],
                    'certifications': ['Boya Uzmanı Sertifikası', 'Dekoratif Boyama Eğitimi'],
                    'working_hours': {'monday': '09:00-18:00', 'tuesday': '09:00-18:00', 'wednesday': '09:00-18:00'},
                    'service_areas': ['Beşiktaş', 'Kadıköy', 'Üsküdar'],
                    'website': 'www.demirboya.com',
                    'response_time': '3 saat',
                    'is_available': False,
                    'average_rating': 4.7,
                    'total_reviews': 203,
                    'is_verified': True,
                    'avatar': 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80'
                }
            },
            {
                'email': 'customer@test.com',
                'password': '123456',
                'first_name': 'Ayşe',
                'last_name': 'Kara',
                'phone': '+90 555 456 7890',
                'user_type': 'customer',
                'customer_data': {
                    'address': 'Kadıköy Merkez, İstanbul',
                    'city': 'İstanbul',
                    'district': 'Kadıköy'
                }
            }
        ]
        
        for user_data in users:
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
            
            if user_data['user_type'] == 'customer':
                customer = Customer(
                    user_id=user.id,
                    billing_address=user_data['customer_data']['address'],
                    created_at=datetime.now()
                )
                db.session.add(customer)
            else:
                craftsman_data = user_data['craftsman_data']
                craftsman = Craftsman(
                    user_id=user.id,
                    business_name=craftsman_data['business_name'],
                    description=craftsman_data['description'],
                    city=craftsman_data['city'],
                    district=craftsman_data['district'],
                    address=craftsman_data['address'],
                    hourly_rate=craftsman_data['hourly_rate'],
                    experience_years=craftsman_data['experience_years'],
                    skills=json.dumps(craftsman_data['skills']),
                    certifications=json.dumps(craftsman_data['certifications']),
                    working_hours=json.dumps(craftsman_data['working_hours']),
                    service_areas=json.dumps(craftsman_data['service_areas']),
                    website=craftsman_data['website'],
                    response_time=craftsman_data['response_time'],
                    is_available=craftsman_data['is_available'],
                    average_rating=craftsman_data['average_rating'],
                    total_reviews=craftsman_data['total_reviews'],
                    is_verified=craftsman_data['is_verified'],
                    avatar=craftsman_data['avatar'],
                    created_at=datetime.now()
                )
                db.session.add(craftsman)
        
        db.session.commit()
        print("✅ Test verisi başarıyla eklendi!")
        print("\n📋 Test Kullanıcıları:")
        print("👨‍🔧 Usta: ahmet@test.com / 123456")
        print("👨‍🔧 Usta: mehmet@test.com / 123456")
        print("👨‍🔧 Usta: ali@test.com / 123456")
        print("👤 Müşteri: customer@test.com / 123456")

if __name__ == '__main__':
    seed_data()