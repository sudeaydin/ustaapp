from ..models.quote import Quote
from .. import db

class QuoteService:
    @staticmethod
    def get_by_id(quote_id):
        return Quote.query.get(quote_id)
    
    @staticmethod
    def create(data):
        quote = Quote(**data)
        db.session.add(quote)
        db.session.commit()
        return quote
    
    @staticmethod
    def update(quote, data):
        for key, value in data.items():
            if hasattr(quote, key):
                setattr(quote, key, value)
        db.session.commit()
        return quote