import React from 'react'
import { render } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'

// Custom render function that includes providers
export function renderWithProviders(ui, options = {}) {
  const {
    initialEntries = ['/'],
    ...renderOptions
  } = options

  function Wrapper({ children }) {
    return (
      <BrowserRouter>
        {children}
      </BrowserRouter>
    )
  }

  return render(ui, { wrapper: Wrapper, ...renderOptions })
}

// Mock API responses
export const mockApiResponses = {
  // Auth responses
  loginSuccess: {
    success: true,
    data: {
      access_token: 'mock-token',
      user: {
        id: 1,
        email: 'test@example.com',
        first_name: 'Test',
        last_name: 'User',
        user_type: 'customer'
      }
    }
  },
  
  loginError: {
    success: false,
    error: true,
    message: 'Geçersiz email veya şifre',
    code: 'INVALID_CREDENTIALS'
  },
  
  // Search responses
  searchCraftsmen: {
    success: true,
    data: {
      craftsmen: [
        {
          id: 1,
          business_name: 'Test Elektrik',
          description: 'Test açıklama',
          city: 'İstanbul',
          average_rating: 4.5,
          hourly_rate: 150.0,
          user: {
            first_name: 'Ahmet',
            last_name: 'Usta'
          }
        }
      ],
      pagination: {
        page: 1,
        per_page: 10,
        total: 1,
        pages: 1
      }
    }
  },
  
  // Quote responses
  quoteRequest: {
    success: true,
    data: {
      quote: {
        id: 1,
        status: 'PENDING',
        category: 'Elektrik',
        description: 'Test iş'
      }
    }
  }
}

// Mock localStorage
export const mockLocalStorage = (() => {
  let store = {}
  
  return {
    getItem: (key) => store[key] || null,
    setItem: (key, value) => store[key] = value.toString(),
    removeItem: (key) => delete store[key],
    clear: () => store = {},
    get length() {
      return Object.keys(store).length
    },
    key: (index) => Object.keys(store)[index] || null
  }
})()

// Mock fetch for API calls
export function mockFetch(responses = {}) {
  return jest.fn((url, options = {}) => {
    const method = options.method || 'GET'
    const key = `${method} ${url}`
    
    if (responses[key]) {
      return Promise.resolve({
        ok: responses[key].ok !== false,
        status: responses[key].status || 200,
        json: () => Promise.resolve(responses[key].data || responses[key])
      })
    }
    
    // Default success response
    return Promise.resolve({
      ok: true,
      status: 200,
      json: () => Promise.resolve({ success: true, data: {} })
    })
  })
}

// Test data factories
export const createTestUser = (overrides = {}) => ({
  id: 1,
  email: 'test@example.com',
  first_name: 'Test',
  last_name: 'User',
  user_type: 'customer',
  ...overrides
})

export const createTestCraftsman = (overrides = {}) => ({
  id: 1,
  business_name: 'Test İşletme',
  description: 'Test açıklama',
  specialties: 'Elektrik',
  city: 'İstanbul',
  district: 'Kadıköy',
  average_rating: 4.5,
  hourly_rate: 150.0,
  is_available: true,
  is_verified: true,
  user: createTestUser({ user_type: 'craftsman' }),
  ...overrides
})

export const createTestQuote = (overrides = {}) => ({
  id: 1,
  status: 'PENDING',
  category: 'Elektrik',
  area_type: 'salon',
  budget_range: '1000-3000',
  description: 'Test iş açıklaması',
  customer_id: 1,
  craftsman_id: 1,
  created_at: new Date().toISOString(),
  ...overrides
})

// Custom matchers for better assertions
export const customMatchers = {
  toBeValidApiResponse(received) {
    const pass = received && 
                 typeof received === 'object' &&
                 'success' in received &&
                 typeof received.success === 'boolean'
    
    return {
      message: () => `Expected ${received} to be a valid API response`,
      pass
    }
  },
  
  toHaveSuccessResponse(received) {
    const pass = received && 
                 received.success === true &&
                 'data' in received
    
    return {
      message: () => `Expected ${received} to have success response`,
      pass
    }
  },
  
  toHaveErrorResponse(received) {
    const pass = received && 
                 received.success === false &&
                 received.error === true &&
                 'message' in received
    
    return {
      message: () => `Expected ${received} to have error response`,
      pass
    }
  }
}