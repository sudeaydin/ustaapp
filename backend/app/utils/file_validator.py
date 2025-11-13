"""
File upload validation and security utilities
"""
import os
import magic
from werkzeug.utils import secure_filename
from typing import Tuple
import re

# Allowed file extensions
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'pdf'}

# Maximum file size (5MB)
MAX_FILE_SIZE = 5 * 1024 * 1024

# MIME type whitelist
ALLOWED_MIME_TYPES = {
    'image/png': 'png',
    'image/jpeg': 'jpg',
    'image/jpg': 'jpg',
    'image/gif': 'gif',
    'image/webp': 'webp',
    'application/pdf': 'pdf'
}


def validate_file_extension(filename: str) -> bool:
    """
    Check if file extension is allowed.
    
    Args:
        filename: Name of the file
        
    Returns:
        True if extension is allowed
    """
    if '.' not in filename:
        return False
    
    extension = filename.rsplit('.', 1)[1].lower()
    return extension in ALLOWED_EXTENSIONS


def get_mime_type(file_content: bytes) -> str:
    """
    Get MIME type from file content (magic number check).
    
    Args:
        file_content: File content as bytes
        
    Returns:
        MIME type string
    """
    try:
        mime = magic.Magic(mime=True)
        return mime.from_buffer(file_content)
    except:
        # Fallback if python-magic is not available
        return 'application/octet-stream'


def validate_file_content(file_content: bytes) -> Tuple[bool, str]:
    """
    Validate file content using magic number.
    
    Args:
        file_content: File content as bytes
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    mime_type = get_mime_type(file_content)
    
    if mime_type not in ALLOWED_MIME_TYPES:
        return False, f"Dosya tipi desteklenmiyor: {mime_type}"
    
    return True, ""


def validate_file_size(file_size: int) -> Tuple[bool, str]:
    """
    Check if file size is within limits.
    
    Args:
        file_size: Size of file in bytes
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    if file_size > MAX_FILE_SIZE:
        max_mb = MAX_FILE_SIZE / (1024 * 1024)
        return False, f"Dosya boyutu çok büyük. Maksimum {max_mb}MB"
    
    if file_size == 0:
        return False, "Dosya boş olamaz"
    
    return True, ""


def sanitize_filename(filename: str) -> str:
    """
    Sanitize filename to prevent path traversal and other attacks.
    
    Args:
        filename: Original filename
        
    Returns:
        Sanitized filename
    """
    # Use werkzeug's secure_filename
    filename = secure_filename(filename)
    
    # Additional sanitization
    # Remove any remaining special characters
    filename = re.sub(r'[^a-zA-Z0-9._-]', '_', filename)
    
    # Limit filename length
    name, ext = os.path.splitext(filename)
    if len(name) > 100:
        name = name[:100]
    
    return name + ext


def validate_image_file(file_path: str) -> Tuple[bool, str]:
    """
    Comprehensive validation for image files.
    
    Args:
        file_path: Path to the file
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    try:
        from PIL import Image
        
        # Try to open and verify the image
        img = Image.open(file_path)
        img.verify()
        
        # Check image dimensions (prevent decompression bomb)
        img = Image.open(file_path)  # Reopen after verify
        width, height = img.size
        
        # Maximum dimensions: 4096x4096
        if width > 4096 or height > 4096:
            return False, "Görsel boyutları çok büyük (max 4096x4096)"
        
        # Check for suspicious metadata
        exif = img._getexif() if hasattr(img, '_getexif') else None
        if exif:
            # Remove GPS data for privacy
            gps_tags = [0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007]
            for tag in gps_tags:
                if tag in exif:
                    del exif[tag]
        
        return True, ""
        
    except Exception as e:
        return False, f"Geçersiz görsel dosyası: {str(e)}"


def validate_uploaded_file(file) -> Tuple[bool, str, str]:
    """
    Complete validation for uploaded file.
    
    Args:
        file: FileStorage object from Flask
        
    Returns:
        Tuple of (is_valid, error_message, sanitized_filename)
    """
    # Check if file exists
    if not file:
        return False, "Dosya seçilmedi", ""
    
    # Check if filename exists
    if not file.filename:
        return False, "Dosya adı geçersiz", ""
    
    # Validate extension
    if not validate_file_extension(file.filename):
        return False, "Dosya uzantısı desteklenmiyor", ""
    
    # Sanitize filename
    safe_filename = sanitize_filename(file.filename)
    
    # Read file content
    file_content = file.read()
    file.seek(0)  # Reset file pointer
    
    # Validate size
    is_valid, error = validate_file_size(len(file_content))
    if not is_valid:
        return False, error, ""
    
    # Validate content (magic number)
    is_valid, error = validate_file_content(file_content)
    if not is_valid:
        return False, error, ""
    
    return True, "", safe_filename


def scan_file_for_viruses(file_path: str) -> Tuple[bool, str]:
    """
    Scan file for viruses using ClamAV (if available).
    
    Args:
        file_path: Path to the file
        
    Returns:
        Tuple of (is_clean, message)
    """
    try:
        import pyclamd
        
        # Try to connect to ClamAV daemon
        cd = pyclamd.ClamdUnixSocket()
        
        # Scan the file
        scan_result = cd.scan_file(file_path)
        
        if scan_result is None:
            return True, "Dosya temiz"
        else:
            return False, f"Virüs tespit edildi: {scan_result}"
            
    except ImportError:
        # ClamAV not available, skip virus scanning
        return True, "Virüs taraması yapılamadı (ClamAV kurulu değil)"
    except Exception as e:
        # ClamAV error, log but don't block upload
        return True, f"Virüs tarama hatası: {str(e)}"


def get_safe_upload_path(base_path: str, filename: str) -> str:
    """
    Get safe upload path outside web root.
    
    Args:
        base_path: Base upload directory
        filename: Sanitized filename
        
    Returns:
        Safe absolute path
    """
    # Ensure base path is absolute
    base_path = os.path.abspath(base_path)
    
    # Create full path
    full_path = os.path.join(base_path, filename)
    
    # Verify path is within base_path (prevent directory traversal)
    if not os.path.abspath(full_path).startswith(base_path):
        raise ValueError("Invalid upload path")
    
    return full_path
