from flask_jwt_extended import get_jwt_identity

def get_current_user_id():
    """
    Get current user ID from JWT token as integer
    Handles the conversion from string to integer consistently
    """
    try:
        identity = get_jwt_identity()
        return int(identity) if identity else None
    except (ValueError, TypeError):
        return None

def get_current_user_id_str():
    """
    Get current user ID from JWT token as string
    For cases where string ID is needed
    """
    return get_jwt_identity()