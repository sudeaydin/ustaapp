#!/usr/bin/env python3
"""
Add more fake data to make the app look full and populated
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models import User, Quote, Review, Appointment
from werkzeug.security import generate_password_hash
from datetime import datetime, timedelta
import random

def create_fake_users():
    """Create 15+ fake users (mix of customers and craftsmen)"""
    
    fake_customers = [
        {'email': 'ayse.yilmaz@gmail.com', 'name': 'Ayşe Yılmaz', 'phone': '0532 123 4567'},
        {'email': 'mehmet.demir@hotmail.com', 'name': 'Mehmet Demir', 'phone': '0533 234 5678'},
        {'email': 'zeynep.kaya@outlook.com', 'name': 'Zeynep Kaya', 'phone': '0534 345 6789'},
        {'email': 'ali.ozturk@gmail.com', 'name': 'Ali Öztürk', 'phone': '0535 456 7890'},
        {'email': 'fatma.celik@yahoo.com', 'name': 'Fatma Çelik', 'phone': '0536 567 8901'},
        {'email': 'ibrahim.sahin@gmail.com', 'name': 'İbrahim Şahin', 'phone': '0537 678 9012'},
        {'email': 'elif.yavuz@hotmail.com', 'name': 'Elif Yavuz', 'phone': '0538 789 0123'},
        {'email': 'mustafa.kilic@gmail.com', 'name': 'Mustafa Kılıç', 'phone': '0539 890 1234'},
    ]
    
    fake_craftsmen = [
        {
            'email': 'usta.hasan@gmail.com', 
            'name': 'Hasan Usta', 
            'phone': '0541 111 2222',
            'business_name': 'Hasan Elektrik Servisi',
            'category': 'Elektrikçi',
            'hourly_rate': 150,
            'description': 'Profesyonel elektrik tesisatı ve onarım hizmetleri. 20 yıllık tecrübe.',
            'city': 'İstanbul',
            'district': 'Üsküdar'
        },
        {
            'email': 'usta.selim@hotmail.com', 
            'name': 'Selim Usta', 
            'phone': '0542 222 3333',
            'business_name': 'Selim Boyama',
            'category': 'Boyacı',
            'hourly_rate': 120,
            'description': 'İç ve dış mekan boyama işleri. Kaliteli malzeme kullanımı.',
            'city': 'İstanbul',
            'district': 'Kadıköy'
        },
        {
            'email': 'usta.emre@gmail.com', 
            'name': 'Emre Usta', 
            'phone': '0543 333 4444',
            'business_name': 'Emre Tesisatçı',
            'category': 'Tesisatçı',
            'hourly_rate': 140,
            'description': 'Su tesisatı, doğalgaz tesisatı ve kombi bakım onarım.',
            'city': 'İstanbul',
            'district': 'Şişli'
        },
        {
            'email': 'usta.ayhan@yahoo.com', 
            'name': 'Ayhan Usta', 
            'phone': '0544 444 5555',
            'business_name': 'Ayhan Mobilyacı',
            'category': 'Mobilyacı',
            'hourly_rate': 160,
            'description': 'Özel tasarım mobilya üretimi ve onarım hizmetleri.',
            'city': 'İstanbul',
            'district': 'Beşiktaş'
        },
        {
            'email': 'usta.sevim@gmail.com', 
            'name': 'Sevim Hanım', 
            'phone': '0545 555 6666',
            'business_name': 'Sevim Temizlik',
            'category': 'Temizlik',
            'hourly_rate': 90,
            'description': 'Ev ve ofis temizlik hizmetleri. Güvenilir ve titiz çalışma.',
            'city': 'İstanbul',
            'district': 'Bakırköy'
        },
        {
            'email': 'usta.kerim@hotmail.com', 
            'name': 'Kerim Usta', 
            'phone': '0546 666 7777',
            'business_name': 'Kerim Klima Servisi',
            'category': 'Klima Teknisyeni',
            'hourly_rate': 130,
            'description': 'Klima montaj, bakım ve onarım hizmetleri. Tüm markalar.',
            'city': 'İstanbul',
            'district': 'Maltepe'
        },
        {
            'email': 'usta.nurhan@gmail.com', 
            'name': 'Nurhan Hanım', 
            'phone': '0547 777 8888',
            'business_name': 'Nurhan Terzi',
            'category': 'Terzi',
            'hourly_rate': 100,
            'description': 'Giyim eşyası dikim, onarım ve tadilat hizmetleri.',
            'city': 'İstanbul',
            'district': 'Fatih'
        },
        {
            'email': 'usta.omer@yahoo.com', 
            'name': 'Ömer Usta', 
            'phone': '0548 888 9999',
            'business_name': 'Ömer Bahçıvanlık',
            'category': 'Bahçıvan',
            'hourly_rate': 110,
            'description': 'Bahçe düzenleme, budama ve peyzaj hizmetleri.',
            'city': 'İstanbul',
            'district': 'Sarıyer'
        },
        {
            'email': 'usta.gulsen@gmail.com', 
            'name': 'Gülsen Hanım', 
            'phone': '0549 999 0000',
            'business_name': 'Gülsen Kuaför',
            'category': 'Kuaför',
            'hourly_rate': 80,
            'description': 'Kadın kuaförü hizmetleri. Saç kesimi, boyama, bakım.',
            'city': 'İstanbul',
            'district': 'Beyoğlu'
        }
    ]
    
    created_users = {}
    
    # Create customers
    for customer_data in fake_customers:
        if not User.query.filter_by(email=customer_data['email']).first():
            user = User(
                email=customer_data['email'],
                password_hash=generate_password_hash('123456'),
                name=customer_data['name'],
                phone=customer_data['phone'],
                user_type='customer',
                is_verified=True,
                created_at=datetime.now() - timedelta(days=random.randint(1, 90))
            )
            db.session.add(user)
            created_users[customer_data['email']] = user
            print(f"✅ Created customer: {customer_data['name']}")
    
    # Create craftsmen
    for craftsman_data in fake_craftsmen:
        if not User.query.filter_by(email=craftsman_data['email']).first():
            user = User(
                email=craftsman_data['email'],
                password_hash=generate_password_hash('123456'),
                name=craftsman_data['name'],
                phone=craftsman_data['phone'],
                user_type='craftsman',
                business_name=craftsman_data['business_name'],
                category=craftsman_data['category'],
                hourly_rate=craftsman_data['hourly_rate'],
                description=craftsman_data['description'],
                city=craftsman_data['city'],
                district=craftsman_data['district'],
                is_verified=True,
                is_available=True,
                created_at=datetime.now() - timedelta(days=random.randint(1, 60))
            )
            db.session.add(user)
            created_users[craftsman_data['email']] = user
            print(f"✅ Created craftsman: {craftsman_data['name']} - {craftsman_data['category']}")
    
    return created_users

def create_fake_quotes(created_users):
    """Create fake quotes between users"""
    
    customers = [u for u in created_users.values() if u.user_type == 'customer']
    craftsmen = [u for u in created_users.values() if u.user_type == 'craftsman']
    
    categories = ['Elektrikçi', 'Boyacı', 'Tesisatçı', 'Temizlik', 'Mobilyacı', 'Klima Teknisyeni']
    locations = ['Kadıköy, İstanbul', 'Üsküdar, İstanbul', 'Şişli, İstanbul', 'Beşiktaş, İstanbul', 'Bakırköy, İstanbul']
    statuses = ['pending', 'quoted', 'accepted', 'completed', 'rejected']
    descriptions = [
        'Evimde elektrik arızası var, acil müdahale gerekiyor.',
        'Salon duvarlarını boyatmak istiyorum.',
        'Mutfak lavabosunda sızıntı problemi var.',
        'Haftalık ev temizliği hizmeti alacağım.',
        'Yatak odası için dolap yaptırmak istiyorum.',
        'Klima bakımı ve temizliği yapılmasını istiyorum.'
    ]
    
    for i in range(25):  # 25 fake quote
        customer = random.choice(customers)
        craftsman = random.choice(craftsmen)
        
        if customer != craftsman:  # Same user check
            quote = Quote(
                customer_id=customer.id,
                craftsman_id=craftsman.id,
                category=random.choice(categories),
                job_type=random.choice(categories),
                location=random.choice(locations),
                area_type=random.choice(['salon', 'yatak_odası', 'mutfak', 'banyo', 'diğer']),
                budget_range=random.choice(['500-1000', '1000-2000', '2000-5000', '5000+']),
                description=random.choice(descriptions),
                status=random.choice(statuses),
                quoted_price=random.randint(500, 3000),
                craftsman_notes=f'Bu iş için {random.randint(500, 3000)} TL teklif ediyorum.',
                estimated_duration_days=random.randint(1, 7),
                created_at=datetime.now() - timedelta(days=random.randint(1, 30))
            )
            db.session.add(quote)
    
    print(f"✅ Created 25 fake quotes")

def create_fake_reviews(created_users):
    """Create fake reviews"""
    
    # Get completed quotes to create reviews for them
    completed_quotes = Quote.query.filter_by(status='completed').all()
    
    review_comments = [
        'Çok memnun kaldım, işini titizlikle yaptı.',
        'Zamanında geldi, kaliteli malzeme kullandı. Tavsiye ederim.',
        'Profesyonel bir çalışma oldu, teşekkür ederim.',
        'Fiyat performans açısından çok iyi, tekrar çalışırım.',
        'İşçiliği çok güzel, temiz çalışıyor.',
        'Güler yüzlü ve dürüst bir usta, memnun kaldım.',
        'Beklediğimden daha hızlı bitirdi işi.',
        'Kaliteli iş çıkardı, arkadaşlarıma tavsiye ettim.',
        'Çok titiz ve özenli çalışıyor, süper.',
        'Fiyatı uygun, işi de kaliteli yapıyor.'
    ]
    
    for quote in completed_quotes[:15]:  # İlk 15 completed quote için review
        if not Review.query.filter_by(quote_id=quote.id).first():
            review = Review(
                quote_id=quote.id,
                customer_id=quote.customer_id,
                craftsman_id=quote.craftsman_id,
                overall_rating=random.randint(4, 5),  # 4-5 arası rating
                quality_rating=random.randint(4, 5),
                communication_rating=random.randint(4, 5),
                timeliness_rating=random.randint(4, 5),
                value_rating=random.randint(4, 5),
                comment=random.choice(review_comments),
                is_verified=True,
                is_visible=True,
                created_at=datetime.now() - timedelta(days=random.randint(1, 20))
            )
            db.session.add(review)
    
    print(f"✅ Created fake reviews for completed quotes")

def create_fake_appointments():
    """Create fake appointments"""
    
    craftsmen = User.query.filter_by(user_type='craftsman').all()
    
    appointment_titles = [
        'Elektrik Tesisatı Kontrolü',
        'Duvar Boyama İşi',
        'Su Tesisatı Onarımı',
        'Genel Ev Temizliği',
        'Dolap Montajı',
        'Klima Bakımı',
        'Bahçe Düzenlemesi',
        'Saç Kesimi',
        'Terzi İşleri'
    ]
    
    for craftsman in craftsmen[:10]:  # İlk 10 craftsman için
        for i in range(3):  # Her craftsman için 3 appointment
            start_time = datetime.now() + timedelta(days=random.randint(1, 30), hours=random.randint(8, 17))
            
            appointment = Appointment(
                craftsman_id=craftsman.id,
                title=random.choice(appointment_titles),
                description=f'{craftsman.name} ile randevu',
                start_time=start_time,
                end_time=start_time + timedelta(hours=random.randint(1, 4)),
                status=random.choice(['confirmed', 'pending', 'cancelled']),
                appointment_type=random.choice(['consultation', 'work', 'follow_up']),
                location=f'{craftsman.district}, {craftsman.city}',
                created_at=datetime.now() - timedelta(days=random.randint(1, 10))
            )
            db.session.add(appointment)
    
    print(f"✅ Created fake appointments")

def main():
    app = create_app()
    
    with app.app_context():
        print("🚀 Adding more fake data to database...")
        
        # Create fake users
        created_users = create_fake_users()
        db.session.commit()
        
        # Create fake quotes
        create_fake_quotes(created_users)
        db.session.commit()
        
        # Create fake reviews
        create_fake_reviews(created_users)
        db.session.commit()
        
        # Create fake appointments
        create_fake_appointments()
        db.session.commit()
        
        print("\n🎉 Successfully added fake data!")
        print("📊 Database now has:")
        print(f"   - Users: {User.query.count()}")
        print(f"   - Quotes: {Quote.query.count()}")
        print(f"   - Reviews: {Review.query.count()}")
        print(f"   - Appointments: {Appointment.query.count()}")

if __name__ == '__main__':
    main()