from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.utils.auth_utils import get_current_user_id
from app import db
from app.models.job import Job, JobStatus, JobUrgency
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category
from app.models.notification import Notification
from datetime import datetime
import logging

job_bp = Blueprint('job', __name__)

@job_bp.route('/', methods=['GET'])
@jwt_required()
def get_jobs():
    """Get jobs with filtering options"""
    try:
        user_id = get_current_user_id()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Get filter parameters
        status = request.args.get('status')
        category_id = request.args.get('category_id', type=int)
        city = request.args.get('city')
        district = request.args.get('district')
        urgency = request.args.get('urgency')
        min_budget = request.args.get('min_budget', type=float)
        max_budget = request.args.get('max_budget', type=float)
        skills = request.args.getlist('skills')  # Can pass multiple skills
        
        # Pagination
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        # Base query
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            query = Job.query.filter_by(customer_id=customer.id)
        else:
            # For craftsmen, show available jobs or assigned jobs
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            show_assigned = request.args.get('assigned', 'false').lower() == 'true'
            
            if show_assigned:
                query = Job.query.filter_by(assigned_craftsman_id=craftsman.id)
            else:
                query = Job.query.filter(Job.status == JobStatus.OPEN.value)
        
        # Apply filters
        if status:
            query = query.filter(Job.status == status)
        
        if category_id:
            query = query.filter(Job.category_id == category_id)
        
        if city:
            query = query.filter(Job.city.ilike(f'%{city}%'))
        
        if district:
            query = query.filter(Job.district.ilike(f'%{district}%'))
        
        if urgency:
            query = query.filter(Job.urgency == urgency)
        
        if min_budget:
            query = query.filter(Job.budget_min >= min_budget)
        
        if max_budget:
            query = query.filter(Job.budget_max <= max_budget)
        
        # Order by creation date (newest first)
        query = query.order_by(Job.created_at.desc())
        
        # Paginate
        jobs_pagination = query.paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        jobs = jobs_pagination.items
        
        # Filter by skills if provided (post-query filtering for JSON field)
        if skills:
            filtered_jobs = []
            for job in jobs:
                if job.required_skills:
                    if any(skill in job.required_skills for skill in skills):
                        filtered_jobs.append(job)
            jobs = filtered_jobs
        
        return jsonify({
            'success': True,
            'jobs': [job.to_dict() for job in jobs],
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total': jobs_pagination.total,
                'pages': jobs_pagination.pages,
                'has_next': jobs_pagination.has_next,
                'has_prev': jobs_pagination.has_prev
            }
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting jobs: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@job_bp.route('/', methods=['POST'])
@jwt_required()
def create_job():
    """Create a new job request"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user or user.user_type != 'customer':
            return jsonify({'error': 'Only customers can create jobs'}), 403
        
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer:
            return jsonify({'error': 'Customer profile not found'}), 404
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'description', 'category_id', 'location']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': True,
                    'message': f'{field} is required'
                }), 400
        
        # Validate category exists
        category = Category.query.get(data['category_id'])
        if not category:
            return jsonify({
                'error': True,
                'message': 'Invalid category'
            }), 400
        
        # Create job
        job = Job(
            title=data['title'],
            description=data['description'],
            category_id=data['category_id'],
            location=data['location'],
            city=data.get('city'),
            district=data.get('district'),
            address=data.get('address'),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            budget_min=data.get('budget_min'),
            budget_max=data.get('budget_max'),
            urgency=data.get('urgency', JobUrgency.NORMAL.value),
            customer_id=customer.id,
            preferred_start_date=datetime.fromisoformat(data['preferred_start_date']) if data.get('preferred_start_date') else None,
            preferred_end_date=datetime.fromisoformat(data['preferred_end_date']) if data.get('preferred_end_date') else None,
            required_skills=data.get('required_skills', []),
            materials_provided=data.get('materials_provided', False),
            tools_provided=data.get('tools_provided', False),
            images=data.get('images', []),
            attachments=data.get('attachments', [])
        )
        
        db.session.add(job)
        db.session.commit()
        
        # Create notification for nearby craftsmen (simplified)
        # In a real app, you'd have a background job for this
        craftsmen = Craftsman.query.limit(10).all()  # Get first 10 craftsmen for demo
        for craftsman in craftsmen:
            Notification.create_notification(
                user_id=craftsman.user_id,
                notification_type='job',
                title='Yeni İş İlanı',
                message=f'Yeni bir iş ilanı: {job.title}',
                related_id=job.id,
                related_type='job',
                action_url=f'/job/{job.id}'
            )
        
        return jsonify({
            'success': True,
            'message': 'Job created successfully',
            'job': job.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        logging.error(f"Error creating job: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@job_bp.route('/<int:job_id>', methods=['GET'])
@jwt_required()
def get_job_details():
    """Get detailed information about a specific job"""
    try:
        user_id = get_jwt_identity()
        job_id = request.view_args['job_id']
        
        job = Job.query.get(job_id)
        if not job:
            return jsonify({'error': 'Job not found'}), 404
        
        # Check if user has access to this job
        user = User.query.get(user_id)
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            if job.customer_id != customer.id:
                return jsonify({'error': 'Access denied'}), 403
        
        return jsonify({
            'success': True,
            'job': job.to_dict()
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting job details: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@job_bp.route('/<int:job_id>/assign', methods=['POST'])
@jwt_required()
def assign_job():
    """Assign a job to a craftsman"""
    try:
        user_id = get_jwt_identity()
        job_id = request.view_args['job_id']
        data = request.get_json()
        
        job = Job.query.get(job_id)
        if not job:
            return jsonify({'error': 'Job not found'}), 404
        
        # Check if user is the customer who created this job
        user = User.query.get(user_id)
        if user.user_type != 'customer':
            return jsonify({'error': 'Only customers can assign jobs'}), 403
        
        customer = Customer.query.filter_by(user_id=user_id).first()
        if job.customer_id != customer.id:
            return jsonify({'error': 'Access denied'}), 403
        
        # Check if job is in assignable state
        if job.status != JobStatus.OPEN.value:
            return jsonify({'error': 'Job is not available for assignment'}), 400
        
        # Validate craftsman
        craftsman_id = data.get('craftsman_id')
        if not craftsman_id:
            return jsonify({'error': 'Craftsman ID is required'}), 400
        
        craftsman = Craftsman.query.get(craftsman_id)
        if not craftsman:
            return jsonify({'error': 'Craftsman not found'}), 404
        
        # Assign the job
        job.assign_craftsman(craftsman_id)
        
        # Create notification for craftsman
        Notification.create_notification(
            user_id=craftsman.user_id,
            notification_type='job',
            title='İş Atandı',
            message=f'Size yeni bir iş atandı: {job.title}',
            priority='high',
            related_id=job.id,
            related_type='job',
            action_url=f'/job/{job.id}'
        )
        
        return jsonify({
            'success': True,
            'message': 'Job assigned successfully',
            'job': job.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logging.error(f"Error assigning job: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@job_bp.route('/<int:job_id>/start', methods=['POST'])
@jwt_required()
def start_job():
    """Start working on an assigned job"""
    try:
        user_id = get_jwt_identity()
        job_id = request.view_args['job_id']
        
        job = Job.query.get(job_id)
        if not job:
            return jsonify({'error': 'Job not found'}), 404
        
        # Check if user is the assigned craftsman
        user = User.query.get(user_id)
        if user.user_type != 'craftsman':
            return jsonify({'error': 'Only craftsmen can start jobs'}), 403
        
        craftsman = Craftsman.query.filter_by(user_id=user_id).first()
        if job.assigned_craftsman_id != craftsman.id:
            return jsonify({'error': 'You are not assigned to this job'}), 403
        
        # Start the job
        if job.start_job():
            # Create notification for customer
            Notification.create_notification(
                user_id=job.customer.user_id,
                notification_type='job',
                title='İş Başladı',
                message=f'{job.title} işi başladı.',
                related_id=job.id,
                related_type='job',
                action_url=f'/job/{job.id}/progress'
            )
            
            return jsonify({
                'success': True,
                'message': 'Job started successfully',
                'job': job.to_dict()
            }), 200
        else:
            return jsonify({'error': 'Cannot start job in current state'}), 400
        
    except Exception as e:
        logging.error(f"Error starting job: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@job_bp.route('/<int:job_id>/complete', methods=['POST'])
@jwt_required()
def complete_job():
    """Mark job as completed"""
    try:
        user_id = get_jwt_identity()
        job_id = request.view_args['job_id']
        data = request.get_json()
        
        job = Job.query.get(job_id)
        if not job:
            return jsonify({'error': 'Job not found'}), 404
        
        # Check if user is the assigned craftsman
        user = User.query.get(user_id)
        if user.user_type != 'craftsman':
            return jsonify({'error': 'Only craftsmen can complete jobs'}), 403
        
        craftsman = Craftsman.query.filter_by(user_id=user_id).first()
        if job.assigned_craftsman_id != craftsman.id:
            return jsonify({'error': 'You are not assigned to this job'}), 403
        
        # Complete the job
        final_price = data.get('final_price')
        if job.complete_job(final_price):
            # Create notification for customer
            Notification.create_notification(
                user_id=job.customer.user_id,
                notification_type='job',
                title='İş Tamamlandı',
                message=f'{job.title} işi tamamlandı. Lütfen kontrol edin.',
                priority='high',
                related_id=job.id,
                related_type='job',
                action_url=f'/job/{job.id}'
            )
            
            return jsonify({
                'success': True,
                'message': 'Job completed successfully',
                'job': job.to_dict()
            }), 200
        else:
            return jsonify({'error': 'Cannot complete job in current state'}), 400
        
    except Exception as e:
        logging.error(f"Error completing job: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@job_bp.route('/<int:job_id>/approve', methods=['POST'])
@jwt_required()
def approve_job():
    """Customer approves completed job"""
    try:
        user_id = get_jwt_identity()
        job_id = request.view_args['job_id']
        
        job = Job.query.get(job_id)
        if not job:
            return jsonify({'error': 'Job not found'}), 404
        
        # Check if user is the customer
        user = User.query.get(user_id)
        if user.user_type != 'customer':
            return jsonify({'error': 'Only customers can approve jobs'}), 403
        
        customer = Customer.query.filter_by(user_id=user_id).first()
        if job.customer_id != customer.id:
            return jsonify({'error': 'Access denied'}), 403
        
        # Approve the job
        if job.approve_job():
            # Create notification for craftsman
            Notification.create_notification(
                user_id=job.assigned_craftsman.user_id,
                notification_type='job',
                title='İş Onaylandı',
                message=f'{job.title} işi müşteri tarafından onaylandı.',
                priority='high',
                related_id=job.id,
                related_type='job',
                action_url=f'/job/{job.id}'
            )
            
            return jsonify({
                'success': True,
                'message': 'Job approved successfully',
                'job': job.to_dict()
            }), 200
        else:
            return jsonify({'error': 'Cannot approve job in current state'}), 400
        
    except Exception as e:
        logging.error(f"Error approving job: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@job_bp.route('/<int:job_id>/cancel', methods=['POST'])
@jwt_required()
def cancel_job():
    """Cancel a job"""
    try:
        user_id = get_jwt_identity()
        job_id = request.view_args['job_id']
        data = request.get_json()
        
        job = Job.query.get(job_id)
        if not job:
            return jsonify({'error': 'Job not found'}), 404
        
        # Check if user has permission to cancel
        user = User.query.get(user_id)
        can_cancel = False
        
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            can_cancel = job.customer_id == customer.id
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            can_cancel = job.assigned_craftsman_id == craftsman.id
        
        if not can_cancel:
            return jsonify({'error': 'Access denied'}), 403
        
        # Cancel the job
        reason = data.get('reason', 'No reason provided')
        if job.cancel_job(reason):
            # Create notification for the other party
            if user.user_type == 'customer' and job.assigned_craftsman:
                Notification.create_notification(
                    user_id=job.assigned_craftsman.user_id,
                    notification_type='job',
                    title='İş İptal Edildi',
                    message=f'{job.title} işi müşteri tarafından iptal edildi.',
                    related_id=job.id,
                    related_type='job'
                )
            elif user.user_type == 'craftsman':
                Notification.create_notification(
                    user_id=job.customer.user_id,
                    notification_type='job',
                    title='İş İptal Edildi',
                    message=f'{job.title} işi usta tarafından iptal edildi.',
                    related_id=job.id,
                    related_type='job'
                )
            
            return jsonify({
                'success': True,
                'message': 'Job cancelled successfully',
                'job': job.to_dict()
            }), 200
        else:
            return jsonify({'error': 'Cannot cancel job in current state'}), 400
        
    except Exception as e:
        logging.error(f"Error cancelling job: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@job_bp.route('/search', methods=['GET'])
def search_jobs():
    """Advanced job search with location and skills"""
    try:
        # Location-based search
        city = request.args.get('city')
        district = request.args.get('district')
        lat = request.args.get('lat', type=float)
        lng = request.args.get('lng', type=float)
        radius = request.args.get('radius', 10, type=float)  # Default 10km radius
        
        # Skill-based search
        skills = request.args.getlist('skills')
        
        # Other filters
        category_id = request.args.get('category_id', type=int)
        urgency = request.args.get('urgency')
        min_budget = request.args.get('min_budget', type=float)
        max_budget = request.args.get('max_budget', type=float)
        
        jobs = []
        
        # Location-based search
        if city or district or (lat and lng):
            location_jobs = Job.get_jobs_by_location(
                city=city, 
                district=district, 
                radius_km=radius, 
                lat=lat, 
                lng=lng
            )
            jobs.extend(location_jobs)
        
        # Skill-based search
        if skills:
            skill_jobs = Job.get_jobs_by_skills(skills)
            if jobs:
                # Intersection of location and skill results
                job_ids = [j.id for j in jobs]
                jobs = [j for j in skill_jobs if j.id in job_ids]
            else:
                jobs = skill_jobs
        
        # If no specific search criteria, get all open jobs
        if not jobs and not any([city, district, lat, lng, skills]):
            jobs = Job.query.filter(Job.status == JobStatus.OPEN.value).all()
        
        # Apply additional filters
        if category_id:
            jobs = [j for j in jobs if j.category_id == category_id]
        
        if urgency:
            jobs = [j for j in jobs if j.urgency == urgency]
        
        if min_budget:
            jobs = [j for j in jobs if j.budget_min and j.budget_min >= min_budget]
        
        if max_budget:
            jobs = [j for j in jobs if j.budget_max and j.budget_max <= max_budget]
        
        # Sort by creation date (newest first)
        jobs.sort(key=lambda x: x.created_at, reverse=True)
        
        return jsonify({
            'success': True,
            'jobs': [job.to_dict() for job in jobs],
            'total': len(jobs)
        }), 200
        
    except Exception as e:
        logging.error(f"Error searching jobs: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500