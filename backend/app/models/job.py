from datetime import datetime, timedelta
from sqlalchemy import Column, Integer, String, Text, Float, Boolean, DateTime, ForeignKey, Enum as SQLEnum, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from app.extensions import db
import enum

# Job status enumeration
class JobStatus(enum.Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    IN_PROGRESS = "in_progress"
    PAUSED = "paused"
    MATERIALS_NEEDED = "materials_needed"
    QUALITY_CHECK = "quality_check"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    DISPUTED = "disputed"

# Job priority enumeration
class JobPriority(enum.Enum):
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    URGENT = "urgent"
    EMERGENCY = "emergency"

# Material status enumeration
class MaterialStatus(enum.Enum):
    PLANNED = "planned"
    ORDERED = "ordered"
    DELIVERED = "delivered"
    USED = "used"
    RETURNED = "returned"

# Time entry type enumeration
class TimeEntryType(enum.Enum):
    WORK = "work"
    TRAVEL = "travel"
    BREAK = "break"
    MATERIALS = "materials"
    CONSULTATION = "consultation"

# Warranty status enumeration
class WarrantyStatus(enum.Enum):
    ACTIVE = "active"
    EXPIRED = "expired"
    CLAIMED = "claimed"
    VOID = "void"

class Job(db.Model):
    __tablename__ = 'jobs'

    id = Column(Integer, primary_key=True)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    
    # Relationships
    customer_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    craftsman_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    quote_id = Column(Integer, ForeignKey('quotes.id'), nullable=True)
    
    # Job details
    status = Column(SQLEnum(JobStatus), default=JobStatus.PENDING, nullable=False, index=True)
    priority = Column(SQLEnum(JobPriority), default=JobPriority.NORMAL, nullable=False, index=True)
    category = Column(String(100), nullable=False, index=True)
    subcategory = Column(String(100))
    
    # Location
    address = Column(Text)
    city = Column(String(100), index=True)
    district = Column(String(100))
    latitude = Column(Float)
    longitude = Column(Float)
    
    # Pricing
    estimated_cost = Column(Float)
    final_cost = Column(Float)
    materials_cost = Column(Float, default=0.0)
    labor_cost = Column(Float, default=0.0)
    additional_costs = Column(Float, default=0.0)
    
    # Timing
    estimated_duration = Column(Integer)  # in hours
    actual_duration = Column(Integer)  # in hours
    scheduled_start = Column(DateTime, index=True)
    actual_start = Column(DateTime)
    scheduled_end = Column(DateTime)
    actual_end = Column(DateTime)
    
    # Job lifecycle
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    accepted_at = Column(DateTime)
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    
    # Emergency service
    is_emergency = Column(Boolean, default=False, index=True)
    emergency_level = Column(Integer)  # 1-5 scale
    emergency_contact = Column(String(20))
    emergency_notes = Column(Text)
    
    # Quality and completion
    completion_percentage = Column(Float, default=0.0)
    quality_score = Column(Float)
    customer_satisfaction = Column(Integer)  # 1-5 rating
    
    # Additional fields
    special_requirements = Column(Text)
    images = Column(JSON)  # List of image URLs
    documents = Column(JSON)  # List of document URLs
    notes = Column(Text)
    cancellation_reason = Column(Text)
    
    # Warranty information
    warranty_period_months = Column(Integer, default=12)
    warranty_start_date = Column(DateTime)
    warranty_end_date = Column(DateTime)
    warranty_terms = Column(Text)
    
    # Relationships
    customer = relationship("User", foreign_keys=[customer_id], backref="customer_jobs")
    craftsman = relationship("User", foreign_keys=[craftsman_id], backref="craftsman_jobs")
    quote = relationship("Quote", backref="job")
    materials = relationship("JobMaterial", back_populates="job", cascade="all, delete-orphan")
    time_entries = relationship("TimeEntry", back_populates="job", cascade="all, delete-orphan")
    warranty_claims = relationship("WarrantyClaim", back_populates="job", cascade="all, delete-orphan")
    progress_updates = relationship("JobProgressUpdate", back_populates="job", cascade="all, delete-orphan")

    def __repr__(self):
        return f'<Job {self.id}: {self.title}>'

    @property
    def total_cost(self):
        """Calculate total job cost"""
        return (self.materials_cost or 0) + (self.labor_cost or 0) + (self.additional_costs or 0)

    @property
    def is_overdue(self):
        """Check if job is overdue"""
        if not self.scheduled_end:
            return False
        return datetime.utcnow() > self.scheduled_end and self.status not in [JobStatus.COMPLETED, JobStatus.CANCELLED]

    @property
    def warranty_status(self):
        """Get current warranty status"""
        if not self.warranty_start_date:
            return WarrantyStatus.VOID
        
        if datetime.utcnow() > self.warranty_end_date:
            return WarrantyStatus.EXPIRED
        
        # Check if there are any warranty claims
        if any(claim.status == 'approved' for claim in self.warranty_claims):
            return WarrantyStatus.CLAIMED
        
        return WarrantyStatus.ACTIVE

    def start_warranty(self):
        """Start warranty period"""
        self.warranty_start_date = datetime.utcnow()
        self.warranty_end_date = self.warranty_start_date + timedelta(days=self.warranty_period_months * 30)

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'customer_id': self.customer_id,
            'craftsman_id': self.craftsman_id,
            'quote_id': self.quote_id,
            'status': self.status.value if self.status else None,
            'priority': self.priority.value if self.priority else None,
            'category': self.category,
            'subcategory': self.subcategory,
            'address': self.address,
            'city': self.city,
            'district': self.district,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'estimated_cost': self.estimated_cost,
            'final_cost': self.final_cost,
            'materials_cost': self.materials_cost,
            'labor_cost': self.labor_cost,
            'additional_costs': self.additional_costs,
            'total_cost': self.total_cost,
            'estimated_duration': self.estimated_duration,
            'actual_duration': self.actual_duration,
            'scheduled_start': self.scheduled_start.isoformat() if self.scheduled_start else None,
            'actual_start': self.actual_start.isoformat() if self.actual_start else None,
            'scheduled_end': self.scheduled_end.isoformat() if self.scheduled_end else None,
            'actual_end': self.actual_end.isoformat() if self.actual_end else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'accepted_at': self.accepted_at.isoformat() if self.accepted_at else None,
            'started_at': self.started_at.isoformat() if self.started_at else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'is_emergency': self.is_emergency,
            'emergency_level': self.emergency_level,
            'emergency_contact': self.emergency_contact,
            'emergency_notes': self.emergency_notes,
            'completion_percentage': self.completion_percentage,
            'quality_score': self.quality_score,
            'customer_satisfaction': self.customer_satisfaction,
            'special_requirements': self.special_requirements,
            'images': self.images,
            'documents': self.documents,
            'notes': self.notes,
            'cancellation_reason': self.cancellation_reason,
            'warranty_period_months': self.warranty_period_months,
            'warranty_start_date': self.warranty_start_date.isoformat() if self.warranty_start_date else None,
            'warranty_end_date': self.warranty_end_date.isoformat() if self.warranty_end_date else None,
            'warranty_terms': self.warranty_terms,
            'warranty_status': self.warranty_status.value if self.warranty_status else None,
            'is_overdue': self.is_overdue,
            'customer': self.customer.to_dict() if self.customer else None,
            'craftsman': self.craftsman.to_dict() if self.craftsman else None,
            'materials': [material.to_dict() for material in self.materials],
            'time_entries': [entry.to_dict() for entry in self.time_entries],
            'progress_updates': [update.to_dict() for update in self.progress_updates]
        }

class JobMaterial(db.Model):
    __tablename__ = 'job_materials'

    id = Column(Integer, primary_key=True)
    job_id = Column(Integer, ForeignKey('jobs.id'), nullable=False)
    
    # Material details
    name = Column(String(200), nullable=False)
    description = Column(Text)
    category = Column(String(100))
    brand = Column(String(100))
    model = Column(String(100))
    
    # Quantity and units
    quantity = Column(Float, nullable=False)
    unit = Column(String(50), nullable=False)  # piece, meter, kg, etc.
    
    # Pricing
    unit_cost = Column(Float)
    total_cost = Column(Float)
    supplier = Column(String(200))
    supplier_contact = Column(String(100))
    
    # Status and tracking
    status = Column(SQLEnum(MaterialStatus), default=MaterialStatus.PLANNED, nullable=False)
    ordered_at = Column(DateTime)
    expected_delivery = Column(DateTime)
    delivered_at = Column(DateTime)
    used_at = Column(DateTime)
    
    # Additional info
    notes = Column(Text)
    receipt_url = Column(String(500))
    warranty_info = Column(Text)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    job = relationship("Job", back_populates="materials")

    def __repr__(self):
        return f'<JobMaterial {self.id}: {self.name}>'

    def to_dict(self):
        return {
            'id': self.id,
            'job_id': self.job_id,
            'name': self.name,
            'description': self.description,
            'category': self.category,
            'brand': self.brand,
            'model': self.model,
            'quantity': self.quantity,
            'unit': self.unit,
            'unit_cost': self.unit_cost,
            'total_cost': self.total_cost,
            'supplier': self.supplier,
            'supplier_contact': self.supplier_contact,
            'status': self.status.value if self.status else None,
            'ordered_at': self.ordered_at.isoformat() if self.ordered_at else None,
            'expected_delivery': self.expected_delivery.isoformat() if self.expected_delivery else None,
            'delivered_at': self.delivered_at.isoformat() if self.delivered_at else None,
            'used_at': self.used_at.isoformat() if self.used_at else None,
            'notes': self.notes,
            'receipt_url': self.receipt_url,
            'warranty_info': self.warranty_info,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class TimeEntry(db.Model):
    __tablename__ = 'time_entries'

    id = Column(Integer, primary_key=True)
    job_id = Column(Integer, ForeignKey('jobs.id'), nullable=False)
    craftsman_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Time tracking
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime)
    duration_minutes = Column(Integer)  # calculated duration
    
    # Entry details
    entry_type = Column(SQLEnum(TimeEntryType), default=TimeEntryType.WORK, nullable=False)
    description = Column(Text)
    location = Column(String(200))
    
    # Billing
    hourly_rate = Column(Float)
    billable_duration = Column(Integer)  # may differ from actual duration
    total_cost = Column(Float)
    is_billable = Column(Boolean, default=True)
    
    # Additional info
    notes = Column(Text)
    images = Column(JSON)  # Progress images
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    job = relationship("Job", back_populates="time_entries")
    craftsman = relationship("User", foreign_keys=[craftsman_id])

    def __repr__(self):
        return f'<TimeEntry {self.id}: {self.entry_type.value}>'

    def calculate_duration(self):
        """Calculate duration in minutes"""
        if self.start_time and self.end_time:
            delta = self.end_time - self.start_time
            self.duration_minutes = int(delta.total_seconds() / 60)
            if self.hourly_rate and self.is_billable:
                hours = self.billable_duration / 60 if self.billable_duration else self.duration_minutes / 60
                self.total_cost = hours * self.hourly_rate

    def to_dict(self):
        return {
            'id': self.id,
            'job_id': self.job_id,
            'craftsman_id': self.craftsman_id,
            'start_time': self.start_time.isoformat() if self.start_time else None,
            'end_time': self.end_time.isoformat() if self.end_time else None,
            'duration_minutes': self.duration_minutes,
            'entry_type': self.entry_type.value if self.entry_type else None,
            'description': self.description,
            'location': self.location,
            'hourly_rate': self.hourly_rate,
            'billable_duration': self.billable_duration,
            'total_cost': self.total_cost,
            'is_billable': self.is_billable,
            'notes': self.notes,
            'images': self.images,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'craftsman': self.craftsman.to_dict() if self.craftsman else None
        }

class JobProgressUpdate(db.Model):
    __tablename__ = 'job_progress_updates'

    id = Column(Integer, primary_key=True)
    job_id = Column(Integer, ForeignKey('jobs.id'), nullable=False)
    craftsman_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Progress details
    title = Column(String(200), nullable=False)
    description = Column(Text)
    completion_percentage = Column(Float, nullable=False)
    
    # Media
    images = Column(JSON)  # Progress images
    videos = Column(JSON)  # Progress videos
    
    # Visibility
    is_visible_to_customer = Column(Boolean, default=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    
    # Relationships
    job = relationship("Job", back_populates="progress_updates")
    craftsman = relationship("User", foreign_keys=[craftsman_id])

    def __repr__(self):
        return f'<JobProgressUpdate {self.id}: {self.title}>'

    def to_dict(self):
        return {
            'id': self.id,
            'job_id': self.job_id,
            'craftsman_id': self.craftsman_id,
            'title': self.title,
            'description': self.description,
            'completion_percentage': self.completion_percentage,
            'images': self.images,
            'videos': self.videos,
            'is_visible_to_customer': self.is_visible_to_customer,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'craftsman': self.craftsman.to_dict() if self.craftsman else None
        }

class WarrantyClaim(db.Model):
    __tablename__ = 'warranty_claims'

    id = Column(Integer, primary_key=True)
    job_id = Column(Integer, ForeignKey('jobs.id'), nullable=False)
    customer_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    craftsman_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Claim details
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    issue_type = Column(String(100))  # defect, malfunction, etc.
    severity = Column(String(50))  # low, medium, high, critical
    
    # Status tracking
    status = Column(String(50), default='submitted', nullable=False, index=True)  # submitted, reviewing, approved, rejected, resolved
    resolution = Column(Text)
    resolution_cost = Column(Float)
    
    # Timeline
    claimed_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    reviewed_at = Column(DateTime)
    resolved_at = Column(DateTime)
    
    # Media evidence
    images = Column(JSON)
    videos = Column(JSON)
    documents = Column(JSON)
    
    # Communication
    customer_notes = Column(Text)
    craftsman_response = Column(Text)
    admin_notes = Column(Text)
    
    # Relationships
    job = relationship("Job", back_populates="warranty_claims")
    customer = relationship("User", foreign_keys=[customer_id])
    craftsman = relationship("User", foreign_keys=[craftsman_id])

    def __repr__(self):
        return f'<WarrantyClaim {self.id}: {self.title}>'

    @property
    def is_valid(self):
        """Check if warranty claim is within warranty period"""
        if not self.job.warranty_end_date:
            return False
        return datetime.utcnow() <= self.job.warranty_end_date

    def to_dict(self):
        return {
            'id': self.id,
            'job_id': self.job_id,
            'customer_id': self.customer_id,
            'craftsman_id': self.craftsman_id,
            'title': self.title,
            'description': self.description,
            'issue_type': self.issue_type,
            'severity': self.severity,
            'status': self.status,
            'resolution': self.resolution,
            'resolution_cost': self.resolution_cost,
            'claimed_at': self.claimed_at.isoformat() if self.claimed_at else None,
            'reviewed_at': self.reviewed_at.isoformat() if self.reviewed_at else None,
            'resolved_at': self.resolved_at.isoformat() if self.resolved_at else None,
            'images': self.images,
            'videos': self.videos,
            'documents': self.documents,
            'customer_notes': self.customer_notes,
            'craftsman_response': self.craftsman_response,
            'admin_notes': self.admin_notes,
            'is_valid': self.is_valid,
            'customer': self.customer.to_dict() if self.customer else None,
            'craftsman': self.craftsman.to_dict() if self.craftsman else None,
            'job': {
                'id': self.job.id,
                'title': self.job.title,
                'warranty_end_date': self.job.warranty_end_date.isoformat() if self.job.warranty_end_date else None
            } if self.job else None
        }

class EmergencyService(db.Model):
    __tablename__ = 'emergency_services'

    id = Column(Integer, primary_key=True)
    customer_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    craftsman_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    job_id = Column(Integer, ForeignKey('jobs.id'), nullable=True)
    
    # Emergency details
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    emergency_type = Column(String(100), nullable=False)  # plumbing, electrical, etc.
    severity = Column(Integer, nullable=False)  # 1-5 scale
    
    # Location
    address = Column(Text, nullable=False)
    city = Column(String(100), nullable=False)
    district = Column(String(100))
    latitude = Column(Float)
    longitude = Column(Float)
    
    # Contact info
    contact_name = Column(String(100))
    contact_phone = Column(String(20), nullable=False)
    alternative_contact = Column(String(20))
    
    # Status and timing
    status = Column(String(50), default='requested', nullable=False, index=True)  # requested, assigned, en_route, in_progress, completed, cancelled
    requested_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    assigned_at = Column(DateTime)
    arrived_at = Column(DateTime)
    completed_at = Column(DateTime)
    
    # Pricing
    estimated_cost = Column(Float)
    final_cost = Column(Float)
    emergency_fee = Column(Float)  # Additional fee for emergency service
    
    # Additional info
    images = Column(JSON)
    notes = Column(Text)
    customer_rating = Column(Integer)  # 1-5 rating
    customer_feedback = Column(Text)
    
    # Relationships
    customer = relationship("User", foreign_keys=[customer_id])
    craftsman = relationship("User", foreign_keys=[craftsman_id])
    job = relationship("Job", foreign_keys=[job_id])

    def __repr__(self):
        return f'<EmergencyService {self.id}: {self.title}>'

    @property
    def response_time_minutes(self):
        """Calculate response time in minutes"""
        if self.assigned_at:
            delta = self.assigned_at - self.requested_at
            return int(delta.total_seconds() / 60)
        return None

    @property
    def is_urgent(self):
        """Check if emergency is urgent (severity 4-5)"""
        return self.severity >= 4

    def to_dict(self):
        return {
            'id': self.id,
            'customer_id': self.customer_id,
            'craftsman_id': self.craftsman_id,
            'job_id': self.job_id,
            'title': self.title,
            'description': self.description,
            'emergency_type': self.emergency_type,
            'severity': self.severity,
            'address': self.address,
            'city': self.city,
            'district': self.district,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'contact_name': self.contact_name,
            'contact_phone': self.contact_phone,
            'alternative_contact': self.alternative_contact,
            'status': self.status,
            'requested_at': self.requested_at.isoformat() if self.requested_at else None,
            'assigned_at': self.assigned_at.isoformat() if self.assigned_at else None,
            'arrived_at': self.arrived_at.isoformat() if self.arrived_at else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'estimated_cost': self.estimated_cost,
            'final_cost': self.final_cost,
            'emergency_fee': self.emergency_fee,
            'images': self.images,
            'notes': self.notes,
            'customer_rating': self.customer_rating,
            'customer_feedback': self.customer_feedback,
            'response_time_minutes': self.response_time_minutes,
            'is_urgent': self.is_urgent,
            'customer': self.customer.to_dict() if self.customer else None,
            'craftsman': self.craftsman.to_dict() if self.craftsman else None,
            'job': self.job.to_dict() if self.job else None
        }