// Frontend Analytics Utilities

class AnalyticsManager {
  constructor() {
    this.sessionId = this.generateSessionId()
    this.pageStartTime = Date.now()
    this.isInitialized = false
    
    this.init()
  }
  
  init() {
    if (this.isInitialized) return
    
    // Track page views automatically
    this.setupPageTracking()
    
    // Track user interactions
    this.setupInteractionTracking()
    
    // Track performance metrics
    this.setupPerformanceTracking()
    
    this.isInitialized = true
  }
  
  generateSessionId() {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }
  
  setupPageTracking() {
    // Track initial page load
    this.trackPageView(window.location.pathname)
    
    // Track navigation changes (for SPA)
    let lastPath = window.location.pathname
    
    const observer = new MutationObserver(() => {
      if (window.location.pathname !== lastPath) {
        this.trackPageView(window.location.pathname)
        lastPath = window.location.pathname
        this.pageStartTime = Date.now()
      }
    })
    
    observer.observe(document.body, {
      childList: true,
      subtree: true
    })
    
    // Track page visibility changes
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        this.trackEvent('page_hidden', {
          duration: Date.now() - this.pageStartTime,
          page: window.location.pathname
        })
      } else {
        this.pageStartTime = Date.now()
        this.trackEvent('page_visible', {
          page: window.location.pathname
        })
      }
    })
  }
  
  setupInteractionTracking() {
    // Track button clicks
    document.addEventListener('click', (event) => {
      const target = event.target
      
      if (target.tagName === 'BUTTON' || target.closest('button')) {
        const button = target.tagName === 'BUTTON' ? target : target.closest('button')
        const buttonText = button.textContent?.trim() || 'Unknown Button'
        
        this.trackEvent('button_click', {
          button_text: buttonText,
          button_id: button.id,
          button_class: button.className,
          page: window.location.pathname
        })
      }
      
      // Track link clicks
      if (target.tagName === 'A' || target.closest('a')) {
        const link = target.tagName === 'A' ? target : target.closest('a')
        
        this.trackEvent('link_click', {
          href: link.href,
          text: link.textContent?.trim(),
          page: window.location.pathname
        })
      }
    })
    
    // Track form submissions
    document.addEventListener('submit', (event) => {
      const form = event.target
      
      if (form.tagName === 'FORM') {
        this.trackEvent('form_submit', {
          form_id: form.id,
          form_class: form.className,
          page: window.location.pathname
        })
      }
    })
    
    // Track scroll depth
    let maxScrollDepth = 0
    let scrollTimeout
    
    window.addEventListener('scroll', () => {
      clearTimeout(scrollTimeout)
      
      scrollTimeout = setTimeout(() => {
        const scrollDepth = Math.round(
          (window.scrollY + window.innerHeight) / document.body.scrollHeight * 100
        )
        
        if (scrollDepth > maxScrollDepth) {
          maxScrollDepth = scrollDepth
          
          // Track milestone scroll depths
          if (scrollDepth >= 25 && maxScrollDepth < 25) {
            this.trackEvent('scroll_depth', { depth: 25, page: window.location.pathname })
          } else if (scrollDepth >= 50 && maxScrollDepth < 50) {
            this.trackEvent('scroll_depth', { depth: 50, page: window.location.pathname })
          } else if (scrollDepth >= 75 && maxScrollDepth < 75) {
            this.trackEvent('scroll_depth', { depth: 75, page: window.location.pathname })
          } else if (scrollDepth >= 90 && maxScrollDepth < 90) {
            this.trackEvent('scroll_depth', { depth: 90, page: window.location.pathname })
          }
        }
      }, 100)
    })
  }
  
  setupPerformanceTracking() {
    // Track page load performance
    window.addEventListener('load', () => {
      setTimeout(() => {
        const perfData = performance.getEntriesByType('navigation')[0]
        
        if (perfData) {
          this.trackEvent('page_performance', {
            load_time: perfData.loadEventEnd - perfData.loadEventStart,
            dom_content_loaded: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
            page: window.location.pathname
          })
        }
      }, 1000)
    })
    
    // Track API call performance
    this.originalFetch = window.fetch
    window.fetch = async (...args) => {
      const startTime = Date.now()
      const url = args[0]
      
      try {
        const response = await this.originalFetch(...args)
        const duration = Date.now() - startTime
        
        // Track API performance
        if (typeof url === 'string' && url.includes('/api/')) {
          this.trackEvent('api_call', {
            url: url,
            method: args[1]?.method || 'GET',
            status: response.status,
            duration: duration,
            success: response.ok
          })
        }
        
        return response
      } catch (error) {
        const duration = Date.now() - startTime
        
        if (typeof url === 'string' && url.includes('/api/')) {
          this.trackEvent('api_call', {
            url: url,
            method: args[1]?.method || 'GET',
            status: 0,
            duration: duration,
            success: false,
            error: error.message
          })
        }
        
        throw error
      }
    }
  }
  
  // Core tracking methods
  async trackPageView(page) {
    try {
      await this.trackEvent('page_view', {
        page: page,
        referrer: document.referrer,
        user_agent: navigator.userAgent,
        screen_resolution: `${screen.width}x${screen.height}`,
        viewport_size: `${window.innerWidth}x${window.innerHeight}`
      })
    } catch (error) {
      console.error('Page view tracking error:', error)
    }
  }
  
  async trackEvent(action, details = {}) {
    try {
      const eventData = {
        action,
        details: {
          ...details,
          session_id: this.sessionId,
          timestamp: new Date().toISOString(),
          url: window.location.href,
          page_title: document.title
        },
        page: window.location.pathname
      }
      
      // Send to backend
      const token = localStorage.getItem('authToken')
      if (token) {
        await fetch('/api/analytics/track', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
            'X-Session-ID': this.sessionId
          },
          body: JSON.stringify(eventData)
        })
      }
      
      // Send to Google Analytics if available
      if (typeof gtag !== 'undefined') {
        gtag('event', action, {
          event_category: 'user_interaction',
          event_label: details.page || window.location.pathname,
          value: details.value || 1
        })
      }
      
    } catch (error) {
      console.error('Event tracking error:', error)
    }
  }
  
  // Business-specific tracking methods
  trackSearch(query, filters = {}) {
    this.trackEvent('search', {
      query,
      filters,
      results_count: filters.results_count || 0
    })
  }
  
  trackQuoteRequest(craftsmanId, category) {
    this.trackEvent('quote_request', {
      craftsman_id: craftsmanId,
      category,
      funnel_step: 'quote_request_submitted'
    })
  }
  
  trackQuoteResponse(quoteId, responseType) {
    this.trackEvent('quote_response', {
      quote_id: quoteId,
      response_type: responseType,
      funnel_step: 'quote_response_given'
    })
  }
  
  trackPayment(quoteId, amount) {
    this.trackEvent('payment', {
      quote_id: quoteId,
      amount,
      funnel_step: 'payment_completed'
    })
  }
  
  trackRegistration(userType) {
    this.trackEvent('registration', {
      user_type: userType,
      funnel_step: 'registration_completed'
    })
  }
  
  trackLogin(userType) {
    this.trackEvent('login', {
      user_type: userType,
      funnel_step: 'login_completed'
    })
  }
  
  trackProfileUpdate(section) {
    this.trackEvent('profile_update', {
      section,
      action_type: 'profile_management'
    })
  }
  
  trackMessageSent(recipientType) {
    this.trackEvent('message_sent', {
      recipient_type: recipientType,
      communication_type: 'direct_message'
    })
  }
  
  trackFileUpload(fileType, fileSize) {
    this.trackEvent('file_upload', {
      file_type: fileType,
      file_size: fileSize,
      action_type: 'content_creation'
    })
  }
  
  // Error tracking
  trackError(error, context = {}) {
    this.trackEvent('error', {
      error_message: error.message,
      error_stack: error.stack,
      context,
      page: window.location.pathname
    })
  }
  
  // Performance tracking
  trackUserTiming(name, duration) {
    this.trackEvent('user_timing', {
      timing_name: name,
      duration_ms: duration
    })
  }
  
  // Conversion funnel tracking
  trackFunnelStep(step, metadata = {}) {
    this.trackEvent('funnel_step', {
      step,
      metadata,
      funnel_type: 'quote_to_payment'
    })
  }
  
  // Session tracking
  startSession() {
    this.trackEvent('session_start', {
      session_id: this.sessionId
    })
  }
  
  endSession() {
    const sessionDuration = Date.now() - this.pageStartTime
    this.trackEvent('session_end', {
      session_id: this.sessionId,
      session_duration: sessionDuration
    })
  }
}

// Create singleton instance
const analyticsManager = new AnalyticsManager()

// React hook for analytics
export const useAnalytics = () => {
  const [isTracking, setIsTracking] = useState(true)
  
  useEffect(() => {
    // Start session
    analyticsManager.startSession()
    
    // End session on page unload
    const handleBeforeUnload = () => {
      analyticsManager.endSession()
    }
    
    window.addEventListener('beforeunload', handleBeforeUnload)
    
    return () => {
      window.removeEventListener('beforeunload', handleBeforeUnload)
      analyticsManager.endSession()
    }
  }, [])
  
  return {
    isTracking,
    setTracking: setIsTracking,
    trackEvent: (action, details) => analyticsManager.trackEvent(action, details),
    trackSearch: (query, filters) => analyticsManager.trackSearch(query, filters),
    trackQuoteRequest: (craftsmanId, category) => analyticsManager.trackQuoteRequest(craftsmanId, category),
    trackQuoteResponse: (quoteId, responseType) => analyticsManager.trackQuoteResponse(quoteId, responseType),
    trackPayment: (quoteId, amount) => analyticsManager.trackPayment(quoteId, amount),
    trackError: (error, context) => analyticsManager.trackError(error, context),
    trackFunnelStep: (step, metadata) => analyticsManager.trackFunnelStep(step, metadata)
  }
}

// Higher-order component for automatic page tracking
export const withAnalytics = (WrappedComponent) => {
  return function AnalyticsWrapper(props) {
    const analytics = useAnalytics()
    
    useEffect(() => {
      // Track component mount
      analytics.trackEvent('component_mount', {
        component: WrappedComponent.name || 'Unknown'
      })
      
      return () => {
        // Track component unmount
        analytics.trackEvent('component_unmount', {
          component: WrappedComponent.name || 'Unknown'
        })
      }
    }, [])
    
    return <WrappedComponent {...props} analytics={analytics} />
  }
}

// Error boundary with analytics
export class AnalyticsErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false }
  }
  
  static getDerivedStateFromError(error) {
    return { hasError: true }
  }
  
  componentDidCatch(error, errorInfo) {
    // Track error
    analyticsManager.trackError(error, {
      error_info: errorInfo,
      component_stack: errorInfo.componentStack
    })
  }
  
  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-gray-900 mb-4">
              Bir şeyler ters gitti
            </h1>
            <p className="text-gray-600 mb-6">
              Teknik ekibimiz bilgilendirildi. Lütfen sayfayı yenileyin.
            </p>
            <button
              onClick={() => window.location.reload()}
              className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
            >
              Sayfayı Yenile
            </button>
          </div>
        </div>
      )
    }
    
    return this.props.children
  }
}

// Performance monitoring
export const trackApiCall = async (url, options = {}) => {
  const startTime = Date.now()
  
  try {
    const response = await fetch(url, options)
    const duration = Date.now() - startTime
    
    analyticsManager.trackEvent('api_call', {
      url,
      method: options.method || 'GET',
      status: response.status,
      duration,
      success: response.ok
    })
    
    return response
  } catch (error) {
    const duration = Date.now() - startTime
    
    analyticsManager.trackEvent('api_call', {
      url,
      method: options.method || 'GET',
      status: 0,
      duration,
      success: false,
      error: error.message
    })
    
    throw error
  }
}

// Business metrics tracking
export const trackBusinessEvent = {
  searchPerformed: (query, resultsCount) => {
    analyticsManager.trackSearch(query, { results_count: resultsCount })
  },
  
  craftsmanViewed: (craftsmanId) => {
    analyticsManager.trackEvent('craftsman_viewed', {
      craftsman_id: craftsmanId,
      funnel_step: 'craftsman_profile_viewed'
    })
  },
  
  quoteRequested: (craftsmanId, category) => {
    analyticsManager.trackQuoteRequest(craftsmanId, category)
  },
  
  quoteResponded: (quoteId, responseType) => {
    analyticsManager.trackQuoteResponse(quoteId, responseType)
  },
  
  paymentCompleted: (quoteId, amount) => {
    analyticsManager.trackPayment(quoteId, amount)
  },
  
  userRegistered: (userType) => {
    analyticsManager.trackRegistration(userType)
  },
  
  userLoggedIn: (userType) => {
    analyticsManager.trackLogin(userType)
  },
  
  profileUpdated: (section) => {
    analyticsManager.trackProfileUpdate(section)
  },
  
  messageSent: (recipientType) => {
    analyticsManager.trackMessageSent(recipientType)
  },
  
  fileUploaded: (fileType, fileSize) => {
    analyticsManager.trackFileUpload(fileType, fileSize)
  }
}

// Conversion funnel tracking
export const trackFunnel = {
  step1_landing: () => analyticsManager.trackFunnelStep('landing_page'),
  step2_search: () => analyticsManager.trackFunnelStep('search_performed'),
  step3_craftsman_view: () => analyticsManager.trackFunnelStep('craftsman_viewed'),
  step4_quote_request: () => analyticsManager.trackFunnelStep('quote_requested'),
  step5_quote_received: () => analyticsManager.trackFunnelStep('quote_received'),
  step6_payment: () => analyticsManager.trackFunnelStep('payment_completed')
}

export default analyticsManager

// Import React
import React, { useState, useEffect } from 'react'