"""
Customer domain exceptions

Custom exceptions for customer-related business logic errors.
"""


class CustomerError(Exception):
    """Base exception for customer-related errors"""
    pass


class CustomerNotFoundError(CustomerError):
    """Raised when a customer is not found"""
    pass


class QuoteNotFoundError(CustomerError):
    """Raised when a quote is not found"""
    pass


class QuoteAccessDeniedError(CustomerError):
    """Raised when customer tries to access a quote that doesn't belong to them"""
    pass


class QuoteStatusError(CustomerError):
    """Raised when quote action is not allowed in current status"""
    pass


class ReviewValidationError(CustomerError):
    """Raised when review validation fails"""
    pass


class ReviewAlreadyExistsError(CustomerError):
    """Raised when customer tries to create duplicate review"""
    pass


class NoCompletedJobError(CustomerError):
    """Raised when customer hasn't completed a job with the craftsman"""
    pass
