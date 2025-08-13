from flask import Blueprint, request, jsonify, g
from functools import wraps
from datetime import datetime, timedelta
import uuid
from ..models import db, User, QuoteRequest, Review
from ..services.auth_service import verify_token
from ..utils.response_utils import success_response, error_response

marketplace_bp = Blueprint('marketplace', __name__, url_prefix='/marketplace')

def auth_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return error_response('Missing or invalid authorization header', 401)
        
        token = auth_header.split(' ')[1]
        user_data = verify_token(token)
        if not user_data:
            return error_response('Invalid token', 401)
        
        g.current_user = user_data
        return f(*args, **kwargs)
    
    return decorated_function

# Mock data for marketplace listings (in production, this would be a database table)
marketplace_listings = [
    {
        'id': str(uuid.uuid4()),
        'title': 'Mutfak Dolabı Tamiri',
        'description': 'Mutfak dolabının menteşeleri kırıldı, değiştirilmesi gerekiyor. Yaklaşık 5 adet menteşe var.',
        'category': 'Tadilat',
        'location': {
            'city': 'İstanbul',
            'lat': 41.0082,
            'lng': 28.9784
        },
        'budget': {
            'type': 'range',
            'min': 500,
            'max': 1000,
            'currency': 'TRY'
        },
        'dateRange': {
            'start': '2025-01-20T00:00:00Z',
            'end': '2025-01-25T00:00:00Z'
        },
        'attachments': [],
        'visibility': 'marketplace',
        'status': 'open',
        'postedBy': {
            'userId': 'user_123',
            'name': 'Ahmet Yılmaz',
            'avatar': None
        },
        'postedAt': '2025-01-13T10:00:00Z',
        'bidsCount': 3
    },
    {
        'id': str(uuid.uuid4()),
        'title': 'Elektrik Tesisatı Kontrolü',
        'description': 'Evde elektrik kesintisi yaşanıyor, genel kontrol yapılması gerekiyor.',
        'category': 'Elektrik',
        'location': {
            'city': 'Ankara',
            'lat': 39.9334,
            'lng': 32.8597
        },
        'budget': {
            'type': 'fixed',
            'min': 800,
            'max': 800,
            'currency': 'TRY'
        },
        'dateRange': {
            'start': '2025-01-15T00:00:00Z',
            'end': '2025-01-18T00:00:00Z'
        },
        'attachments': [],
        'visibility': 'marketplace',
        'status': 'open',
        'postedBy': {
            'userId': 'user_456',
            'name': 'Fatma Demir',
            'avatar': None
        },
        'postedAt': '2025-01-12T14:30:00Z',
        'bidsCount': 5
    },
    {
        'id': str(uuid.uuid4()),
        'title': 'Su Tesisatı Arızası',
        'description': 'Banyo lavabosundan su sızıyor, acil müdahale gerekiyor.',
        'category': 'Su Tesisatı',
        'location': {
            'city': 'İzmir',
            'lat': 38.4237,
            'lng': 27.1428
        },
        'budget': {
            'type': 'range',
            'min': 300,
            'max': 600,
            'currency': 'TRY'
        },
        'dateRange': {
            'start': '2025-01-14T00:00:00Z',
            'end': '2025-01-16T00:00:00Z'
        },
        'attachments': [],
        'visibility': 'marketplace',
        'status': 'open',
        'postedBy': {
            'userId': 'user_789',
            'name': 'Mehmet Kaya',
            'avatar': None
        },
        'postedAt': '2025-01-11T09:15:00Z',
        'bidsCount': 2
    },
    {
        'id': str(uuid.uuid4()),
        'title': 'Ev Temizliği',
        'description': '3+1 daire genel temizlik, cam silme dahil.',
        'category': 'Temizlik',
        'location': {
            'city': 'Bursa',
            'lat': 40.1826,
            'lng': 29.0665
        },
        'budget': {
            'type': 'fixed',
            'min': 400,
            'max': 400,
            'currency': 'TRY'
        },
        'dateRange': {
            'start': '2025-01-16T00:00:00Z',
            'end': '2025-01-16T00:00:00Z'
        },
        'attachments': [],
        'visibility': 'marketplace',
        'status': 'open',
        'postedBy': {
            'userId': 'user_101',
            'name': 'Ayşe Öztürk',
            'avatar': None
        },
        'postedAt': '2025-01-10T16:45:00Z',
        'bidsCount': 7
    },
    {
        'id': str(uuid.uuid4()),
        'title': 'Bahçe Düzenleme',
        'description': 'Bahçede çim biçme, ağaç budama ve çiçek dikimi yapılacak.',
        'category': 'Bahçe',
        'location': {
            'city': 'Antalya',
            'lat': 36.8969,
            'lng': 30.7133
        },
        'budget': {
            'type': 'range',
            'min': 1000,
            'max': 1500,
            'currency': 'TRY'
        },
        'dateRange': {
            'start': '2025-01-18T00:00:00Z',
            'end': '2025-01-22T00:00:00Z'
        },
        'attachments': [],
        'visibility': 'marketplace',
        'status': 'open',
        'postedBy': {
            'userId': 'user_202',
            'name': 'Can Arslan',
            'avatar': None
        },
        'postedAt': '2025-01-09T11:20:00Z',
        'bidsCount': 4
    }
]

# Mock data for offers
marketplace_offers = [
    {
        'id': str(uuid.uuid4()),
        'listingId': marketplace_listings[0]['id'],
        'amount': 750,
        'currency': 'TRY',
        'etaDays': 2,
        'note': 'Menteşe değişimi konusunda 5 yıllık tecrübem var. Kaliteli malzeme kullanırım.',
        'status': 'active',
        'provider': {
            'id': 'craftsman_123',
            'name': 'Usta Mehmet',
            'avatar': None,
            'rating': 4.8,
            'reviewCount': 24,
            'speciality': 'Dolap Tamiri'
        },
        'createdAt': '2025-01-13T12:30:00Z'
    },
    {
        'id': str(uuid.uuid4()),
        'listingId': marketplace_listings[1]['id'],
        'amount': 800,
        'currency': 'TRY',
        'etaDays': 1,
        'note': 'Elektrik tesisatı uzmanıyım. Aynı gün çözüm sağlarım.',
        'status': 'active',
        'provider': {
            'id': 'craftsman_456',
            'name': 'Elektrikçi Ali',
            'avatar': None,
            'rating': 4.9,
            'reviewCount': 45,
            'speciality': 'Elektrik Tesisatı'
        },
        'createdAt': '2025-01-12T15:45:00Z'
    }
]

@marketplace_bp.route('/listings', methods=['GET'])
def get_listings():
    """Get marketplace listings with filtering and pagination"""
    try:
        # Get query parameters
        page = int(request.args.get('page', 1))
        limit = int(request.args.get('limit', 20))
        category = request.args.get('category')
        location = request.args.get('location')
        min_budget = request.args.get('minBudget', type=float)
        max_budget = request.args.get('maxBudget', type=float)
        query = request.args.get('query', '').lower()

        # Filter listings
        filtered_listings = marketplace_listings.copy()

        if category:
            filtered_listings = [l for l in filtered_listings if l['category'] == category]

        if location:
            filtered_listings = [l for l in filtered_listings if l['location']['city'] == location]

        if query:
            filtered_listings = [
                l for l in filtered_listings 
                if query in l['title'].lower() or query in l['description'].lower()
            ]

        if min_budget is not None:
            filtered_listings = [l for l in filtered_listings if l['budget']['min'] >= min_budget]

        if max_budget is not None:
            filtered_listings = [l for l in filtered_listings if l['budget']['max'] <= max_budget]

        # Pagination
        total_count = len(filtered_listings)
        start_idx = (page - 1) * limit
        end_idx = start_idx + limit
        paginated_listings = filtered_listings[start_idx:end_idx]

        total_pages = (total_count + limit - 1) // limit

        return success_response({
            'listings': paginated_listings,
            'totalCount': total_count,
            'currentPage': page,
            'totalPages': total_pages,
            'hasMore': page < total_pages
        })

    except Exception as e:
        return error_response(f'Error fetching listings: {str(e)}', 500)

@marketplace_bp.route('/listings/<listing_id>', methods=['GET'])
def get_listing_detail(listing_id):
    """Get detailed information about a specific listing"""
    try:
        # Find listing
        listing = next((l for l in marketplace_listings if l['id'] == listing_id), None)
        if not listing:
            return error_response('Listing not found', 404)

        # Get offers for this listing
        listing_offers = [o for o in marketplace_offers if o['listingId'] == listing_id]

        return success_response({
            'listing': listing,
            'offers': listing_offers
        })

    except Exception as e:
        return error_response(f'Error fetching listing detail: {str(e)}', 500)

@marketplace_bp.route('/listings', methods=['POST'])
@auth_required
def create_listing():
    """Create a new marketplace listing"""
    try:
        data = request.get_json()

        # Validate required fields
        required_fields = ['title', 'description', 'category', 'location', 'budget', 'dateRange']
        for field in required_fields:
            if field not in data:
                return error_response(f'Missing required field: {field}', 400)

        # Create new listing
        new_listing = {
            'id': str(uuid.uuid4()),
            'title': data['title'],
            'description': data['description'],
            'category': data['category'],
            'location': data['location'],
            'budget': data['budget'],
            'dateRange': data['dateRange'],
            'attachments': data.get('attachments', []),
            'visibility': 'marketplace',
            'status': 'open',
            'postedBy': {
                'userId': g.current_user['id'],
                'name': g.current_user.get('name', 'Anonim Kullanıcı'),
                'avatar': g.current_user.get('avatar')
            },
            'postedAt': datetime.utcnow().isoformat() + 'Z',
            'bidsCount': 0
        }

        # Add to listings (in production, save to database)
        marketplace_listings.append(new_listing)

        return success_response(new_listing, 201)

    except Exception as e:
        return error_response(f'Error creating listing: {str(e)}', 500)

@marketplace_bp.route('/listings/<listing_id>/offers', methods=['GET'])
def get_listing_offers(listing_id):
    """Get all offers for a specific listing"""
    try:
        # Find listing
        listing = next((l for l in marketplace_listings if l['id'] == listing_id), None)
        if not listing:
            return error_response('Listing not found', 404)

        # Get offers for this listing
        listing_offers = [o for o in marketplace_offers if o['listingId'] == listing_id]

        return success_response({
            'offers': listing_offers,
            'totalCount': len(listing_offers)
        })

    except Exception as e:
        return error_response(f'Error fetching offers: {str(e)}', 500)

@marketplace_bp.route('/listings/<listing_id>/offers', methods=['POST'])
@auth_required
def submit_offer(listing_id):
    """Submit an offer for a specific listing"""
    try:
        data = request.get_json()

        # Validate required fields
        required_fields = ['amount', 'etaDays']
        for field in required_fields:
            if field not in data:
                return error_response(f'Missing required field: {field}', 400)

        # Find listing
        listing = next((l for l in marketplace_listings if l['id'] == listing_id), None)
        if not listing:
            return error_response('Listing not found', 404)

        # Check if listing is open
        if listing['status'] != 'open':
            return error_response('This listing is no longer accepting offers', 400)

        # Create new offer
        new_offer = {
            'id': str(uuid.uuid4()),
            'listingId': listing_id,
            'amount': data['amount'],
            'currency': data.get('currency', 'TRY'),
            'etaDays': data['etaDays'],
            'note': data.get('note'),
            'status': 'active',
            'provider': {
                'id': g.current_user['id'],
                'name': g.current_user.get('name', 'Anonim Usta'),
                'avatar': g.current_user.get('avatar'),
                'rating': 4.5,  # Would come from user profile
                'reviewCount': 12,  # Would come from user profile
                'speciality': data.get('speciality', listing['category'])
            },
            'createdAt': datetime.utcnow().isoformat() + 'Z'
        }

        # Add to offers (in production, save to database)
        marketplace_offers.append(new_offer)

        # Update listing bids count
        listing['bidsCount'] += 1

        return success_response(new_offer, 201)

    except Exception as e:
        return error_response(f'Error submitting offer: {str(e)}', 500)

@marketplace_bp.route('/listings/<listing_id>', methods=['PATCH'])
@auth_required
def update_listing(listing_id):
    """Update a marketplace listing"""
    try:
        data = request.get_json()

        # Find listing
        listing = next((l for l in marketplace_listings if l['id'] == listing_id), None)
        if not listing:
            return error_response('Listing not found', 404)

        # Check if user is the owner
        if listing['postedBy']['userId'] != g.current_user['id']:
            return error_response('You can only update your own listings', 403)

        # Update allowed fields
        allowed_fields = ['title', 'description', 'status', 'budget', 'dateRange']
        for field in allowed_fields:
            if field in data:
                listing[field] = data[field]

        return success_response(listing)

    except Exception as e:
        return error_response(f'Error updating listing: {str(e)}', 500)

@marketplace_bp.route('/my-listings', methods=['GET'])
@auth_required
def get_my_listings():
    """Get current user's listings"""
    try:
        user_id = g.current_user['id']
        user_listings = [l for l in marketplace_listings if l['postedBy']['userId'] == user_id]

        return success_response({
            'listings': user_listings,
            'totalCount': len(user_listings)
        })

    except Exception as e:
        return error_response(f'Error fetching user listings: {str(e)}', 500)

@marketplace_bp.route('/my-offers', methods=['GET'])
@auth_required
def get_my_offers():
    """Get current user's offers"""
    try:
        user_id = g.current_user['id']
        user_offers = [o for o in marketplace_offers if o['provider']['id'] == user_id]

        return success_response({
            'offers': user_offers,
            'totalCount': len(user_offers)
        })

    except Exception as e:
        return error_response(f'Error fetching user offers: {str(e)}', 500)

@marketplace_bp.route('/offers/<offer_id>', methods=['PATCH'])
@auth_required
def update_offer(offer_id):
    """Update an offer (withdraw, accept, reject)"""
    try:
        data = request.get_json()

        # Find offer
        offer = next((o for o in marketplace_offers if o['id'] == offer_id), None)
        if not offer:
            return error_response('Offer not found', 404)

        # Find related listing
        listing = next((l for l in marketplace_listings if l['id'] == offer['listingId']), None)
        if not listing:
            return error_response('Related listing not found', 404)

        # Check permissions
        user_id = g.current_user['id']
        is_offer_owner = offer['provider']['id'] == user_id
        is_listing_owner = listing['postedBy']['userId'] == user_id

        if not (is_offer_owner or is_listing_owner):
            return error_response('You can only update your own offers or offers on your listings', 403)

        # Update status
        if 'status' in data:
            new_status = data['status']
            
            # Validate status transitions
            if is_offer_owner and new_status == 'withdrawn':
                offer['status'] = 'withdrawn'
            elif is_listing_owner and new_status in ['accepted', 'rejected']:
                offer['status'] = new_status
                if new_status == 'accepted':
                    # Close the listing when an offer is accepted
                    listing['status'] = 'closed'
            else:
                return error_response('Invalid status update', 400)

        return success_response(offer)

    except Exception as e:
        return error_response(f'Error updating offer: {str(e)}', 500)