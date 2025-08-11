from flask import Blueprint, request, jsonify
from app.utils.accessibility import (
    AccessibilityValidator, 
    AccessibilityContentGenerator, 
    AccessibilityReporter,
    AccessibilityContentOptimizer
)
from app.utils.security import rate_limit, require_auth

accessibility_bp = Blueprint('accessibility', __name__)

@accessibility_bp.route('/validate/alt-text', methods=['POST'])
@rate_limit(requests_per_minute=60)
def validate_alt_text():
    """Validate alt text for accessibility compliance"""
    try:
        data = request.get_json()
        alt_text = data.get('alt_text', '')
        context = data.get('context', '')
        
        validation_result = AccessibilityValidator.validate_alt_text(alt_text, context)
        
        return jsonify({
            'success': True,
            'data': validation_result
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Alt text validation failed: {str(e)}'
        }), 500

@accessibility_bp.route('/validate/color-contrast', methods=['POST'])
@rate_limit(requests_per_minute=60)
def validate_color_contrast():
    """Validate color contrast for WCAG compliance"""
    try:
        data = request.get_json()
        foreground = data.get('foreground')
        background = data.get('background')
        
        if not foreground or not background:
            return jsonify({
                'success': False,
                'message': 'Both foreground and background colors are required'
            }), 400
        
        contrast_result = AccessibilityValidator.check_color_contrast(foreground, background)
        
        return jsonify({
            'success': True,
            'data': contrast_result
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Color contrast validation failed: {str(e)}'
        }), 500

@accessibility_bp.route('/validate/heading-structure', methods=['POST'])
@rate_limit(requests_per_minute=30)
def validate_heading_structure():
    """Validate heading hierarchy in content"""
    try:
        data = request.get_json()
        content = data.get('content', '')
        
        if not content:
            return jsonify({
                'success': False,
                'message': 'Content is required'
            }), 400
        
        heading_result = AccessibilityValidator.validate_heading_structure(content)
        
        return jsonify({
            'success': True,
            'data': heading_result
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Heading structure validation failed: {str(e)}'
        }), 500

@accessibility_bp.route('/validate/form', methods=['POST'])
@rate_limit(requests_per_minute=60)
def validate_form_accessibility():
    """Validate form accessibility"""
    try:
        data = request.get_json()
        form_data = data.get('form_data', {})
        
        validation_result = AccessibilityValidator.validate_form_labels(form_data)
        
        return jsonify({
            'success': True,
            'data': validation_result
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Form validation failed: {str(e)}'
        }), 500

@accessibility_bp.route('/generate/alt-text-suggestions', methods=['POST'])
@rate_limit(requests_per_minute=60)
def generate_alt_text_suggestions():
    """Generate alt text suggestions"""
    try:
        data = request.get_json()
        context = data.get('context', '')
        image_type = data.get('image_type', 'general')
        
        suggestions = AccessibilityContentGenerator.generate_alt_text_suggestions(context, image_type)
        
        return jsonify({
            'success': True,
            'data': {
                'suggestions': suggestions,
                'context': context,
                'image_type': image_type
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Alt text generation failed: {str(e)}'
        }), 500

@accessibility_bp.route('/generate/aria-labels', methods=['POST'])
@rate_limit(requests_per_minute=60)
def generate_aria_labels():
    """Generate ARIA labels for content"""
    try:
        data = request.get_json()
        content_type = data.get('content_type', '')
        context = data.get('context', {})
        
        if not content_type:
            return jsonify({
                'success': False,
                'message': 'Content type is required'
            }), 400
        
        aria_labels = AccessibilityContentGenerator.generate_aria_labels(content_type, context)
        
        return jsonify({
            'success': True,
            'data': aria_labels
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'ARIA label generation failed: {str(e)}'
        }), 500

@accessibility_bp.route('/optimize/content', methods=['POST'])
@rate_limit(requests_per_minute=30)
def optimize_content():
    """Optimize content for accessibility"""
    try:
        data = request.get_json()
        content = data.get('content', '')
        content_type = data.get('content_type', 'text')
        
        if not content:
            return jsonify({
                'success': False,
                'message': 'Content is required'
            }), 400
        
        if content_type == 'text':
            optimized = AccessibilityContentOptimizer.optimize_text_content(content)
        elif content_type == 'form':
            optimized = AccessibilityContentOptimizer.optimize_form_structure(content)
        else:
            optimized = content
        
        return jsonify({
            'success': True,
            'data': {
                'original': content,
                'optimized': optimized,
                'content_type': content_type
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Content optimization failed: {str(e)}'
        }), 500

@accessibility_bp.route('/report/page', methods=['POST'])
@rate_limit(requests_per_minute=20)
@require_auth
def generate_page_report():
    """Generate accessibility report for a page"""
    try:
        data = request.get_json()
        page_content = data.get('page_content', '')
        page_url = data.get('page_url', '')
        
        if not page_content:
            return jsonify({
                'success': False,
                'message': 'Page content is required'
            }), 400
        
        report = AccessibilityReporter.generate_page_report(page_content, page_url)
        
        return jsonify({
            'success': True,
            'data': report
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Report generation failed: {str(e)}'
        }), 500

@accessibility_bp.route('/report/color-palette', methods=['POST'])
@rate_limit(requests_per_minute=20)
@require_auth
def generate_color_palette_report():
    """Generate accessibility report for color palette"""
    try:
        data = request.get_json()
        colors = data.get('colors', {})
        
        if not colors:
            return jsonify({
                'success': False,
                'message': 'Color palette is required'
            }), 400
        
        report = AccessibilityReporter.generate_color_palette_report(colors)
        
        return jsonify({
            'success': True,
            'data': report
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Color palette report generation failed: {str(e)}'
        }), 500

@accessibility_bp.route('/check/app-colors', methods=['GET'])
@rate_limit(requests_per_minute=30)
def check_app_color_accessibility():
    """Check accessibility of app's color palette"""
    try:
        # UstamApp color palette
        app_colors = {
            "poppy": "#E63946",
            "mint-green": "#2D9CDB", 
            "non-photo-blue": "#A8DADC",
            "ucla-blue": "#467599",
            "delft-blue": "#1D3354",
            "white": "#FFFFFF",
            "black": "#000000",
            "gray-light": "#F8F9FA",
            "gray-medium": "#6C757D",
            "gray-dark": "#343A40"
        }
        
        report = AccessibilityReporter.generate_color_palette_report(app_colors)
        
        return jsonify({
            'success': True,
            'data': {
                'app_colors': app_colors,
                'accessibility_report': report
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'App color check failed: {str(e)}'
        }), 500

@accessibility_bp.route('/guidelines', methods=['GET'])
@rate_limit(requests_per_minute=30)
def get_accessibility_guidelines():
    """Get accessibility guidelines and best practices"""
    try:
        guidelines = {
            "wcag_levels": {
                "A": "Minimum level of accessibility",
                "AA": "Standard level for most websites",
                "AAA": "Enhanced level for specialized content"
            },
            "color_contrast": {
                "normal_text": "4.5:1 ratio for AA compliance",
                "large_text": "3:1 ratio for AA compliance (18pt+ or 14pt+ bold)",
                "aaa_normal": "7:1 ratio for AAA compliance",
                "aaa_large": "4.5:1 ratio for AAA compliance"
            },
            "keyboard_navigation": {
                "tab_order": "Logical tab order through interactive elements",
                "focus_indicators": "Visible focus indicators for all interactive elements",
                "skip_links": "Skip links to main content and navigation",
                "keyboard_shortcuts": "Keyboard alternatives for mouse actions"
            },
            "screen_readers": {
                "alt_text": "Descriptive alt text for all images",
                "aria_labels": "ARIA labels for complex UI elements",
                "semantic_html": "Use semantic HTML elements (header, nav, main, etc.)",
                "heading_structure": "Logical heading hierarchy (h1-h6)"
            },
            "forms": {
                "labels": "All form inputs must have associated labels",
                "error_messages": "Clear error messages with role='alert'",
                "required_fields": "Mark required fields with aria-required",
                "fieldsets": "Group related form fields with fieldsets"
            },
            "content": {
                "language": "Specify page language with lang attribute",
                "reading_order": "Logical reading order for content",
                "link_text": "Descriptive link text (avoid 'click here')",
                "abbreviations": "Expand abbreviations on first use"
            }
        }
        
        return jsonify({
            'success': True,
            'data': guidelines
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Guidelines retrieval failed: {str(e)}'
        }), 500

@accessibility_bp.route('/tools/contrast-checker', methods=['POST'])
@rate_limit(requests_per_minute=60)
def contrast_checker_tool():
    """Interactive contrast checker tool"""
    try:
        data = request.get_json()
        foreground = data.get('foreground')
        background = data.get('background')
        font_size = data.get('font_size', 16)  # in pixels
        font_weight = data.get('font_weight', 'normal')
        
        if not foreground or not background:
            return jsonify({
                'success': False,
                'message': 'Both colors are required'
            }), 400
        
        contrast_result = AccessibilityValidator.check_color_contrast(foreground, background)
        
        # Determine if it's large text
        is_large_text = (
            font_size >= 18 or 
            (font_size >= 14 and font_weight in ['bold', '600', '700', '800', '900'])
        )
        
        # Adjust validation for large text
        if is_large_text:
            contrast_result['valid'] = contrast_result['ratio'] >= 3.0
            contrast_result['required_ratio'] = 3.0
            contrast_result['text_size'] = 'large'
        else:
            contrast_result['required_ratio'] = 4.5
            contrast_result['text_size'] = 'normal'
        
        return jsonify({
            'success': True,
            'data': {
                'contrast': contrast_result,
                'input': {
                    'foreground': foreground,
                    'background': background,
                    'font_size': font_size,
                    'font_weight': font_weight,
                    'is_large_text': is_large_text
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Contrast check failed: {str(e)}'
        }), 500