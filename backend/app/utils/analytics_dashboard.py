from datetime import datetime, timedelta
from typing import List, Dict, Optional, Any, Tuple
from sqlalchemy import and_, or_, func, desc, asc, text, case
from sqlalchemy.orm import joinedload
from app import db
from app.models.user import User
from app.models.quote import Quote, QuoteStatus
from app.models.job import Job, JobStatus, JobPriority
from app.models.message import Message
from app.models.review import Review
import json
from decimal import Decimal

class CraftsmanDashboard:
    """Comprehensive craftsman dashboard analytics"""
    
    @staticmethod
    def get_craftsman_overview(craftsman_id: int, days: int = 30) -> Dict[str, Any]:
        """Get comprehensive craftsman overview"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Basic metrics
        total_quotes = Quote.query.filter(
            Quote.craftsman_id == craftsman_id,
            Quote.created_at >= start_date
        ).count()
        
        accepted_quotes = Quote.query.filter(
            Quote.craftsman_id == craftsman_id,
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        ).count()
        
        completed_jobs = Job.query.filter(
            Job.craftsman_id == craftsman_id,
            Job.status == JobStatus.COMPLETED,
            Job.completed_at >= start_date
        ).count()
        
        # Revenue metrics
        revenue_query = db.session.query(func.sum(Quote.final_price)).filter(
            Quote.craftsman_id == craftsman_id,
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        ).scalar()
        total_revenue = float(revenue_query or 0)
        
        # Average metrics
        avg_quote_value = db.session.query(func.avg(Quote.final_price)).filter(
            Quote.craftsman_id == craftsman_id,
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        ).scalar()
        
        # Response time
        response_times = db.session.query(
            func.extract('epoch', Quote.updated_at - Quote.created_at)
        ).filter(
            Quote.craftsman_id == craftsman_id,
            Quote.status != QuoteStatus.PENDING,
            Quote.created_at >= start_date
        ).all()
        
        avg_response_time = sum(rt[0] for rt in response_times) / len(response_times) if response_times else 0
        
        # Customer satisfaction
        avg_rating = db.session.query(func.avg(Review.rating)).filter(
            Review.craftsman_id == craftsman_id,
            Review.created_at >= start_date
        ).scalar()
        
        return {
            'total_quotes': total_quotes,
            'accepted_quotes': accepted_quotes,
            'completed_jobs': completed_jobs,
            'acceptance_rate': (accepted_quotes / total_quotes * 100) if total_quotes > 0 else 0,
            'total_revenue': total_revenue,
            'avg_quote_value': float(avg_quote_value or 0),
            'avg_response_time_hours': avg_response_time / 3600 if avg_response_time else 0,
            'avg_rating': float(avg_rating or 0),
            'period_days': days
        }
    
    @staticmethod
    def get_craftsman_performance_trends(craftsman_id: int, days: int = 90) -> Dict[str, List]:
        """Get performance trends over time"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Daily metrics
        daily_stats = db.session.query(
            func.date(Quote.created_at).label('date'),
            func.count(Quote.id).label('quotes_count'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, 1)], else_=0)).label('accepted_count'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=0)).label('revenue')
        ).filter(
            Quote.craftsman_id == craftsman_id,
            Quote.created_at >= start_date
        ).group_by(func.date(Quote.created_at)).all()
        
        # Format for frontend
        dates = []
        quotes = []
        accepted = []
        revenue = []
        
        for stat in daily_stats:
            dates.append(stat.date.strftime('%Y-%m-%d'))
            quotes.append(stat.quotes_count)
            accepted.append(stat.accepted_count)
            revenue.append(float(stat.revenue or 0))
        
        return {
            'dates': dates,
            'quotes': quotes,
            'accepted_quotes': accepted,
            'daily_revenue': revenue
        }
    
    @staticmethod
    def get_craftsman_top_categories(craftsman_id: int, days: int = 30) -> List[Dict]:
        """Get top performing categories for craftsman"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        category_stats = db.session.query(
            Quote.category,
            func.count(Quote.id).label('total_quotes'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, 1)], else_=0)).label('accepted_quotes'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=0)).label('revenue'),
            func.avg(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=None)).label('avg_price')
        ).filter(
            Quote.craftsman_id == craftsman_id,
            Quote.created_at >= start_date
        ).group_by(Quote.category).order_by(desc('revenue')).limit(10).all()
        
        return [
            {
                'category': stat.category,
                'total_quotes': stat.total_quotes,
                'accepted_quotes': stat.accepted_quotes,
                'revenue': float(stat.revenue or 0),
                'avg_price': float(stat.avg_price or 0),
                'acceptance_rate': (stat.accepted_quotes / stat.total_quotes * 100) if stat.total_quotes > 0 else 0
            }
            for stat in category_stats
        ]
    
    @staticmethod
    def get_craftsman_recent_activity(craftsman_id: int, limit: int = 20) -> List[Dict]:
        """Get recent activity for craftsman"""
        # Recent quotes
        recent_quotes = Quote.query.filter(
            Quote.craftsman_id == craftsman_id
        ).order_by(desc(Quote.updated_at)).limit(limit).all()
        
        # Recent jobs
        recent_jobs = Job.query.filter(
            Job.craftsman_id == craftsman_id
        ).order_by(desc(Job.updated_at)).limit(limit).all()
        
        # Recent messages
        recent_messages = Message.query.filter(
            or_(Message.sender_id == craftsman_id, Message.receiver_id == craftsman_id)
        ).order_by(desc(Message.created_at)).limit(limit).all()
        
        activities = []
        
        # Add quotes
        for quote in recent_quotes:
            activities.append({
                'type': 'quote',
                'id': quote.id,
                'title': f'Teklif #{quote.id}',
                'description': quote.category,
                'status': quote.status.value,
                'amount': float(quote.final_price or 0),
                'date': quote.updated_at.isoformat(),
                'customer_name': f"{quote.customer.first_name} {quote.customer.last_name}" if quote.customer else 'N/A'
            })
        
        # Add jobs
        for job in recent_jobs:
            activities.append({
                'type': 'job',
                'id': job.id,
                'title': job.title,
                'description': job.category,
                'status': job.status.value,
                'amount': float(job.final_cost or 0),
                'date': job.updated_at.isoformat(),
                'customer_name': f"{job.customer.first_name} {job.customer.last_name}" if job.customer else 'N/A'
            })
        
        # Add messages
        for message in recent_messages:
            activities.append({
                'type': 'message',
                'id': message.id,
                'title': 'Yeni Mesaj',
                'description': message.content[:50] + '...' if len(message.content) > 50 else message.content,
                'status': 'new' if message.receiver_id == craftsman_id and not message.is_read else 'sent',
                'date': message.created_at.isoformat(),
                'customer_name': f"{message.sender.first_name} {message.sender.last_name}" if message.sender_id != craftsman_id else f"{message.receiver.first_name} {message.receiver.last_name}"
            })
        
        # Sort by date and return limited results
        activities.sort(key=lambda x: x['date'], reverse=True)
        return activities[:limit]

class CustomerHistoryAnalytics:
    """Customer history and behavior analytics"""
    
    @staticmethod
    def get_customer_overview(customer_id: int, days: int = 30) -> Dict[str, Any]:
        """Get comprehensive customer overview"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Basic metrics
        total_requests = Quote.query.filter(
            Quote.customer_id == customer_id,
            Quote.created_at >= start_date
        ).count()
        
        completed_jobs = Job.query.filter(
            Job.customer_id == customer_id,
            Job.status == JobStatus.COMPLETED,
            Job.completed_at >= start_date
        ).count()
        
        # Spending metrics
        total_spent = db.session.query(func.sum(Quote.final_price)).filter(
            Quote.customer_id == customer_id,
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        ).scalar()
        
        # Average metrics
        avg_job_value = db.session.query(func.avg(Quote.final_price)).filter(
            Quote.customer_id == customer_id,
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        ).scalar()
        
        # Satisfaction metrics
        avg_rating_given = db.session.query(func.avg(Review.rating)).filter(
            Review.customer_id == customer_id,
            Review.created_at >= start_date
        ).scalar()
        
        return {
            'total_requests': total_requests,
            'completed_jobs': completed_jobs,
            'total_spent': float(total_spent or 0),
            'avg_job_value': float(avg_job_value or 0),
            'avg_rating_given': float(avg_rating_given or 0),
            'period_days': days
        }
    
    @staticmethod
    def get_customer_spending_trends(customer_id: int, days: int = 90) -> Dict[str, List]:
        """Get customer spending trends"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Monthly spending
        monthly_stats = db.session.query(
            func.date_trunc('month', Quote.created_at).label('month'),
            func.sum(Quote.final_price).label('total_spent'),
            func.count(Quote.id).label('jobs_count')
        ).filter(
            Quote.customer_id == customer_id,
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        ).group_by(func.date_trunc('month', Quote.created_at)).all()
        
        months = []
        spending = []
        job_counts = []
        
        for stat in monthly_stats:
            months.append(stat.month.strftime('%Y-%m'))
            spending.append(float(stat.total_spent or 0))
            job_counts.append(stat.jobs_count)
        
        return {
            'months': months,
            'spending': spending,
            'job_counts': job_counts
        }
    
    @staticmethod
    def get_customer_preferred_categories(customer_id: int, days: int = 365) -> List[Dict]:
        """Get customer's preferred job categories"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        category_stats = db.session.query(
            Quote.category,
            func.count(Quote.id).label('total_requests'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, 1)], else_=0)).label('accepted_requests'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=0)).label('total_spent'),
            func.avg(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=None)).label('avg_spent')
        ).filter(
            Quote.customer_id == customer_id,
            Quote.created_at >= start_date
        ).group_by(Quote.category).order_by(desc('total_spent')).all()
        
        return [
            {
                'category': stat.category,
                'total_requests': stat.total_requests,
                'accepted_requests': stat.accepted_requests,
                'total_spent': float(stat.total_spent or 0),
                'avg_spent': float(stat.avg_spent or 0)
            }
            for stat in category_stats
        ]

class TrendAnalytics:
    """Platform-wide trend analysis"""
    
    @staticmethod
    def get_platform_trends(days: int = 30) -> Dict[str, Any]:
        """Get overall platform trends"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # User growth
        new_customers = User.query.filter(
            User.user_type == 'customer',
            User.created_at >= start_date
        ).count()
        
        new_craftsmen = User.query.filter(
            User.user_type == 'craftsman',
            User.created_at >= start_date
        ).count()
        
        # Activity metrics
        total_quotes = Quote.query.filter(Quote.created_at >= start_date).count()
        total_jobs = Job.query.filter(Job.created_at >= start_date).count()
        total_messages = Message.query.filter(Message.created_at >= start_date).count()
        
        # Revenue metrics
        platform_revenue = db.session.query(func.sum(Quote.final_price)).filter(
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        ).scalar()
        
        return {
            'new_customers': new_customers,
            'new_craftsmen': new_craftsmen,
            'total_quotes': total_quotes,
            'total_jobs': total_jobs,
            'total_messages': total_messages,
            'platform_revenue': float(platform_revenue or 0),
            'period_days': days
        }
    
    @staticmethod
    def get_category_trends(days: int = 30) -> List[Dict]:
        """Get trending categories"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        category_trends = db.session.query(
            Quote.category,
            func.count(Quote.id).label('quote_count'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, 1)], else_=0)).label('accepted_count'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=0)).label('revenue'),
            func.avg(Quote.final_price).label('avg_price')
        ).filter(
            Quote.created_at >= start_date
        ).group_by(Quote.category).order_by(desc('quote_count')).all()
        
        return [
            {
                'category': trend.category,
                'quote_count': trend.quote_count,
                'accepted_count': trend.accepted_count,
                'revenue': float(trend.revenue or 0),
                'avg_price': float(trend.avg_price or 0),
                'acceptance_rate': (trend.accepted_count / trend.quote_count * 100) if trend.quote_count > 0 else 0
            }
            for trend in category_trends
        ]
    
    @staticmethod
    def get_geographic_trends(days: int = 30) -> List[Dict]:
        """Get geographic distribution trends"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        city_trends = db.session.query(
            Quote.city,
            func.count(Quote.id).label('quote_count'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=0)).label('revenue'),
            func.avg(Quote.final_price).label('avg_price')
        ).filter(
            Quote.created_at >= start_date,
            Quote.city.isnot(None)
        ).group_by(Quote.city).order_by(desc('quote_count')).limit(20).all()
        
        return [
            {
                'city': trend.city,
                'quote_count': trend.quote_count,
                'revenue': float(trend.revenue or 0),
                'avg_price': float(trend.avg_price or 0)
            }
            for trend in city_trends
        ]

class PerformanceReports:
    """Detailed performance reporting"""
    
    @staticmethod
    def generate_craftsman_report(craftsman_id: int, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Generate comprehensive craftsman performance report"""
        
        # Quote metrics
        quote_stats = db.session.query(
            func.count(Quote.id).label('total_quotes'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, 1)], else_=0)).label('accepted_quotes'),
            func.sum(case([(Quote.status == QuoteStatus.REJECTED, 1)], else_=0)).label('rejected_quotes'),
            func.sum(case([(Quote.status == QuoteStatus.PENDING, 1)], else_=0)).label('pending_quotes'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=0)).label('total_revenue'),
            func.avg(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=None)).label('avg_quote_value'),
            func.min(Quote.final_price).label('min_quote'),
            func.max(Quote.final_price).label('max_quote')
        ).filter(
            Quote.craftsman_id == craftsman_id,
            Quote.created_at >= start_date,
            Quote.created_at <= end_date
        ).first()
        
        # Job completion metrics
        job_stats = db.session.query(
            func.count(Job.id).label('total_jobs'),
            func.sum(case([(Job.status == JobStatus.COMPLETED, 1)], else_=0)).label('completed_jobs'),
            func.sum(case([(Job.status == JobStatus.IN_PROGRESS, 1)], else_=0)).label('in_progress_jobs'),
            func.avg(Job.completion_percentage).label('avg_completion'),
            func.avg(Job.customer_satisfaction).label('avg_satisfaction')
        ).filter(
            Job.craftsman_id == craftsman_id,
            Job.created_at >= start_date,
            Job.created_at <= end_date
        ).first()
        
        # Response time analysis
        response_times = db.session.query(
            func.extract('epoch', Quote.updated_at - Quote.created_at).label('response_time')
        ).filter(
            Quote.craftsman_id == craftsman_id,
            Quote.status != QuoteStatus.PENDING,
            Quote.created_at >= start_date,
            Quote.created_at <= end_date
        ).all()
        
        response_time_stats = {
            'avg_response_time': 0,
            'min_response_time': 0,
            'max_response_time': 0
        }
        
        if response_times:
            times = [rt.response_time for rt in response_times if rt.response_time]
            if times:
                response_time_stats = {
                    'avg_response_time': sum(times) / len(times) / 3600,  # Convert to hours
                    'min_response_time': min(times) / 3600,
                    'max_response_time': max(times) / 3600
                }
        
        return {
            'period': {
                'start_date': start_date.isoformat(),
                'end_date': end_date.isoformat(),
                'days': (end_date - start_date).days
            },
            'quotes': {
                'total': quote_stats.total_quotes or 0,
                'accepted': quote_stats.accepted_quotes or 0,
                'rejected': quote_stats.rejected_quotes or 0,
                'pending': quote_stats.pending_quotes or 0,
                'acceptance_rate': (quote_stats.accepted_quotes / quote_stats.total_quotes * 100) if quote_stats.total_quotes > 0 else 0
            },
            'revenue': {
                'total': float(quote_stats.total_revenue or 0),
                'avg_quote_value': float(quote_stats.avg_quote_value or 0),
                'min_quote': float(quote_stats.min_quote or 0),
                'max_quote': float(quote_stats.max_quote or 0)
            },
            'jobs': {
                'total': job_stats.total_jobs or 0,
                'completed': job_stats.completed_jobs or 0,
                'in_progress': job_stats.in_progress_jobs or 0,
                'completion_rate': (job_stats.completed_jobs / job_stats.total_jobs * 100) if job_stats.total_jobs > 0 else 0,
                'avg_completion': float(job_stats.avg_completion or 0),
                'avg_satisfaction': float(job_stats.avg_satisfaction or 0)
            },
            'response_time': response_time_stats
        }
    
    @staticmethod
    def generate_customer_report(customer_id: int, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Generate comprehensive customer behavior report"""
        
        # Request metrics
        request_stats = db.session.query(
            func.count(Quote.id).label('total_requests'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, 1)], else_=0)).label('accepted_requests'),
            func.sum(case([(Quote.status == QuoteStatus.REJECTED, 1)], else_=0)).label('rejected_requests'),
            func.sum(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=0)).label('total_spent'),
            func.avg(case([(Quote.status == QuoteStatus.ACCEPTED, Quote.final_price)], else_=None)).label('avg_job_value')
        ).filter(
            Quote.customer_id == customer_id,
            Quote.created_at >= start_date,
            Quote.created_at <= end_date
        ).first()
        
        # Job satisfaction
        satisfaction_stats = db.session.query(
            func.count(Review.id).label('total_reviews'),
            func.avg(Review.rating).label('avg_rating_given'),
            func.sum(case([(Review.rating >= 4, 1)], else_=0)).label('positive_reviews')
        ).filter(
            Review.customer_id == customer_id,
            Review.created_at >= start_date,
            Review.created_at <= end_date
        ).first()
        
        return {
            'period': {
                'start_date': start_date.isoformat(),
                'end_date': end_date.isoformat(),
                'days': (end_date - start_date).days
            },
            'requests': {
                'total': request_stats.total_requests or 0,
                'accepted': request_stats.accepted_requests or 0,
                'rejected': request_stats.rejected_requests or 0,
                'acceptance_rate': (request_stats.accepted_requests / request_stats.total_requests * 100) if request_stats.total_requests > 0 else 0
            },
            'spending': {
                'total': float(request_stats.total_spent or 0),
                'avg_job_value': float(request_stats.avg_job_value or 0)
            },
            'satisfaction': {
                'total_reviews': satisfaction_stats.total_reviews or 0,
                'avg_rating_given': float(satisfaction_stats.avg_rating_given or 0),
                'positive_reviews': satisfaction_stats.positive_reviews or 0,
                'satisfaction_rate': (satisfaction_stats.positive_reviews / satisfaction_stats.total_reviews * 100) if satisfaction_stats.total_reviews > 0 else 0
            }
        }

class CostCalculator:
    """Advanced cost calculation and estimation"""
    
    # Base rates by category (in TRY)
    BASE_RATES = {
        'elektrik': {'hourly': 150, 'materials_markup': 1.3, 'complexity_multiplier': 1.2},
        'tesisatçı': {'hourly': 140, 'materials_markup': 1.25, 'complexity_multiplier': 1.15},
        'boyacı': {'hourly': 120, 'materials_markup': 1.4, 'complexity_multiplier': 1.1},
        'marangoz': {'hourly': 160, 'materials_markup': 1.35, 'complexity_multiplier': 1.25},
        'tadilat': {'hourly': 130, 'materials_markup': 1.3, 'complexity_multiplier': 1.3},
        'temizlik': {'hourly': 80, 'materials_markup': 1.2, 'complexity_multiplier': 1.05},
        'nakliye': {'hourly': 100, 'materials_markup': 1.1, 'complexity_multiplier': 1.1},
        'default': {'hourly': 120, 'materials_markup': 1.25, 'complexity_multiplier': 1.15}
    }
    
    # Area complexity factors
    AREA_FACTORS = {
        'kitchen': 1.3,
        'bathroom': 1.4,
        'living_room': 1.1,
        'bedroom': 1.0,
        'balcony': 1.2,
        'garden': 1.15,
        'office': 1.1,
        'other': 1.0
    }
    
    # Urgency multipliers
    URGENCY_MULTIPLIERS = {
        'low': 1.0,
        'normal': 1.0,
        'high': 1.2,
        'urgent': 1.5,
        'emergency': 2.0
    }
    
    @staticmethod
    def calculate_job_cost(
        category: str,
        estimated_hours: float,
        materials_cost: float = 0,
        area_type: str = 'other',
        urgency: str = 'normal',
        complexity_score: int = 5,  # 1-10 scale
        location_factor: float = 1.0,
        craftsman_experience: int = 1  # years
    ) -> Dict[str, Any]:
        """Calculate comprehensive job cost estimation"""
        
        # Get base rates
        rates = CostCalculator.BASE_RATES.get(category.lower(), CostCalculator.BASE_RATES['default'])
        base_hourly = rates['hourly']
        materials_markup = rates['materials_markup']
        complexity_multiplier = rates['complexity_multiplier']
        
        # Calculate labor cost
        area_factor = CostCalculator.AREA_FACTORS.get(area_type.lower(), 1.0)
        urgency_multiplier = CostCalculator.URGENCY_MULTIPLIERS.get(urgency.lower(), 1.0)
        complexity_factor = 1.0 + ((complexity_score - 5) * 0.1)  # Scale around 1.0
        experience_factor = 1.0 + (min(craftsman_experience, 20) * 0.02)  # Max 40% bonus for 20 years
        
        adjusted_hourly = (
            base_hourly * 
            area_factor * 
            urgency_multiplier * 
            complexity_factor * 
            experience_factor * 
            location_factor
        )
        
        labor_cost = adjusted_hourly * estimated_hours
        
        # Calculate materials cost with markup
        marked_up_materials = materials_cost * materials_markup
        
        # Additional costs
        travel_cost = estimated_hours * 10  # 10 TRY per hour for travel
        overhead_cost = labor_cost * 0.15  # 15% overhead
        
        # Total cost
        subtotal = labor_cost + marked_up_materials + travel_cost + overhead_cost
        tax_amount = subtotal * 0.18  # 18% VAT
        total_cost = subtotal + tax_amount
        
        # Confidence score based on data availability
        confidence_factors = [
            1.0 if category in CostCalculator.BASE_RATES else 0.8,
            1.0 if materials_cost > 0 else 0.9,
            1.0 if area_type in CostCalculator.AREA_FACTORS else 0.95,
            1.0 if urgency in CostCalculator.URGENCY_MULTIPLIERS else 0.95
        ]
        confidence_score = sum(confidence_factors) / len(confidence_factors) * 100
        
        return {
            'breakdown': {
                'labor_cost': round(labor_cost, 2),
                'materials_cost': round(marked_up_materials, 2),
                'travel_cost': round(travel_cost, 2),
                'overhead_cost': round(overhead_cost, 2),
                'subtotal': round(subtotal, 2),
                'tax_amount': round(tax_amount, 2),
                'total_cost': round(total_cost, 2)
            },
            'factors': {
                'base_hourly_rate': base_hourly,
                'adjusted_hourly_rate': round(adjusted_hourly, 2),
                'area_factor': area_factor,
                'urgency_multiplier': urgency_multiplier,
                'complexity_factor': round(complexity_factor, 2),
                'experience_factor': round(experience_factor, 2),
                'location_factor': location_factor,
                'materials_markup': materials_markup
            },
            'estimation_quality': {
                'confidence_score': round(confidence_score, 1),
                'estimated_hours': estimated_hours,
                'complexity_score': complexity_score
            },
            'price_range': {
                'min_price': round(total_cost * 0.85, 2),  # -15%
                'max_price': round(total_cost * 1.15, 2),  # +15%
                'most_likely': round(total_cost, 2)
            }
        }
    
    @staticmethod
    def get_market_price_comparison(category: str, city: str = None, days: int = 90) -> Dict[str, Any]:
        """Get market price comparison for category"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Base query
        query = db.session.query(
            func.avg(Quote.final_price).label('avg_price'),
            func.min(Quote.final_price).label('min_price'),
            func.max(Quote.final_price).label('max_price'),
            func.count(Quote.id).label('sample_size'),
            func.percentile_cont(0.5).within_group(Quote.final_price).label('median_price')
        ).filter(
            Quote.category == category,
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        )
        
        # Add city filter if provided
        if city:
            query = query.filter(Quote.city == city)
        
        market_stats = query.first()
        
        return {
            'category': category,
            'city': city,
            'period_days': days,
            'avg_price': float(market_stats.avg_price or 0),
            'min_price': float(market_stats.min_price or 0),
            'max_price': float(market_stats.max_price or 0),
            'median_price': float(market_stats.median_price or 0),
            'sample_size': market_stats.sample_size or 0
        }
    
    @staticmethod
    def get_pricing_recommendations(craftsman_id: int, category: str) -> Dict[str, Any]:
        """Get pricing recommendations based on market data and craftsman performance"""
        
        # Get craftsman's historical performance
        craftsman_stats = db.session.query(
            func.avg(Quote.final_price).label('avg_price'),
            func.avg(case([(Quote.status == QuoteStatus.ACCEPTED, 1.0)], else_=0.0)).label('acceptance_rate'),
            func.count(Quote.id).label('total_quotes')
        ).filter(
            Quote.craftsman_id == craftsman_id,
            Quote.category == category,
            Quote.created_at >= datetime.utcnow() - timedelta(days=180)
        ).first()
        
        # Get market averages
        market_stats = db.session.query(
            func.avg(Quote.final_price).label('market_avg'),
            func.percentile_cont(0.25).within_group(Quote.final_price).label('q1_price'),
            func.percentile_cont(0.75).within_group(Quote.final_price).label('q3_price')
        ).filter(
            Quote.category == category,
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= datetime.utcnow() - timedelta(days=90)
        ).first()
        
        craftsman_avg = float(craftsman_stats.avg_price or 0)
        market_avg = float(market_stats.market_avg or 0)
        acceptance_rate = float(craftsman_stats.acceptance_rate or 0) * 100
        
        # Generate recommendations
        recommendations = []
        
        if acceptance_rate < 30 and craftsman_avg > market_avg * 1.1:
            recommendations.append({
                'type': 'price_reduction',
                'message': 'Fiyatlarınızı %10-15 düşürmeyi düşünün',
                'suggested_price': round(craftsman_avg * 0.9, 2)
            })
        elif acceptance_rate > 70 and craftsman_avg < market_avg * 0.9:
            recommendations.append({
                'type': 'price_increase',
                'message': 'Fiyatlarınızı %5-10 artırabilirsiniz',
                'suggested_price': round(craftsman_avg * 1.1, 2)
            })
        
        return {
            'craftsman_performance': {
                'avg_price': craftsman_avg,
                'acceptance_rate': acceptance_rate,
                'total_quotes': craftsman_stats.total_quotes or 0
            },
            'market_data': {
                'avg_price': market_avg,
                'q1_price': float(market_stats.q1_price or 0),
                'q3_price': float(market_stats.q3_price or 0)
            },
            'recommendations': recommendations,
            'price_position': 'above_market' if craftsman_avg > market_avg * 1.05 else 'below_market' if craftsman_avg < market_avg * 0.95 else 'market_aligned'
        }

class BusinessMetrics:
    """Business intelligence and metrics"""
    
    @staticmethod
    def get_conversion_funnel(days: int = 30) -> Dict[str, Any]:
        """Get conversion funnel metrics"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Funnel stages
        total_quotes = Quote.query.filter(Quote.created_at >= start_date).count()
        
        quoted_requests = Quote.query.filter(
            Quote.created_at >= start_date,
            Quote.status != QuoteStatus.PENDING
        ).count()
        
        accepted_quotes = Quote.query.filter(
            Quote.created_at >= start_date,
            Quote.status == QuoteStatus.ACCEPTED
        ).count()
        
        completed_jobs = Job.query.filter(
            Job.created_at >= start_date,
            Job.status == JobStatus.COMPLETED
        ).count()
        
        return {
            'stages': {
                'quote_requests': total_quotes,
                'quotes_provided': quoted_requests,
                'quotes_accepted': accepted_quotes,
                'jobs_completed': completed_jobs
            },
            'conversion_rates': {
                'quote_response_rate': (quoted_requests / total_quotes * 100) if total_quotes > 0 else 0,
                'quote_acceptance_rate': (accepted_quotes / quoted_requests * 100) if quoted_requests > 0 else 0,
                'job_completion_rate': (completed_jobs / accepted_quotes * 100) if accepted_quotes > 0 else 0,
                'overall_conversion': (completed_jobs / total_quotes * 100) if total_quotes > 0 else 0
            }
        }
    
    @staticmethod
    def get_revenue_analytics(days: int = 30) -> Dict[str, Any]:
        """Get detailed revenue analytics"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Revenue by category
        category_revenue = db.session.query(
            Quote.category,
            func.sum(Quote.final_price).label('revenue'),
            func.count(Quote.id).label('job_count'),
            func.avg(Quote.final_price).label('avg_price')
        ).filter(
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        ).group_by(Quote.category).order_by(desc('revenue')).all()
        
        # Daily revenue trend
        daily_revenue = db.session.query(
            func.date(Quote.created_at).label('date'),
            func.sum(Quote.final_price).label('revenue'),
            func.count(Quote.id).label('jobs')
        ).filter(
            Quote.status == QuoteStatus.ACCEPTED,
            Quote.created_at >= start_date
        ).group_by(func.date(Quote.created_at)).order_by('date').all()
        
        total_revenue = sum(cat.revenue for cat in category_revenue if cat.revenue)
        
        return {
            'total_revenue': float(total_revenue),
            'category_breakdown': [
                {
                    'category': cat.category,
                    'revenue': float(cat.revenue or 0),
                    'job_count': cat.job_count,
                    'avg_price': float(cat.avg_price or 0),
                    'percentage': (float(cat.revenue or 0) / total_revenue * 100) if total_revenue > 0 else 0
                }
                for cat in category_revenue
            ],
            'daily_trend': [
                {
                    'date': day.date.strftime('%Y-%m-%d'),
                    'revenue': float(day.revenue or 0),
                    'jobs': day.jobs
                }
                for day in daily_revenue
            ]
        }
    
    @staticmethod
    def get_user_engagement_metrics(days: int = 30) -> Dict[str, Any]:
        """Get user engagement and activity metrics"""
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Active users
        active_customers = db.session.query(func.count(func.distinct(Quote.customer_id))).filter(
            Quote.created_at >= start_date
        ).scalar()
        
        active_craftsmen = db.session.query(func.count(func.distinct(Quote.craftsman_id))).filter(
            Quote.created_at >= start_date,
            Quote.status != QuoteStatus.PENDING
        ).scalar()
        
        # Message activity
        total_messages = Message.query.filter(Message.created_at >= start_date).count()
        
        # User retention (users who were active in previous period and current period)
        previous_start = start_date - timedelta(days=days)
        
        returning_customers = db.session.query(func.count(func.distinct(Quote.customer_id))).filter(
            Quote.customer_id.in_(
                db.session.query(Quote.customer_id).filter(
                    Quote.created_at >= previous_start,
                    Quote.created_at < start_date
                )
            ),
            Quote.created_at >= start_date
        ).scalar()
        
        return {
            'active_users': {
                'customers': active_customers or 0,
                'craftsmen': active_craftsmen or 0,
                'total': (active_customers or 0) + (active_craftsmen or 0)
            },
            'engagement': {
                'total_messages': total_messages,
                'avg_messages_per_user': total_messages / ((active_customers or 0) + (active_craftsmen or 0)) if (active_customers or 0) + (active_craftsmen or 0) > 0 else 0
            },
            'retention': {
                'returning_customers': returning_customers or 0,
                'retention_rate': (returning_customers / active_customers * 100) if active_customers > 0 else 0
            }
        }

class AnalyticsDashboardManager:
    """Main analytics dashboard manager"""
    
    @staticmethod
    def get_dashboard_data(user_id: int, user_type: str, days: int = 30) -> Dict[str, Any]:
        """Get comprehensive dashboard data based on user type"""
        
        if user_type == 'craftsman':
            overview = CraftsmanDashboard.get_craftsman_overview(user_id, days)
            trends = CraftsmanDashboard.get_craftsman_performance_trends(user_id, days)
            categories = CraftsmanDashboard.get_craftsman_top_categories(user_id, days)
            recent_activity = CraftsmanDashboard.get_craftsman_recent_activity(user_id)
            
            return {
                'user_type': 'craftsman',
                'overview': overview,
                'trends': trends,
                'top_categories': categories,
                'recent_activity': recent_activity
            }
        
        elif user_type == 'customer':
            overview = CustomerHistoryAnalytics.get_customer_overview(user_id, days)
            spending_trends = CustomerHistoryAnalytics.get_customer_spending_trends(user_id, days)
            preferred_categories = CustomerHistoryAnalytics.get_customer_preferred_categories(user_id)
            
            return {
                'user_type': 'customer',
                'overview': overview,
                'spending_trends': spending_trends,
                'preferred_categories': preferred_categories
            }
        
        else:  # admin or other
            platform_trends = TrendAnalytics.get_platform_trends(days)
            category_trends = TrendAnalytics.get_category_trends(days)
            geographic_trends = TrendAnalytics.get_geographic_trends(days)
            conversion_funnel = BusinessMetrics.get_conversion_funnel(days)
            revenue_analytics = BusinessMetrics.get_revenue_analytics(days)
            engagement_metrics = BusinessMetrics.get_user_engagement_metrics(days)
            
            return {
                'user_type': 'admin',
                'platform_trends': platform_trends,
                'category_trends': category_trends,
                'geographic_trends': geographic_trends,
                'conversion_funnel': conversion_funnel,
                'revenue_analytics': revenue_analytics,
                'engagement_metrics': engagement_metrics
            }
    
    @staticmethod
    def generate_custom_report(
        user_id: int,
        user_type: str,
        start_date: datetime,
        end_date: datetime,
        metrics: List[str] = None
    ) -> Dict[str, Any]:
        """Generate custom analytics report"""
        
        if user_type == 'craftsman':
            return PerformanceReports.generate_craftsman_report(user_id, start_date, end_date)
        elif user_type == 'customer':
            return PerformanceReports.generate_customer_report(user_id, start_date, end_date)
        else:
            # Admin report - combine multiple metrics
            return {
                'platform_trends': TrendAnalytics.get_platform_trends((end_date - start_date).days),
                'conversion_funnel': BusinessMetrics.get_conversion_funnel((end_date - start_date).days),
                'revenue_analytics': BusinessMetrics.get_revenue_analytics((end_date - start_date).days)
            }

class AnalyticsDashboardConstants:
    """Constants for analytics dashboard"""
    
    DASHBOARD_REFRESH_INTERVALS = {
        'real_time': 30,  # seconds
        'frequent': 300,  # 5 minutes
        'normal': 1800,   # 30 minutes
        'slow': 3600      # 1 hour
    }
    
    METRIC_CATEGORIES = {
        'performance': ['quotes', 'acceptance_rate', 'completion_rate', 'response_time'],
        'financial': ['revenue', 'avg_job_value', 'profit_margin'],
        'customer': ['satisfaction', 'retention', 'repeat_customers'],
        'operational': ['active_jobs', 'pending_quotes', 'overdue_jobs']
    }
    
    CHART_COLORS = {
        'primary': '#3B82F6',
        'secondary': '#10B981',
        'accent': '#F59E0B',
        'danger': '#EF4444',
        'warning': '#F97316',
        'info': '#06B6D4',
        'success': '#22C55E',
        'purple': '#8B5CF6'
    }
    
    DEFAULT_PERIODS = [7, 14, 30, 60, 90, 180, 365]
    
    EXPORT_FORMATS = ['json', 'csv', 'pdf', 'excel']
    
    # KPI thresholds
    KPI_THRESHOLDS = {
        'acceptance_rate': {'excellent': 80, 'good': 60, 'poor': 40},
        'response_time_hours': {'excellent': 2, 'good': 6, 'poor': 24},
        'customer_satisfaction': {'excellent': 4.5, 'good': 4.0, 'poor': 3.5},
        'completion_rate': {'excellent': 95, 'good': 85, 'poor': 70}
    }
    
    BENCHMARK_CATEGORIES = [
        'elektrik', 'tesisatçı', 'boyacı', 'marangoz', 
        'tadilat', 'temizlik', 'nakliye'
    ]