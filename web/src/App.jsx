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
          <div className="App">
            <Routes>
              <Route path="/" element={<StartPage />} />
              <Route path="/login" element={<LoginPage />} />
              <Route path="/register" element={<RegisterPage />} />
              <Route path="/home" element={<HomePage />} />
              <Route path="/craftsmen" element={<CraftsmanListPage />} />
              <Route path="/profile" element={<ProfilePage />} />
              <Route path="/messages" element={<MessagesPage />} />
              <Route path="/messages/:partnerId" element={<MessagesPage />} />
              <Route path="/test-upload" element={<TestUploadPage />} />
              <Route path="/profile/edit" element={<ProfileEditPage />} />
              <Route path="/chat/:partnerId" element={<RealTimeChatPage />} />
              <Route path="/register/craftsman" element={<CraftsmanRegisterPage />} />
              <Route path="/register/customer" element={<CustomerRegisterPage />} />
              <Route path="/dashboard/craftsman" element={<CraftsmanDashboard />} />
              <Route path="/dashboard/customer" element={<CustomerDashboard />} />
              <Route path="/craftsmen" element={<CraftsmenSearchPage />} />
              <Route path="/craftsman/jobs" element={<CraftsmanJobHistoryPage />} />
              <Route path="/customer/jobs" element={<CustomerJobHistoryPage />} />
              <Route path="/craftsman/:id" element={<CraftsmanProfilePage />} />
              <Route path="/review/:jobId" element={<ReviewFormPage />} />
              <Route path="/job-request/new" element={<JobRequestFormPage />} />
              <Route path="/jobs" element={<JobListPage />} />
              <Route path="/job/:jobId" element={<JobDetailPage />} />
              <Route path="/job/:jobId/proposal" element={<ProposalFormPage />} />
              <Route path="/job/:jobId/progress" element={<JobProgressPage />} />
            </Routes>
          </div>
        </AuthProvider>
      </Router>
    </QueryClientProvider>
  );
}

export default App;
