from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.appointment import Appointment, AppointmentStatus, AppointmentType
from app.utils.validators import ResponseHelper
from datetime import datetime, timedelta
from sqlalchemy import and_, or_

calendar_bp = Blueprint('calendar', __name__)

@calendar_bp.route('/appointments', methods=['GET'])
@jwt_required()
def get_appointments():
    """Get user's appointments with filtering"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return ResponseHelper.not_found('User not found')
        
        # Get query parameters
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        status = request.args.get('status')
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 20, type=int), 50)
        
        # Build query based on user type
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            if not customer:
                return ResponseHelper.not_found('Customer profile not found')
            query = Appointment.query.filter_by(customer_id=customer.id)
        else:  # craftsman
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            if not craftsman:
                return ResponseHelper.not_found('Craftsman profile not found')
            query = Appointment.query.filter_by(craftsman_id=craftsman.id)
        
        # Apply filters
        if start_date:
            try:
                start_dt = datetime.fromisoformat(start_date)
                query = query.filter(Appointment.start_time >= start_dt)
            except ValueError:
                return ResponseHelper.validation_error('Invalid start_date format')
        
        if end_date:
            try:
                end_dt = datetime.fromisoformat(end_date)
                query = query.filter(Appointment.end_time <= end_dt)
            except ValueError:
                return ResponseHelper.validation_error('Invalid end_date format')
        
        if status:
            try:
                status_enum = AppointmentStatus(status)
                query = query.filter(Appointment.status == status_enum)
            except ValueError:
                return ResponseHelper.validation_error('Invalid status')
        
        # Paginate results
        appointments = query.order_by(Appointment.start_time.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        return ResponseHelper.success(
            data={
                'appointments': [appointment.to_dict() for appointment in appointments.items],
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': appointments.total,
                    'pages': appointments.pages,
                    'has_next': appointments.has_next,
                    'has_prev': appointments.has_prev,
                }
            },
            message='Randevular başarıyla getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Randevular getirilemedi', str(e))

@calendar_bp.route('/appointments', methods=['POST'])
@jwt_required()
def create_appointment():
    """Create a new appointment"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return ResponseHelper.not_found('User not found')
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'start_time', 'end_time']
        for field in required_fields:
            if not data.get(field):
                return ResponseHelper.validation_error(f'{field} is required')
        
        # Parse dates
        try:
            start_time = datetime.fromisoformat(data['start_time'])
            end_time = datetime.fromisoformat(data['end_time'])
        except ValueError:
            return ResponseHelper.validation_error('Invalid date format')
        
        # Validate date logic
        if start_time >= end_time:
            return ResponseHelper.validation_error('End time must be after start time')
        
        if start_time < datetime.now():
            return ResponseHelper.validation_error('Cannot create appointment in the past')
        
        # Get customer and craftsman IDs based on user type
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            if not customer:
                return ResponseHelper.not_found('Customer profile not found')
            
            customer_id = customer.id
            craftsman_id = data.get('craftsman_id')
            if not craftsman_id:
                return ResponseHelper.validation_error('craftsman_id is required for customers')
        else:  # craftsman
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            if not craftsman:
                return ResponseHelper.not_found('Craftsman profile not found')
            
            craftsman_id = craftsman.id
            customer_id = data.get('customer_id')
            if not customer_id:
                return ResponseHelper.validation_error('customer_id is required for craftsmen')
        
        # Check for conflicts
        conflict_query = Appointment.query.filter(
            or_(
                Appointment.customer_id == customer_id,
                Appointment.craftsman_id == craftsman_id
            ),
            Appointment.status.in_([AppointmentStatus.CONFIRMED, AppointmentStatus.IN_PROGRESS]),
            or_(
                and_(Appointment.start_time <= start_time, Appointment.end_time > start_time),
                and_(Appointment.start_time < end_time, Appointment.end_time >= end_time),
                and_(Appointment.start_time >= start_time, Appointment.end_time <= end_time)
            )
        )
        
        if conflict_query.first():
            return ResponseHelper.validation_error('Bu zaman diliminde çakışan randevu var')
        
        # Create appointment
        appointment = Appointment(
            customer_id=customer_id,
            craftsman_id=craftsman_id,
            quote_id=data.get('quote_id'),
            title=data['title'],
            description=data.get('description'),
            start_time=start_time,
            end_time=end_time,
            type=AppointmentType(data.get('type', 'consultation')),
            location=data.get('location'),
            notes=data.get('notes'),
            is_all_day=data.get('is_all_day', False),
            reminder_time=data.get('reminder_time'),
        )
        
        db.session.add(appointment)
        db.session.commit()
        
        return ResponseHelper.success(
            data=appointment.to_dict(),
            message='Randevu başarıyla oluşturuldu'
        )
        
    except Exception as e:
        db.session.rollback()
        return ResponseHelper.server_error('Randevu oluşturulamadı', str(e))

@calendar_bp.route('/appointments/<int:appointment_id>', methods=['PUT'])
@jwt_required()
def update_appointment(appointment_id):
    """Update an appointment"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return ResponseHelper.not_found('User not found')
        
        # Find appointment
        appointment = Appointment.query.get(appointment_id)
        if not appointment:
            return ResponseHelper.not_found('Randevu bulunamadı')
        
        # Check authorization
        authorized = False
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            authorized = customer and appointment.customer_id == customer.id
        else:  # craftsman
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            authorized = craftsman and appointment.craftsman_id == craftsman.id
        
        if not authorized:
            return ResponseHelper.forbidden('Bu randevuyu güncelleme yetkiniz yok')
        
        data = request.get_json()
        
        # Update fields
        if 'title' in data:
            appointment.title = data['title']
        if 'description' in data:
            appointment.description = data['description']
        if 'location' in data:
            appointment.location = data['location']
        if 'notes' in data:
            appointment.notes = data['notes']
        if 'status' in data:
            try:
                appointment.status = AppointmentStatus(data['status'])
            except ValueError:
                return ResponseHelper.validation_error('Invalid status')
        
        # Update times if provided
        if 'start_time' in data or 'end_time' in data:
            try:
                new_start = datetime.fromisoformat(data['start_time']) if 'start_time' in data else appointment.start_time
                new_end = datetime.fromisoformat(data['end_time']) if 'end_time' in data else appointment.end_time
                
                if new_start >= new_end:
                    return ResponseHelper.validation_error('End time must be after start time')
                
                appointment.start_time = new_start
                appointment.end_time = new_end
            except ValueError:
                return ResponseHelper.validation_error('Invalid date format')
        
        appointment.updated_at = datetime.utcnow()
        db.session.commit()
        
        return ResponseHelper.success(
            data=appointment.to_dict(),
            message='Randevu başarıyla güncellendi'
        )
        
    except Exception as e:
        db.session.rollback()
        return ResponseHelper.server_error('Randevu güncellenemedi', str(e))

@calendar_bp.route('/appointments/<int:appointment_id>', methods=['DELETE'])
@jwt_required()
def cancel_appointment(appointment_id):
    """Cancel an appointment"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return ResponseHelper.not_found('User not found')
        
        # Find appointment
        appointment = Appointment.query.get(appointment_id)
        if not appointment:
            return ResponseHelper.not_found('Randevu bulunamadı')
        
        # Check authorization
        authorized = False
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            authorized = customer and appointment.customer_id == customer.id
        else:  # craftsman
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            authorized = craftsman and appointment.craftsman_id == craftsman.id
        
        if not authorized:
            return ResponseHelper.forbidden('Bu randevuyu iptal etme yetkiniz yok')
        
        # Check if can be cancelled
        if not appointment.can_be_cancelled():
            return ResponseHelper.validation_error('Bu randevu iptal edilemez')
        
        appointment.status = AppointmentStatus.CANCELLED
        appointment.updated_at = datetime.utcnow()
        db.session.commit()
        
        return ResponseHelper.success(
            data=appointment.to_dict(),
            message='Randevu başarıyla iptal edildi'
        )
        
    except Exception as e:
        db.session.rollback()
        return ResponseHelper.server_error('Randevu iptal edilemedi', str(e))

@calendar_bp.route('/availability/<int:craftsman_id>', methods=['GET'])
def get_craftsman_availability(craftsman_id):
    """Get craftsman's availability for a date range"""
    try:
        craftsman = Craftsman.query.get(craftsman_id)
        if not craftsman:
            return ResponseHelper.not_found('Usta bulunamadı')
        
        # Get date range (default to next 30 days)
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        
        if not start_date:
            start_date = datetime.now().date()
        else:
            try:
                start_date = datetime.fromisoformat(start_date).date()
            except ValueError:
                return ResponseHelper.validation_error('Invalid start_date format')
        
        if not end_date:
            end_date = start_date + timedelta(days=30)
        else:
            try:
                end_date = datetime.fromisoformat(end_date).date()
            except ValueError:
                return ResponseHelper.validation_error('Invalid end_date format')
        
        # Get existing appointments
        appointments = Appointment.query.filter(
            Appointment.craftsman_id == craftsman_id,
            Appointment.status.in_([AppointmentStatus.CONFIRMED, AppointmentStatus.IN_PROGRESS]),
            Appointment.start_time >= datetime.combine(start_date, datetime.min.time()),
            Appointment.end_time <= datetime.combine(end_date, datetime.max.time())
        ).all()
        
        # Generate availability slots (9 AM to 6 PM, 1-hour slots)
        availability = []
        current_date = start_date
        
        while current_date <= end_date:
            # Skip weekends for now (can be configurable)
            if current_date.weekday() < 5:  # Monday = 0, Friday = 4
                day_slots = []
                
                for hour in range(9, 18):  # 9 AM to 6 PM
                    slot_start = datetime.combine(current_date, datetime.min.time().replace(hour=hour))
                    slot_end = slot_start + timedelta(hours=1)
                    
                    # Check if slot conflicts with existing appointments
                    is_available = not any(
                        appointment.start_time < slot_end and appointment.end_time > slot_start
                        for appointment in appointments
                    )
                    
                    day_slots.append({
                        'start_time': slot_start.isoformat(),
                        'end_time': slot_end.isoformat(),
                        'is_available': is_available,
                    })
                
                availability.append({
                    'date': current_date.isoformat(),
                    'slots': day_slots,
                })
            
            current_date += timedelta(days=1)
        
        return ResponseHelper.success(
            data={
                'craftsman_id': craftsman_id,
                'availability': availability,
                'existing_appointments': [apt.to_dict(include_relations=False) for apt in appointments],
            },
            message='Müsaitlik bilgileri getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Müsaitlik bilgileri getirilemedi', str(e))

@calendar_bp.route('/appointments/upcoming', methods=['GET'])
@jwt_required()
def get_upcoming_appointments():
    """Get upcoming appointments for the user"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return ResponseHelper.not_found('User not found')
        
        limit = request.args.get('limit', 5, type=int)
        
        # Build query based on user type
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            if not customer:
                return ResponseHelper.not_found('Customer profile not found')
            query = Appointment.query.filter_by(customer_id=customer.id)
        else:  # craftsman
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            if not craftsman:
                return ResponseHelper.not_found('Craftsman profile not found')
            query = Appointment.query.filter_by(craftsman_id=craftsman.id)
        
        # Get upcoming appointments
        upcoming = query.filter(
            Appointment.start_time > datetime.now(),
            Appointment.status.in_([AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED])
        ).order_by(Appointment.start_time.asc()).limit(limit).all()
        
        return ResponseHelper.success(
            data=[appointment.to_dict() for appointment in upcoming],
            message='Yaklaşan randevular getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Yaklaşan randevular getirilemedi', str(e))

@calendar_bp.route('/appointments/today', methods=['GET'])
@jwt_required()
def get_today_appointments():
    """Get today's appointments for the user"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return ResponseHelper.not_found('User not found')
        
        # Build query based on user type
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            if not customer:
                return ResponseHelper.not_found('Customer profile not found')
            query = Appointment.query.filter_by(customer_id=customer.id)
        else:  # craftsman
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            if not craftsman:
                return ResponseHelper.not_found('Craftsman profile not found')
            query = Appointment.query.filter_by(craftsman_id=craftsman.id)
        
        # Get today's appointments
        today = datetime.now().date()
        today_appointments = query.filter(
            Appointment.start_time >= datetime.combine(today, datetime.min.time()),
            Appointment.start_time < datetime.combine(today + timedelta(days=1), datetime.min.time())
        ).order_by(Appointment.start_time.asc()).all()
        
        return ResponseHelper.success(
            data=[appointment.to_dict() for appointment in today_appointments],
            message='Bugünün randevuları getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Bugünün randevuları getirilemedi', str(e))