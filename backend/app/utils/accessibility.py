"""
Accessibility utilities for backend content validation and WCAG compliance
"""

import re
from typing import Dict, List, Optional, Tuple
from PIL import Image, ImageDraw, ImageFont
import colorsys

class AccessibilityValidator:
    """Validates content for accessibility compliance"""
    
    @staticmethod
    def validate_alt_text(alt_text: str, image_context: str = "") -> Dict[str, any]:
        """Validate alt text for images"""
        if not alt_text:
            return {
                "valid": False,
                "issues": ["Alt text is missing"],
                "suggestions": ["Add descriptive alt text for the image"]
            }
        
        issues = []
        suggestions = []
        
        # Check length
        if len(alt_text) > 125:
            issues.append("Alt text is too long (over 125 characters)")
            suggestions.append("Keep alt text concise and descriptive")
        
        # Check for redundant phrases
        redundant_phrases = [
            "image of", "picture of", "photo of", "graphic of",
            "resim", "fotoğraf", "görsel", "görüntü"
        ]
        
        for phrase in redundant_phrases:
            if phrase.lower() in alt_text.lower():
                issues.append(f"Contains redundant phrase: '{phrase}'")
                suggestions.append(f"Remove redundant phrase '{phrase}' from alt text")
        
        # Check if it's just filename
        if re.match(r'^[a-zA-Z0-9_\-\.]+\.(jpg|jpeg|png|gif|svg)$', alt_text, re.IGNORECASE):
            issues.append("Alt text appears to be a filename")
            suggestions.append("Replace filename with descriptive text")
        
        return {
            "valid": len(issues) == 0,
            "issues": issues,
            "suggestions": suggestions,
            "length": len(alt_text)
        }
    
    @staticmethod
    def validate_heading_structure(content: str) -> Dict[str, any]:
        """Validate heading hierarchy in content"""
        # Extract headings from HTML content
        heading_pattern = r'<h([1-6])[^>]*>(.*?)</h[1-6]>'
        headings = re.findall(heading_pattern, content, re.IGNORECASE | re.DOTALL)
        
        issues = []
        suggestions = []
        
        if not headings:
            return {
                "valid": True,
                "issues": [],
                "suggestions": [],
                "headings": []
            }
        
        previous_level = 0
        
        for i, (level_str, text) in enumerate(headings):
            level = int(level_str)
            clean_text = re.sub(r'<[^>]+>', '', text).strip()
            
            # Check for empty headings
            if not clean_text:
                issues.append(f"Empty heading at position {i+1}")
                suggestions.append("Add meaningful text to all headings")
            
            # Check heading hierarchy
            if i == 0 and level != 1:
                issues.append("First heading should be H1")
                suggestions.append("Start with H1 for main page title")
            
            if level > previous_level + 1:
                issues.append(f"Heading level jumps from H{previous_level} to H{level}")
                suggestions.append("Don't skip heading levels")
            
            previous_level = level
        
        return {
            "valid": len(issues) == 0,
            "issues": issues,
            "suggestions": suggestions,
            "headings": [{"level": int(h[0]), "text": re.sub(r'<[^>]+>', '', h[1]).strip()} for h in headings]
        }
    
    @staticmethod
    def check_color_contrast(foreground: str, background: str) -> Dict[str, any]:
        """Check color contrast ratio between foreground and background"""
        try:
            fg_rgb = AccessibilityValidator._hex_to_rgb(foreground)
            bg_rgb = AccessibilityValidator._hex_to_rgb(background)
            
            if not fg_rgb or not bg_rgb:
                return {
                    "valid": False,
                    "ratio": 0,
                    "level": "FAIL",
                    "issues": ["Invalid color format"]
                }
            
            ratio = AccessibilityValidator._calculate_contrast_ratio(fg_rgb, bg_rgb)
            
            # WCAG standards
            level = "FAIL"
            if ratio >= 7:
                level = "AAA"
            elif ratio >= 4.5:
                level = "AA"
            elif ratio >= 3:
                level = "AA Large"
            
            return {
                "valid": ratio >= 4.5,
                "ratio": round(ratio, 2),
                "level": level,
                "issues": [] if ratio >= 4.5 else ["Color contrast ratio is below WCAG AA standard (4.5:1)"],
                "suggestions": [] if ratio >= 4.5 else ["Increase contrast between text and background colors"]
            }
            
        except Exception as e:
            return {
                "valid": False,
                "ratio": 0,
                "level": "ERROR",
                "issues": [f"Error calculating contrast: {str(e)}"]
            }
    
    @staticmethod
    def _hex_to_rgb(hex_color: str) -> Optional[Tuple[int, int, int]]:
        """Convert hex color to RGB tuple"""
        hex_color = hex_color.lstrip('#')
        if len(hex_color) != 6:
            return None
        
        try:
            return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
        except ValueError:
            return None
    
    @staticmethod
    def _calculate_contrast_ratio(rgb1: Tuple[int, int, int], rgb2: Tuple[int, int, int]) -> float:
        """Calculate contrast ratio between two RGB colors"""
        l1 = AccessibilityValidator._get_relative_luminance(rgb1)
        l2 = AccessibilityValidator._get_relative_luminance(rgb2)
        
        lighter = max(l1, l2)
        darker = min(l1, l2)
        
        return (lighter + 0.05) / (darker + 0.05)
    
    @staticmethod
    def _get_relative_luminance(rgb: Tuple[int, int, int]) -> float:
        """Calculate relative luminance of RGB color"""
        r, g, b = rgb
        
        def normalize(val):
            val = val / 255.0
            return val / 12.92 if val <= 0.03928 else pow((val + 0.055) / 1.055, 2.4)
        
        return 0.2126 * normalize(r) + 0.7152 * normalize(g) + 0.0722 * normalize(b)
    
    @staticmethod
    def validate_form_labels(form_data: Dict) -> Dict[str, any]:
        """Validate form accessibility"""
        issues = []
        suggestions = []
        
        for field_name, field_value in form_data.items():
            # Check for proper field naming
            if not field_name or len(field_name) < 2:
                issues.append(f"Field '{field_name}' has insufficient label")
                suggestions.append("Use descriptive field names")
            
            # Check for placeholder-only labels (anti-pattern)
            if isinstance(field_value, dict):
                if field_value.get('placeholder') and not field_value.get('label'):
                    issues.append(f"Field '{field_name}' uses placeholder as label")
                    suggestions.append("Add proper label in addition to placeholder")
        
        return {
            "valid": len(issues) == 0,
            "issues": issues,
            "suggestions": suggestions
        }

class AccessibilityContentGenerator:
    """Generate accessible content and alternatives"""
    
    @staticmethod
    def generate_alt_text_suggestions(image_context: str, image_type: str = "general") -> List[str]:
        """Generate alt text suggestions based on context"""
        suggestions = []
        
        context_lower = image_context.lower()
        
        if "profile" in context_lower or "avatar" in context_lower:
            suggestions.extend([
                "Kullanıcı profil fotoğrafı",
                "Usta profil resmi",
                "Müşteri avatar görüntüsü"
            ])
        
        elif "portfolio" in context_lower or "work" in context_lower:
            suggestions.extend([
                "Tamamlanmış iş örneği",
                "Usta portföy çalışması",
                "Hizmet sonucu görüntüsü"
            ])
        
        elif "logo" in context_lower or "brand" in context_lower:
            suggestions.extend([
                "UstamApp logosu",
                "Şirket logosu",
                "Marka görseli"
            ])
        
        elif "category" in context_lower:
            suggestions.extend([
                "Hizmet kategorisi ikonu",
                "Kategori görseli",
                "Hizmet türü simgesi"
            ])
        
        else:
            suggestions.extend([
                "Açıklayıcı görsel",
                "İçerik görseli",
                "Destekleyici resim"
            ])
        
        return suggestions
    
    @staticmethod
    def generate_aria_labels(content_type: str, context: Dict = None) -> Dict[str, str]:
        """Generate ARIA labels for different content types"""
        context = context or {}
        
        labels = {}
        
        if content_type == "button":
            action = context.get("action", "tıkla")
            target = context.get("target", "")
            labels["aria-label"] = f"{target} {action}".strip()
            
        elif content_type == "link":
            destination = context.get("destination", "")
            labels["aria-label"] = f"{destination} sayfasına git"
            
        elif content_type == "form":
            form_purpose = context.get("purpose", "form")
            labels["aria-label"] = f"{form_purpose} formu"
            
        elif content_type == "navigation":
            nav_type = context.get("type", "navigasyon")
            labels["aria-label"] = f"{nav_type} menüsü"
        
        elif content_type == "search":
            labels["aria-label"] = "Arama kutusu"
            labels["aria-describedby"] = "search-help"
            
        return labels

class AccessibilityReporter:
    """Generate accessibility reports and audits"""
    
    @staticmethod
    def generate_page_report(page_content: str, page_url: str = "") -> Dict[str, any]:
        """Generate comprehensive accessibility report for a page"""
        report = {
            "url": page_url,
            "timestamp": "2024-01-15T10:00:00Z",
            "overall_score": 0,
            "issues": [],
            "suggestions": [],
            "checks": {}
        }
        
        # Check heading structure
        heading_check = AccessibilityValidator.validate_heading_structure(page_content)
        report["checks"]["headings"] = heading_check
        
        # Check for images without alt text
        img_pattern = r'<img[^>]*(?:src="[^"]*")[^>]*(?:alt="([^"]*)")?[^>]*>'
        images = re.findall(img_pattern, page_content, re.IGNORECASE)
        
        missing_alt = len([img for img in images if not img or not img.strip()])
        if missing_alt > 0:
            report["issues"].append(f"{missing_alt} images missing alt text")
            report["suggestions"].append("Add descriptive alt text to all images")
        
        # Check for form labels
        input_pattern = r'<input[^>]*(?:id="([^"]*)")?[^>]*>'
        inputs = re.findall(input_pattern, page_content, re.IGNORECASE)
        
        label_pattern = r'<label[^>]*for="([^"]*)"[^>]*>'
        labels = re.findall(label_pattern, page_content, re.IGNORECASE)
        
        unlabeled_inputs = [inp for inp in inputs if inp and inp not in labels]
        if unlabeled_inputs:
            report["issues"].append(f"{len(unlabeled_inputs)} form inputs without labels")
            report["suggestions"].append("Associate all form inputs with labels")
        
        # Calculate overall score
        total_checks = 3
        passed_checks = sum([
            1 if heading_check["valid"] else 0,
            1 if missing_alt == 0 else 0,
            1 if len(unlabeled_inputs) == 0 else 0
        ])
        
        report["overall_score"] = round((passed_checks / total_checks) * 100)
        
        return report
    
    @staticmethod
    def generate_color_palette_report(colors: Dict[str, str]) -> Dict[str, any]:
        """Generate accessibility report for color palette"""
        report = {
            "colors": colors,
            "contrast_checks": [],
            "issues": [],
            "suggestions": []
        }
        
        # Common color combinations to check
        combinations = [
            ("primary", "white"),
            ("secondary", "white"),
            ("accent", "white"),
            ("text", "background"),
            ("link", "background")
        ]
        
        for fg_key, bg_key in combinations:
            if fg_key in colors and bg_key in colors:
                contrast_check = AccessibilityValidator.check_color_contrast(
                    colors[fg_key], 
                    colors[bg_key]
                )
                
                contrast_check["combination"] = f"{fg_key} on {bg_key}"
                report["contrast_checks"].append(contrast_check)
                
                if not contrast_check["valid"]:
                    report["issues"].extend(contrast_check["issues"])
                    report["suggestions"].extend(contrast_check["suggestions"])
        
        return report

class AccessibilityContentOptimizer:
    """Optimize content for better accessibility"""
    
    @staticmethod
    def optimize_text_content(content: str) -> str:
        """Optimize text content for screen readers"""
        # Replace common symbols with readable text
        replacements = {
            "&": " ve ",
            "@": " at ",
            "#": " numara ",
            "%": " yüzde ",
            "+": " artı ",
            "=": " eşittir ",
            "<": " küçüktür ",
            ">": " büyüktür ",
            "€": " euro ",
            "$": " dolar ",
            "₺": " lira "
        }
        
        optimized = content
        for symbol, replacement in replacements.items():
            optimized = optimized.replace(symbol, replacement)
        
        # Clean up multiple spaces
        optimized = re.sub(r'\s+', ' ', optimized).strip()
        
        return optimized
    
    @staticmethod
    def generate_aria_descriptions(element_type: str, context: Dict = None) -> str:
        """Generate ARIA descriptions for elements"""
        context = context or {}
        
        if element_type == "craftsman_card":
            name = context.get("name", "Usta")
            specialty = context.get("specialty", "")
            rating = context.get("rating", 0)
            location = context.get("location", "")
            
            description = f"{name}"
            if specialty:
                description += f", {specialty} uzmanı"
            if rating > 0:
                description += f", {rating} yıldız puan"
            if location:
                description += f", {location} bölgesinde"
            description += ". Profili görüntülemek için tıklayın"
            
            return description
        
        elif element_type == "quote_status":
            status = context.get("status", "")
            amount = context.get("amount", "")
            
            status_texts = {
                "pending": "Beklemede",
                "quoted": "Teklif verildi",
                "accepted": "Kabul edildi",
                "rejected": "Reddedildi",
                "completed": "Tamamlandı"
            }
            
            description = f"Teklif durumu: {status_texts.get(status, status)}"
            if amount:
                description += f", tutar: {amount} lira"
            
            return description
        
        return ""
    
    @staticmethod
    def optimize_form_structure(form_html: str) -> str:
        """Optimize form HTML for accessibility"""
        # Add fieldsets for related form groups
        # Add aria-required to required fields
        # Ensure proper label associations
        
        optimized = form_html
        
        # Add aria-required to required fields
        required_pattern = r'(<input[^>]*required[^>]*>)'
        optimized = re.sub(
            required_pattern, 
            lambda m: m.group(1).replace('>', ' aria-required="true">'),
            optimized,
            flags=re.IGNORECASE
        )
        
        # Add role="alert" to error messages
        error_pattern = r'(<div[^>]*class="[^"]*error[^"]*"[^>]*>)'
        optimized = re.sub(
            error_pattern,
            lambda m: m.group(1).replace('>', ' role="alert">'),
            optimized,
            flags=re.IGNORECASE
        )
        
        return optimized

class AccessibilityTesting:
    """Accessibility testing utilities"""
    
    @staticmethod
    def test_keyboard_navigation(page_elements: List[Dict]) -> Dict[str, any]:
        """Test keyboard navigation flow"""
        focusable_elements = [
            elem for elem in page_elements 
            if elem.get("focusable", False)
        ]
        
        issues = []
        suggestions = []
        
        if not focusable_elements:
            issues.append("No focusable elements found")
            suggestions.append("Add focusable elements for keyboard navigation")
        
        # Check tab order
        tab_indices = [elem.get("tabindex", 0) for elem in focusable_elements]
        if len(set(tab_indices)) != len(tab_indices) and any(idx > 0 for idx in tab_indices):
            issues.append("Duplicate or conflicting tabindex values")
            suggestions.append("Use sequential tabindex values or rely on natural tab order")
        
        return {
            "valid": len(issues) == 0,
            "focusable_count": len(focusable_elements),
            "issues": issues,
            "suggestions": suggestions
        }
    
    @staticmethod
    def test_screen_reader_content(content: str) -> Dict[str, any]:
        """Test content for screen reader compatibility"""
        issues = []
        suggestions = []
        
        # Check for text in images
        if "<img" in content and "alt=" not in content:
            issues.append("Images without alt text found")
            suggestions.append("Add alt text to all images")
        
        # Check for proper semantic structure
        if "<div" in content and not any(tag in content for tag in ["<main", "<section", "<article", "<nav", "<header", "<footer"]):
            suggestions.append("Consider using semantic HTML elements instead of generic divs")
        
        # Check for proper list structure
        if "<li" in content and not any(tag in content for tag in ["<ul", "<ol"]):
            issues.append("List items found without proper list container")
            suggestions.append("Wrap list items in ul or ol elements")
        
        return {
            "valid": len(issues) == 0,
            "issues": issues,
            "suggestions": suggestions
        }

# Accessibility constants
WCAG_CONTRAST_RATIOS = {
    "AA_NORMAL": 4.5,
    "AA_LARGE": 3.0,
    "AAA_NORMAL": 7.0,
    "AAA_LARGE": 4.5
}

ARIA_ROLES = {
    "navigation": "navigation",
    "main": "main",
    "banner": "banner",
    "contentinfo": "contentinfo",
    "search": "search",
    "form": "form",
    "button": "button",
    "link": "link",
    "dialog": "dialog",
    "alert": "alert",
    "status": "status",
    "progressbar": "progressbar",
    "tab": "tab",
    "tabpanel": "tabpanel",
    "tablist": "tablist"
}

SEMANTIC_ELEMENTS = [
    "header", "nav", "main", "section", "article", 
    "aside", "footer", "h1", "h2", "h3", "h4", "h5", "h6"
]