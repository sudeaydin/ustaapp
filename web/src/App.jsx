import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, useLocation } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AuthProvider } from './context/AuthContext';
import { AnalyticsManager } from './utils/analytics';
import { AccessibilityManager, SkipLink } from './utils/accessibility';

// Import pages
import { StartPage } from './pages/StartPage';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import { HomePage } from './pages/HomePage';
import { CraftsmanListPage } from './pages/CraftsmanListPage';
import ProfilePage from './pages/ProfilePage';
import MessagesPage from './pages/MessagesPage';
import TestUploadPage from './pages/TestUploadPage';
import ProfileEditPage from './pages/ProfileEditPage';
import RealTimeChatPage from './pages/RealTimeChatPage';
import CraftsmanRegisterPage from './pages/CraftsmanRegisterPage';
import CustomerRegisterPage from './pages/CustomerRegisterPage';
import CraftsmanDashboard from './pages/CraftsmanDashboard';
import CustomerDashboard from './pages/CustomerDashboard';
import CraftsmenSearchPage from './pages/CraftsmenSearchPage';
import CraftsmanJobHistoryPage from './pages/CraftsmanJobHistoryPage';
import CustomerJobHistoryPage from './pages/CustomerJobHistoryPage';
import CraftsmanProfilePage from './pages/CraftsmanProfilePage';
import ReviewFormPage from './pages/ReviewFormPage';
import JobRequestFormPage from './pages/JobRequestFormPage';
import JobListPage from './pages/JobListPage';
import JobDetailPage from './pages/JobDetailPage';
import ProposalFormPage from './pages/ProposalFormPage';
import JobProgressPage from './pages/JobProgressPage';
import AnalyticsPage from './pages/AnalyticsPage';
import NotificationsPage from './pages/NotificationsPage';
import TestingPage from './pages/TestingPage';
import AccessibilityTestPage from './pages/AccessibilityTestPage';
import LandingPage from './pages/LandingPage';
import SearchPage from './pages/SearchPage';
import PaymentPage from './pages/PaymentPage';
import PaymentHistory from './components/PaymentHistory';
import OnboardingPage from './pages/OnboardingPage';
import AuthChoicePage from './pages/AuthChoicePage';
import QuoteRequestFormPage from './pages/QuoteRequestFormPage';
import QuotePaymentPage from './pages/QuotePaymentPage';
import { CraftsmanBusinessProfilePage } from './pages/CraftsmanBusinessProfilePage';
import LegalPage from './pages/LegalPage';
import JobDashboard from './components/jobs/JobDashboard';
import NotificationCenter from './components/notifications/NotificationCenter';
import { NotificationProvider } from './context/NotificationContext';
import { ProtectedRoute, PublicRoute, CustomerRoute, CraftsmanRoute } from './components/ProtectedRoute';
import MobileNavigation from './components/MobileNavigation';
import ErrorBoundary from './components/ErrorBoundary';
import CookieConsentBanner from './components/common/CookieConsentBanner';
import UserAgreementChecker from './components/legal/UserAgreementChecker';

// Create QueryClient
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      staleTime: 5 * 60 * 1000, // 5 minutes
    },
  },
});

// Analytics tracking component
function AnalyticsTracker() {
  const location = useLocation();
  
  useEffect(() => {
    // Initialize analytics on app start
    AnalyticsManager.getInstance().initialize();
    
    // Track page view on location change
    AnalyticsManager.getInstance().trackPageView(location.pathname);
  }, [location]);
  
  return null;
}

// Accessibility initialization component
function AccessibilityInitializer() {
  useEffect(() => {
    // Initialize accessibility features
    AccessibilityManager.initialize();
  }, []);
  
  return null;
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <AuthProvider>
          <NotificationProvider>
            <ErrorBoundary>
              <AnalyticsTracker />
              <AccessibilityInitializer />
              <SkipLink href="#main-content" />
              <CookieConsentBanner />
              <UserAgreementChecker />
              <div className="App">
                <main id="main-content" role="main">
                  <Routes>
                    {/* 🌐 Public Routes - Anyone can access */}
                    <Route path="/" element={<PublicRoute><OnboardingPage /></PublicRoute>} />
                    <Route path="/landing" element={<PublicRoute><LandingPage /></PublicRoute>} />
                    <Route path="/auth-choice" element={<PublicRoute><AuthChoicePage /></PublicRoute>} />
                    <Route path="/login" element={<PublicRoute><LoginPage /></PublicRoute>} />
                    <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />
                    <Route path="/register/craftsman" element={<PublicRoute><CraftsmanRegisterPage /></PublicRoute>} />
                    <Route path="/register/customer" element={<PublicRoute><CustomerRegisterPage /></PublicRoute>} />
                    <Route path="/craftsmen" element={<PublicRoute><CraftsmanListPage /></PublicRoute>} />
                    <Route path="/search" element={<SearchPage />} />
                    <Route path="/craftsman/:id" element={<PublicRoute><CraftsmanProfilePage /></PublicRoute>} />
                    <Route path="/legal" element={<PublicRoute><LegalPage /></PublicRoute>} />
                    
                    {/* 🔒 Protected Routes - Login required */}
                    <Route path="/profile" element={<ProtectedRoute><ProfilePage /></ProtectedRoute>} />
                    <Route path="/profile/edit" element={<ProtectedRoute><ProfileEditPage /></ProtectedRoute>} />
                    <Route path="/messages" element={<ProtectedRoute><MessagesPage /></ProtectedRoute>} />
                    <Route path="/messages/:partnerId" element={<ProtectedRoute><MessagesPage /></ProtectedRoute>} />
                    <Route path="/chat/:partnerId" element={<ProtectedRoute><RealTimeChatPage /></ProtectedRoute>} />
                    <Route path="/job/:jobId" element={<ProtectedRoute><JobDetailPage /></ProtectedRoute>} />
                    <Route path="/job/:jobId/progress" element={<ProtectedRoute><JobProgressPage /></ProtectedRoute>} />
                    <Route path="/analytics" element={<ProtectedRoute><AnalyticsPage /></ProtectedRoute>} />
                    <Route path="/notifications" element={<ProtectedRoute><NotificationsPage /></ProtectedRoute>} />
                    <Route path="/testing" element={<ProtectedRoute><TestingPage /></ProtectedRoute>} />
                    <Route path="/accessibility-test" element={<ProtectedRoute><AccessibilityTestPage /></ProtectedRoute>} />
                    <Route path="/payment-history" element={<ProtectedRoute><PaymentHistory /></ProtectedRoute>} />
                    <Route path="/jobs" element={<ProtectedRoute><JobListPage /></ProtectedRoute>} />
                    <Route path="/job-management" element={<ProtectedRoute><JobDashboard /></ProtectedRoute>} />
                    <Route path="/enhanced-notifications" element={<ProtectedRoute><NotificationCenter /></ProtectedRoute>} />
                    <Route path="/test-upload" element={<ProtectedRoute><TestUploadPage /></ProtectedRoute>} />
                    
                    {/* 👤 Customer Only Routes */}
                    <Route path="/dashboard/customer" element={<CustomerRoute><CustomerDashboard /></CustomerRoute>} />
                    <Route path="/customer/jobs" element={<CustomerRoute><CustomerJobHistoryPage /></CustomerRoute>} />
                    <Route path="/job-request/new" element={<CustomerRoute><JobRequestFormPage /></CustomerRoute>} />
                    <Route path="/quote-request/:craftsmanId" element={<CustomerRoute><QuoteRequestFormPage /></CustomerRoute>} />
                    <Route path="/payment/quote/:quoteId" element={<CustomerRoute><QuotePaymentPage /></CustomerRoute>} />
                    <Route path="/craftsman/:id/business-profile" element={<ProtectedRoute><CraftsmanBusinessProfilePage /></ProtectedRoute>} />
                    <Route path="/review/:jobId" element={<CustomerRoute><ReviewFormPage /></CustomerRoute>} />
                    <Route path="/payment/:jobId" element={<CustomerRoute><PaymentPage /></CustomerRoute>} />
                    
                    {/* 🔨 Craftsman Only Routes */}
                    <Route path="/dashboard/craftsman" element={<CraftsmanRoute><CraftsmanDashboard /></CraftsmanRoute>} />
                    <Route path="/craftsman/jobs" element={<CraftsmanRoute><CraftsmanJobHistoryPage /></CraftsmanRoute>} />
                    <Route path="/job/:jobId/proposal" element={<CraftsmanRoute><ProposalFormPage /></CraftsmanRoute>} />
                    
                    {/* 📋 Legacy/Dev Routes */}
                    <Route path="/start" element={<PublicRoute><StartPage /></PublicRoute>} />
                    <Route path="/home" element={<PublicRoute><HomePage /></PublicRoute>} />
                  </Routes>
                </main>
                <MobileNavigation />
              </div>
            </ErrorBoundary>
          </NotificationProvider>
        </AuthProvider>
      </Router>
    </QueryClientProvider>
  );
}

export default App;
