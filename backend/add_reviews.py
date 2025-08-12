from app import create_app, db
from app.models.review import Review
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.quote import Quote
from datetime import datetime, timedelta
import random

def create_dummy_reviews():
    app = create_app()
    
    with app.app_context():
        # Get all quotes that don't have reviews yet
        quotes = Quote.query.outerjoin(Review).filter(Review.id == None).all()
        
        print(f"Found {len(quotes)} quotes without reviews")
        
        # Sample review comments
        positive_comments = [
            "Çok memnun kaldım! İşini gerçekten iyi yapıyor.",
            "Zamanında geldi, temiz çalıştı. Tavsiye ederim.",
            "Profesyonel yaklaşım, kaliteli iş. Tekrar çalışmak isterim.",
            "Fiyat/performans açısından çok başarılı.",
            "İşinde uzman, güvenilir biri. Memnun kaldık.",
            "Hızlı ve kaliteli hizmet aldık. Teşekkürler.",
            "Çok titiz çalışıyor, detaylara önem veriyor.",
            "Samimi ve dürüst yaklaşımı var. Beğendik.",
        ]
        
        neutral_comments = [
            "İş tamam ama biraz geç teslim oldu.",
            "Ortalama bir hizmet aldık.",
            "İdare eder, fiyat uygundu.",
            "Büyük sorun yoktu ama çok da özel değildi.",
        ]
        
        negative_comments = [
            "Geç geldi, iletişim kurmakta zorlandık.",
            "İş tamam ama beklediğimiz kadar titiz değildi.",
            "Fiyat biraz yüksekti bence.",
        ]
        
        # Create reviews for random quotes (about 70% of them)
        review_count = 0
        selected_quotes = random.sample(quotes, min(len(quotes), int(len(quotes) * 0.7)))
        
        for quote in selected_quotes:
            # Generate rating (mostly positive)
            rating_weights = [1, 1, 2, 4, 6]  # More weight on higher ratings
            rating = random.choices([1, 2, 3, 4, 5], weights=rating_weights)[0]
            
            # Choose comment based on rating
            if rating >= 4:
                comment = random.choice(positive_comments)
            elif rating == 3:
                comment = random.choice(neutral_comments)
            else:
                comment = random.choice(negative_comments)
            
            # Generate sub-ratings
            quality_rating = max(1, min(5, rating + random.randint(-1, 1)))
            communication_rating = max(1, min(5, rating + random.randint(-1, 1)))
            punctuality_rating = max(1, min(5, rating + random.randint(-1, 1)))
            cleanliness_rating = max(1, min(5, rating + random.randint(-1, 1)))
            
            # Random date in last 6 months
            days_ago = random.randint(1, 180)
            created_at = datetime.now() - timedelta(days=days_ago)
            
            review = Review(
                customer_id=quote.customer_id,
                craftsman_id=quote.craftsman_id,
                quote_id=quote.id,
                rating=rating,
                comment=comment,
                title=f"Çalışma Deneyimi - {rating}/5",
                quality_rating=quality_rating,
                communication_rating=communication_rating,
                punctuality_rating=punctuality_rating,
                cleanliness_rating=cleanliness_rating,
                created_at=created_at,
                updated_at=created_at
            )
            
            db.session.add(review)
            review_count += 1
        
        try:
            db.session.commit()
            print(f"✅ Successfully created {review_count} dummy reviews!")
            
            # Show summary
            craftsmen = Craftsman.query.all()
            for craftsman in craftsmen:
                reviews = Review.query.filter_by(craftsman_id=craftsman.id).all()
                if reviews:
                    avg_rating = sum(r.rating for r in reviews) / len(reviews)
                    print(f"Craftsman {craftsman.id}: {len(reviews)} reviews, avg rating: {avg_rating:.1f}")
            
        except Exception as e:
            db.session.rollback()
            print(f"❌ Error creating reviews: {e}")

if __name__ == "__main__":
    create_dummy_reviews()