import React, { useState, useEffect, useRef } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNotification } from '../context/NotificationContext';
import TestUtils from '../utils/testUtils';

const TestingPage = () => {
  const { user } = useAuth();
  const { addNotification } = useNotification();
  const [activeTab, setActiveTab] = useState('validation');
  const [testResults, setTestResults] = useState({});
  const [isRunning, setIsRunning] = useState(false);
  const testContainerRef = useRef(null);

  const tabs = [
    { id: 'validation', label: 'Form Validation', icon: '✅' },
    { id: 'api', label: 'API Testing', icon: '🌐' },
    { id: 'performance', label: 'Performance', icon: '⚡' },
    { id: 'accessibility', label: 'Accessibility', icon: '♿' },
    { id: 'browser', label: 'Browser Features', icon: '🔧' },
    { id: 'data', label: 'Test Data', icon: '📊' },
    { id: 'visual', label: 'Visual Testing', icon: '👁️' }
  ];

  // Form validation tests
  const [validationTests, setValidationTests] = useState({
    email: '',
    phone: '',
    password: '',
    jobTitle: '',
    jobDescription: '',
    jobBudget: '',
    proposalMessage: '',
    proposalPrice: ''
  });

  // API test results
  const [apiResults, setApiResults] = useState([]);

  // Performance test results
  const [performanceResults, setPerformanceResults] = useState(null);

  // Accessibility test results
  const [accessibilityResults, setAccessibilityResults] = useState(null);

  // Browser features
  const [browserFeatures, setBrowserFeatures] = useState(null);

  useEffect(() => {
    // Initialize browser feature detection
    setBrowserFeatures(TestUtils.detectFeatures());
  }, []);

  const runValidationTests = () => {
    const results = {
      email: TestUtils.validateEmail(validationTests.email),
      phone: TestUtils.validatePhone(validationTests.phone),
      password: TestUtils.validatePassword(validationTests.password),
      jobRequest: TestUtils.validateJobRequest({
        title: validationTests.jobTitle,
        description: validationTests.jobDescription,
        budget: parseInt(validationTests.jobBudget) || 0,
        category: 'Elektrikçi',
        location: { city: 'İstanbul' }
      }),
      proposal: TestUtils.validateProposal({
        message: validationTests.proposalMessage,
        price: parseInt(validationTests.proposalPrice) || 0,
        timeline: 5
      })
    };
    
    setTestResults({ ...testResults, validation: results });
  };

  const runApiTests = async () => {
    setIsRunning(true);
    const endpoints = [
      '/api/login',
      '/api/jobs',
      '/api/proposals',
      '/api/messages',
      '/api/analytics',
      '/api/notifications'
    ];

    const results = [];
    
    for (const endpoint of endpoints) {
      try {
        const startTime = performance.now();
        const response = await TestUtils.simulateApiCall(endpoint);
        const endTime = performance.now();
        
        results.push({
          endpoint,
          status: 'success',
          responseTime: (endTime - startTime).toFixed(2),
          data: response
        });
      } catch (error) {
        results.push({
          endpoint,
          status: 'error',
          error: error.message
        });
      }
    }
    
    setApiResults(results);
    setIsRunning(false);
  };

  const runPerformanceTests = () => {
    const testFunction = () => {
      // Simulate heavy computation
      let result = 0;
      for (let i = 0; i < 1000; i++) {
        result += Math.random();
      }
      return result;
    };

    const results = TestUtils.measurePerformance(testFunction, 100);
    const memoryUsage = TestUtils.detectMemoryLeaks();
    
    setPerformanceResults({
      computation: results,
      memory: memoryUsage
    });
  };

  const runAccessibilityTests = () => {
    if (testContainerRef.current) {
      const results = TestUtils.checkAccessibility(testContainerRef.current);
      setAccessibilityResults(results);
    }
  };

  const generateTestData = (type) => {
    const data = TestUtils.generateTestData[type]();
    addNotification({
      type: 'system',
      title: 'Test Data Generated',
      message: `${type.charAt(0).toUpperCase() + type.slice(1)} test data created`,
      priority: 'low'
    });
    return data;
  };

  const captureScreenshot = async () => {
    if (testContainerRef.current) {
      const screenshot = await TestUtils.captureScreenshot(
        testContainerRef.current,
        `ustam-screenshot-${Date.now()}.png`
      );
      if (screenshot) {
        addNotification({
          type: 'system',
          title: 'Screenshot Captured',
          message: 'Visual test screenshot has been saved',
          priority: 'normal'
        });
      }
    }
  };

  const simulateError = (errorType) => {
    try {
      TestUtils.simulateError(errorType);
    } catch (error) {
      addNotification({
        type: 'system',
        title: 'Error Simulated',
        message: `${errorType} error: ${error.message}`,
        priority: 'high'
      });
    }
  };

  const renderValidationTab = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Form Validation Tests
        </h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Email Validation */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Email Test
            </label>
            <input
              type="email"
              value={validationTests.email}
              onChange={(e) => setValidationTests({...validationTests, email: e.target.value})}
              placeholder="test@example.com"
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
            {testResults.validation?.email !== undefined && (
              <p className={`text-sm mt-1 ${testResults.validation.email ? 'text-green-600' : 'text-red-600'}`}>
                {testResults.validation.email ? '✅ Valid email' : '❌ Invalid email'}
              </p>
            )}
          </div>

          {/* Phone Validation */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Phone Test
            </label>
            <input
              type="tel"
              value={validationTests.phone}
              onChange={(e) => setValidationTests({...validationTests, phone: e.target.value})}
              placeholder="05551234567"
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
            {testResults.validation?.phone !== undefined && (
              <p className={`text-sm mt-1 ${testResults.validation.phone ? 'text-green-600' : 'text-red-600'}`}>
                {testResults.validation.phone ? '✅ Valid phone' : '❌ Invalid phone'}
              </p>
            )}
          </div>

          {/* Password Validation */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Password Test
            </label>
            <input
              type="password"
              value={validationTests.password}
              onChange={(e) => setValidationTests({...validationTests, password: e.target.value})}
              placeholder="Password123!"
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
            {testResults.validation?.password && (
              <div className="text-sm mt-1 space-y-1">
                <p className={testResults.validation.password.length ? 'text-green-600' : 'text-red-600'}>
                  {testResults.validation.password.length ? '✅' : '❌'} At least 8 characters
                </p>
                <p className={testResults.validation.password.hasUpperCase ? 'text-green-600' : 'text-red-600'}>
                  {testResults.validation.password.hasUpperCase ? '✅' : '❌'} Uppercase letter
                </p>
                <p className={testResults.validation.password.hasLowerCase ? 'text-green-600' : 'text-red-600'}>
                  {testResults.validation.password.hasLowerCase ? '✅' : '❌'} Lowercase letter
                </p>
                <p className={testResults.validation.password.hasNumber ? 'text-green-600' : 'text-red-600'}>
                  {testResults.validation.password.hasNumber ? '✅' : '❌'} Number
                </p>
              </div>
            )}
          </div>

          {/* Job Title Validation */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Job Title Test
            </label>
            <input
              type="text"
              value={validationTests.jobTitle}
              onChange={(e) => setValidationTests({...validationTests, jobTitle: e.target.value})}
              placeholder="Elektrik tesisatı"
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
          </div>
        </div>

        <button
          onClick={runValidationTests}
          className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          Run Validation Tests
        </button>
      </div>
    </div>
  );

  const renderApiTab = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          API Endpoint Tests
        </h3>
        
        <button
          onClick={runApiTests}
          disabled={isRunning}
          className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50"
        >
          {isRunning ? 'Running Tests...' : 'Run API Tests'}
        </button>

        {apiResults.length > 0 && (
          <div className="mt-6 space-y-3">
            {apiResults.map((result, index) => (
              <div key={index} className="p-4 border border-gray-200 dark:border-gray-700 rounded-lg">
                <div className="flex items-center justify-between">
                  <span className="font-medium text-gray-900 dark:text-white">
                    {result.endpoint}
                  </span>
                  <span className={`px-2 py-1 rounded text-sm ${
                    result.status === 'success' 
                      ? 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200'
                      : 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200'
                  }`}>
                    {result.status === 'success' ? '✅ Success' : '❌ Error'}
                  </span>
                </div>
                {result.responseTime && (
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                    Response time: {result.responseTime}ms
                  </p>
                )}
                {result.error && (
                  <p className="text-sm text-red-600 dark:text-red-400 mt-1">
                    Error: {result.error}
                  </p>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );

  const renderPerformanceTab = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Performance Tests
        </h3>
        
        <button
          onClick={runPerformanceTests}
          className="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
        >
          Run Performance Tests
        </button>

        {performanceResults && (
          <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="p-4 border border-gray-200 dark:border-gray-700 rounded-lg">
              <h4 className="font-medium text-gray-900 dark:text-white mb-2">
                Computation Performance
              </h4>
              <div className="space-y-1 text-sm text-gray-600 dark:text-gray-400">
                <p>Total time: {performanceResults.computation.totalTime}ms</p>
                <p>Average time: {performanceResults.computation.averageTime}ms</p>
                <p>Iterations: {performanceResults.computation.iterations}</p>
              </div>
            </div>
            
            {performanceResults.memory && (
              <div className="p-4 border border-gray-200 dark:border-gray-700 rounded-lg">
                <h4 className="font-medium text-gray-900 dark:text-white mb-2">
                  Memory Usage
                </h4>
                <div className="space-y-1 text-sm text-gray-600 dark:text-gray-400">
                  <p>Used: {(performanceResults.memory.usedJSHeapSize / 1024 / 1024).toFixed(2)} MB</p>
                  <p>Total: {(performanceResults.memory.totalJSHeapSize / 1024 / 1024).toFixed(2)} MB</p>
                  <p>Usage: {performanceResults.memory.usage}%</p>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );

  const renderAccessibilityTab = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Accessibility Tests
        </h3>
        
        <button
          onClick={runAccessibilityTests}
          className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors"
        >
          Run Accessibility Tests
        </button>

        {accessibilityResults && (
          <div className="mt-6">
            <div className={`p-4 border rounded-lg ${
              accessibilityResults.isAccessible 
                ? 'border-green-200 dark:border-green-800 bg-green-50 dark:bg-green-900/20'
                : 'border-red-200 dark:border-red-800 bg-red-50 dark:bg-red-900/20'
            }`}>
              <h4 className={`font-medium mb-2 ${
                accessibilityResults.isAccessible 
                  ? 'text-green-800 dark:text-green-200'
                  : 'text-red-800 dark:text-red-200'
              }`}>
                {accessibilityResults.isAccessible ? '✅ Accessible' : '❌ Accessibility Issues Found'}
              </h4>
              
              {accessibilityResults.issues.length > 0 && (
                <ul className="space-y-1 text-sm text-red-700 dark:text-red-300">
                  {accessibilityResults.issues.map((issue, index) => (
                    <li key={index}>• {issue}</li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );

  const renderBrowserTab = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Browser Feature Detection
        </h3>
        
        {browserFeatures && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {Object.entries(browserFeatures).map(([feature, supported]) => (
              <div key={feature} className="flex items-center justify-between p-3 border border-gray-200 dark:border-gray-700 rounded-lg">
                <span className="text-gray-900 dark:text-white capitalize">
                  {feature.replace(/([A-Z])/g, ' $1').trim()}
                </span>
                <span className={`px-2 py-1 rounded text-sm ${
                  supported 
                    ? 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200'
                    : 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200'
                }`}>
                  {supported ? '✅ Supported' : '❌ Not Supported'}
                </span>
              </div>
            ))}
          </div>
        )}

        <div className="mt-6">
          <h4 className="font-medium text-gray-900 dark:text-white mb-3">
            Error Simulation
          </h4>
          <div className="flex flex-wrap gap-2">
            {['generic', 'network', 'validation', 'permission', 'notFound'].map(errorType => (
              <button
                key={errorType}
                onClick={() => simulateError(errorType)}
                className="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700 transition-colors text-sm"
              >
                Simulate {errorType} Error
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );

  const renderDataTab = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Test Data Generation
        </h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {['user', 'job', 'proposal', 'notification'].map(type => (
            <button
              key={type}
              onClick={() => {
                const data = generateTestData(type);
                console.log(`Generated ${type} data:`, data);
              }}
              className="p-4 border border-gray-200 dark:border-gray-700 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors text-left"
            >
              <h4 className="font-medium text-gray-900 dark:text-white capitalize">
                Generate {type} Data
              </h4>
              <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                Create mock {type} data for testing
              </p>
            </button>
          ))}
        </div>
      </div>
    </div>
  );

  const renderVisualTab = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Visual Testing
        </h3>
        
        <button
          onClick={captureScreenshot}
          className="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 transition-colors"
        >
          📸 Capture Screenshot
        </button>
        
        <div className="mt-4 p-4 border border-gray-200 dark:border-gray-700 rounded-lg">
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Screenshots will be automatically downloaded for visual regression testing.
            Note: html2canvas library is required for this feature to work.
          </p>
        </div>
      </div>
    </div>
  );

  return (
    <div ref={testContainerRef} className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="max-w-6xl mx-auto px-4 py-6">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            🧪 Testing & QA Dashboard
          </h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Comprehensive testing tools for quality assurance and debugging
          </p>
        </div>

        {/* Tabs */}
        <div className="mb-8">
          <div className="border-b border-gray-200 dark:border-gray-700">
            <nav className="-mb-px flex space-x-8 overflow-x-auto">
              {tabs.map(tab => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`py-2 px-1 border-b-2 font-medium text-sm whitespace-nowrap ${
                    activeTab === tab.id
                      ? 'border-blue-500 text-blue-600 dark:text-blue-400'
                      : 'border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300'
                  }`}
                >
                  {tab.icon} {tab.label}
                </button>
              ))}
            </nav>
          </div>
        </div>

        {/* Tab Content */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
          {activeTab === 'validation' && renderValidationTab()}
          {activeTab === 'api' && renderApiTab()}
          {activeTab === 'performance' && renderPerformanceTab()}
          {activeTab === 'accessibility' && renderAccessibilityTab()}
          {activeTab === 'browser' && renderBrowserTab()}
          {activeTab === 'data' && renderDataTab()}
          {activeTab === 'visual' && renderVisualTab()}
        </div>

        {/* System Info */}
        <div className="mt-8 bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            System Information
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
            <div>
              <p className="text-gray-600 dark:text-gray-400">User Agent:</p>
              <p className="text-gray-900 dark:text-white break-all">{navigator.userAgent}</p>
            </div>
            <div>
              <p className="text-gray-600 dark:text-gray-400">Screen Resolution:</p>
              <p className="text-gray-900 dark:text-white">{screen.width} x {screen.height}</p>
            </div>
            <div>
              <p className="text-gray-600 dark:text-gray-400">Current User:</p>
              <p className="text-gray-900 dark:text-white">
                {user ? `${user.first_name} (${user.user_type})` : 'Not logged in'}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TestingPage;