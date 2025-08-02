// Test utilities for ustam application
export const TestUtils = {
  // Form validation helpers
  validateEmail: (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  },

  validatePhone: (phone) => {
    const phoneRegex = /^(\+90|0)?[5][0-9]{9}$/;
    return phoneRegex.test(phone.replace(/\s/g, ''));
  },

  validatePassword: (password) => {
    return {
      length: password.length >= 8,
      hasUpperCase: /[A-Z]/.test(password),
      hasLowerCase: /[a-z]/.test(password),
      hasNumber: /\d/.test(password),
      hasSpecialChar: /[!@#$%^&*(),.?":{}|<>]/.test(password),
      isValid: password.length >= 8 && /[A-Z]/.test(password) && /[a-z]/.test(password) && /\d/.test(password)
    };
  },

  // Data validation
  validateJobRequest: (jobData) => {
    const errors = {};
    
    if (!jobData.title || jobData.title.trim().length < 5) {
      errors.title = 'İş başlığı en az 5 karakter olmalıdır';
    }
    
    if (!jobData.description || jobData.description.trim().length < 20) {
      errors.description = 'İş açıklaması en az 20 karakter olmalıdır';
    }
    
    if (!jobData.category) {
      errors.category = 'Kategori seçimi zorunludur';
    }
    
    if (!jobData.budget || jobData.budget < 50) {
      errors.budget = 'Bütçe en az 50 TL olmalıdır';
    }
    
    if (!jobData.location || !jobData.location.city) {
      errors.location = 'Şehir seçimi zorunludur';
    }
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors
    };
  },

  validateProposal: (proposalData) => {
    const errors = {};
    
    if (!proposalData.message || proposalData.message.trim().length < 10) {
      errors.message = 'Teklif mesajı en az 10 karakter olmalıdır';
    }
    
    if (!proposalData.price || proposalData.price < 1) {
      errors.price = 'Fiyat 1 TL\'den fazla olmalıdır';
    }
    
    if (!proposalData.timeline || proposalData.timeline < 1) {
      errors.timeline = 'Teslim süresi en az 1 gün olmalıdır';
    }
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors
    };
  },

  // Component testing helpers
  simulateFormSubmit: (formData) => {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({
          success: true,
          data: formData,
          timestamp: new Date().toISOString()
        });
      }, 1000);
    });
  },

  simulateApiCall: (endpoint, method = 'GET', data = null) => {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        // Simulate different response scenarios
        const scenarios = {
          '/api/login': { success: true, user: { id: 1, name: 'Test User' } },
          '/api/jobs': { success: true, jobs: [] },
          '/api/proposals': { success: true, proposals: [] },
          '/api/messages': { success: true, messages: [] },
          '/api/analytics': { success: true, analytics: {} },
          '/api/notifications': { success: true, notifications: [] }
        };

        if (Math.random() > 0.9) {
          // 10% chance of error for testing
          reject(new Error('Simulated API error'));
        } else {
          resolve(scenarios[endpoint] || { success: true, data: data });
        }
      }, Math.random() * 1000 + 500); // Random delay 500-1500ms
    });
  },

  // Performance testing
  measurePerformance: (functionToTest, iterations = 100) => {
    const startTime = performance.now();
    
    for (let i = 0; i < iterations; i++) {
      functionToTest();
    }
    
    const endTime = performance.now();
    const totalTime = endTime - startTime;
    
    return {
      totalTime: totalTime.toFixed(2),
      averageTime: (totalTime / iterations).toFixed(2),
      iterations
    };
  },

  // Accessibility testing helpers
  checkAccessibility: (element) => {
    const issues = [];
    
    // Check for alt text on images
    const images = element.querySelectorAll('img');
    images.forEach((img, index) => {
      if (!img.alt) {
        issues.push(`Image ${index + 1} missing alt text`);
      }
    });
    
    // Check for form labels
    const inputs = element.querySelectorAll('input, textarea, select');
    inputs.forEach((input, index) => {
      const hasLabel = input.labels && input.labels.length > 0;
      const hasAriaLabel = input.getAttribute('aria-label');
      const hasPlaceholder = input.placeholder;
      
      if (!hasLabel && !hasAriaLabel && !hasPlaceholder) {
        issues.push(`Form input ${index + 1} missing label or aria-label`);
      }
    });
    
    // Check for heading hierarchy
    const headings = element.querySelectorAll('h1, h2, h3, h4, h5, h6');
    let previousLevel = 0;
    headings.forEach((heading, index) => {
      const currentLevel = parseInt(heading.tagName.charAt(1));
      if (index === 0 && currentLevel !== 1) {
        issues.push('Page should start with h1');
      }
      if (currentLevel > previousLevel + 1) {
        issues.push(`Heading level jump from h${previousLevel} to h${currentLevel}`);
      }
      previousLevel = currentLevel;
    });
    
    return {
      isAccessible: issues.length === 0,
      issues
    };
  },

  // Error simulation for testing error boundaries
  simulateError: (errorType = 'generic') => {
    const errors = {
      generic: new Error('Simulated generic error'),
      network: new Error('Network connection failed'),
      validation: new Error('Validation failed'),
      permission: new Error('Permission denied'),
      notFound: new Error('Resource not found')
    };
    
    throw errors[errorType] || errors.generic;
  },

  // Local storage testing
  testLocalStorage: () => {
    try {
      const testKey = '__test__';
      const testValue = 'test';
      localStorage.setItem(testKey, testValue);
      const retrieved = localStorage.getItem(testKey);
      localStorage.removeItem(testKey);
      return retrieved === testValue;
    } catch (error) {
      return false;
    }
  },

  // Session storage testing
  testSessionStorage: () => {
    try {
      const testKey = '__test__';
      const testValue = 'test';
      sessionStorage.setItem(testKey, testValue);
      const retrieved = sessionStorage.getItem(testKey);
      sessionStorage.removeItem(testKey);
      return retrieved === testValue;
    } catch (error) {
      return false;
    }
  },

  // Browser feature detection
  detectFeatures: () => {
    return {
      localStorage: TestUtils.testLocalStorage(),
      sessionStorage: TestUtils.testSessionStorage(),
      geolocation: 'geolocation' in navigator,
      notifications: 'Notification' in window,
      serviceWorker: 'serviceWorker' in navigator,
      webRTC: !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia),
      touchSupport: 'ontouchstart' in window,
      darkModeSupport: window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
    };
  },

  // Generate test data
  generateTestData: {
    user: (overrides = {}) => ({
      id: Math.floor(Math.random() * 1000),
      first_name: 'Test',
      last_name: 'User',
      email: `test${Math.floor(Math.random() * 1000)}@example.com`,
      phone: '05551234567',
      user_type: 'customer',
      created_at: new Date().toISOString(),
      ...overrides
    }),

    job: (overrides = {}) => ({
      id: Math.floor(Math.random() * 1000),
      title: 'Test İş',
      description: 'Bu bir test iş açıklamasıdır. En az 20 karakter olmalıdır.',
      category: 'Elektrikçi',
      budget: Math.floor(Math.random() * 1000) + 100,
      location: { city: 'İstanbul', district: 'Kadıköy' },
      status: 'active',
      created_at: new Date().toISOString(),
      ...overrides
    }),

    proposal: (overrides = {}) => ({
      id: Math.floor(Math.random() * 1000),
      job_id: Math.floor(Math.random() * 100),
      craftsman_id: Math.floor(Math.random() * 100),
      message: 'Test teklif mesajı',
      price: Math.floor(Math.random() * 500) + 50,
      timeline: Math.floor(Math.random() * 10) + 1,
      status: 'pending',
      created_at: new Date().toISOString(),
      ...overrides
    }),

    notification: (overrides = {}) => ({
      id: Math.floor(Math.random() * 1000),
      type: 'message',
      title: 'Test Bildirim',
      message: 'Bu bir test bildirimidir',
      read: false,
      priority: 'normal',
      timestamp: new Date(),
      actionUrl: '/test',
      ...overrides
    })
  },

  // Visual regression testing helpers
  captureScreenshot: async (element, filename) => {
    if (typeof html2canvas !== 'undefined') {
      try {
        const canvas = await html2canvas(element);
        const link = document.createElement('a');
        link.download = filename || 'screenshot.png';
        link.href = canvas.toDataURL();
        link.click();
        return canvas.toDataURL();
      } catch (error) {
        console.error('Screenshot capture failed:', error);
        return null;
      }
    }
    return null;
  },

  // Memory leak detection
  detectMemoryLeaks: () => {
    if (performance.memory) {
      return {
        usedJSHeapSize: performance.memory.usedJSHeapSize,
        totalJSHeapSize: performance.memory.totalJSHeapSize,
        jsHeapSizeLimit: performance.memory.jsHeapSizeLimit,
        usage: ((performance.memory.usedJSHeapSize / performance.memory.jsHeapSizeLimit) * 100).toFixed(2)
      };
    }
    return null;
  }
};

export default TestUtils;