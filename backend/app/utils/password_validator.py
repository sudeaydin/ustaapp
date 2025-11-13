"""
Password validation utilities for enhanced security
"""
import re
from typing import Tuple

# Common weak passwords list (Turkish and English)
COMMON_PASSWORDS = {
    '123456', 'password', 'qwerty', '12345678', '111111', '123123',
    'password123', '1q2w3e4r', 'admin', 'letmein', 'welcome',
    'monkey', 'dragon', 'master', 'sunshine', 'princess',
    'sifre', 'parola', '123456789', 'qwerty123', 'abc123',
    'password1', '12341234', 'test123', 'admin123', 'welcome123'
}


def validate_password_strength(password: str) -> Tuple[bool, str]:
    """
    Validate password strength according to security requirements.
    
    Requirements:
    - Minimum 8 characters
    - At least 1 uppercase letter
    - At least 1 lowercase letter
    - At least 1 number
    - At least 1 special character
    - Not in common passwords list
    
    Args:
        password: The password to validate
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    
    # Check minimum length
    if len(password) < 8:
        return False, "Şifre en az 8 karakter olmalıdır"
    
    # Check maximum length (prevent DoS)
    if len(password) > 128:
        return False, "Şifre en fazla 128 karakter olabilir"
    
    # Check for uppercase letter
    if not re.search(r'[A-Z]', password):
        return False, "Şifre en az bir büyük harf içermelidir"
    
    # Check for lowercase letter
    if not re.search(r'[a-z]', password):
        return False, "Şifre en az bir küçük harf içermelidir"
    
    # Check for digit
    if not re.search(r'\d', password):
        return False, "Şifre en az bir rakam içermelidir"
    
    # Check for special character
    if not re.search(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/]', password):
        return False, "Şifre en az bir özel karakter içermelidir (!@#$%^&* vb.)"
    
    # Check against common passwords
    if password.lower() in COMMON_PASSWORDS:
        return False, "Bu şifre çok yaygın kullanılıyor. Lütfen daha güçlü bir şifre seçin"
    
    # Check for sequential characters (123, abc, etc.)
    if has_sequential_chars(password):
        return False, "Şifre ardışık karakterler içermemeli (123, abc vb.)"
    
    # Check for repeated characters (aaa, 111, etc.)
    if has_repeated_chars(password):
        return False, "Şifre çok fazla tekrar eden karakter içermemeli"
    
    return True, ""


def has_sequential_chars(password: str, max_sequential: int = 3) -> bool:
    """
    Check if password contains sequential characters.
    
    Args:
        password: Password to check
        max_sequential: Maximum allowed sequential characters
        
    Returns:
        True if password has too many sequential characters
    """
    password_lower = password.lower()
    
    for i in range(len(password_lower) - max_sequential + 1):
        # Check for sequential numbers
        try:
            nums = [int(password_lower[i + j]) for j in range(max_sequential)]
            if all(nums[j] == nums[0] + j for j in range(max_sequential)):
                return True
            if all(nums[j] == nums[0] - j for j in range(max_sequential)):
                return True
        except ValueError:
            pass
        
        # Check for sequential letters
        chars = [ord(password_lower[i + j]) for j in range(max_sequential)]
        if all(chars[j] == chars[0] + j for j in range(max_sequential)):
            return True
        if all(chars[j] == chars[0] - j for j in range(max_sequential)):
            return True
    
    return False


def has_repeated_chars(password: str, max_repeat: int = 3) -> bool:
    """
    Check if password has too many repeated characters.
    
    Args:
        password: Password to check
        max_repeat: Maximum allowed repeated characters
        
    Returns:
        True if password has too many repeated characters
    """
    for i in range(len(password) - max_repeat + 1):
        if len(set(password[i:i + max_repeat])) == 1:
            return True
    
    return False


def calculate_password_strength(password: str) -> dict:
    """
    Calculate password strength score and provide feedback.
    
    Args:
        password: Password to analyze
        
    Returns:
        Dict with strength score (0-100) and feedback
    """
    score = 0
    feedback = []
    
    # Length score (max 25 points)
    length = len(password)
    if length >= 8:
        score += min(25, (length - 7) * 3)
    
    # Character variety (max 40 points)
    if re.search(r'[a-z]', password):
        score += 10
    if re.search(r'[A-Z]', password):
        score += 10
    if re.search(r'\d', password):
        score += 10
    if re.search(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/]', password):
        score += 10
    
    # No common password (20 points)
    if password.lower() not in COMMON_PASSWORDS:
        score += 20
    else:
        feedback.append("Yaygın bir şifre kullanıyorsunuz")
    
    # No sequential chars (10 points)
    if not has_sequential_chars(password):
        score += 10
    else:
        feedback.append("Ardışık karakterler içeriyor")
    
    # No repeated chars (5 points)
    if not has_repeated_chars(password):
        score += 5
    else:
        feedback.append("Çok fazla tekrar eden karakter var")
    
    # Determine strength level
    if score >= 80:
        strength = "Çok Güçlü"
        color = "green"
    elif score >= 60:
        strength = "Güçlü"
        color = "lightgreen"
    elif score >= 40:
        strength = "Orta"
        color = "orange"
    else:
        strength = "Zayıf"
        color = "red"
    
    return {
        'score': score,
        'strength': strength,
        'color': color,
        'feedback': feedback
    }
