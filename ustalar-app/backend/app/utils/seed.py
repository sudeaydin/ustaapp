from app import create_app, db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category

app = create_app()

def seed_categories():
    """Seed categories"""
    categories = [
        {'name': 'Elektrikçi', 'description': 'Elektrik tesisatı ve onarım', 'icon': 'electrical'},
        {'name': 'Tesisatçı', 'description': 'Su ve doğalgaz tesisatı', 'icon': 'plumbing'},
        {'name': 'Boyacı', 'description': 'Duvar ve iç dekorasyon boyama', 'icon': 'paint'},
        {'name': 'Marangoz', 'description': 'Ahşap işleri ve mobilya', 'icon': 'carpenter'},
        {'name': 'Temizlik', 'description': 'Ev ve ofis temizliği', 'icon': 'cleaning'},
        {'name': 'Bahçıvan', 'description': 'Bahçe düzenleme ve bakım', 'icon': 'gardening'},
        {'name': 'Klima Teknisyeni', 'description': 'Klima montaj ve bakım', 'icon': 'hvac'},
        {'name': 'Beyaz Eşya Teknisyeni', 'description': 'Beyaz eşya onarım', 'icon': 'appliance'}
    ]
    
    for cat_data in categories:
        if not Category.query.filter_by(name=cat_data['name']).first():
            category = Category(**cat_data)
            db.session.add(category)
            print(f"Kategori eklendi: {cat_data['name']}")

def seed_users():
    """Seed test users"""
    # Test müşteri
    if not User.query.filter_by(email='musteri@example.com').first():
        user = User(
            email='musteri@example.com',
            phone='5551112233',
            user_type='customer',
            first_name='Ali',
            last_name='Müşteri'
        )
        user.set_password('musteri123')
        db.session.add(user)
        db.session.flush()
        
        customer = Customer(
            user_id=user.id,
            address='Atatürk Caddesi No: 123',
            city='İstanbul',
            district='Kadıköy'
        )
        db.session.add(customer)
        print('Test müşteri eklendi')

    # Test usta
    if not User.query.filter_by(email='usta@example.com').first():
        user = User(
            email='usta@example.com',
            phone='5552223344',
            user_type='craftsman',
            first_name='Mehmet',
            last_name='Usta'
        )
        user.set_password('usta123')
        db.session.add(user)
        db.session.flush()
        
        craftsman = Craftsman(
            user_id=user.id,
            business_name='Mehmet Usta Elektrik',
            description='10 yıllık deneyim ile elektrik tesisatı ve onarım hizmetleri',
            address='Cumhuriyet Mahallesi No: 456',
            city='İstanbul',
            district='Şişli',
            hourly_rate=150.00,
            is_available=True
        )
        db.session.add(craftsman)
        db.session.flush()
        
        # Kategorileri ekle
        elektrik_category = Category.query.filter_by(name='Elektrikçi').first()
        if elektrik_category:
            craftsman.categories.append(elektrik_category)
        
        print('Test usta eklendi')

if __name__ == '__main__':
    with app.app_context():
        print('Seed işlemi başlatılıyor...')
        
        seed_categories()
        seed_users()
        
        db.session.commit()
        print('Seed işlemi tamamlandı!') 