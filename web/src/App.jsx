import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

// Pages
import { StartPage } from './pages/StartPage'
import { LoginPage } from './pages/LoginPage'
import { RegisterPage } from './pages/RegisterPage'
import { HomePage } from './pages/HomePage'
import { CraftsmanListPage } from './pages/CraftsmanListPage'
import { CraftsmanDetailPage } from './pages/CraftsmanDetailPage'
import { QuoteRequestPage } from './pages/QuoteRequestPage'

// Create a client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
    },
  },
})

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <div className="min-h-screen bg-gray-50">
          <Routes>
            <Route path="/" element={<StartPage />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} />
            <Route path="/home" element={<HomePage />} />
            <Route path="/dashboard" element={<HomePage />} />
            <Route path="/craftsmen" element={<CraftsmanListPage />} />
            <Route path="/craftsman/:id" element={<CraftsmanDetailPage />} />
            <Route path="/quote-request/:craftsmanId" element={<QuoteRequestPage />} />
          </Routes>
        </div>
      </Router>
    </QueryClientProvider>
  )
}

export default App
