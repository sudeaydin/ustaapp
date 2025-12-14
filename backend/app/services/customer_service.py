"""
Customer Service

Business logic for customer-related operations.
Handles profile management, quotes, reviews, favorites, and statistics.
"""

import logging
from datetime import datetime
from sqlalchemy import func
from sqlalchemy.orm import joinedload

from app.extensions import db
from app.models.customer import Customer
from app.models.user import User
from app.models.quote import Quote
from app.models.review import Review
from app.models.job import Job
from app.models.craftsman import Craftsman
from app.exceptions import (
    CustomerNotFoundError,
    QuoteNotFoundError,
    QuoteAccessDeniedError,
    QuoteStatusError,
    ReviewValidationError,
    ReviewAlreadyExistsError,
    NoCompletedJobError
)

logger = logging.getLogger(__name__)


class CustomerService:
    """Service class for customer business logic"""

    @staticmethod
    def get_by_id(customer_id):
        """
        Get customer by ID.

        Args:
            customer_id: Customer ID

        Returns:
            Customer object or None
        """
        return Customer.query.filter_by(id=customer_id).first()

    @staticmethod
    def get_by_user_id(user_id):
        """
        Get customer by user ID.

        Args:
            user_id: User ID

        Returns:
            Customer object or None
        """
        return Customer.query.filter_by(user_id=user_id).first()

    @staticmethod
    def get_profile(user_id):
        """
        Get customer profile with user details.

        Args:
            user_id: User ID

        Returns:
            Customer object with eager-loaded user

        Raises:
            CustomerNotFoundError: If customer not found
        """
        customer = Customer.query.options(
            joinedload(Customer.user)
        ).filter_by(user_id=user_id).first()

        if not customer:
            raise CustomerNotFoundError(f"Customer not found for user_id: {user_id}")

        return customer

    @staticmethod
    def update_profile(user_id, data):
        """
        Update customer profile.

        Updates both Customer and User models based on provided data.

        Args:
            user_id: User ID
            data: Dictionary of fields to update

        Returns:
            Updated Customer object

        Raises:
            CustomerNotFoundError: If customer not found
        """
        customer = CustomerService.get_profile(user_id)

        # Allowed customer fields
        customer_fields = ['billing_address', 'city', 'district']

        # Allowed user fields
        user_fields = ['first_name', 'last_name', 'phone']

        # Update customer fields
        for key in customer_fields:
            if key in data:
                setattr(customer, key, data[key])

        # Update user fields
        for key in user_fields:
            if key in data:
                setattr(customer.user, key, data[key])

        customer.updated_at = datetime.utcnow()
        db.session.commit()

        logger.info(f"Updated customer profile for user_id: {user_id}")
        return customer

    @staticmethod
    def get_quotes_for_customer(customer_id, status=None, page=1, per_page=10):
        """
        Get all quotes for a customer with optional filtering.

        Args:
            customer_id: Customer ID
            status: Optional status filter ('pending', 'quoted', 'accepted', 'rejected', 'completed')
            page: Page number for pagination
            per_page: Items per page

        Returns:
            Paginated query result with quotes
        """
        query = Quote.query.filter_by(customer_id=customer_id)

        if status:
            query = query.filter_by(status=status)

        quotes = query.order_by(Quote.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )

        return quotes

    @staticmethod
    def accept_quote(customer_id, quote_id):
        """
        Accept a quote.

        Business rules:
        - Quote must belong to the customer
        - Quote must be in 'quoted' status
        - Sets status to 'accepted' and records accepted_at timestamp

        Args:
            customer_id: Customer ID
            quote_id: Quote ID

        Returns:
            Updated Quote object

        Raises:
            QuoteNotFoundError: If quote not found
            QuoteAccessDeniedError: If quote doesn't belong to customer
            QuoteStatusError: If quote is not in 'quoted' status
        """
        quote = Quote.query.filter_by(id=quote_id).first()

        if not quote:
            raise QuoteNotFoundError(f"Quote {quote_id} not found")

        if quote.customer_id != customer_id:
            raise QuoteAccessDeniedError(
                f"Quote {quote_id} does not belong to customer {customer_id}"
            )

        if quote.status != 'quoted':
            raise QuoteStatusError(
                f"Cannot accept quote in status '{quote.status}'. Must be 'quoted'"
            )

        quote.status = 'accepted'
        quote.accepted_at = datetime.utcnow()
        db.session.commit()

        logger.info(f"Customer {customer_id} accepted quote {quote_id}")
        return quote

    @staticmethod
    def reject_quote(customer_id, quote_id, reason=None):
        """
        Reject a quote.

        Business rules:
        - Quote must belong to the customer
        - Quote must be in 'quoted' or 'pending' status
        - Sets status to 'rejected' and optionally records rejection reason

        Args:
            customer_id: Customer ID
            quote_id: Quote ID
            reason: Optional rejection reason

        Returns:
            Updated Quote object

        Raises:
            QuoteNotFoundError: If quote not found
            QuoteAccessDeniedError: If quote doesn't belong to customer
            QuoteStatusError: If quote cannot be rejected
        """
        quote = Quote.query.filter_by(id=quote_id).first()

        if not quote:
            raise QuoteNotFoundError(f"Quote {quote_id} not found")

        if quote.customer_id != customer_id:
            raise QuoteAccessDeniedError(
                f"Quote {quote_id} does not belong to customer {customer_id}"
            )

        if quote.status not in ['quoted', 'pending']:
            raise QuoteStatusError(
                f"Cannot reject quote in status '{quote.status}'"
            )

        quote.status = 'rejected'
        if reason and hasattr(quote, 'rejection_reason'):
            quote.rejection_reason = reason
        db.session.commit()

        logger.info(f"Customer {customer_id} rejected quote {quote_id}")
        return quote

    @staticmethod
    def get_reviews(customer_id):
        """
        Get all reviews written by a customer.

        Args:
            customer_id: Customer ID

        Returns:
            List of Review objects
        """
        reviews = Review.query.filter_by(customer_id=customer_id).order_by(
            Review.created_at.desc()
        ).all()

        return reviews

    @staticmethod
    def create_review(customer_id, craftsman_id, rating, comment):
        """
        Create a review for a craftsman.

        Business rules:
        - Customer must have completed at least one job with the craftsman
        - Customer can only create one review per craftsman
        - Rating must be between 1 and 5

        Args:
            customer_id: Customer ID
            craftsman_id: Craftsman ID
            rating: Rating (1-5)
            comment: Review comment

        Returns:
            Created Review object

        Raises:
            ReviewValidationError: If validation fails
            NoCompletedJobError: If no completed job exists
            ReviewAlreadyExistsError: If review already exists
        """
        # Validate rating
        if not isinstance(rating, (int, float)) or rating < 1 or rating > 5:
            raise ReviewValidationError("Rating must be between 1 and 5")

        if not comment or len(comment.strip()) < 10:
            raise ReviewValidationError("Comment must be at least 10 characters")

        # Check if craftsman exists
        craftsman = Craftsman.query.filter_by(id=craftsman_id).first()
        if not craftsman:
            raise ReviewValidationError(f"Craftsman {craftsman_id} not found")

        # Check for completed job between customer and craftsman
        # Try both craftsman_id and assigned_craftsman_id fields
        completed_job = Job.query.filter(
            Job.customer_id == customer_id,
            Job.status == 'completed'
        ).filter(
            (Job.craftsman_id == craftsman_id) if hasattr(Job, 'craftsman_id')
            else (Job.assigned_craftsman_id == craftsman_id)
        ).first()

        if not completed_job:
            raise NoCompletedJobError(
                f"Customer {customer_id} has no completed jobs with craftsman {craftsman_id}"
            )

        # Check if review already exists
        existing_review = Review.query.filter_by(
            customer_id=customer_id,
            craftsman_id=craftsman_id
        ).first()

        if existing_review:
            raise ReviewAlreadyExistsError(
                f"Customer {customer_id} already reviewed craftsman {craftsman_id}"
            )

        # Create review
        review = Review(
            customer_id=customer_id,
            craftsman_id=craftsman_id,
            rating=rating,
            comment=comment.strip(),
            created_at=datetime.utcnow()
        )

        db.session.add(review)
        db.session.commit()

        # Update craftsman's average rating and review count
        CustomerService._update_craftsman_rating(craftsman_id)

        logger.info(f"Customer {customer_id} created review for craftsman {craftsman_id}")
        return review

    @staticmethod
    def _update_craftsman_rating(craftsman_id):
        """
        Update craftsman's average rating and total reviews count.

        Args:
            craftsman_id: Craftsman ID
        """
        craftsman = Craftsman.query.filter_by(id=craftsman_id).first()
        if not craftsman:
            return

        # Calculate average rating
        result = db.session.query(
            func.avg(Review.rating).label('avg_rating'),
            func.count(Review.id).label('total_reviews')
        ).filter_by(craftsman_id=craftsman_id).first()

        craftsman.average_rating = round(result.avg_rating, 2) if result.avg_rating else 0
        craftsman.total_reviews = result.total_reviews or 0
        db.session.commit()

    @staticmethod
    def get_favorites(customer_id):
        """
        Get customer's favorite craftsmen.

        Args:
            customer_id: Customer ID

        Returns:
            List of Craftsman objects

        Note:
            TODO: Requires a CustomerFavorite junction table to be implemented.
            For now, returns empty list.
        """
        # TODO: Implement favorites functionality
        # Requires CustomerFavorite model with customer_id and craftsman_id
        # Example implementation:
        # favorites = db.session.query(Craftsman).join(
        #     CustomerFavorite,
        #     CustomerFavorite.craftsman_id == Craftsman.id
        # ).filter(CustomerFavorite.customer_id == customer_id).all()

        logger.warning(f"Favorites not implemented - returning empty list for customer {customer_id}")
        return []

    @staticmethod
    def get_statistics(customer_id):
        """
        Get customer statistics.

        Calculates:
        - Total quotes requested
        - Active quotes (pending, quoted)
        - Completed jobs
        - Total reviews given
        - Total spent (sum of completed job prices)
        - Member since date

        Args:
            customer_id: Customer ID

        Returns:
            Dictionary with statistics

        Raises:
            CustomerNotFoundError: If customer not found
        """
        customer = CustomerService.get_by_id(customer_id)
        if not customer:
            raise CustomerNotFoundError(f"Customer {customer_id} not found")

        # Total quotes
        total_quotes = Quote.query.filter_by(customer_id=customer_id).count()

        # Active quotes (pending or quoted status)
        active_quotes = Quote.query.filter_by(customer_id=customer_id).filter(
            Quote.status.in_(['pending', 'quoted'])
        ).count()

        # Completed jobs
        completed_jobs = Job.query.filter_by(
            customer_id=customer_id,
            status='completed'
        ).count()

        # Total reviews given
        total_reviews_given = Review.query.filter_by(customer_id=customer_id).count()

        # Calculate total spent
        # Try to use Job.price first, fall back to Quote.amount
        total_spent = 0
        try:
            if hasattr(Job, 'price'):
                total_spent_result = db.session.query(
                    func.sum(Job.price).label('total_spent')
                ).filter_by(
                    customer_id=customer_id,
                    status='completed'
                ).first()
                total_spent = float(total_spent_result.total_spent or 0)
            else:
                # Fall back to Quote.amount for completed quotes
                logger.warning("Job.price field not found, calculating from quotes")
                total_spent_result = db.session.query(
                    func.sum(Quote.amount).label('total_spent')
                ).filter_by(
                    customer_id=customer_id,
                    status='completed'
                ).first()
                total_spent = float(total_spent_result.total_spent or 0)
        except AttributeError as e:
            logger.error(f"Error calculating total_spent (missing field): {e}")
            total_spent = 0
        except Exception as e:
            logger.error(f"Error calculating total_spent: {e}")
            total_spent = 0

        statistics = {
            'total_quotes': total_quotes,
            'active_quotes': active_quotes,
            'completed_jobs': completed_jobs,
            'total_reviews_given': total_reviews_given,
            'total_spent': total_spent,
            'member_since': customer.created_at.isoformat() if customer.created_at else None
        }

        return statistics
