import { useEffect, useRef } from 'react';

/**
 * Accessibility Manager for WCAG compliance
 */
export class AccessibilityManager {
  static ariaLiveRegion = null;
  static initialized = false;

  /**
   * Initialize accessibility features
   */
  static initialize() {
    if (this.initialized) return;
    
    this.createAriaLiveRegion();
    this.setupKeyboardNavigation();
    this.setupFocusManagement();
    this.addAccessibilityStyles();
    this.initialized = true;
  }

  /**
   * Create ARIA live region for screen reader announcements
   */
  static createAriaLiveRegion() {
    if (!this.ariaLiveRegion) {
      this.ariaLiveRegion = document.createElement('div');
      this.ariaLiveRegion.setAttribute('aria-live', 'polite');
      this.ariaLiveRegion.setAttribute('aria-atomic', 'true');
      this.ariaLiveRegion.className = 'sr-only';
      this.ariaLiveRegion.style.cssText = `
        position: absolute !important;
        width: 1px !important;
        height: 1px !important;
        padding: 0 !important;
        margin: -1px !important;
        overflow: hidden !important;
        clip: rect(0, 0, 0, 0) !important;
        white-space: nowrap !important;
        border: 0 !important;
      `;
      document.body.appendChild(this.ariaLiveRegion);
    }
  }

  /**
   * Announce message to screen readers
   */
  static announce(message, priority = 'polite') {
    if (!this.ariaLiveRegion) {
      this.createAriaLiveRegion();
    }

    this.ariaLiveRegion.setAttribute('aria-live', priority);
    this.ariaLiveRegion.textContent = message;
    
    setTimeout(() => {
      if (this.ariaLiveRegion) {
        this.ariaLiveRegion.textContent = '';
      }
    }, 1000);
  }

  /**
   * Setup keyboard navigation shortcuts
   */
  static setupKeyboardNavigation() {
    document.addEventListener('keydown', (e) => {
      // Skip to main content (Alt + M)
      if (e.altKey && e.key === 'm') {
        e.preventDefault();
        const main = document.querySelector('main, [role="main"], #main-content');
        if (main) {
          main.setAttribute('tabindex', '-1');
          main.focus();
          this.announce('Ana içeriğe geçildi');
        }
      }

      // Skip to navigation (Alt + N)
      if (e.altKey && e.key === 'n') {
        e.preventDefault();
        const nav = document.querySelector('nav, [role="navigation"], .main-nav');
        if (nav) {
          const firstLink = nav.querySelector('a, button');
          if (firstLink) {
            firstLink.focus();
            this.announce('Navigasyona geçildi');
          }
        }
      }

      // Escape key to close modals/dropdowns
      if (e.key === 'Escape') {
        const activeModal = document.querySelector('[role="dialog"]:not([aria-hidden="true"])');
        if (activeModal) {
          const closeButton = activeModal.querySelector('[aria-label*="kapat"], [aria-label*="close"], .close-button');
          if (closeButton) {
            closeButton.click();
            this.announce('Modal kapatıldı');
          }
        }
      }
    });
  }

  /**
   * Setup focus management
   */
  static setupFocusManagement() {
    // Track focus for better keyboard navigation
    document.addEventListener('focusin', (e) => {
      e.target.classList.add('keyboard-focus');
    });

    document.addEventListener('focusout', (e) => {
      e.target.classList.remove('keyboard-focus');
    });

    // Remove focus indicators on mouse interaction
    document.addEventListener('mousedown', (e) => {
      e.target.classList.remove('keyboard-focus');
    });
  }

  /**
   * Add accessibility styles
   */
  static addAccessibilityStyles() {
    const style = document.createElement('style');
    style.textContent = `
      /* Screen reader only content */
      .sr-only {
        position: absolute !important;
        width: 1px !important;
        height: 1px !important;
        padding: 0 !important;
        margin: -1px !important;
        overflow: hidden !important;
        clip: rect(0, 0, 0, 0) !important;
        white-space: nowrap !important;
        border: 0 !important;
      }

      /* Skip links */
      .skip-link {
        position: absolute;
        top: -40px;
        left: 6px;
        background: #000;
        color: #fff;
        padding: 8px;
        text-decoration: none;
        border-radius: 4px;
        z-index: 10000;
        opacity: 0;
        transition: opacity 0.2s;
      }

      .skip-link:focus {
        top: 6px;
        opacity: 1;
      }

      /* Focus indicators */
      .keyboard-focus {
        outline: 2px solid #467599 !important;
        outline-offset: 2px !important;
      }

      /* High contrast mode support */
      @media (prefers-contrast: high) {
        * {
          border-color: ButtonText !important;
        }
      }

      /* Reduced motion support */
      @media (prefers-reduced-motion: reduce) {
        *, *::before, *::after {
          animation-duration: 0.01ms !important;
          animation-iteration-count: 1 !important;
          transition-duration: 0.01ms !important;
        }
      }

      /* Large text support */
      @media (prefers-reduced-motion: no-preference) {
        .accessible-button {
          transition: all 0.2s ease;
        }
      }
    `;
    document.head.appendChild(style);
  }

  /**
   * Trap focus within an element (for modals)
   */
  static trapFocus(element) {
    const focusableElements = element.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    
    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];

    const handleTabKey = (e) => {
      if (e.key === 'Tab') {
        if (e.shiftKey) {
          if (document.activeElement === firstElement) {
            e.preventDefault();
            lastElement.focus();
          }
        } else {
          if (document.activeElement === lastElement) {
            e.preventDefault();
            firstElement.focus();
          }
        }
      }
    };

    element.addEventListener('keydown', handleTabKey);
    
    // Focus first element
    if (firstElement) {
      firstElement.focus();
    }

    // Return cleanup function
    return () => {
      element.removeEventListener('keydown', handleTabKey);
    };
  }

  /**
   * Generate unique IDs for form elements
   */
  static generateId(prefix = 'element') {
    return `${prefix}-${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Check color contrast ratio
   */
  static checkColorContrast(foreground, background) {
    const rgb1 = this.hexToRgb(foreground);
    const rgb2 = this.hexToRgb(background);
    
    if (!rgb1 || !rgb2) return 21; // Max contrast if can't parse
    
    const l1 = this.getRelativeLuminance(rgb1);
    const l2 = this.getRelativeLuminance(rgb2);
    
    const lighter = Math.max(l1, l2);
    const darker = Math.min(l1, l2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /**
   * Convert hex color to RGB
   */
  static hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  }

  /**
   * Calculate relative luminance
   */
  static getRelativeLuminance(rgb) {
    const { r, g, b } = rgb;
    
    const normalize = (val) => {
      val = val / 255;
      return val <= 0.03928 ? val / 12.92 : Math.pow((val + 0.055) / 1.055, 2.4);
    };
    
    return 0.2126 * normalize(r) + 0.7152 * normalize(g) + 0.0722 * normalize(b);
  }
}

/**
 * React hook for accessibility features
 */
export function useAccessibility(options = {}) {
  const { announcements = true, focusTrap = false, element = null } = options;

  useEffect(() => {
    if (announcements) {
      AccessibilityManager.initialize();
    }

    let cleanup = null;
    if (focusTrap && element) {
      cleanup = AccessibilityManager.trapFocus(element);
    }

    return () => {
      if (cleanup) cleanup();
    };
  }, [announcements, focusTrap, element]);

  return {
    announce: AccessibilityManager.announce,
    trapFocus: AccessibilityManager.trapFocus,
    generateId: AccessibilityManager.generateId
  };
}

/**
 * Accessible button component
 */
export function AccessibleButton({ 
  children, 
  onClick, 
  ariaLabel, 
  ariaDescribedBy,
  disabled = false,
  loading = false,
  variant = 'primary',
  size = 'medium',
  className = '',
  ...props 
}) {
  const handleClick = (e) => {
    if (disabled || loading) {
      e.preventDefault();
      return;
    }
    onClick?.(e);
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleClick(e);
    }
  };

  return (
    <button
      {...props}
      onClick={handleClick}
      onKeyDown={handleKeyDown}
      aria-label={ariaLabel}
      aria-describedby={ariaDescribedBy}
      aria-disabled={disabled || loading}
      disabled={disabled || loading}
      className={`accessible-button ${variant} ${size} ${className} ${disabled ? 'disabled' : ''} ${loading ? 'loading' : ''}`}
    >
      {loading && (
        <span className="loading-spinner" aria-hidden="true" />
      )}
      <span className={loading ? 'sr-only' : ''}>{children}</span>
      {loading && (
        <span className="sr-only">Yükleniyor...</span>
      )}
    </button>
  );
}

/**
 * Accessible form input component
 */
export function AccessibleInput({
  label,
  id,
  error,
  required = false,
  type = 'text',
  ariaDescribedBy,
  className = '',
  ...props
}) {
  const inputId = id || AccessibilityManager.generateId('input');
  const errorId = error ? `${inputId}-error` : null;
  const describedBy = [ariaDescribedBy, errorId].filter(Boolean).join(' ');

  return (
    <div className={`accessible-input-group ${className}`}>
      <label htmlFor={inputId} className={`input-label ${required ? 'required' : ''}`}>
        {label}
        {required && <span aria-label="gerekli alan" className="required-indicator"> *</span>}
      </label>
      <input
        {...props}
        id={inputId}
        type={type}
        aria-required={required}
        aria-invalid={!!error}
        aria-describedby={describedBy || undefined}
        className={`accessible-input ${error ? 'error' : ''}`}
      />
      {error && (
        <div id={errorId} className="input-error" role="alert" aria-live="polite">
          <span className="sr-only">Hata: </span>
          {error}
        </div>
      )}
    </div>
  );
}

/**
 * Accessible modal component
 */
export function AccessibleModal({ 
  isOpen, 
  onClose, 
  title, 
  children, 
  ariaLabel,
  ariaDescribedBy,
  className = ''
}) {
  const modalRef = useRef(null);
  const previousFocus = useRef(null);
  const modalId = AccessibilityManager.generateId('modal');
  const titleId = `${modalId}-title`;

  useEffect(() => {
    if (isOpen) {
      // Save previous focus
      previousFocus.current = document.activeElement;
      
      // Trap focus in modal
      if (modalRef.current) {
        const cleanup = AccessibilityManager.trapFocus(modalRef.current);
        
        // Announce modal opening
        AccessibilityManager.announce(`Modal açıldı: ${title}`);
        
        return cleanup;
      }
    } else if (previousFocus.current) {
      // Restore previous focus
      previousFocus.current.focus();
    }
  }, [isOpen, title]);

  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape' && isOpen) {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden'; // Prevent background scroll
    }

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = '';
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div 
      className={`modal-overlay ${className}`}
      role="dialog"
      aria-modal="true"
      aria-labelledby={ariaLabel ? undefined : titleId}
      aria-label={ariaLabel}
      aria-describedby={ariaDescribedBy}
      ref={modalRef}
    >
      <div className="modal-content">
        <div className="modal-header">
          <h2 id={titleId} className="modal-title">
            {title}
          </h2>
          <button
            onClick={onClose}
            aria-label="Modalı kapat"
            className="modal-close"
          >
            <span aria-hidden="true">×</span>
          </button>
        </div>
        <div className="modal-body">
          {children}
        </div>
      </div>
    </div>
  );
}

/**
 * Accessible skip link component
 */
export function SkipLink({ href = '#main-content', children = 'Ana içeriğe geç' }) {
  return (
    <a 
      href={href}
      className="skip-link"
      onClick={(e) => {
        e.preventDefault();
        const target = document.querySelector(href);
        if (target) {
          target.setAttribute('tabindex', '-1');
          target.focus();
          AccessibilityManager.announce('Ana içeriğe geçildi');
        }
      }}
    >
      {children}
    </a>
  );
}

/**
 * Accessible breadcrumb component
 */
export function AccessibleBreadcrumb({ items, className = '' }) {
  return (
    <nav aria-label="Sayfa yolu" className={`breadcrumb ${className}`}>
      <ol className="breadcrumb-list">
        {items.map((item, index) => (
          <li key={index} className="breadcrumb-item">
            {index < items.length - 1 ? (
              <>
                <a 
                  href={item.url} 
                  aria-current={index === items.length - 1 ? 'page' : undefined}
                  className="breadcrumb-link"
                >
                  {item.name}
                </a>
                <span aria-hidden="true" className="breadcrumb-separator"> / </span>
              </>
            ) : (
              <span aria-current="page" className="breadcrumb-current">
                {item.name}
              </span>
            )}
          </li>
        ))}
      </ol>
    </nav>
  );
}

/**
 * Accessible loading indicator
 */
export function AccessibleLoader({ 
  message = 'Yükleniyor...', 
  size = 'medium',
  className = ''
}) {
  return (
    <div className={`loader ${size} ${className}`} role="status" aria-live="polite">
      <div className="spinner" aria-hidden="true"></div>
      <span className="sr-only">{message}</span>
    </div>
  );
}

/**
 * Screen reader only text component
 */
export function ScreenReaderOnly({ children, as: Component = 'span' }) {
  return (
    <Component className="sr-only">
      {children}
    </Component>
  );
}

/**
 * Accessible pagination component
 */
export function AccessiblePagination({ 
  currentPage, 
  totalPages, 
  onPageChange,
  ariaLabel = 'Sayfalama navigasyonu',
  className = ''
}) {
  const pages = [];
  const maxVisiblePages = 5;
  
  let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
  let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
  
  if (endPage - startPage + 1 < maxVisiblePages) {
    startPage = Math.max(1, endPage - maxVisiblePages + 1);
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i);
  }

  return (
    <nav aria-label={ariaLabel} className={`pagination ${className}`}>
      <ul className="pagination-list">
        {/* Previous button */}
        <li>
          <button
            onClick={() => onPageChange(currentPage - 1)}
            disabled={currentPage === 1}
            aria-label="Önceki sayfa"
            className="pagination-button prev"
          >
            <span aria-hidden="true">‹</span>
            <span>Önceki</span>
          </button>
        </li>

        {/* First page */}
        {startPage > 1 && (
          <>
            <li>
              <button
                onClick={() => onPageChange(1)}
                aria-label="1. sayfaya git"
                className="pagination-button"
              >
                1
              </button>
            </li>
            {startPage > 2 && (
              <li className="pagination-ellipsis" aria-hidden="true">
                <span>...</span>
              </li>
            )}
          </>
        )}

        {/* Page numbers */}
        {pages.map(page => (
          <li key={page}>
            <button
              onClick={() => onPageChange(page)}
              aria-label={page === currentPage ? `Şu anki sayfa, sayfa ${page}` : `${page}. sayfaya git`}
              aria-current={page === currentPage ? 'page' : undefined}
              className={`pagination-button ${page === currentPage ? 'current' : ''}`}
            >
              {page}
            </button>
          </li>
        ))}

        {/* Last page */}
        {endPage < totalPages && (
          <>
            {endPage < totalPages - 1 && (
              <li className="pagination-ellipsis" aria-hidden="true">
                <span>...</span>
              </li>
            )}
            <li>
              <button
                onClick={() => onPageChange(totalPages)}
                aria-label={`${totalPages}. sayfaya git`}
                className="pagination-button"
              >
                {totalPages}
              </button>
            </li>
          </>
        )}

        {/* Next button */}
        <li>
          <button
            onClick={() => onPageChange(currentPage + 1)}
            disabled={currentPage === totalPages}
            aria-label="Sonraki sayfa"
            className="pagination-button next"
          >
            <span>Sonraki</span>
            <span aria-hidden="true">›</span>
          </button>
        </li>
      </ul>
    </nav>
  );
}

/**
 * Accessible tabs component
 */
export function AccessibleTabs({ 
  tabs, 
  activeTab, 
  onTabChange, 
  ariaLabel = 'Sekmeler',
  className = ''
}) {
  const tabListId = AccessibilityManager.generateId('tablist');
  
  const handleKeyDown = (e, index) => {
    let newIndex = index;
    
    switch (e.key) {
      case 'ArrowLeft':
        e.preventDefault();
        newIndex = index > 0 ? index - 1 : tabs.length - 1;
        break;
      case 'ArrowRight':
        e.preventDefault();
        newIndex = index < tabs.length - 1 ? index + 1 : 0;
        break;
      case 'Home':
        e.preventDefault();
        newIndex = 0;
        break;
      case 'End':
        e.preventDefault();
        newIndex = tabs.length - 1;
        break;
    }
    
    if (newIndex !== index) {
      onTabChange(tabs[newIndex].id);
      setTimeout(() => {
        const newTab = document.querySelector(`[data-tab-id="${tabs[newIndex].id}"]`);
        if (newTab) newTab.focus();
      }, 0);
    }
  };

  return (
    <div className={`accessible-tabs ${className}`}>
      <div role="tablist" aria-label={ariaLabel} id={tabListId} className="tab-list">
        {tabs.map((tab, index) => (
          <button
            key={tab.id}
            role="tab"
            data-tab-id={tab.id}
            aria-selected={activeTab === tab.id}
            aria-controls={`panel-${tab.id}`}
            id={`tab-${tab.id}`}
            tabIndex={activeTab === tab.id ? 0 : -1}
            onClick={() => onTabChange(tab.id)}
            onKeyDown={(e) => handleKeyDown(e, index)}
            className={`tab-button ${activeTab === tab.id ? 'active' : ''}`}
          >
            {tab.label}
          </button>
        ))}
      </div>
      
      <div className="tab-panels">
        {tabs.map(tab => (
          <div
            key={`panel-${tab.id}`}
            role="tabpanel"
            id={`panel-${tab.id}`}
            aria-labelledby={`tab-${tab.id}`}
            hidden={activeTab !== tab.id}
            className="tab-panel"
            tabIndex={activeTab === tab.id ? 0 : -1}
          >
            {activeTab === tab.id && tab.content}
          </div>
        ))}
      </div>
    </div>
  );
}

/**
 * Accessible form validation
 */
export function validateFormAccessibility(formElement) {
  const issues = [];
  const inputs = formElement.querySelectorAll('input, select, textarea');
  
  inputs.forEach(input => {
    const id = input.getAttribute('id');
    const ariaLabel = input.getAttribute('aria-label');
    const ariaLabelledBy = input.getAttribute('aria-labelledby');
    
    if (!id && !ariaLabel && !ariaLabelledBy) {
      issues.push({
        element: input,
        issue: 'Input missing label or aria-label'
      });
    }
    
    if (id) {
      const label = formElement.querySelector(`label[for="${id}"]`);
      if (!label && !ariaLabel && !ariaLabelledBy) {
        issues.push({
          element: input,
          issue: 'Input has ID but no associated label'
        });
      }
    }
    
    if (input.hasAttribute('required') && !input.hasAttribute('aria-required')) {
      issues.push({
        element: input,
        issue: 'Required field missing aria-required'
      });
    }
  });
  
  return issues;
}

/**
 * Accessibility constants
 */
export const KEYBOARD_SHORTCUTS = {
  SKIP_TO_MAIN: 'Alt + M',
  SKIP_TO_NAV: 'Alt + N',
  CLOSE_MODAL: 'Escape',
  NEXT_TAB: 'Arrow Right',
  PREV_TAB: 'Arrow Left',
  FIRST_TAB: 'Home',
  LAST_TAB: 'End'
};

export const ARIA_LIVE_TYPES = {
  POLITE: 'polite',
  ASSERTIVE: 'assertive',
  OFF: 'off'
};

export const CONTRAST_LEVELS = {
  AA_NORMAL: 4.5,
  AA_LARGE: 3,
  AAA_NORMAL: 7,
  AAA_LARGE: 4.5
};