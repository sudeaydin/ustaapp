import { AnalyticsManager } from './analytics';

// API Configuration
const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? 'https://api.ustamapp.com' 
  : 'http://localhost:5000';

const API_TIMEOUT = 30000; // 30 seconds

// API Error Class
class ApiError extends Error {
  constructor(message, status, code, details) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

// API Client Class
class ApiClient {
  constructor() {
    this.baseURL = API_BASE_URL;
    this.timeout = API_TIMEOUT;
  }

  // Get auth headers
  getAuthHeaders() {
    const token = localStorage.getItem('authToken');
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    
    return headers;
  }

  // Generic request method
  async request(method, endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const { body, headers = {}, requiresAuth = false, timeout = this.timeout } = options;
    const startTime = Date.now();

    const config = {
      method: method.toUpperCase(),
      headers: {
        ...(requiresAuth ? this.getAuthHeaders() : {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
        ...headers,
      },
    };

    if (body && method.toUpperCase() !== 'GET') {
      config.body = JSON.stringify(body);
    }

    // Add timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    config.signal = controller.signal;

    try {
      const response = await fetch(url, config);
      clearTimeout(timeoutId);

      // Handle authentication errors
      if (response.status === 401) {
        localStorage.removeItem('authToken');
        localStorage.removeItem('userType');
        localStorage.removeItem('userId');
        window.location.href = '/login';
        throw new ApiError('Oturum süreniz dolmuş', 401, 'UNAUTHORIZED');
      }

      const data = await response.json();

      if (!response.ok) {
        throw new ApiError(
          data.message || 'Bir hata oluştu',
          response.status,
          data.code || 'API_ERROR',
          data.details
        );
      }

      // Track successful API call
      this._trackApiCall(endpoint, method, response.status, Date.now() - startTime);
      
      return data;
    } catch (error) {
      clearTimeout(timeoutId);
      
      // Track failed API call
      const duration = Date.now() - startTime;
      const statusCode = error.status || (error.name === 'AbortError' ? 408 : 0);
      this._trackApiCall(endpoint, method, statusCode, duration);
      
      if (error.name === 'AbortError') {
        throw new ApiError('İstek zaman aşımına uğradı', 408, 'TIMEOUT');
      }
      
      if (error instanceof ApiError) {
        throw error;
      }
      
      // Network errors
      throw new ApiError(
        'Bağlantı hatası. İnternet bağlantınızı kontrol edin.',
        0,
        'NETWORK_ERROR'
      );
    }
  }

  // HTTP Methods
  async get(endpoint, options = {}) {
    return this.request('GET', endpoint, options);
  }

  async post(endpoint, body, options = {}) {
    return this.request('POST', endpoint, { ...options, body });
  }

  async put(endpoint, body, options = {}) {
    return this.request('PUT', endpoint, { ...options, body });
  }

  async delete(endpoint, options = {}) {
    return this.request('DELETE', endpoint, options);
  }

  // File upload
  async upload(endpoint, formData, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const { requiresAuth = true, onProgress } = options;

    const headers = {};
    if (requiresAuth) {
      const token = localStorage.getItem('authToken');
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
    }

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: formData,
      });

      if (response.status === 401) {
        localStorage.removeItem('authToken');
        window.location.href = '/login';
        throw new ApiError('Oturum süreniz dolmuş', 401, 'UNAUTHORIZED');
      }

      const data = await response.json();

      if (!response.ok) {
        throw new ApiError(
          data.message || 'Upload hatası',
          response.status,
          data.code || 'UPLOAD_ERROR',
          data.details
        );
      }

      return data;
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError('Upload sırasında hata oluştu', 0, 'UPLOAD_ERROR');
    }
  }
}

// Create singleton instance
const apiClient = new ApiClient();

// API Endpoints
export const API_ENDPOINTS = {
  // Auth
  LOGIN: '/api/auth/login',
  REGISTER: '/api/auth/register',
  PROFILE: '/api/auth/profile',
  DELETE_ACCOUNT: '/api/auth/delete-account',
  
  // Search
  SEARCH_CRAFTSMEN: '/api/search/craftsmen',
  SEARCH_CATEGORIES: '/api/search/categories',
  SEARCH_LOCATIONS: '/api/search/locations',
  
  // Quotes
  QUOTE_REQUEST: '/api/quote-requests/request',
  QUOTE_RESPONSE: '/api/quote-requests/respond',
  QUOTE_DECISION: '/api/quote-requests/decision',
  MY_QUOTES: '/api/quote-requests/my-quotes',
  
  // Craftsmen
  CRAFTSMAN_DETAIL: (id) => `/api/craftsmen/${id}`,
  CRAFTSMAN_BUSINESS_PROFILE: (id) => `/api/craftsmen/${id}/business-profile`,
  
  // Upload
  UPLOAD_PORTFOLIO: '/api/auth/upload-portfolio-image',
  DELETE_PORTFOLIO: '/api/auth/delete-portfolio-image',
};

// Convenience API functions
export const api = {
  // Auth methods
  login: (email, password) => 
    apiClient.post(API_ENDPOINTS.LOGIN, { email, password }),
  
  register: (userData) => 
    apiClient.post(API_ENDPOINTS.REGISTER, userData),
  
  getProfile: () => 
    apiClient.get(API_ENDPOINTS.PROFILE, { requiresAuth: true }),
  
  deleteAccount: () => 
    apiClient.delete(API_ENDPOINTS.DELETE_ACCOUNT, { requiresAuth: true }),

  // Search methods
  searchCraftsmen: (params = {}) => 
    apiClient.get(`${API_ENDPOINTS.SEARCH_CRAFTSMEN}?${new URLSearchParams(params)}`),
  
  getCategories: () => 
    apiClient.get(API_ENDPOINTS.SEARCH_CATEGORIES),
  
  getLocations: () => 
    apiClient.get(API_ENDPOINTS.SEARCH_LOCATIONS),

  // Craftsman methods
  getCraftsmanDetail: (id) => 
    apiClient.get(API_ENDPOINTS.CRAFTSMAN_DETAIL(id)),
  
  getCraftsmanBusinessProfile: (id) => 
    apiClient.get(API_ENDPOINTS.CRAFTSMAN_BUSINESS_PROFILE(id)),

  // Quote methods
  createQuoteRequest: (quoteData) => 
    apiClient.post(API_ENDPOINTS.QUOTE_REQUEST, quoteData, { requiresAuth: true }),
  
  respondToQuote: (responseData) => 
    apiClient.post(API_ENDPOINTS.QUOTE_RESPONSE, responseData, { requiresAuth: true }),
  
  makeQuoteDecision: (decisionData) => 
    apiClient.post(API_ENDPOINTS.QUOTE_DECISION, decisionData, { requiresAuth: true }),
  
  getMyQuotes: () => 
    apiClient.get(API_ENDPOINTS.MY_QUOTES, { requiresAuth: true }),

  // Upload methods
  uploadPortfolioImage: (formData) => 
    apiClient.upload(API_ENDPOINTS.UPLOAD_PORTFOLIO, formData),
  
  deletePortfolioImage: (imagePath) => 
    apiClient.delete(API_ENDPOINTS.DELETE_PORTFOLIO, { 
      requiresAuth: true,
      body: { image_path: imagePath }
    }),

  // Analytics methods
  getAnalyticsDashboard: (params = {}) =>
    apiClient.get('/api/analytics/dashboard/overview', { 
      requiresAuth: true,
      ...params 
    }),

  getTrends: (params = {}) =>
    apiClient.get('/api/analytics/trends', { 
      requiresAuth: true,
      ...params 
    }),

  getCostEstimate: (jobData) =>
    apiClient.post('/api/analytics/cost-estimate', jobData, { requiresAuth: true }),

  // Legal compliance methods
  getLegalDocument: (documentType) =>
    apiClient.get(`/api/legal/documents/${documentType}`),

  recordConsent: (consentType, granted, version = '1.0') =>
    apiClient.post('/api/legal/consent', {
      consent_type: consentType,
      granted,
      version
    }, { requiresAuth: true }),

  getUserConsents: () =>
    apiClient.get('/api/legal/consents', { requiresAuth: true }),

  requestDataExport: () =>
    apiClient.post('/api/legal/data-export', {}, { requiresAuth: true }),

  requestAccountDeletion: () =>
    apiClient.post('/api/legal/delete-account', {}, { requiresAuth: true }),

  validateAge: (birthDate) =>
    apiClient.post('/api/legal/validate-age', { birth_date: birthDate }),

  getCommunicationRules: () =>
    apiClient.get('/api/legal/communication-rules'),

  getDocumentVersions: () =>
    apiClient.get('/api/legal/document-versions'),

  // Job Management methods
  getJobs: (params = {}) =>
    apiClient.get('/api/job-management/jobs', { 
      requiresAuth: true,
      params 
    }),

  getJobDetail: (jobId) =>
    apiClient.get(`/api/job-management/jobs/${jobId}`, { requiresAuth: true }),

  updateJob: (jobId, updateData) =>
    apiClient.put(`/api/job-management/jobs/${jobId}`, updateData, { requiresAuth: true }),

  getJobMaterials: (jobId) =>
    apiClient.get(`/api/job-management/jobs/${jobId}/materials`, { requiresAuth: true }),

  addJobMaterial: (jobId, materialData) =>
    apiClient.post(`/api/job-management/jobs/${jobId}/materials`, materialData, { requiresAuth: true }),

  updateMaterialStatus: (materialId, status, notes) =>
    apiClient.put(`/api/job-management/materials/${materialId}/status`, { 
      status, 
      notes 
    }, { requiresAuth: true }),

  startTimeTracking: (jobId, entryData) =>
    apiClient.post(`/api/job-management/jobs/${jobId}/time/start`, entryData, { requiresAuth: true }),

  endTimeTracking: (entryId, notes, images) =>
    apiClient.put(`/api/job-management/time-entries/${entryId}/end`, { 
      notes, 
      images 
    }, { requiresAuth: true }),

  getJobTimeSummary: (jobId) =>
    apiClient.get(`/api/job-management/jobs/${jobId}/time-summary`, { requiresAuth: true }),

  getCraftsmanTimeSummary: (startDate, endDate) =>
    apiClient.get('/api/job-management/craftsman/time-summary', { 
      requiresAuth: true,
      params: { start_date: startDate, end_date: endDate }
    }),

  addProgressUpdate: (jobId, updateData) =>
    apiClient.post(`/api/job-management/jobs/${jobId}/progress`, updateData, { requiresAuth: true }),

  getJobProgress: (jobId) =>
    apiClient.get(`/api/job-management/jobs/${jobId}/progress`, { requiresAuth: true }),

  getWarranties: (userType) =>
    apiClient.get('/api/job-management/warranties', { 
      requiresAuth: true,
      params: { user_type: userType }
    }),

  createWarrantyClaim: (jobId, claimData) =>
    apiClient.post(`/api/job-management/jobs/${jobId}/warranty-claim`, claimData, { requiresAuth: true }),

  getWarrantyClaims: (userType) =>
    apiClient.get('/api/job-management/warranty-claims', { 
      requiresAuth: true,
      params: { user_type: userType }
    }),

  processWarrantyClaim: (claimId, action, responseData) =>
    apiClient.put(`/api/job-management/warranty-claims/${claimId}/process`, { 
      action, 
      response_data: responseData 
    }, { requiresAuth: true }),

  createEmergencyRequest: (emergencyData) =>
    apiClient.post('/api/job-management/emergency-services', emergencyData, { requiresAuth: true }),

  getNearbyEmergencies: (maxDistance) =>
    apiClient.get('/api/job-management/emergency-services/nearby', { 
      requiresAuth: true,
      params: { max_distance: maxDistance }
    }),

  assignEmergencyService: (emergencyId) =>
    apiClient.put(`/api/job-management/emergency-services/${emergencyId}/assign`, {}, { requiresAuth: true }),

  updateEmergencyStatus: (emergencyId, status, locationData) =>
    apiClient.put(`/api/job-management/emergency-services/${emergencyId}/status`, { 
      status, 
      location_data: locationData 
    }, { requiresAuth: true }),

  getJobPerformanceMetrics: (userType, days) =>
    apiClient.get('/api/job-management/analytics/performance', { 
      requiresAuth: true,
      params: { user_type: userType, days }
    }),

  getJobCostBreakdown: (jobId) =>
    apiClient.get(`/api/job-management/jobs/${jobId}/cost-breakdown`, { requiresAuth: true }),

  getJobTimeline: (jobId) =>
    apiClient.get(`/api/job-management/jobs/${jobId}/timeline`, { requiresAuth: true }),

  getJobConstants: () =>
    apiClient.get('/api/job-management/constants'),

  getEmergencyStatistics: () =>
    apiClient.get('/api/job-management/emergency-services/statistics', { requiresAuth: true }),

  // Enhanced Notifications methods
  registerDeviceToken: (tokenData) =>
    apiClient.post('/api/notifications/enhanced/device-token', tokenData, { requiresAuth: true }),

  sendNotification: (notificationData) =>
    apiClient.post('/api/notifications/enhanced/send', notificationData, { requiresAuth: true }),

  getNotificationPreferences: () =>
    apiClient.get('/api/notifications/enhanced/preferences', { requiresAuth: true }),

  updateNotificationPreferences: (preferences) =>
    apiClient.put('/api/notifications/enhanced/preferences', preferences, { requiresAuth: true }),

  createLocationShare: (shareData) =>
    apiClient.post('/api/notifications/enhanced/location/share', shareData, { requiresAuth: true }),

  updateLocation: (shareId, locationData) =>
    apiClient.put(`/api/notifications/enhanced/location/share/${shareId}/update`, locationData, { requiresAuth: true }),

  stopLocationShare: (shareId) =>
    apiClient.delete(`/api/notifications/enhanced/location/share/${shareId}/stop`, { requiresAuth: true }),

  getLocationShares: () =>
    apiClient.get('/api/notifications/enhanced/location/shares', { requiresAuth: true }),

  createCalendarEvent: (eventData) =>
    apiClient.post('/api/notifications/enhanced/calendar/event', eventData, { requiresAuth: true }),

  broadcastEmergency: (emergencyData) =>
    apiClient.post('/api/notifications/enhanced/emergency/broadcast', emergencyData, { requiresAuth: true }),

  getNotificationAnalytics: (days = 30) =>
    apiClient.get('/api/notifications/enhanced/analytics', { 
      requiresAuth: true,
      params: { days }
    }),

  trackNotificationInteraction: (notificationId, action) =>
    apiClient.post('/api/notifications/enhanced/interaction', { 
      notification_id: notificationId, 
      action 
    }, { requiresAuth: true }),

  scheduleNotification: (notificationData) =>
    apiClient.post('/api/notifications/enhanced/schedule', notificationData, { requiresAuth: true }),

  getScheduledNotifications: () =>
    apiClient.get('/api/notifications/enhanced/scheduled', { requiresAuth: true }),

  testNotification: (testData) =>
    apiClient.post('/api/notifications/enhanced/test', testData, { requiresAuth: true }),

  subscribeToTopic: (topic) =>
    apiClient.post('/api/notifications/enhanced/topics/subscribe', { topic }, { requiresAuth: true }),

  unsubscribeFromTopic: (topic) =>
    apiClient.post('/api/notifications/enhanced/topics/unsubscribe', { topic }, { requiresAuth: true }),

  // Analytics Dashboard methods
  getAnalyticsDashboard: (params = {}) =>
    apiClient.get('/api/analytics-dashboard/dashboard', { 
      requiresAuth: true,
      params 
    }),

  getCraftsmanOverview: (craftsmanId, days = 30) =>
    apiClient.get(`/api/analytics-dashboard/craftsman/${craftsmanId}/overview`, { 
      requiresAuth: true,
      params: { days }
    }),

  getCustomerHistory: (customerId, days = 30) =>
    apiClient.get(`/api/analytics-dashboard/customer/${customerId}/history`, { 
      requiresAuth: true,
      params: { days }
    }),

  getPlatformTrends: (days = 30) =>
    apiClient.get('/api/analytics-dashboard/trends/platform', { 
      requiresAuth: true,
      params: { days }
    }),

  getCategoryTrends: (days = 30) =>
    apiClient.get('/api/analytics-dashboard/trends/categories', { 
      requiresAuth: true,
      params: { days }
    }),

  getGeographicTrends: (days = 30) =>
    apiClient.get('/api/analytics-dashboard/trends/geographic', { 
      requiresAuth: true,
      params: { days }
    }),

  generateCustomReport: (reportData) =>
    apiClient.post('/api/analytics-dashboard/reports/custom', reportData, { requiresAuth: true }),

  getCraftsmanReport: (craftsmanId, startDate, endDate) =>
    apiClient.get(`/api/analytics-dashboard/reports/craftsman/${craftsmanId}`, { 
      requiresAuth: true,
      params: { start_date: startDate, end_date: endDate }
    }),

  getCustomerReport: (customerId, startDate, endDate) =>
    apiClient.get(`/api/analytics-dashboard/reports/customer/${customerId}`, { 
      requiresAuth: true,
      params: { start_date: startDate, end_date: endDate }
    }),

  calculateJobCost: (costData) =>
    apiClient.post('/api/analytics-dashboard/cost-calculator', costData, { requiresAuth: true }),

  getMarketComparison: (comparisonData) =>
    apiClient.post('/api/analytics-dashboard/cost-calculator/market-comparison', comparisonData, { requiresAuth: true }),

  getPricingRecommendations: (craftsmanId, category) =>
    apiClient.get(`/api/analytics-dashboard/cost-calculator/pricing-recommendations/${craftsmanId}`, { 
      requiresAuth: true,
      params: { category }
    }),

  getConversionFunnel: (days = 30) =>
    apiClient.get('/api/analytics-dashboard/business/conversion-funnel', { 
      requiresAuth: true,
      params: { days }
    }),

  getRevenueAnalytics: (days = 30) =>
    apiClient.get('/api/analytics-dashboard/business/revenue', { 
      requiresAuth: true,
      params: { days }
    }),

  getEngagementMetrics: (days = 30) =>
    apiClient.get('/api/analytics-dashboard/business/engagement', { 
      requiresAuth: true,
      params: { days }
    }),

  getRecentActivity: (limit = 20) =>
    apiClient.get('/api/analytics-dashboard/activity/recent', { 
      requiresAuth: true,
      params: { limit }
    }),

  getAnalyticsDashboardConstants: () =>
    apiClient.get('/api/analytics-dashboard/constants'),

  comparePerformance: (days = 30, category = null) =>
    apiClient.get('/api/analytics-dashboard/performance/compare', { 
      requiresAuth: true,
      params: { days, category }
    }),

  exportDashboard: (exportData) =>
    apiClient.post('/api/analytics-dashboard/export/dashboard', exportData, { requiresAuth: true }),

  getRealtimeMetrics: () =>
    apiClient.get('/api/analytics-dashboard/realtime/metrics', { requiresAuth: true }),

  // Track API call performance
  _trackApiCall(endpoint, method, statusCode, duration) {
    try {
      AnalyticsManager.getInstance().trackApiCall(endpoint, method, statusCode, duration);
    } catch (error) {
      // Silently fail to avoid disrupting API calls
      console.warn('Failed to track API call:', error);
    }
  },
};

export { ApiError, apiClient };
export default api;