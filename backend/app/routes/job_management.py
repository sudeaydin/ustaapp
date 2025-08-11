from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import Schema, fields, validate, ValidationError
from app.utils.security import rate_limit, require_auth
from app.utils.job_management import (
    JobTracker, MaterialManager, TimeTracker, ProgressManager, 
    WarrantyManager, EmergencyServiceManager, JobAnalytics, JobConstants
)
from app.models.job import (
    Job, JobMaterial, TimeEntry, JobProgressUpdate, WarrantyClaim, EmergencyService,
    JobStatus, JobPriority, MaterialStatus, TimeEntryType
)
from app import db
from datetime import datetime

job_management_bp = Blueprint('job_management', __name__)

# Validation Schemas
class JobUpdateSchema(Schema):
    status = fields.Str(validate=validate.OneOf([s.value for s in JobStatus]))
    priority = fields.Str(validate=validate.OneOf([p.value for p in JobPriority]))
    notes = fields.Str()
    completion_percentage = fields.Float(validate=validate.Range(0, 100))
    scheduled_start = fields.DateTime()
    scheduled_end = fields.DateTime()
    estimated_cost = fields.Float(validate=validate.Range(0))
    warranty_period_months = fields.Int(validate=validate.Range(1, 120))

class MaterialSchema(Schema):
    name = fields.Str(required=True, validate=validate.Length(1, 200))
    description = fields.Str()
    category = fields.Str()
    brand = fields.Str()
    model = fields.Str()
    quantity = fields.Float(required=True, validate=validate.Range(0.01))
    unit = fields.Str(required=True, validate=validate.OneOf(JobConstants.MATERIAL_UNITS))
    unit_cost = fields.Float(validate=validate.Range(0))
    supplier = fields.Str()
    supplier_contact = fields.Str()
    expected_delivery = fields.DateTime()
    notes = fields.Str()

class TimeEntrySchema(Schema):
    entry_type = fields.Str(validate=validate.OneOf([t.value for t in TimeEntryType]))
    description = fields.Str()
    location = fields.Str()
    hourly_rate = fields.Float(validate=validate.Range(0))
    is_billable = fields.Bool()

class ProgressUpdateSchema(Schema):
    title = fields.Str(required=True, validate=validate.Length(1, 200))
    description = fields.Str()
    completion_percentage = fields.Float(required=True, validate=validate.Range(0, 100))
    images = fields.List(fields.Str())
    videos = fields.List(fields.Str())
    is_visible_to_customer = fields.Bool()

class WarrantyClaimSchema(Schema):
    title = fields.Str(required=True, validate=validate.Length(1, 200))
    description = fields.Str(required=True, validate=validate.Length(1, 1000))
    issue_type = fields.Str()
    severity = fields.Str(validate=validate.OneOf(['low', 'medium', 'high', 'critical']))
    images = fields.List(fields.Str())
    videos = fields.List(fields.Str())
    customer_notes = fields.Str()

class EmergencyServiceSchema(Schema):
    title = fields.Str(required=True, validate=validate.Length(1, 200))
    description = fields.Str(required=True, validate=validate.Length(1, 1000))
    emergency_type = fields.Str(required=True)
    severity = fields.Int(required=True, validate=validate.Range(1, 5))
    address = fields.Str(required=True)
    city = fields.Str(required=True)
    district = fields.Str()
    latitude = fields.Float()
    longitude = fields.Float()
    contact_name = fields.Str()
    contact_phone = fields.Str(required=True)
    alternative_contact = fields.Str()
    images = fields.List(fields.Str())

# Job Management Routes

@job_management_bp.route('/jobs', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_jobs():
    """Get jobs for user"""
    try:
        user_id = get_jwt_identity()
        user_type = request.args.get('user_type', 'customer')
        status = request.args.get('status')
        page = int(request.args.get('page', 1))
        per_page = min(int(request.args.get('per_page', 20)), 100)
        
        query = Job.query
        
        # Filter by user
        if user_type == 'customer':
            query = query.filter(Job.customer_id == user_id)
        elif user_type == 'craftsman':
            query = query.filter(Job.craftsman_id == user_id)
        
        # Filter by status
        if status:
            try:
                job_status = JobStatus(status)
                query = query.filter(Job.status == job_status)
            except ValueError:
                return jsonify({
                    'success': False,
                    'message': 'Invalid status'
                }), 400
        
        # Pagination
        pagination = query.order_by(Job.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        jobs = [job.to_dict() for job in pagination.items]
        
        return jsonify({
            'success': True,
            'data': {
                'jobs': jobs,
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': pagination.total,
                    'pages': pagination.pages,
                    'has_next': pagination.has_next,
                    'has_prev': pagination.has_prev
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get jobs: {str(e)}'
        }), 500

@job_management_bp.route('/jobs/<int:job_id>', methods=['GET'])
@rate_limit(requests_per_minute=120)
@require_auth
def get_job_detail(job_id):
    """Get detailed job information"""
    try:
        user_id = get_jwt_identity()
        
        job = Job.query.filter(
            Job.id == job_id,
            (Job.customer_id == user_id) | (Job.craftsman_id == user_id)
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found'
            }), 404
        
        # Get additional data
        timeline = JobTracker.get_job_timeline(job_id)
        cost_breakdown = JobAnalytics.get_cost_breakdown(job_id)
        progress_updates = ProgressManager.get_job_progress(job_id)
        
        return jsonify({
            'success': True,
            'data': {
                'job': job.to_dict(),
                'timeline': timeline,
                'cost_breakdown': cost_breakdown,
                'progress_updates': [update.to_dict() for update in progress_updates]
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get job detail: {str(e)}'
        }), 500

@job_management_bp.route('/jobs/<int:job_id>', methods=['PUT'])
@rate_limit(requests_per_minute=30)
@require_auth
def update_job(job_id):
    """Update job details"""
    try:
        user_id = get_jwt_identity()
        schema = JobUpdateSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # Check job ownership
        job = Job.query.filter(
            Job.id == job_id,
            (Job.customer_id == user_id) | (Job.craftsman_id == user_id)
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found'
            }), 404
        
        # Update job
        for key, value in data.items():
            if key == 'status':
                JobTracker.update_job_status(job_id, JobStatus(value), data.get('notes'))
            else:
                setattr(job, key, value)
        
        job.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': job.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Failed to update job: {str(e)}'
        }), 500

# Material Management Routes

@job_management_bp.route('/jobs/<int:job_id>/materials', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_job_materials(job_id):
    """Get materials for a job"""
    try:
        user_id = get_jwt_identity()
        
        # Check job access
        job = Job.query.filter(
            Job.id == job_id,
            (Job.customer_id == user_id) | (Job.craftsman_id == user_id)
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found'
            }), 404
        
        materials = JobMaterial.query.filter(JobMaterial.job_id == job_id).all()
        total_cost = MaterialManager.get_job_materials_cost(job_id)
        
        return jsonify({
            'success': True,
            'data': {
                'materials': [material.to_dict() for material in materials],
                'total_cost': total_cost
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get materials: {str(e)}'
        }), 500

@job_management_bp.route('/jobs/<int:job_id>/materials', methods=['POST'])
@rate_limit(requests_per_minute=30)
@require_auth
def add_job_material(job_id):
    """Add material to job"""
    try:
        user_id = get_jwt_identity()
        schema = MaterialSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # Check if user is craftsman for this job
        job = Job.query.filter(
            Job.id == job_id,
            Job.craftsman_id == user_id
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found or access denied'
            }), 404
        
        material = MaterialManager.add_material(job_id, data)
        
        return jsonify({
            'success': True,
            'data': material.to_dict()
        }), 201
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to add material: {str(e)}'
        }), 500

@job_management_bp.route('/materials/<int:material_id>/status', methods=['PUT'])
@rate_limit(requests_per_minute=30)
@require_auth
def update_material_status(material_id):
    """Update material status"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        status_str = data.get('status')
        notes = data.get('notes')
        
        if not status_str:
            return jsonify({
                'success': False,
                'message': 'Status is required'
            }), 400
        
        try:
            status = MaterialStatus(status_str)
        except ValueError:
            return jsonify({
                'success': False,
                'message': 'Invalid status'
            }), 400
        
        # Check if user is craftsman for this material's job
        material = JobMaterial.query.join(Job).filter(
            JobMaterial.id == material_id,
            Job.craftsman_id == user_id
        ).first()
        
        if not material:
            return jsonify({
                'success': False,
                'message': 'Material not found or access denied'
            }), 404
        
        success = MaterialManager.update_material_status(material_id, status, notes)
        
        if success:
            updated_material = JobMaterial.query.get(material_id)
            return jsonify({
                'success': True,
                'data': updated_material.to_dict()
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Failed to update material status'
            }), 500
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to update material status: {str(e)}'
        }), 500

# Time Tracking Routes

@job_management_bp.route('/jobs/<int:job_id>/time/start', methods=['POST'])
@rate_limit(requests_per_minute=30)
@require_auth
def start_time_tracking(job_id):
    """Start time tracking for a job"""
    try:
        user_id = get_jwt_identity()
        schema = TimeEntrySchema()
        
        try:
            data = schema.load(request.get_json() or {})
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # Check if user is craftsman for this job
        job = Job.query.filter(
            Job.id == job_id,
            Job.craftsman_id == user_id
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found or access denied'
            }), 404
        
        entry_type = TimeEntryType(data.get('entry_type', 'work'))
        entry = TimeTracker.start_time_entry(
            job_id, user_id, entry_type,
            data.get('description'), data.get('location')
        )
        
        return jsonify({
            'success': True,
            'data': entry.to_dict()
        }), 201
        
    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to start time tracking: {str(e)}'
        }), 500

@job_management_bp.route('/time-entries/<int:entry_id>/end', methods=['PUT'])
@rate_limit(requests_per_minute=30)
@require_auth
def end_time_tracking(entry_id):
    """End time tracking entry"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json() or {}
        
        # Check if user owns this time entry
        entry = TimeEntry.query.filter(
            TimeEntry.id == entry_id,
            TimeEntry.craftsman_id == user_id
        ).first()
        
        if not entry:
            return jsonify({
                'success': False,
                'message': 'Time entry not found or access denied'
            }), 404
        
        updated_entry = TimeTracker.end_time_entry(
            entry_id, data.get('notes'), data.get('images')
        )
        
        return jsonify({
            'success': True,
            'data': updated_entry.to_dict()
        })
        
    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to end time tracking: {str(e)}'
        }), 500

@job_management_bp.route('/jobs/<int:job_id>/time-summary', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_job_time_summary(job_id):
    """Get time summary for a job"""
    try:
        user_id = get_jwt_identity()
        
        # Check job access
        job = Job.query.filter(
            Job.id == job_id,
            (Job.customer_id == user_id) | (Job.craftsman_id == user_id)
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found'
            }), 404
        
        summary = TimeTracker.get_job_time_summary(job_id)
        
        return jsonify({
            'success': True,
            'data': summary
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get time summary: {str(e)}'
        }), 500

@job_management_bp.route('/craftsman/time-summary', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_craftsman_time_summary():
    """Get time summary for craftsman"""
    try:
        user_id = get_jwt_identity()
        
        start_date_str = request.args.get('start_date')
        end_date_str = request.args.get('end_date')
        
        start_date = datetime.fromisoformat(start_date_str) if start_date_str else None
        end_date = datetime.fromisoformat(end_date_str) if end_date_str else None
        
        summary = TimeTracker.get_craftsman_time_summary(user_id, start_date, end_date)
        
        return jsonify({
            'success': True,
            'data': summary
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get time summary: {str(e)}'
        }), 500

# Progress Tracking Routes

@job_management_bp.route('/jobs/<int:job_id>/progress', methods=['POST'])
@rate_limit(requests_per_minute=30)
@require_auth
def add_progress_update(job_id):
    """Add progress update to job"""
    try:
        user_id = get_jwt_identity()
        schema = ProgressUpdateSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # Check if user is craftsman for this job
        job = Job.query.filter(
            Job.id == job_id,
            Job.craftsman_id == user_id
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found or access denied'
            }), 404
        
        update = ProgressManager.add_progress_update(job_id, user_id, data)
        
        return jsonify({
            'success': True,
            'data': update.to_dict()
        }), 201
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to add progress update: {str(e)}'
        }), 500

@job_management_bp.route('/jobs/<int:job_id>/progress', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_job_progress(job_id):
    """Get progress updates for a job"""
    try:
        user_id = get_jwt_identity()
        
        # Check job access
        job = Job.query.filter(
            Job.id == job_id,
            (Job.customer_id == user_id) | (Job.craftsman_id == user_id)
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found'
            }), 404
        
        progress_updates = ProgressManager.get_job_progress(job_id)
        current_progress = ProgressManager.calculate_job_progress(job_id)
        
        return jsonify({
            'success': True,
            'data': {
                'progress_updates': [update.to_dict() for update in progress_updates],
                'current_progress': current_progress
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get progress: {str(e)}'
        }), 500

# Warranty Management Routes

@job_management_bp.route('/warranties', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_warranties():
    """Get active warranties for user"""
    try:
        user_id = get_jwt_identity()
        user_type = request.args.get('user_type', 'customer')
        
        warranties = WarrantyManager.get_active_warranties(user_id, user_type)
        
        return jsonify({
            'success': True,
            'data': [job.to_dict() for job in warranties]
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get warranties: {str(e)}'
        }), 500

@job_management_bp.route('/jobs/<int:job_id>/warranty-claim', methods=['POST'])
@rate_limit(requests_per_minute=10)
@require_auth
def create_warranty_claim(job_id):
    """Create warranty claim"""
    try:
        user_id = get_jwt_identity()
        schema = WarrantyClaimSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # Check if user is customer for this job
        job = Job.query.filter(
            Job.id == job_id,
            Job.customer_id == user_id
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found or access denied'
            }), 404
        
        claim = WarrantyManager.create_warranty_claim(job_id, user_id, data)
        
        return jsonify({
            'success': True,
            'data': claim.to_dict()
        }), 201
        
    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to create warranty claim: {str(e)}'
        }), 500

@job_management_bp.route('/warranty-claims', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_warranty_claims():
    """Get warranty claims for user"""
    try:
        user_id = get_jwt_identity()
        user_type = request.args.get('user_type', 'customer')
        
        claims = WarrantyManager.get_warranty_claims(user_id, user_type)
        
        return jsonify({
            'success': True,
            'data': [claim.to_dict() for claim in claims]
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get warranty claims: {str(e)}'
        }), 500

@job_management_bp.route('/warranty-claims/<int:claim_id>/process', methods=['PUT'])
@rate_limit(requests_per_minute=20)
@require_auth
def process_warranty_claim(claim_id):
    """Process warranty claim (craftsman response)"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        action = data.get('action')  # approve, reject, resolve
        response_data = data.get('response_data', {})
        
        if action not in ['approve', 'reject', 'resolve']:
            return jsonify({
                'success': False,
                'message': 'Invalid action'
            }), 400
        
        # Check if user is craftsman for this claim
        claim = WarrantyClaim.query.filter(
            WarrantyClaim.id == claim_id,
            WarrantyClaim.craftsman_id == user_id
        ).first()
        
        if not claim:
            return jsonify({
                'success': False,
                'message': 'Warranty claim not found or access denied'
            }), 404
        
        success = WarrantyManager.process_warranty_claim(claim_id, action, response_data)
        
        if success:
            updated_claim = WarrantyClaim.query.get(claim_id)
            return jsonify({
                'success': True,
                'data': updated_claim.to_dict()
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Failed to process warranty claim'
            }), 500
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to process warranty claim: {str(e)}'
        }), 500

# Emergency Service Routes

@job_management_bp.route('/emergency-services', methods=['POST'])
@rate_limit(requests_per_minute=5)  # Limited for emergency requests
@require_auth
def create_emergency_request():
    """Create emergency service request"""
    try:
        user_id = get_jwt_identity()
        schema = EmergencyServiceSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        emergency = EmergencyServiceManager.create_emergency_request(user_id, data)
        
        return jsonify({
            'success': True,
            'data': emergency.to_dict(),
            'message': 'Emergency request created. Nearby craftsmen will be notified.'
        }), 201
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to create emergency request: {str(e)}'
        }), 500

@job_management_bp.route('/emergency-services/nearby', methods=['GET'])
@rate_limit(requests_per_minute=30)
@require_auth
def get_nearby_emergencies():
    """Get nearby emergency requests for craftsman"""
    try:
        user_id = get_jwt_identity()
        max_distance = float(request.args.get('max_distance', 50))
        
        emergencies = EmergencyServiceManager.get_emergency_requests_nearby(user_id, max_distance)
        
        return jsonify({
            'success': True,
            'data': [emergency.to_dict() for emergency in emergencies]
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get nearby emergencies: {str(e)}'
        }), 500

@job_management_bp.route('/emergency-services/<int:emergency_id>/assign', methods=['PUT'])
@rate_limit(requests_per_minute=20)
@require_auth
def assign_emergency_service(emergency_id):
    """Assign emergency service to craftsman"""
    try:
        user_id = get_jwt_identity()
        
        success = EmergencyServiceManager.assign_emergency_service(emergency_id, user_id)
        
        if success:
            emergency = EmergencyService.query.get(emergency_id)
            return jsonify({
                'success': True,
                'data': emergency.to_dict(),
                'message': 'Emergency service assigned successfully'
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Failed to assign emergency service'
            }), 400
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to assign emergency service: {str(e)}'
        }), 500

@job_management_bp.route('/emergency-services/<int:emergency_id>/status', methods=['PUT'])
@rate_limit(requests_per_minute=30)
@require_auth
def update_emergency_status(emergency_id):
    """Update emergency service status"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        status = data.get('status')
        location_data = data.get('location_data')
        
        if not status:
            return jsonify({
                'success': False,
                'message': 'Status is required'
            }), 400
        
        # Check if user is craftsman for this emergency
        emergency = EmergencyService.query.filter(
            EmergencyService.id == emergency_id,
            EmergencyService.craftsman_id == user_id
        ).first()
        
        if not emergency:
            return jsonify({
                'success': False,
                'message': 'Emergency service not found or access denied'
            }), 404
        
        success = EmergencyServiceManager.update_emergency_status(emergency_id, status, location_data)
        
        if success:
            updated_emergency = EmergencyService.query.get(emergency_id)
            return jsonify({
                'success': True,
                'data': updated_emergency.to_dict()
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Failed to update emergency status'
            }), 500
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to update emergency status: {str(e)}'
        }), 500

# Analytics and Reporting Routes

@job_management_bp.route('/analytics/performance', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_performance_metrics():
    """Get job performance metrics"""
    try:
        user_id = get_jwt_identity()
        user_type = request.args.get('user_type', 'customer')
        days = int(request.args.get('days', 30))
        
        metrics = JobAnalytics.get_job_performance_metrics(user_id, user_type, days)
        
        return jsonify({
            'success': True,
            'data': metrics
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get performance metrics: {str(e)}'
        }), 500

@job_management_bp.route('/jobs/<int:job_id>/cost-breakdown', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_cost_breakdown(job_id):
    """Get detailed cost breakdown for job"""
    try:
        user_id = get_jwt_identity()
        
        # Check job access
        job = Job.query.filter(
            Job.id == job_id,
            (Job.customer_id == user_id) | (Job.craftsman_id == user_id)
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found'
            }), 404
        
        breakdown = JobAnalytics.get_cost_breakdown(job_id)
        
        return jsonify({
            'success': True,
            'data': breakdown
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get cost breakdown: {str(e)}'
        }), 500

@job_management_bp.route('/jobs/<int:job_id>/timeline', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_job_timeline(job_id):
    """Get job timeline with all events"""
    try:
        user_id = get_jwt_identity()
        
        # Check job access
        job = Job.query.filter(
            Job.id == job_id,
            (Job.customer_id == user_id) | (Job.craftsman_id == user_id)
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found'
            }), 404
        
        timeline = JobTracker.get_job_timeline(job_id)
        
        return jsonify({
            'success': True,
            'data': timeline
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get job timeline: {str(e)}'
        }), 500

# Utility Routes

@job_management_bp.route('/constants', methods=['GET'])
@rate_limit(requests_per_minute=60)
def get_job_constants():
    """Get job management constants"""
    try:
        return jsonify({
            'success': True,
            'data': {
                'job_statuses': [status.value for status in JobStatus],
                'job_priorities': [priority.value for priority in JobPriority],
                'material_statuses': [status.value for status in MaterialStatus],
                'time_entry_types': [entry_type.value for entry_type in TimeEntryType],
                'material_units': JobConstants.MATERIAL_UNITS,
                'emergency_response_targets': JobConstants.EMERGENCY_RESPONSE_TARGETS,
                'default_warranty_periods': JobConstants.DEFAULT_WARRANTY_PERIODS,
                'time_entry_descriptions': {k.value: v for k, v in JobConstants.TIME_ENTRY_DESCRIPTIONS.items()},
                'priority_descriptions': {k.value: v for k, v in JobConstants.PRIORITY_DESCRIPTIONS.items()}
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get constants: {str(e)}'
        }), 500

@job_management_bp.route('/emergency-services/statistics', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_emergency_statistics():
    """Get emergency service statistics"""
    try:
        stats = EmergencyServiceManager.get_emergency_statistics()
        
        return jsonify({
            'success': True,
            'data': stats
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get emergency statistics: {str(e)}'
        }), 500