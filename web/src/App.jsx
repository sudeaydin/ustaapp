import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AuthProvider } from './context/AuthContext';

// Import pages
import { StartPage } from './pages/StartPage';
import { LoginPage } from './pages/LoginPage';
import { RegisterPage } from './pages/RegisterPage';
import { HomePage } from './pages/HomePage';
import { CraftsmanListPage } from './pages/CraftsmanListPage';
import { ProfilePage } from './pages/ProfilePage';
import { MessagesPage } from './pages/MessagesPage';
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
import MessagesPage from './pages/MessagesPage';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import ProfilePage from './pages/ProfilePage';
import LandingPage from './pages/LandingPage';
import AnalyticsPage from './pages/AnalyticsPage';
import NotificationsPage from './pages/NotificationsPage';
import TestingPage from './pages/TestingPage';
import PaymentPage from './pages/PaymentPage';
import PaymentHistory from './components/PaymentHistory';
import { NotificationProvider } from './context/NotificationContext';
import { ProtectedRoute, PublicRoute, CustomerRoute, CraftsmanRoute } from './components/ProtectedRoute';
import MobileNavigation from './components/MobileNavigation';
import ErrorBoundary from './components/ErrorBoundary';

// Create QueryClient
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      staleTime: 5 * 60 * 1000, // 5 minutes
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <AuthProvider>
          <NotificationProvider>
            <ErrorBoundary>
              <div className="App">
            <Routes>
              {/* 🌐 Public Routes - Anyone can access */}
              <Route path="/" element={<PublicRoute><LandingPage /></PublicRoute>} />
              <Route path="/login" element={<PublicRoute><LoginPage /></PublicRoute>} />
              <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />
              <Route path="/craftsmen" element={<PublicRoute><CraftsmanListPage /></PublicRoute>} />
              <Route path="/craftsman/:id" element={<PublicRoute><CraftsmanProfilePage /></PublicRoute>} />
              
              {/* 🔒 Protected Routes - Login required */}
              <Route path="/profile" element={<ProtectedRoute><ProfilePage /></ProtectedRoute>} />
              <Route path="/messages" element={<ProtectedRoute><MessagesPage /></ProtectedRoute>} />
              <Route path="/messages/:partnerId" element={<ProtectedRoute><MessagesPage /></ProtectedRoute>} />
              <Route path="/job/:jobId" element={<ProtectedRoute><JobDetailPage /></ProtectedRoute>} />
              <Route path="/job/:jobId/progress" element={<ProtectedRoute><JobProgressPage /></ProtectedRoute>} />
              <Route path="/analytics" element={<ProtectedRoute><AnalyticsPage /></ProtectedRoute>} />
              <Route path="/notifications" element={<ProtectedRoute><NotificationsPage /></ProtectedRoute>} />
              <Route path="/testing" element={<ProtectedRoute><TestingPage /></ProtectedRoute>} />
              <Route path="/payment-history" element={<ProtectedRoute><PaymentHistory /></ProtectedRoute>} />
              
              {/* 👤 Customer Only Routes */}
              <Route path="/dashboard/customer" element={<CustomerRoute><CustomerDashboard /></CustomerRoute>} />
              <Route path="/customer/jobs" element={<CustomerRoute><CustomerJobHistoryPage /></CustomerRoute>} />
              <Route path="/job-request/new" element={<CustomerRoute><JobRequestFormPage /></CustomerRoute>} />
              <Route path="/review/:jobId" element={<CustomerRoute><ReviewFormPage /></CustomerRoute>} />
              <Route path="/payment/:jobId" element={<CustomerRoute><PaymentPage /></CustomerRoute>} />
              
              {/* 🔨 Craftsman Only Routes */}
              <Route path="/dashboard/craftsman" element={<CraftsmanRoute><CraftsmanDashboard /></CraftsmanRoute>} />
              <Route path="/craftsman/jobs" element={<CraftsmanRoute><CraftsmanJobHistoryPage /></CraftsmanRoute>} />
              <Route path="/job/:jobId/proposal" element={<CraftsmanRoute><ProposalFormPage /></CraftsmanRoute>} />
              
              {/* 📋 Legacy/Dev Routes */}
              <Route path="/start" element={<PublicRoute><StartPage /></PublicRoute>} />
              <Route path="/home" element={<PublicRoute><HomePage /></PublicRoute>} />
              <Route path="/jobs" element={<ProtectedRoute><JobListPage /></ProtectedRoute>} />
              <Route path="/test-upload" element={<ProtectedRoute><TestUploadPage /></ProtectedRoute>} />
              <Route path="/profile/edit" element={<ProtectedRoute><ProfileEditPage /></ProtectedRoute>} />
              <Route path="/chat/:partnerId" element={<ProtectedRoute><RealTimeChatPage /></ProtectedRoute>} />
              <Route path="/register/craftsman" element={<PublicRoute><CraftsmanRegisterPage /></PublicRoute>} />
              <Route path="/register/customer" element={<PublicRoute><CustomerRegisterPage /></PublicRoute>} />
              <Route path="/craftsmen" element={<PublicRoute><CraftsmenSearchPage /></PublicRoute>} />
              <Route path="/messages" element={<MessagesPage />} />
              <Route path="/messages/:conversationId" element={<MessagesPage />} />
              <Route path="/login" element={<LoginPage />} />
              <Route path="/register" element={<RegisterPage />} />
              <Route path="/profile" element={<ProfilePage />} />
              <Route path="/profile/:userId" element={<ProfilePage />} />
            </Routes>
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
