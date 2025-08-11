from datetime import datetime, timedelta
from typing import List, Dict, Optional, Any
from sqlalchemy import and_, or_, func, desc, asc
from sqlalchemy.orm import joinedload
from app import db
from app.models.job import Job, JobMaterial, TimeEntry, JobProgressUpdate, WarrantyClaim, EmergencyService
from app.models.job import JobStatus, JobPriority, MaterialStatus, TimeEntryType, WarrantyStatus
from app.models.user import User
from app.models.quote import Quote
import json

class JobTracker:
    """Comprehensive job tracking and management"""
    
    @staticmethod
    def create_job_from_quote(quote_id: int, additional_data: Dict = None) -> Optional[Job]:
        """Create a job from an accepted quote"""
        try:
            quote = Quote.query.get(quote_id)
            if not quote or quote.status != 'ACCEPTED':
                return None
            
            job_data = {
                'title': quote.title,
                'description': quote.description,
                'customer_id': quote.customer_id,
                'craftsman_id': quote.craftsman_id,
                'quote_id': quote_id,
                'category': quote.category,
                'estimated_cost': quote.final_price,
                'warranty_period_months': 12,  # Default warranty
                'status': JobStatus.ACCEPTED
            }
            
            if additional_data:
                job_data.update(additional_data)
            
            job = Job(**job_data)
            db.session.add(job)
            db.session.commit()
            
            return job
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def update_job_status(job_id: int, new_status: JobStatus, notes: str = None) -> bool:
        """Update job status with automatic timestamp tracking"""
        try:
            job = Job.query.get(job_id)
            if not job:
                return False
            
            old_status = job.status
            job.status = new_status
            job.updated_at = datetime.utcnow()
            
            # Update specific timestamps based on status
            if new_status == JobStatus.IN_PROGRESS and not job.started_at:
                job.started_at = datetime.utcnow()
                job.actual_start = datetime.utcnow()
            elif new_status == JobStatus.COMPLETED and not job.completed_at:
                job.completed_at = datetime.utcnow()
                job.actual_end = datetime.utcnow()
                job.completion_percentage = 100.0
                # Start warranty period
                job.start_warranty()
            
            if notes:
                job.notes = f"{job.notes or ''}\n[{datetime.utcnow().strftime('%Y-%m-%d %H:%M')}] Status changed from {old_status.value} to {new_status.value}: {notes}"
            
            db.session.commit()
            return True
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def get_job_timeline(job_id: int) -> List[Dict]:
        """Get comprehensive job timeline with all events"""
        try:
            job = Job.query.options(
                joinedload(Job.time_entries),
                joinedload(Job.progress_updates),
                joinedload(Job.materials)
            ).get(job_id)
            
            if not job:
                return []
            
            timeline = []
            
            # Job creation
            timeline.append({
                'type': 'job_created',
                'timestamp': job.created_at,
                'title': 'İş Oluşturuldu',
                'description': f'İş talebi oluşturuldu: {job.title}',
                'icon': 'create'
            })
            
            # Job acceptance
            if job.accepted_at:
                timeline.append({
                    'type': 'job_accepted',
                    'timestamp': job.accepted_at,
                    'title': 'İş Kabul Edildi',
                    'description': 'Usta tarafından kabul edildi',
                    'icon': 'check'
                })
            
            # Job start
            if job.started_at:
                timeline.append({
                    'type': 'job_started',
                    'timestamp': job.started_at,
                    'title': 'İş Başladı',
                    'description': 'Çalışma başlatıldı',
                    'icon': 'play'
                })
            
            # Progress updates
            for update in job.progress_updates:
                timeline.append({
                    'type': 'progress_update',
                    'timestamp': update.created_at,
                    'title': update.title,
                    'description': update.description,
                    'completion_percentage': update.completion_percentage,
                    'images': update.images,
                    'icon': 'progress'
                })
            
            # Material events
            for material in job.materials:
                if material.ordered_at:
                    timeline.append({
                        'type': 'material_ordered',
                        'timestamp': material.ordered_at,
                        'title': 'Malzeme Sipariş Edildi',
                        'description': f'{material.name} sipariş edildi',
                        'icon': 'shopping'
                    })
                
                if material.delivered_at:
                    timeline.append({
                        'type': 'material_delivered',
                        'timestamp': material.delivered_at,
                        'title': 'Malzeme Teslim Alındı',
                        'description': f'{material.name} teslim alındı',
                        'icon': 'delivery'
                    })
            
            # Job completion
            if job.completed_at:
                timeline.append({
                    'type': 'job_completed',
                    'timestamp': job.completed_at,
                    'title': 'İş Tamamlandı',
                    'description': 'Çalışma tamamlandı ve garanti başladı',
                    'icon': 'done'
                })
            
            # Sort by timestamp
            timeline.sort(key=lambda x: x['timestamp'])
            
            return timeline
            
        except Exception as e:
            raise e
    
    @staticmethod
    def get_jobs_by_status(status: JobStatus, user_id: int = None, user_type: str = None) -> List[Job]:
        """Get jobs by status, optionally filtered by user"""
        try:
            query = Job.query.filter(Job.status == status)
            
            if user_id and user_type:
                if user_type == 'customer':
                    query = query.filter(Job.customer_id == user_id)
                elif user_type == 'craftsman':
                    query = query.filter(Job.craftsman_id == user_id)
            
            return query.order_by(desc(Job.created_at)).all()
            
        except Exception as e:
            raise e
    
    @staticmethod
    def get_overdue_jobs() -> List[Job]:
        """Get all overdue jobs"""
        try:
            return Job.query.filter(
                and_(
                    Job.scheduled_end < datetime.utcnow(),
                    Job.status.notin_([JobStatus.COMPLETED, JobStatus.CANCELLED])
                )
            ).order_by(asc(Job.scheduled_end)).all()
            
        except Exception as e:
            raise e

class MaterialManager:
    """Material management for jobs"""
    
    @staticmethod
    def add_material(job_id: int, material_data: Dict) -> JobMaterial:
        """Add material to job"""
        try:
            material = JobMaterial(
                job_id=job_id,
                **material_data
            )
            
            # Calculate total cost
            if material.unit_cost and material.quantity:
                material.total_cost = material.unit_cost * material.quantity
            
            db.session.add(material)
            db.session.commit()
            
            return material
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def update_material_status(material_id: int, status: MaterialStatus, notes: str = None) -> bool:
        """Update material status"""
        try:
            material = JobMaterial.query.get(material_id)
            if not material:
                return False
            
            material.status = status
            material.updated_at = datetime.utcnow()
            
            # Update specific timestamps
            if status == MaterialStatus.ORDERED:
                material.ordered_at = datetime.utcnow()
            elif status == MaterialStatus.DELIVERED:
                material.delivered_at = datetime.utcnow()
            elif status == MaterialStatus.USED:
                material.used_at = datetime.utcnow()
            
            if notes:
                material.notes = f"{material.notes or ''}\n[{datetime.utcnow().strftime('%Y-%m-%d %H:%M')}] {notes}"
            
            db.session.commit()
            return True
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def get_job_materials_cost(job_id: int) -> float:
        """Calculate total materials cost for a job"""
        try:
            materials = JobMaterial.query.filter(JobMaterial.job_id == job_id).all()
            return sum(material.total_cost or 0 for material in materials)
            
        except Exception as e:
            raise e
    
    @staticmethod
    def get_materials_by_status(status: MaterialStatus, job_id: int = None) -> List[JobMaterial]:
        """Get materials by status"""
        try:
            query = JobMaterial.query.filter(JobMaterial.status == status)
            
            if job_id:
                query = query.filter(JobMaterial.job_id == job_id)
            
            return query.order_by(desc(JobMaterial.created_at)).all()
            
        except Exception as e:
            raise e

class TimeTracker:
    """Time tracking for job work"""
    
    @staticmethod
    def start_time_entry(job_id: int, craftsman_id: int, entry_type: TimeEntryType = TimeEntryType.WORK, 
                        description: str = None, location: str = None) -> TimeEntry:
        """Start a new time entry"""
        try:
            # Check if there's an active entry for this craftsman
            active_entry = TimeEntry.query.filter(
                and_(
                    TimeEntry.craftsman_id == craftsman_id,
                    TimeEntry.end_time.is_(None)
                )
            ).first()
            
            if active_entry:
                raise ValueError("Active time entry already exists. Please end the current entry first.")
            
            entry = TimeEntry(
                job_id=job_id,
                craftsman_id=craftsman_id,
                start_time=datetime.utcnow(),
                entry_type=entry_type,
                description=description,
                location=location
            )
            
            db.session.add(entry)
            db.session.commit()
            
            return entry
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def end_time_entry(entry_id: int, notes: str = None, images: List[str] = None) -> TimeEntry:
        """End a time entry"""
        try:
            entry = TimeEntry.query.get(entry_id)
            if not entry:
                raise ValueError("Time entry not found")
            
            if entry.end_time:
                raise ValueError("Time entry already ended")
            
            entry.end_time = datetime.utcnow()
            entry.calculate_duration()
            
            if notes:
                entry.notes = notes
            
            if images:
                entry.images = images
            
            db.session.commit()
            return entry
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def get_job_time_summary(job_id: int) -> Dict:
        """Get time summary for a job"""
        try:
            entries = TimeEntry.query.filter(TimeEntry.job_id == job_id).all()
            
            total_minutes = sum(entry.duration_minutes or 0 for entry in entries)
            billable_minutes = sum(entry.billable_duration or entry.duration_minutes or 0 
                                 for entry in entries if entry.is_billable)
            total_cost = sum(entry.total_cost or 0 for entry in entries if entry.is_billable)
            
            # Group by entry type
            by_type = {}
            for entry in entries:
                entry_type = entry.entry_type.value
                if entry_type not in by_type:
                    by_type[entry_type] = {
                        'total_minutes': 0,
                        'billable_minutes': 0,
                        'total_cost': 0,
                        'entries_count': 0
                    }
                
                by_type[entry_type]['total_minutes'] += entry.duration_minutes or 0
                by_type[entry_type]['entries_count'] += 1
                
                if entry.is_billable:
                    by_type[entry_type]['billable_minutes'] += entry.billable_duration or entry.duration_minutes or 0
                    by_type[entry_type]['total_cost'] += entry.total_cost or 0
            
            return {
                'total_minutes': total_minutes,
                'total_hours': round(total_minutes / 60, 2),
                'billable_minutes': billable_minutes,
                'billable_hours': round(billable_minutes / 60, 2),
                'total_cost': total_cost,
                'entries_count': len(entries),
                'by_type': by_type
            }
            
        except Exception as e:
            raise e
    
    @staticmethod
    def get_craftsman_time_summary(craftsman_id: int, start_date: datetime = None, 
                                 end_date: datetime = None) -> Dict:
        """Get time summary for a craftsman"""
        try:
            query = TimeEntry.query.filter(TimeEntry.craftsman_id == craftsman_id)
            
            if start_date:
                query = query.filter(TimeEntry.start_time >= start_date)
            if end_date:
                query = query.filter(TimeEntry.start_time <= end_date)
            
            entries = query.all()
            
            total_minutes = sum(entry.duration_minutes or 0 for entry in entries)
            billable_minutes = sum(entry.billable_duration or entry.duration_minutes or 0 
                                 for entry in entries if entry.is_billable)
            total_earnings = sum(entry.total_cost or 0 for entry in entries if entry.is_billable)
            
            # Group by job
            by_job = {}
            for entry in entries:
                job_id = entry.job_id
                if job_id not in by_job:
                    by_job[job_id] = {
                        'job_title': entry.job.title if entry.job else f'Job {job_id}',
                        'total_minutes': 0,
                        'billable_minutes': 0,
                        'total_cost': 0,
                        'entries_count': 0
                    }
                
                by_job[job_id]['total_minutes'] += entry.duration_minutes or 0
                by_job[job_id]['entries_count'] += 1
                
                if entry.is_billable:
                    by_job[job_id]['billable_minutes'] += entry.billable_duration or entry.duration_minutes or 0
                    by_job[job_id]['total_cost'] += entry.total_cost or 0
            
            return {
                'total_minutes': total_minutes,
                'total_hours': round(total_minutes / 60, 2),
                'billable_minutes': billable_minutes,
                'billable_hours': round(billable_minutes / 60, 2),
                'total_earnings': total_earnings,
                'entries_count': len(entries),
                'jobs_count': len(by_job),
                'by_job': by_job
            }
            
        except Exception as e:
            raise e

class ProgressManager:
    """Job progress tracking and updates"""
    
    @staticmethod
    def add_progress_update(job_id: int, craftsman_id: int, update_data: Dict) -> JobProgressUpdate:
        """Add progress update to job"""
        try:
            update = JobProgressUpdate(
                job_id=job_id,
                craftsman_id=craftsman_id,
                **update_data
            )
            
            db.session.add(update)
            
            # Update job completion percentage
            job = Job.query.get(job_id)
            if job and 'completion_percentage' in update_data:
                job.completion_percentage = update_data['completion_percentage']
                job.updated_at = datetime.utcnow()
            
            db.session.commit()
            return update
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def get_job_progress(job_id: int) -> List[JobProgressUpdate]:
        """Get all progress updates for a job"""
        try:
            return JobProgressUpdate.query.filter(
                JobProgressUpdate.job_id == job_id
            ).order_by(desc(JobProgressUpdate.created_at)).all()
            
        except Exception as e:
            raise e
    
    @staticmethod
    def calculate_job_progress(job_id: int) -> float:
        """Calculate overall job progress based on various factors"""
        try:
            job = Job.query.get(job_id)
            if not job:
                return 0.0
            
            # If manually set, use that
            if job.completion_percentage is not None:
                return job.completion_percentage
            
            # Calculate based on time entries and milestones
            progress = 0.0
            
            # Time-based progress (if estimated duration exists)
            if job.estimated_duration and job.started_at:
                elapsed_hours = (datetime.utcnow() - job.started_at).total_seconds() / 3600
                time_progress = min(elapsed_hours / job.estimated_duration * 100, 100)
                progress += time_progress * 0.4  # 40% weight
            
            # Material-based progress
            materials = JobMaterial.query.filter(JobMaterial.job_id == job_id).all()
            if materials:
                used_materials = len([m for m in materials if m.status == MaterialStatus.USED])
                material_progress = (used_materials / len(materials)) * 100
                progress += material_progress * 0.3  # 30% weight
            
            # Status-based progress
            status_progress = {
                JobStatus.PENDING: 0,
                JobStatus.ACCEPTED: 10,
                JobStatus.IN_PROGRESS: 50,
                JobStatus.QUALITY_CHECK: 90,
                JobStatus.COMPLETED: 100
            }.get(job.status, 0)
            
            progress += status_progress * 0.3  # 30% weight
            
            return min(progress, 100.0)
            
        except Exception as e:
            raise e

class WarrantyManager:
    """Warranty management system"""
    
    @staticmethod
    def create_warranty_claim(job_id: int, customer_id: int, claim_data: Dict) -> WarrantyClaim:
        """Create a new warranty claim"""
        try:
            job = Job.query.get(job_id)
            if not job:
                raise ValueError("Job not found")
            
            if not job.warranty_end_date or datetime.utcnow() > job.warranty_end_date:
                raise ValueError("Warranty period has expired")
            
            claim = WarrantyClaim(
                job_id=job_id,
                customer_id=customer_id,
                craftsman_id=job.craftsman_id,
                **claim_data
            )
            
            db.session.add(claim)
            db.session.commit()
            
            return claim
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def process_warranty_claim(claim_id: int, action: str, response_data: Dict = None) -> bool:
        """Process warranty claim (approve, reject, resolve)"""
        try:
            claim = WarrantyClaim.query.get(claim_id)
            if not claim:
                return False
            
            if action == 'approve':
                claim.status = 'approved'
                claim.reviewed_at = datetime.utcnow()
                if response_data and 'craftsman_response' in response_data:
                    claim.craftsman_response = response_data['craftsman_response']
            
            elif action == 'reject':
                claim.status = 'rejected'
                claim.reviewed_at = datetime.utcnow()
                if response_data and 'craftsman_response' in response_data:
                    claim.craftsman_response = response_data['craftsman_response']
            
            elif action == 'resolve':
                claim.status = 'resolved'
                claim.resolved_at = datetime.utcnow()
                if response_data:
                    if 'resolution' in response_data:
                        claim.resolution = response_data['resolution']
                    if 'resolution_cost' in response_data:
                        claim.resolution_cost = response_data['resolution_cost']
            
            db.session.commit()
            return True
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def get_active_warranties(user_id: int, user_type: str) -> List[Job]:
        """Get jobs with active warranties"""
        try:
            current_time = datetime.utcnow()
            
            query = Job.query.filter(
                and_(
                    Job.warranty_start_date.isnot(None),
                    Job.warranty_end_date > current_time,
                    Job.status == JobStatus.COMPLETED
                )
            )
            
            if user_type == 'customer':
                query = query.filter(Job.customer_id == user_id)
            elif user_type == 'craftsman':
                query = query.filter(Job.craftsman_id == user_id)
            
            return query.order_by(desc(Job.warranty_end_date)).all()
            
        except Exception as e:
            raise e
    
    @staticmethod
    def get_warranty_claims(user_id: int, user_type: str) -> List[WarrantyClaim]:
        """Get warranty claims for user"""
        try:
            if user_type == 'customer':
                query = WarrantyClaim.query.filter(WarrantyClaim.customer_id == user_id)
            elif user_type == 'craftsman':
                query = WarrantyClaim.query.filter(WarrantyClaim.craftsman_id == user_id)
            else:
                return []
            
            return query.order_by(desc(WarrantyClaim.claimed_at)).all()
            
        except Exception as e:
            raise e

class EmergencyServiceManager:
    """Emergency service management"""
    
    @staticmethod
    def create_emergency_request(customer_id: int, emergency_data: Dict) -> EmergencyService:
        """Create emergency service request"""
        try:
            emergency = EmergencyService(
                customer_id=customer_id,
                **emergency_data
            )
            
            db.session.add(emergency)
            db.session.commit()
            
            # TODO: Notify available craftsmen in the area
            # EmergencyServiceManager._notify_nearby_craftsmen(emergency)
            
            return emergency
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def assign_emergency_service(emergency_id: int, craftsman_id: int) -> bool:
        """Assign emergency service to craftsman"""
        try:
            emergency = EmergencyService.query.get(emergency_id)
            if not emergency or emergency.status != 'requested':
                return False
            
            emergency.craftsman_id = craftsman_id
            emergency.status = 'assigned'
            emergency.assigned_at = datetime.utcnow()
            
            db.session.commit()
            
            # TODO: Notify customer and craftsman
            
            return True
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def update_emergency_status(emergency_id: int, status: str, location_data: Dict = None) -> bool:
        """Update emergency service status"""
        try:
            emergency = EmergencyService.query.get(emergency_id)
            if not emergency:
                return False
            
            emergency.status = status
            
            if status == 'en_route' and location_data:
                # Update craftsman location
                pass  # TODO: Implement real-time location tracking
            
            elif status == 'in_progress':
                emergency.arrived_at = datetime.utcnow()
            
            elif status == 'completed':
                emergency.completed_at = datetime.utcnow()
                
                # Create regular job if needed
                if emergency.severity >= 3:  # Convert to regular job for follow-up
                    job_data = {
                        'title': f"Follow-up: {emergency.title}",
                        'description': emergency.description,
                        'customer_id': emergency.customer_id,
                        'craftsman_id': emergency.craftsman_id,
                        'category': emergency.emergency_type,
                        'address': emergency.address,
                        'city': emergency.city,
                        'district': emergency.district,
                        'is_emergency': False,
                        'priority': JobPriority.HIGH
                    }
                    
                    job = Job(**job_data)
                    db.session.add(job)
                    emergency.job_id = job.id
            
            db.session.commit()
            return True
            
        except Exception as e:
            db.session.rollback()
            raise e
    
    @staticmethod
    def get_emergency_requests_nearby(craftsman_id: int, max_distance_km: float = 50) -> List[EmergencyService]:
        """Get emergency requests near craftsman"""
        try:
            # Get craftsman location
            craftsman = User.query.get(craftsman_id)
            if not craftsman or not hasattr(craftsman, 'latitude') or not craftsman.latitude:
                return []
            
            # Simple distance filter (for production, use PostGIS)
            lat_range = max_distance_km / 111.0
            lng_range = max_distance_km / (111.0 * abs(craftsman.latitude))
            
            emergencies = EmergencyService.query.filter(
                and_(
                    EmergencyService.status == 'requested',
                    EmergencyService.latitude.between(
                        craftsman.latitude - lat_range, 
                        craftsman.latitude + lat_range
                    ),
                    EmergencyService.longitude.between(
                        craftsman.longitude - lng_range, 
                        craftsman.longitude + lng_range
                    )
                )
            ).order_by(desc(EmergencyService.severity), asc(EmergencyService.requested_at)).all()
            
            return emergencies
            
        except Exception as e:
            raise e
    
    @staticmethod
    def get_emergency_statistics() -> Dict:
        """Get emergency service statistics"""
        try:
            current_time = datetime.utcnow()
            last_30_days = current_time - timedelta(days=30)
            
            # Total requests
            total_requests = EmergencyService.query.count()
            recent_requests = EmergencyService.query.filter(
                EmergencyService.requested_at >= last_30_days
            ).count()
            
            # Response times
            completed_emergencies = EmergencyService.query.filter(
                and_(
                    EmergencyService.status == 'completed',
                    EmergencyService.assigned_at.isnot(None)
                )
            ).all()
            
            response_times = [e.response_time_minutes for e in completed_emergencies if e.response_time_minutes]
            avg_response_time = sum(response_times) / len(response_times) if response_times else 0
            
            # By severity
            by_severity = {}
            for severity in range(1, 6):
                count = EmergencyService.query.filter(
                    and_(
                        EmergencyService.severity == severity,
                        EmergencyService.requested_at >= last_30_days
                    )
                ).count()
                by_severity[severity] = count
            
            return {
                'total_requests': total_requests,
                'recent_requests': recent_requests,
                'avg_response_time_minutes': round(avg_response_time, 1),
                'by_severity': by_severity,
                'completion_rate': len([e for e in completed_emergencies if e.requested_at >= last_30_days]) / max(recent_requests, 1) * 100
            }
            
        except Exception as e:
            raise e

class JobAnalytics:
    """Job analytics and reporting"""
    
    @staticmethod
    def get_job_performance_metrics(user_id: int, user_type: str, days: int = 30) -> Dict:
        """Get job performance metrics"""
        try:
            start_date = datetime.utcnow() - timedelta(days=days)
            
            if user_type == 'customer':
                jobs = Job.query.filter(
                    and_(
                        Job.customer_id == user_id,
                        Job.created_at >= start_date
                    )
                ).all()
            elif user_type == 'craftsman':
                jobs = Job.query.filter(
                    and_(
                        Job.craftsman_id == user_id,
                        Job.created_at >= start_date
                    )
                ).all()
            else:
                return {}
            
            if not jobs:
                return {
                    'total_jobs': 0,
                    'completed_jobs': 0,
                    'completion_rate': 0,
                    'avg_duration_days': 0,
                    'total_value': 0,
                    'avg_satisfaction': 0
                }
            
            completed_jobs = [j for j in jobs if j.status == JobStatus.COMPLETED]
            
            # Calculate durations
            durations = []
            for job in completed_jobs:
                if job.started_at and job.completed_at:
                    duration = (job.completed_at - job.started_at).days
                    durations.append(duration)
            
            avg_duration = sum(durations) / len(durations) if durations else 0
            
            # Calculate satisfaction
            satisfactions = [j.customer_satisfaction for j in completed_jobs if j.customer_satisfaction]
            avg_satisfaction = sum(satisfactions) / len(satisfactions) if satisfactions else 0
            
            # Calculate total value
            total_value = sum(j.final_cost or j.estimated_cost or 0 for j in completed_jobs)
            
            return {
                'total_jobs': len(jobs),
                'completed_jobs': len(completed_jobs),
                'completion_rate': (len(completed_jobs) / len(jobs)) * 100,
                'avg_duration_days': round(avg_duration, 1),
                'total_value': total_value,
                'avg_satisfaction': round(avg_satisfaction, 1),
                'jobs_by_status': {
                    status.value: len([j for j in jobs if j.status == status])
                    for status in JobStatus
                }
            }
            
        except Exception as e:
            raise e
    
    @staticmethod
    def get_cost_breakdown(job_id: int) -> Dict:
        """Get detailed cost breakdown for a job"""
        try:
            job = Job.query.options(
                joinedload(Job.materials),
                joinedload(Job.time_entries)
            ).get(job_id)
            
            if not job:
                return {}
            
            # Materials cost
            materials_cost = sum(m.total_cost or 0 for m in job.materials)
            
            # Labor cost from time entries
            labor_cost = sum(t.total_cost or 0 for t in job.time_entries if t.is_billable)
            
            # Additional costs
            additional_costs = job.additional_costs or 0
            
            total_cost = materials_cost + labor_cost + additional_costs
            
            return {
                'materials_cost': materials_cost,
                'labor_cost': labor_cost,
                'additional_costs': additional_costs,
                'total_cost': total_cost,
                'estimated_cost': job.estimated_cost,
                'final_cost': job.final_cost,
                'cost_variance': (total_cost - (job.estimated_cost or 0)) if job.estimated_cost else 0,
                'materials_breakdown': [m.to_dict() for m in job.materials],
                'time_breakdown': TimeTracker.get_job_time_summary(job_id)
            }
            
        except Exception as e:
            raise e

# Job management constants
class JobConstants:
    # Emergency response time targets (in minutes)
    EMERGENCY_RESPONSE_TARGETS = {
        5: 15,  # Critical - 15 minutes
        4: 30,  # High - 30 minutes
        3: 60,  # Medium - 1 hour
        2: 120, # Low - 2 hours
        1: 240  # Minimal - 4 hours
    }
    
    # Default warranty periods by category (in months)
    DEFAULT_WARRANTY_PERIODS = {
        'electrical': 24,
        'plumbing': 12,
        'hvac': 18,
        'carpentry': 6,
        'painting': 3,
        'cleaning': 1,
        'gardening': 1,
        'general': 6
    }
    
    # Material units
    MATERIAL_UNITS = [
        'piece', 'meter', 'kg', 'liter', 'square_meter', 'cubic_meter',
        'hour', 'day', 'box', 'bag', 'roll', 'bottle', 'can'
    ]
    
    # Time entry types descriptions
    TIME_ENTRY_DESCRIPTIONS = {
        TimeEntryType.WORK: 'Aktif çalışma zamanı',
        TimeEntryType.TRAVEL: 'Seyahat zamanı',
        TimeEntryType.BREAK: 'Mola zamanı',
        TimeEntryType.MATERIALS: 'Malzeme tedarik zamanı',
        TimeEntryType.CONSULTATION: 'Danışmanlık zamanı'
    }
    
    # Job priority descriptions
    PRIORITY_DESCRIPTIONS = {
        JobPriority.LOW: 'Düşük öncelik',
        JobPriority.NORMAL: 'Normal öncelik',
        JobPriority.HIGH: 'Yüksek öncelik',
        JobPriority.URGENT: 'Acil',
        JobPriority.EMERGENCY: 'Acil servis'
    }