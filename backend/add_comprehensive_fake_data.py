#!/usr/bin/env python3
"""
Add comprehensive fake data covering all search filters
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models.user import User
from app.models.craftsman import Craftsman
from app.models.quote import Quote
from app.models.review import Review
from app.models.appointment import Appointment
from werkzeug.security import generate_password_hash
from datetime import datetime, timedelta
import random
import json

def create_comprehensive_fake_data():
    """Create fake data covering all filter categories"""
    
    # All possible categories for comprehensive testing
    categories_data = [
        {'name': 'Elektrikçi', 'districts': ['Kadıköy', 'Üsküdar', 'Şişli', 'Beşiktaş', 'Bakırköy']},
        {'name': 'Tesisatçı', 'districts': ['Maltepe', 'Ataşehir', 'Pendik', 'Kartal', 'Bostancı']},
        {'name': 'Boyacı', 'districts': ['Beyoğlu', 'Fatih', 'Eminönü', 'Zeytinburnu', 'Güngören']},
        {'name': 'Temizlik', 'districts': ['Sarıyer', 'Beykoz', 'Çekmeköy', 'Sancaktepe', 'Sultanbeyli']},
        {'name': 'Mobilyacı', 'districts': ['Esenler', 'Bağcılar', 'Küçükçekmece', 'Avcılar', 'Esenyurt']},
        {'name': 'Klima Teknisyeni', 'districts': ['Başakşehir', 'Arnavutköy', 'Eyüp', 'Gaziosmanpaşa', 'Sultangazi']},
        {'name': 'Bahçıvan', 'districts': ['Büyükçekmece', 'Silivri', 'Çatalca', 'Tuzla', 'Şile']},
        {'name': 'Kuaför', 'districts': ['Nişantaşı', 'Etiler', 'Levent', 'Maslak', 'Mecidiyeköy']},
        {'name': 'Terzi', 'districts': ['Laleli', 'Kapalıçarşı', 'Mahmutpaşa', 'Tahtakale', 'Eminönü']},
        {'name': 'Marangoz', 'districts': ['İkitelli', 'Halkalı', 'Florya', 'Yeşilköy', 'Bakırköy']},
        {'name': 'Kaportacı', 'districts': ['Oto Sanayi', 'İkitelli', 'Hadımköy', 'Arnavutköy', 'Başakşehir']},
        {'name': 'Cam Ustası', 'districts': ['Topkapı', 'Merter', 'Güngören', 'Zeytinburnu', 'Fatih']},
        {'name': 'Oto Elektrikçisi', 'districts': ['Oto Sanayi', 'Mecidiyeköy', 'Maslak', 'İkitelli', 'Halkalı']},
        {'name': 'Bilgisayar Teknisyeni', 'districts': ['Beyazıt', 'Karaköy', 'Galata', 'Şişhane', 'Taksim']},
        {'name': 'Fayansçı', 'districts': ['Topkapı', 'Aksaray', 'Laleli', 'Beyazıt', 'Eminönü']}
    ]
    
    created_users = []
    created_craftsmen = []
    
    # Create 3 craftsmen for each category
    for category_info in categories_data:
        category = category_info['name']
        districts = category_info['districts']
        
        for i in range(3):  # 3 craftsmen per category
            # Create user first
            email = f"usta.{category.lower().replace(' ', '')}{i+1}@test.com"
            name = f"{category} Usta {i+1}"
            business_name = f"{name} - {category}"
            
            # Skip if already exists
            if User.query.filter_by(email=email).first():
                continue
                
            user = User(
                email=email,
                password_hash=generate_password_hash('123456'),
                first_name=name.split()[0],
                last_name=name.split()[-1] if len(name.split()) > 1 else 'Usta',
                phone=f'05{random.randint(30, 59)} {random.randint(100, 999)} {random.randint(1000, 9999)}',
                user_type='craftsman',
                city='İstanbul',
                district=districts[i % len(districts)],
                is_verified=True,
                is_active=True,
                created_at=datetime.now() - timedelta(days=random.randint(1, 365))
            )
            db.session.add(user)
            db.session.flush()  # Get user ID
            
            # Create craftsman profile
            craftsman = Craftsman(
                user_id=user.id,
                business_name=business_name,
                description=f"Profesyonel {category.lower()} hizmetleri. {random.randint(5, 20)} yıllık deneyim.",
                city='İstanbul',
                district=districts[i % len(districts)],
                hourly_rate=random.randint(80, 200),
                experience_years=random.randint(3, 25),
                skills=json.dumps([category, f"{category} Onarımı", f"{category} Montajı"]),
                is_available=random.choice([True, True, True, False]),  # 75% available
                is_verified=True,
                average_rating=round(random.uniform(3.5, 5.0), 1),
                total_reviews=random.randint(5, 50),
                created_at=datetime.now() - timedelta(days=random.randint(1, 300))
            )
            db.session.add(craftsman)
            
            created_users.append(user)
            created_craftsmen.append(craftsman)
            
            print(f"✅ Created: {name} - {category} in {districts[i % len(districts)]}")
    
    # Create customers from different districts
    customer_districts = [
        'Kadıköy', 'Üsküdar', 'Beşiktaş', 'Şişli', 'Bakırköy', 'Maltepe', 
        'Beyoğlu', 'Fatih', 'Sarıyer', 'Esenler', 'Başakşehir', 'Büyükçekmece'
    ]
    
    for i, district in enumerate(customer_districts):
        email = f"musteri.{district.lower()}@test.com"
        
        if User.query.filter_by(email=email).first():
            continue
            
        user = User(
            email=email,
            password_hash=generate_password_hash('123456'),
            first_name=f"Müşteri",
            last_name=f"{district}",
            phone=f'05{random.randint(30, 59)} {random.randint(100, 999)} {random.randint(1000, 9999)}',
            user_type='customer',
            city='İstanbul',
            district=district,
            is_verified=True,
            is_active=True,
            created_at=datetime.now() - timedelta(days=random.randint(1, 200))
        )
        db.session.add(user)
        created_users.append(user)
        print(f"✅ Created customer in {district}")
    
    return created_users, created_craftsmen

def create_comprehensive_quotes_and_reviews(users, craftsmen):
    """Create quotes and reviews for testing"""
    
    # Get all customers from database
    from app.models.user import User
    customers = User.query.filter_by(user_type='customer').all()
    
    # Create quotes covering all categories and statuses
    statuses = ['pending', 'quoted', 'accepted', 'completed', 'rejected']
    
    for i in range(50):  # 50 comprehensive quotes
        customer = random.choice(customers)
        craftsman = random.choice(craftsmen)
        
        quote = Quote(
            customer_id=customer.id,
            craftsman_id=craftsman.user_id,  # craftsman.user_id
            category=craftsman.business_name.split(' - ')[-1] if ' - ' in craftsman.business_name else 'Genel',
            job_type=craftsman.business_name.split(' - ')[-1] if ' - ' in craftsman.business_name else 'Genel',
            location=f"{customer.district}, {customer.city}",
            area_type=random.choice(['salon', 'yatak_odası', 'mutfak', 'banyo', 'balkon', 'teras', 'bahçe', 'ofis', 'diğer']),
            budget_range=random.choice(['500-1000', '1000-2000', '2000-5000', '5000-10000', '10000+']),
            description=f"{craftsman.business_name.split(' - ')[-1]} hizmeti için teklif istiyorum.",
            status=random.choice(statuses),
            quoted_price=random.randint(500, 5000),
            craftsman_notes=f"Bu iş için {random.randint(500, 5000)} TL teklif ediyorum. Kaliteli malzeme dahil.",
            estimated_duration_days=random.randint(1, 10),
            created_at=datetime.now() - timedelta(days=random.randint(1, 60))
        )
        db.session.add(quote)
    
    db.session.commit()  # Commit quotes first
    
    # Create reviews for completed quotes
    completed_quotes = Quote.query.filter_by(status='completed').all()
    
    review_comments = [
        'Mükemmel iş çıkardı, çok memnun kaldım!',
        'Zamanında geldi, temiz çalıştı, kesinlikle tavsiye ederim.',
        'Profesyonel yaklaşım, kaliteli malzeme kullandı.',
        'Fiyat performans olarak çok iyi, tekrar çalışırım.',
        'Güler yüzlü ve dürüst, işini iyi biliyor.',
        'Hızlı ve kaliteli hizmet, teşekkürler.',
        'Beklentilerimi aştı, arkadaşlarıma tavsiye ettim.',
        'Çok titiz çalışıyor, her detayla ilgileniyor.',
        'Uygun fiyat, kaliteli iş, ne isteyebilirim ki.',
        'Gerçekten işinin ehli, süper bir usta.'
    ]
    
    for quote in completed_quotes[:30]:  # First 30 completed quotes
        if not Review.query.filter_by(quote_id=quote.id).first():
            review = Review(
                quote_id=quote.id,
                customer_id=quote.customer_id,
                craftsman_id=quote.craftsman_id,
                rating=random.randint(4, 5),
                quality_rating=random.randint(4, 5),
                communication_rating=random.randint(4, 5),
                punctuality_rating=random.randint(4, 5),
                cleanliness_rating=random.randint(4, 5),
                comment=random.choice(review_comments),
                is_verified=True,
                is_visible=True,
                created_at=datetime.now() - timedelta(days=random.randint(1, 30))
            )
            db.session.add(review)
    
    print(f"✅ Created comprehensive quotes and reviews")

def create_comprehensive_appointments(craftsmen):
    """Create appointments for calendar testing"""
    
    appointment_types = ['consultation', 'work', 'follow_up', 'emergency']
    statuses = ['confirmed', 'pending', 'cancelled', 'completed']
    
    for craftsman in craftsmen[:20]:  # First 20 craftsmen
        for i in range(random.randint(2, 5)):  # 2-5 appointments each
            start_time = datetime.now() + timedelta(
                days=random.randint(-10, 30),  # Past and future appointments
                hours=random.randint(8, 18)
            )
            
            appointment = Appointment(
                craftsman_id=craftsman.user_id,
                title=f"{craftsman.business_name.split(' - ')[-1]} Randevusu",
                description=f"Müşteri randevusu - {craftsman.business_name}",
                start_time=start_time,
                end_time=start_time + timedelta(hours=random.randint(1, 4)),
                status=random.choice(statuses),
                appointment_type=random.choice(appointment_types),
                location=f"{craftsman.district}, {craftsman.city}",
                created_at=datetime.now() - timedelta(days=random.randint(1, 15))
            )
            db.session.add(appointment)
    
    print(f"✅ Created comprehensive appointments")

def main():
    app = create_app()
    
    with app.app_context():
        print("🚀 Creating comprehensive fake data for all filters...")
        
        # Create users and craftsmen covering all categories
        users, craftsmen = create_comprehensive_fake_data()
        db.session.commit()
        
        # Create quotes and reviews
        create_comprehensive_quotes_and_reviews(users, craftsmen)
        db.session.commit()
        
        # Create appointments
        create_comprehensive_appointments(craftsmen)
        db.session.commit()
        
        print("\n🎉 Comprehensive fake data created!")
        print("📊 Final Database Stats:")
        print(f"   - Users: {User.query.count()}")
        print(f"   - Craftsmen: {Craftsman.query.count()}")
        print(f"   - Quotes: {Quote.query.count()}")
        print(f"   - Reviews: {Review.query.count()}")
        print(f"   - Appointments: {Appointment.query.count()}")
        
        # Show categories coverage
        craftsmen_all = Craftsman.query.all()
        categories = set()
        districts = set()
        for c in craftsmen_all:
            if c.business_name and ' - ' in c.business_name:
                categories.add(c.business_name.split(' - ')[-1])
            if c.district:
                districts.add(c.district)
        
        print(f"\n🎯 Filter Coverage:")
        print(f"   - Categories: {len(categories)} ({', '.join(sorted(categories)[:10])}...)")
        print(f"   - Districts: {len(districts)} ({', '.join(sorted(districts)[:10])}...)")

if __name__ == '__main__':
    main()