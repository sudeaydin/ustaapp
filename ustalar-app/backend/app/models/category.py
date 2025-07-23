from app import db
from datetime import datetime

class Category(db.Model):
    """Service categories (fayans, badana, elektrik, etc.)"""
    __tablename__ = 'categories'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    name_en = db.Column(db.String(100))  # English name for future use
    description = db.Column(db.Text)
    icon = db.Column(db.String(255))  # Icon URL or name
    color = db.Column(db.String(7))  # Hex color code
    
    # Status
    is_active = db.Column(db.Boolean, default=True)
    sort_order = db.Column(db.Integer, default=0)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    # services = db.relationship('Service', backref='category', lazy='dynamic')
    # craftsmen = db.relationship('Craftsman', secondary='craftsman_categories', backref='categories', lazy='dynamic')
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'name_en': self.name_en,
            'description': self.description,
            'icon': self.icon,
            'color': self.color,
            'is_active': self.is_active,
            'sort_order': self.sort_order,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    
    def __repr__(self):
        return f'<Category {self.name}>'


# Pre-defined categories for Turkish market
INITIAL_CATEGORIES = [
    {'name': 'Fayans', 'description': 'Banyo ve mutfak fayans işleri', 'icon': 'tiles', 'color': '#3498db'},
    {'name': 'Badana', 'description': 'Duvar boyama ve badana işleri', 'icon': 'paint-brush', 'color': '#e74c3c'},
    {'name': 'Elektrik', 'description': 'Elektrik tesisatı ve onarım', 'icon': 'bolt', 'color': '#f39c12'},
    {'name': 'Su Tesisatı', 'description': 'Su ve doğalgaz tesisatı', 'icon': 'wrench', 'color': '#2980b9'},
    {'name': 'Marangozluk', 'description': 'Ahşap işleri ve mobilya', 'icon': 'hammer', 'color': '#8e44ad'},
    {'name': 'Cam', 'description': 'Cam kesimi ve montajı', 'icon': 'window', 'color': '#1abc9c'},
    {'name': 'Klima', 'description': 'Klima montaj ve bakım', 'icon': 'snowflake', 'color': '#16a085'},
    {'name': 'Temizlik', 'description': 'Ev ve ofis temizlik hizmetleri', 'icon': 'broom', 'color': '#27ae60'},
    {'name': 'Bahçıvanlık', 'description': 'Bahçe düzenleme ve bakım', 'icon': 'leaf', 'color': '#2ecc71'},
    {'name': 'Nakliye', 'description': 'Ev ve ofis taşıma hizmetleri', 'icon': 'truck', 'color': '#34495e'}
]
