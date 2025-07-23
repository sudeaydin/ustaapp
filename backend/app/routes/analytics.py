from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.quote import Quote
from app.models.payment import Payment
from app.models.review import Review
# from app.models.message import Message  # Not needed for current analytics
from datetime import datetime, timedelta
from sqlalchemy import func, and_
import logging

analytics_bp = Blueprint('analytics', __name__)

@analytics_bp.route('/dashboard', methods=['GET'])
@jwt_required()
def get_dashboard_analytics():
    """Get dashboard analytics for the current user"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        if user.user_type == 'customer':
            analytics = get_customer_analytics(user_id)
        else:
            analytics = get_craftsman_analytics(user_id)
        
        return jsonify({
            'success': True,
            'analytics': analytics
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting dashboard analytics: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

def get_customer_analytics(user_id):
    """Get analytics data for customer"""
    customer = Customer.query.filter_by(user_id=user_id).first()
    if not customer:
        return {}
    
    # Time ranges
    now = datetime.utcnow()
    last_30_days = now - timedelta(days=30)
    last_7_days = now - timedelta(days=7)
    
    # Basic stats
    total_quotes = Quote.query.filter_by(customer_id=customer.id).count()
    active_quotes = Quote.query.filter(
        and_(Quote.customer_id == customer.id, 
             Quote.status.in_(['pending', 'accepted']))
    ).count()
    
    completed_quotes = Quote.query.filter(
        and_(Quote.customer_id == customer.id, 
             Quote.status == 'completed')
    ).count()
    
    # Payment stats
    total_spent = db.session.query(func.sum(Payment.total_amount)).filter(
        and_(Payment.customer_id == customer.id,
             Payment.status == 'completed')
    ).scalar() or 0
    
    # Recent activity
    recent_quotes = Quote.query.filter(
        and_(Quote.customer_id == customer.id,
             Quote.created_at >= last_30_days)
    ).count()
    
    # Reviews given
    reviews_given = Review.query.filter_by(customer_id=customer.id).count()
    
    # Average rating given
    avg_rating_given = db.session.query(func.avg(Review.rating)).filter(
        Review.customer_id == customer.id
    ).scalar() or 0
    
    # Monthly spending data
    monthly_spending = []
    for i in range(6):
        month_start = now.replace(day=1) - timedelta(days=30*i)
        month_end = month_start + timedelta(days=30)
        
        spending = db.session.query(func.sum(Payment.total_amount)).filter(
            and_(Payment.customer_id == customer.id,
                 Payment.status == 'completed',
                 Payment.created_at >= month_start,
                 Payment.created_at < month_end)
        ).scalar() or 0
        
        monthly_spending.append({
            'month': month_start.strftime('%Y-%m'),
            'amount': float(spending)
        })
    
    # Quote status distribution
    quote_statuses = db.session.query(
        Quote.status, func.count(Quote.id)
    ).filter(Quote.customer_id == customer.id).group_by(Quote.status).all()
    
    status_distribution = [
        {'status': status, 'count': count} 
        for status, count in quote_statuses
    ]
    
    return {
        'user_type': 'customer',
        'overview': {
            'total_quotes': total_quotes,
            'active_quotes': active_quotes,
            'completed_quotes': completed_quotes,
            'total_spent': float(total_spent),
            'recent_activity': recent_quotes,
            'reviews_given': reviews_given,
            'avg_rating_given': round(float(avg_rating_given), 2)
        },
        'charts': {
            'monthly_spending': monthly_spending,
            'quote_status_distribution': status_distribution
        }
    }

def get_craftsman_analytics(user_id):
    """Get analytics data for craftsman"""
    craftsman = Craftsman.query.filter_by(user_id=user_id).first()
    if not craftsman:
        return {}
    
    # Time ranges
    now = datetime.utcnow()
    last_30_days = now - timedelta(days=30)
    last_7_days = now - timedelta(days=7)
    
    # Basic stats
    total_quotes = Quote.query.filter_by(craftsman_id=craftsman.id).count()
    active_quotes = Quote.query.filter(
        and_(Quote.craftsman_id == craftsman.id, 
             Quote.status.in_(['pending', 'accepted']))
    ).count()
    
    completed_quotes = Quote.query.filter(
        and_(Quote.craftsman_id == craftsman.id, 
             Quote.status == 'completed')
    ).count()
    
    # Earnings stats
    total_earnings = db.session.query(func.sum(Payment.total_amount)).filter(
        and_(Payment.craftsman_id == craftsman.id,
             Payment.status == 'completed')
    ).scalar() or 0
    
    # Recent activity
    recent_quotes = Quote.query.filter(
        and_(Quote.craftsman_id == craftsman.id,
             Quote.created_at >= last_30_days)
    ).count()
    
    # Reviews received
    reviews_received = Review.query.filter_by(craftsman_id=craftsman.id).count()
    
    # Average rating received
    avg_rating = db.session.query(func.avg(Review.rating)).filter(
        Review.craftsman_id == craftsman.id
    ).scalar() or 0
    
    # Response rate (quotes responded to vs total quotes)
    total_available_quotes = Quote.query.filter(
        Quote.status == 'open'
    ).count()
    
    responded_quotes = Quote.query.filter_by(craftsman_id=craftsman.id).count()
    response_rate = (responded_quotes / total_available_quotes * 100) if total_available_quotes > 0 else 0
    
    # Monthly earnings data
    monthly_earnings = []
    for i in range(6):
        month_start = now.replace(day=1) - timedelta(days=30*i)
        month_end = month_start + timedelta(days=30)
        
        earnings = db.session.query(func.sum(Payment.total_amount)).filter(
            and_(Payment.craftsman_id == craftsman.id,
                 Payment.status == 'completed',
                 Payment.created_at >= month_start,
                 Payment.created_at < month_end)
        ).scalar() or 0
        
        monthly_earnings.append({
            'month': month_start.strftime('%Y-%m'),
            'amount': float(earnings)
        })
    
    # Quote status distribution
    quote_statuses = db.session.query(
        Quote.status, func.count(Quote.id)
    ).filter(Quote.craftsman_id == craftsman.id).group_by(Quote.status).all()
    
    status_distribution = [
        {'status': status, 'count': count} 
        for status, count in quote_statuses
    ]
    
    # Performance metrics
    success_rate = (completed_quotes / total_quotes * 100) if total_quotes > 0 else 0
    
    return {
        'user_type': 'craftsman',
        'overview': {
            'total_quotes': total_quotes,
            'active_quotes': active_quotes,
            'completed_quotes': completed_quotes,
            'total_earnings': float(total_earnings),
            'recent_activity': recent_quotes,
            'reviews_received': reviews_received,
            'avg_rating': round(float(avg_rating), 2),
            'response_rate': round(response_rate, 2),
            'success_rate': round(success_rate, 2)
        },
        'charts': {
            'monthly_earnings': monthly_earnings,
            'quote_status_distribution': status_distribution
        }
    }

@analytics_bp.route('/performance', methods=['GET'])
@jwt_required()
def get_performance_analytics():
    """Get detailed performance analytics"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Get time range from query params
        days = request.args.get('days', 30, type=int)
        start_date = datetime.utcnow() - timedelta(days=days)
        
        if user.user_type == 'customer':
            performance = get_customer_performance(user_id, start_date)
        else:
            performance = get_craftsman_performance(user_id, start_date)
        
        return jsonify({
            'success': True,
            'performance': performance,
            'period': f'Last {days} days'
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting performance analytics: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

def get_customer_performance(user_id, start_date):
    """Get customer performance metrics"""
    customer = Customer.query.filter_by(user_id=user_id).first()
    if not customer:
        return {}
    
    # Quotes in period
    quotes_in_period = Quote.query.filter(
        and_(Quote.customer_id == customer.id,
             Quote.created_at >= start_date)
    ).all()
    
    # Daily activity
    daily_activity = []
    current_date = start_date.date()
    end_date = datetime.utcnow().date()
    
    while current_date <= end_date:
        quotes_count = len([q for q in quotes_in_period 
                           if q.created_at.date() == current_date])
        
        daily_activity.append({
            'date': current_date.isoformat(),
            'quotes': quotes_count
        })
        current_date += timedelta(days=1)
    
    # Category preferences
    category_stats = {}
    for quote in quotes_in_period:
        category = getattr(quote, 'category', 'Unknown')
        category_stats[category] = category_stats.get(category, 0) + 1
    
    category_preferences = [
        {'category': cat, 'count': count}
        for cat, count in category_stats.items()
    ]
    
    return {
        'daily_activity': daily_activity,
        'category_preferences': category_preferences,
        'total_quotes_period': len(quotes_in_period),
        'avg_quotes_per_day': len(quotes_in_period) / max(1, (datetime.utcnow().date() - start_date.date()).days)
    }

def get_craftsman_performance(user_id, start_date):
    """Get craftsman performance metrics"""
    craftsman = Craftsman.query.filter_by(user_id=user_id).first()
    if not craftsman:
        return {}
    
    # Quotes in period
    quotes_in_period = Quote.query.filter(
        and_(Quote.craftsman_id == craftsman.id,
             Quote.created_at >= start_date)
    ).all()
    
    # Daily activity
    daily_activity = []
    current_date = start_date.date()
    end_date = datetime.utcnow().date()
    
    while current_date <= end_date:
        quotes_count = len([q for q in quotes_in_period 
                           if q.created_at.date() == current_date])
        
        daily_activity.append({
            'date': current_date.isoformat(),
            'quotes': quotes_count
        })
        current_date += timedelta(days=1)
    
    # Success metrics
    completed_in_period = [q for q in quotes_in_period if q.status == 'completed']
    success_rate = len(completed_in_period) / len(quotes_in_period) * 100 if quotes_in_period else 0
    
    # Response time analysis (mock data)
    avg_response_time = 2.5  # hours
    
    return {
        'daily_activity': daily_activity,
        'total_quotes_period': len(quotes_in_period),
        'completed_quotes_period': len(completed_in_period),
        'success_rate_period': round(success_rate, 2),
        'avg_response_time': avg_response_time,
        'avg_quotes_per_day': len(quotes_in_period) / max(1, (datetime.utcnow().date() - start_date.date()).days)
    }

@analytics_bp.route('/insights', methods=['GET'])
@jwt_required()
def get_insights():
    """Get AI-powered insights and recommendations"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Generate insights based on user data
        if user.user_type == 'customer':
            insights = generate_customer_insights(user_id)
        else:
            insights = generate_craftsman_insights(user_id)
        
        return jsonify({
            'success': True,
            'insights': insights
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting insights: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

def generate_customer_insights(user_id):
    """Generate insights for customer"""
    customer = Customer.query.filter_by(user_id=user_id).first()
    if not customer:
        return []
    
    insights = []
    
    # Check spending patterns
    total_spent = db.session.query(func.sum(Payment.total_amount)).filter(
        and_(Payment.customer_id == customer.id,
             Payment.status == 'completed')
    ).scalar() or 0
    
    if total_spent > 5000:
        insights.append({
            'type': 'spending',
            'title': 'Yüksek Harcama Analizi',
            'message': f'Toplam {total_spent:.2f}₺ harcama yaptınız. Büyük projeler için paket indirimleri değerlendirilebilir.',
            'priority': 'medium',
            'action': 'explore_packages'
        })
    
    # Check review patterns
    reviews_given = Review.query.filter_by(customer_id=customer.id).count()
    if reviews_given < 3:
        insights.append({
            'type': 'engagement',
            'title': 'Değerlendirme Önerisi',
            'message': 'Aldığınız hizmetleri değerlendirerek diğer müşterilere yardımcı olabilirsiniz.',
            'priority': 'low',
            'action': 'write_reviews'
        })
    
    return insights

def generate_craftsman_insights(user_id):
    """Generate insights for craftsman"""
    craftsman = Craftsman.query.filter_by(user_id=user_id).first()
    if not craftsman:
        return []
    
    insights = []
    
    # Check response rate
    total_quotes = Quote.query.filter_by(craftsman_id=craftsman.id).count()
    if total_quotes < 5:
        insights.append({
            'type': 'activity',
            'title': 'Aktivite Artırma',
            'message': 'Daha fazla işe teklif vererek kazancınızı artırabilirsiniz.',
            'priority': 'high',
            'action': 'browse_jobs'
        })
    
    # Check rating
    avg_rating = db.session.query(func.avg(Review.rating)).filter(
        Review.craftsman_id == craftsman.id
    ).scalar() or 0
    
    if avg_rating < 4.0 and avg_rating > 0:
        insights.append({
            'type': 'quality',
            'title': 'Hizmet Kalitesi',
            'message': f'Ortalama puanınız {avg_rating:.1f}. Müşteri memnuniyetini artırmak için geri bildirimleri değerlendirin.',
            'priority': 'high',
            'action': 'improve_service'
        })
    
    return insights