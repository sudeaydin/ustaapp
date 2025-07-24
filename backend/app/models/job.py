from app import db
from datetime import datetime
from enum import Enum

class JobStatus(Enum):
    DRAFT = "draft"
    OPEN = "open"
    ASSIGNED = "assigned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    APPROVED = "approved"
    PAID = "paid"
    CANCELLED = "cancelled"
    DISPUTED = "disputed"

class JobUrgency(Enum):
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    URGENT = "urgent"

class Job(db.Model):
    """Job model for managing job requests and assignments"""
    __tablename__ = 'jobs'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Basic job info
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey('categories.id'), nullable=False)
    
    # Location info
    location = db.Column(db.String(200), nullable=False)
    city = db.Column(db.String(100))
    district = db.Column(db.String(100))
    address = db.Column(db.Text)
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    
    # Job details
    budget_min = db.Column(db.Numeric(10, 2))
    budget_max = db.Column(db.Numeric(10, 2))
    final_price = db.Column(db.Numeric(10, 2))
    urgency = db.Column(db.String(20), default=JobUrgency.NORMAL.value)
    
    # Status and assignment
    status = db.Column(db.String(20), default=JobStatus.OPEN.value)
    customer_id = db.Column(db.Integer, db.ForeignKey('customers.id'), nullable=False)
    assigned_craftsman_id = db.Column(db.Integer, db.ForeignKey('craftsmen.id'))
    
    # Dates
    preferred_start_date = db.Column(db.DateTime)
    preferred_end_date = db.Column(db.DateTime)
    actual_start_date = db.Column(db.DateTime)
    actual_end_date = db.Column(db.DateTime)
    
    # Requirements
    required_skills = db.Column(db.JSON)  # List of required skills
    materials_provided = db.Column(db.Boolean, default=False)
    tools_provided = db.Column(db.Boolean, default=False)
    
    # Images and attachments
    images = db.Column(db.JSON)  # List of image URLs
    attachments = db.Column(db.JSON)  # List of attachment URLs
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    customer = db.relationship('Customer', backref='jobs')
    assigned_craftsman = db.relationship('Craftsman', backref='assigned_jobs')
    category = db.relationship('Category', backref='jobs')
    
    def to_dict(self):
        """Convert job to dictionary"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'category_id': self.category_id,
            'category': self.category.name if self.category else None,
            'location': self.location,
            'city': self.city,
            'district': self.district,
            'address': self.address,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'budget_min': float(self.budget_min) if self.budget_min else None,
            'budget_max': float(self.budget_max) if self.budget_max else None,
            'final_price': float(self.final_price) if self.final_price else None,
            'urgency': self.urgency,
            'status': self.status,
            'customer_id': self.customer_id,
            'assigned_craftsman_id': self.assigned_craftsman_id,
            'preferred_start_date': self.preferred_start_date.isoformat() if self.preferred_start_date else None,
            'preferred_end_date': self.preferred_end_date.isoformat() if self.preferred_end_date else None,
            'actual_start_date': self.actual_start_date.isoformat() if self.actual_start_date else None,
            'actual_end_date': self.actual_end_date.isoformat() if self.actual_end_date else None,
            'required_skills': self.required_skills or [],
            'materials_provided': self.materials_provided,
            'tools_provided': self.tools_provided,
            'images': self.images or [],
            'attachments': self.attachments or [],
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'customer': {
                'id': self.customer.id,
                'name': f"{self.customer.first_name} {self.customer.last_name}",
                'user_id': self.customer.user_id
            } if self.customer else None,
            'assigned_craftsman': {
                'id': self.assigned_craftsman.id,
                'name': f"{self.assigned_craftsman.first_name} {self.assigned_craftsman.last_name}",
                'user_id': self.assigned_craftsman.user_id,
                'skills': self.assigned_craftsman.skills
            } if self.assigned_craftsman else None
        }
    
    @staticmethod
    def get_jobs_by_location(city=None, district=None, radius_km=None, lat=None, lng=None):
        """Get jobs by location criteria"""
        query = Job.query.filter(Job.status.in_([JobStatus.OPEN.value, JobStatus.ASSIGNED.value]))
        
        if city:
            query = query.filter(Job.city.ilike(f'%{city}%'))
        
        if district:
            query = query.filter(Job.district.ilike(f'%{district}%'))
        
        # If coordinates and radius provided, filter by distance
        if lat and lng and radius_km:
            # Simple distance calculation (for more accuracy, use PostGIS)
            lat_range = radius_km / 111.0  # Rough conversion: 1 degree ≈ 111 km
            lng_range = radius_km / (111.0 * abs(lat))
            
            query = query.filter(
                Job.latitude.between(lat - lat_range, lat + lat_range),
                Job.longitude.between(lng - lng_range, lng + lng_range)
            )
        
        return query.all()
    
    @staticmethod
    def get_jobs_by_skills(required_skills):
        """Get jobs that match required skills"""
        if not required_skills:
            return []
        
        jobs = Job.query.filter(Job.status == JobStatus.OPEN.value).all()
        matching_jobs = []
        
        for job in jobs:
            if job.required_skills:
                # Check if any required skill matches
                if any(skill in job.required_skills for skill in required_skills):
                    matching_jobs.append(job)
        
        return matching_jobs
    
    def assign_craftsman(self, craftsman_id):
        """Assign a craftsman to the job"""
        self.assigned_craftsman_id = craftsman_id
        self.status = JobStatus.ASSIGNED.value
        self.updated_at = datetime.utcnow()
        db.session.commit()
    
    def start_job(self):
        """Mark job as started"""
        if self.status == JobStatus.ASSIGNED.value:
            self.status = JobStatus.IN_PROGRESS.value
            self.actual_start_date = datetime.utcnow()
            self.updated_at = datetime.utcnow()
            db.session.commit()
            return True
        return False
    
    def complete_job(self, final_price=None):
        """Mark job as completed"""
        if self.status == JobStatus.IN_PROGRESS.value:
            self.status = JobStatus.COMPLETED.value
            self.actual_end_date = datetime.utcnow()
            if final_price:
                self.final_price = final_price
            self.updated_at = datetime.utcnow()
            db.session.commit()
            return True
        return False
    
    def approve_job(self):
        """Customer approves completed job"""
        if self.status == JobStatus.COMPLETED.value:
            self.status = JobStatus.APPROVED.value
            self.updated_at = datetime.utcnow()
            db.session.commit()
            return True
        return False
    
    def cancel_job(self, reason=None):
        """Cancel the job"""
        if self.status not in [JobStatus.COMPLETED.value, JobStatus.PAID.value]:
            self.status = JobStatus.CANCELLED.value
            self.updated_at = datetime.utcnow()
            db.session.commit()
            return True
        return False