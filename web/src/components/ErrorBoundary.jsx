import React from 'react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { 
      hasError: false, 
      error: null, 
      errorInfo: null,
      errorId: null
    };
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI
    return { 
      hasError: true,
      errorId: Date.now().toString()
    };
  }

  componentDidCatch(error, errorInfo) {
    // Log error details
    console.error('ErrorBoundary caught an error:', error, errorInfo);
    
    this.setState({
      error: error,
      errorInfo: errorInfo
    });

    // Report error to monitoring service (if available)
    this.reportError(error, errorInfo);
  }

  reportError = (error, errorInfo) => {
    // In a real application, you would send this to your error reporting service
    const errorReport = {
      message: error.message,
      stack: error.stack,
      componentStack: errorInfo.componentStack,
      timestamp: new Date().toISOString(),
      userAgent: navigator.userAgent,
      url: window.location.href,
      userId: this.props.userId || 'anonymous'
    };

    // Example: Send to error reporting service
    // errorReportingService.report(errorReport);
    
    // For now, just log to console
    console.log('Error Report:', errorReport);
  };

  handleRetry = () => {
    this.setState({ 
      hasError: false, 
      error: null, 
      errorInfo: null,
      errorId: null
    });
  };

  handleReload = () => {
    window.location.reload();
  };

  render() {
    if (this.state.hasError) {
      const { error, errorInfo, errorId } = this.state;
      const isDevelopment = process.env.NODE_ENV === 'development';

      return (
        <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center px-4">
          <div className="max-w-2xl w-full">
            <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8 border border-gray-200 dark:border-gray-700">
              {/* Error Icon */}
              <div className="flex justify-center mb-6">
                <div className="w-16 h-16 bg-red-100 dark:bg-red-900/20 rounded-full flex items-center justify-center">
                  <svg className="w-8 h-8 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.464 0L4.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                  </svg>
                </div>
              </div>

              {/* Error Title */}
              <div className="text-center mb-6">
                <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
                  Oops! Bir Hata Oluştu
                </h1>
                <p className="text-gray-600 dark:text-gray-400">
                  Beklenmeyen bir hata meydana geldi. Lütfen sayfayı yenilemeyi deneyin.
                </p>
              </div>

              {/* Error Details (Development Only) */}
              {isDevelopment && error && (
                <div className="mb-6 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
                  <h3 className="text-sm font-medium text-red-800 dark:text-red-200 mb-2">
                    Geliştirici Bilgileri:
                  </h3>
                  <div className="text-xs text-red-700 dark:text-red-300 space-y-2">
                    <div>
                      <strong>Hata:</strong> {error.message}
                    </div>
                    {error.stack && (
                      <div>
                        <strong>Stack Trace:</strong>
                        <pre className="mt-1 whitespace-pre-wrap break-all">
                          {error.stack}
                        </pre>
                      </div>
                    )}
                    {errorInfo && errorInfo.componentStack && (
                      <div>
                        <strong>Component Stack:</strong>
                        <pre className="mt-1 whitespace-pre-wrap">
                          {errorInfo.componentStack}
                        </pre>
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* Error ID */}
              <div className="mb-6 p-3 bg-gray-100 dark:bg-gray-700 rounded-lg">
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  <strong>Hata ID:</strong> {errorId}
                </p>
                <p className="text-xs text-gray-500 dark:text-gray-500 mt-1">
                  Bu ID'yi destek ekibiyle paylaşabilirsiniz.
                </p>
              </div>

              {/* Action Buttons */}
              <div className="flex flex-col sm:flex-row gap-3 justify-center">
                <button
                  onClick={this.handleRetry}
                  className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
                >
                  🔄 Tekrar Dene
                </button>
                <button
                  onClick={this.handleReload}
                  className="px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors font-medium"
                >
                  🔃 Sayfayı Yenile
                </button>
                <a
                  href="/"
                  className="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium text-center"
                >
                  🏠 Ana Sayfaya Dön
                </a>
              </div>

              {/* Help Text */}
              <div className="mt-8 text-center">
                <p className="text-sm text-gray-500 dark:text-gray-400">
                  Sorun devam ederse, lütfen{' '}
                  <a 
                    href="mailto:destek@ustam.com" 
                    className="text-blue-600 dark:text-blue-400 hover:underline"
                  >
                    destek@ustam.com
                  </a>
                  {' '}adresinden bizimle iletişime geçin.
                </p>
              </div>
            </div>

            {/* Additional Actions */}
            <div className="mt-6 text-center">
              <details className="text-sm">
                <summary className="cursor-pointer text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200">
                  Teknik Detaylar
                </summary>
                <div className="mt-3 p-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 text-left">
                  <div className="space-y-2 text-xs text-gray-600 dark:text-gray-400">
                    <div><strong>Zaman:</strong> {new Date().toLocaleString('tr-TR')}</div>
                    <div><strong>URL:</strong> {window.location.href}</div>
                    <div><strong>User Agent:</strong> {navigator.userAgent}</div>
                    <div><strong>Ekran Çözünürlüğü:</strong> {screen.width}x{screen.height}</div>
                  </div>
                </div>
              </details>
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;