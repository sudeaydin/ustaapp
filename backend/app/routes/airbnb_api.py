from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import user, craftsman, customer, category, quote, payment, notification, job, message, review
from app import db
from datetime import datetime
import json

airbnb_api = Blueprint('airbnb_api', __name__)

# Kategorileri getir
@airbnb_api.route('/categories', methods=['GET'])
def get_categories():
    try:
        categories = category.Category.query.all()
        return jsonify({
            'success': True,
            'data': [cat.to_dict() for cat in categories]
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Ustaları listele (filtreleme ile)
@airbnb_api.route('/craftsmen', methods=['GET'])
def get_craftsmen():
    try:
        # Query parameters
        category_id = request.args.get('category')
        search = request.args.get('search')
        min_rating = request.args.get('min_rating', type=float)
        max_price = request.args.get('max_price', type=float)
        location = request.args.get('location')
        
        # Base query
        query = craftsman.Craftsman.query.join(user.User)
        
        # Apply filters
        if category_id:
            query = query.filter(craftsman.Craftsman.category_id == category_id)
        
        if search:
            query = query.filter(
                db.or_(
                    user.User.first_name.ilike(f'%{search}%'),
                    user.User.last_name.ilike(f'%{search}%'),
                    craftsman.Craftsman.specialization.ilike(f'%{search}%')
                )
            )
        
        if min_rating:
            query = query.filter(craftsman.Craftsman.rating >= min_rating)
        
        if max_price:
            query = query.filter(craftsman.Craftsman.hourly_rate <= max_price)
        
        if location:
            query = query.filter(user.User.city.ilike(f'%{location}%'))
        
        craftsmen = query.all()
        
        return jsonify({
            'success': True,
            'data': [craftsman_obj.to_dict() for craftsman_obj in craftsmen]
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Usta detayını getir
@airbnb_api.route('/craftsmen/<int:craftsman_id>', methods=['GET'])
def get_craftsman_detail(craftsman_id):
    try:
        craftsman_obj = craftsman.Craftsman.query.get_or_404(craftsman_id)
        user_obj = user.User.query.get(craftsman_obj.user_id)
        
        # Get reviews
        reviews = review.Review.query.filter_by(craftsman_id=craftsman_id).limit(10).all()
        
        # Get recent jobs
        recent_jobs = job.Job.query.filter_by(craftsman_id=craftsman_id).limit(5).all()
        
        data = craftsman_obj.to_dict()
        data['user'] = user_obj.to_dict()
        data['reviews'] = [rev.to_dict() for rev in reviews]
        data['recent_jobs'] = [job_obj.to_dict() for job_obj in recent_jobs]
        
        return jsonify({
            'success': True,
            'data': data
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# İş talebi oluştur
@airbnb_api.route('/job-requests', methods=['POST'])
@jwt_required()
def create_job_request():
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'description', 'category_id', 'location']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} alanı zorunludur'}), 400
        
        # Create job request
        new_job = job.Job(
            customer_id=current_user_id,
            title=data['title'],
            description=data['description'],
            category_id=data['category_id'],
            location=data['location'],
            budget=data.get('budget'),
            urgency=data.get('urgency', 'normal'),
            status='pending',
            created_at=datetime.now()
        )
        
        db.session.add(new_job)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'İş talebi başarıyla oluşturuldu',
            'data': new_job.to_dict()
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

# Kullanıcının iş taleplerini getir
@airbnb_api.route('/my-job-requests', methods=['GET'])
@jwt_required()
def get_my_job_requests():
    try:
        current_user_id = get_jwt_identity()
        status = request.args.get('status')
        
        query = job.Job.query.filter_by(customer_id=current_user_id)
        if status:
            query = query.filter_by(status=status)
        
        jobs = query.order_by(job.Job.created_at.desc()).all()
        
        return jsonify({
            'success': True,
            'data': [job_obj.to_dict() for job_obj in jobs]
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Teklif oluştur
@airbnb_api.route('/quotes', methods=['POST'])
@jwt_required()
def create_quote():
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['job_id', 'price', 'description']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} alanı zorunludur'}), 400
        
        # Check if user is a craftsman
        user_obj = user.User.query.get(current_user_id)
        if user_obj.user_type != 'craftsman':
            return jsonify({'success': False, 'message': 'Sadece ustalar teklif verebilir'}), 403
        
        # Create quote
        new_quote = quote.Quote(
            job_id=data['job_id'],
            craftsman_id=current_user_id,
            price=data['price'],
            description=data['description'],
            estimated_duration=data.get('estimated_duration'),
            status='pending',
            created_at=datetime.now()
        )
        
        db.session.add(new_quote)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Teklif başarıyla oluşturuldu',
            'data': new_quote.to_dict()
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

# İş için teklifleri getir
@airbnb_api.route('/jobs/<int:job_id>/quotes', methods=['GET'])
@jwt_required()
def get_job_quotes(job_id):
    try:
        current_user_id = get_jwt_identity()
        
        # Check if user owns the job
        job_obj = job.Job.query.get_or_404(job_id)
        if job_obj.customer_id != current_user_id:
            return jsonify({'success': False, 'message': 'Bu işe erişim izniniz yok'}), 403
        
        quotes = quote.Quote.query.filter_by(job_id=job_id).all()
        
        return jsonify({
            'success': True,
            'data': [quote_obj.to_dict() for quote_obj in quotes]
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Teklifi kabul et
@airbnb_api.route('/quotes/<int:quote_id>/accept', methods=['POST'])
@jwt_required()
def accept_quote(quote_id):
    try:
        current_user_id = get_jwt_identity()
        
        quote_obj = quote.Quote.query.get_or_404(quote_id)
        job_obj = job.Job.query.get(quote_obj.job_id)
        
        # Check if user owns the job
        if job_obj.customer_id != current_user_id:
            return jsonify({'success': False, 'message': 'Bu işe erişim izniniz yok'}), 403
        
        # Update quote and job status
        quote_obj.status = 'accepted'
        job_obj.status = 'in_progress'
        job_obj.craftsman_id = quote_obj.craftsman_id
        job_obj.accepted_quote_id = quote_id
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Teklif başarıyla kabul edildi'
        }), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

# Mesaj gönder
@airbnb_api.route('/messages', methods=['POST'])
@jwt_required()
def send_message():
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['recipient_id', 'content']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} alanı zorunludur'}), 400
        
        # Create message
        new_message = message.Message(
            sender_id=current_user_id,
            recipient_id=data['recipient_id'],
            content=data['content'],
            created_at=datetime.now()
        )
        
        db.session.add(new_message)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Mesaj başarıyla gönderildi',
            'data': new_message.to_dict()
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

# Mesajları getir
@airbnb_api.route('/messages/<int:partner_id>', methods=['GET'])
@jwt_required()
def get_messages(partner_id):
    try:
        current_user_id = get_jwt_identity()
        
        # Get messages between current user and partner
        messages = message.Message.query.filter(
            db.or_(
                db.and_(message.Message.sender_id == current_user_id, message.Message.recipient_id == partner_id),
                db.and_(message.Message.sender_id == partner_id, message.Message.recipient_id == current_user_id)
            )
        ).order_by(message.Message.created_at.asc()).all()
        
        return jsonify({
            'success': True,
            'data': [msg.to_dict() for msg in messages]
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Kullanıcının mesaj listesini getir
@airbnb_api.route('/conversations', methods=['GET'])
@jwt_required()
def get_conversations():
    try:
        current_user_id = get_jwt_identity()
        
        # Get unique conversations
        conversations = db.session.query(
            message.Message.recipient_id,
            db.func.max(message.Message.created_at).label('last_message_time')
        ).filter(message.Message.sender_id == current_user_id).group_by(message.Message.recipient_id).all()
        
        # Get conversations where user is recipient
        received_conversations = db.session.query(
            message.Message.sender_id,
            db.func.max(message.Message.created_at).label('last_message_time')
        ).filter(message.Message.recipient_id == current_user_id).group_by(message.Message.sender_id).all()
        
        # Combine and get latest messages
        all_conversations = []
        for conv in conversations:
            all_conversations.append({
                'partner_id': conv.recipient_id,
                'last_message_time': conv.last_message_time
            })
        
        for conv in received_conversations:
            all_conversations.append({
                'partner_id': conv.sender_id,
                'last_message_time': conv.last_message_time
            })
        
        # Get unique conversations with latest message
        unique_conversations = []
        seen_partners = set()
        
        for conv in sorted(all_conversations, key=lambda x: x['last_message_time'], reverse=True):
            if conv['partner_id'] not in seen_partners:
                seen_partners.add(conv['partner_id'])
                unique_conversations.append(conv)
        
        return jsonify({
            'success': True,
            'data': unique_conversations
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Bildirimleri getir
@airbnb_api.route('/notifications', methods=['GET'])
@jwt_required()
def get_notifications():
    try:
        current_user_id = get_jwt_identity()
        
        notifications = notification.Notification.query.filter_by(
            user_id=current_user_id
        ).order_by(notification.Notification.created_at.desc()).limit(20).all()
        
        return jsonify({
            'success': True,
            'data': [notif.to_dict() for notif in notifications]
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Bildirimi okundu olarak işaretle
@airbnb_api.route('/notifications/<int:notification_id>/read', methods=['POST'])
@jwt_required()
def mark_notification_read(notification_id):
    try:
        current_user_id = get_jwt_identity()
        
        notif = notification.Notification.query.get_or_404(notification_id)
        if notif.user_id != current_user_id:
            return jsonify({'success': False, 'message': 'Bu bildirime erişim izniniz yok'}), 403
        
        notif.is_read = True
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Bildirim okundu olarak işaretlendi'
        }), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500