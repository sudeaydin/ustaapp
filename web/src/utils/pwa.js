// PWA Installation and Offline utilities

class PWAManager {
  constructor() {
    this.deferredPrompt = null
    this.isInstalled = false
    this.isOnline = navigator.onLine
    
    this.init()
  }
  
  init() {
    // Register service worker
    this.registerServiceWorker()
    
    // Listen for install prompt
    this.setupInstallPrompt()
    
    // Listen for online/offline events
    this.setupConnectivityListener()
    
    // Check if already installed
    this.checkInstallStatus()
  }
  
  async registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      try {
        const registration = await navigator.serviceWorker.register('/sw.js')
        console.log('Service Worker registered:', registration)
        
        // Listen for updates
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing
          newWorker.addEventListener('statechange', () => {
            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
              // New version available
              this.showUpdateAvailable()
            }
          })
        })
        
        return registration
      } catch (error) {
        console.error('Service Worker registration failed:', error)
      }
    }
  }
  
  setupInstallPrompt() {
    window.addEventListener('beforeinstallprompt', (event) => {
      event.preventDefault()
      this.deferredPrompt = event
      this.showInstallButton()
    })
    
    window.addEventListener('appinstalled', () => {
      this.isInstalled = true
      this.hideInstallButton()
      this.showInstallSuccess()
    })
  }
  
  setupConnectivityListener() {
    window.addEventListener('online', () => {
      this.isOnline = true
      this.hideOfflineNotification()
      this.syncPendingData()
    })
    
    window.addEventListener('offline', () => {
      this.isOnline = false
      this.showOfflineNotification()
    })
  }
  
  checkInstallStatus() {
    // Check if running as installed app
    if (window.matchMedia && window.matchMedia('(display-mode: standalone)').matches) {
      this.isInstalled = true
    }
    
    // Check if iOS Safari added to home screen
    if (window.navigator.standalone === true) {
      this.isInstalled = true
    }
  }
  
  async installApp() {
    if (!this.deferredPrompt) {
      this.showInstallInstructions()
      return false
    }
    
    try {
      this.deferredPrompt.prompt()
      const result = await this.deferredPrompt.userChoice
      
      if (result.outcome === 'accepted') {
        console.log('User accepted the install prompt')
        this.isInstalled = true
      } else {
        console.log('User dismissed the install prompt')
      }
      
      this.deferredPrompt = null
      return result.outcome === 'accepted'
    } catch (error) {
      console.error('Install prompt error:', error)
      return false
    }
  }
  
  showInstallButton() {
    // Create install button if not exists
    if (!document.getElementById('pwa-install-btn')) {
      const button = document.createElement('button')
      button.id = 'pwa-install-btn'
      button.innerHTML = '📱 Uygulamayı Yükle'
      button.className = 'fixed bottom-4 right-4 bg-blue-600 text-white px-4 py-2 rounded-lg shadow-lg z-50'
      button.onclick = () => this.installApp()
      
      document.body.appendChild(button)
    }
  }
  
  hideInstallButton() {
    const button = document.getElementById('pwa-install-btn')
    if (button) {
      button.remove()
    }
  }
  
  showInstallInstructions() {
    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent)
    const isAndroid = /Android/.test(navigator.userAgent)
    
    let instructions = ''
    
    if (isIOS) {
      instructions = 'Safari\'de paylaş butonuna tıklayıp "Ana Ekrana Ekle" seçeneğini kullanın.'
    } else if (isAndroid) {
      instructions = 'Chrome menüsünden "Ana ekrana ekle" seçeneğini kullanın.'
    } else {
      instructions = 'Tarayıcınızın adres çubuğundaki yükleme simgesine tıklayın.'
    }
    
    alert(`📱 UstamApp\'i yüklemek için:\n\n${instructions}`)
  }
  
  showInstallSuccess() {
    this.showNotification('✅ UstamApp başarıyla yüklendi!', 'success')
  }
  
  showUpdateAvailable() {
    const updateBanner = document.createElement('div')
    updateBanner.id = 'update-banner'
    updateBanner.innerHTML = `
      <div class="bg-blue-600 text-white p-3 text-center">
        <span>🆕 Yeni versiyon mevcut!</span>
        <button onclick="pwaManager.updateApp()" class="ml-2 bg-white text-blue-600 px-3 py-1 rounded">
          Güncelle
        </button>
        <button onclick="this.parentElement.remove()" class="ml-2 text-white">
          ✕
        </button>
      </div>
    `
    
    document.body.insertBefore(updateBanner, document.body.firstChild)
  }
  
  async updateApp() {
    const registration = await navigator.serviceWorker.getRegistration()
    if (registration && registration.waiting) {
      registration.waiting.postMessage({ type: 'SKIP_WAITING' })
      window.location.reload()
    }
  }
  
  showOfflineNotification() {
    this.showNotification('🔴 İnternet bağlantısı yok. Bazı özellikler sınırlı olabilir.', 'warning', 0)
  }
  
  hideOfflineNotification() {
    const notification = document.getElementById('offline-notification')
    if (notification) {
      notification.remove()
    }
  }
  
  showNotification(message, type = 'info', duration = 5000) {
    const notification = document.createElement('div')
    notification.id = type === 'warning' ? 'offline-notification' : 'pwa-notification'
    notification.className = `fixed top-4 left-1/2 transform -translate-x-1/2 z-50 px-4 py-2 rounded-lg shadow-lg ${
      type === 'success' ? 'bg-green-600 text-white' :
      type === 'warning' ? 'bg-orange-600 text-white' :
      type === 'error' ? 'bg-red-600 text-white' :
      'bg-blue-600 text-white'
    }`
    notification.textContent = message
    
    document.body.appendChild(notification)
    
    if (duration > 0) {
      setTimeout(() => {
        if (notification.parentNode) {
          notification.remove()
        }
      }, duration)
    }
  }
  
  async syncPendingData() {
    if ('serviceWorker' in navigator && 'sync' in window.ServiceWorkerRegistration.prototype) {
      try {
        const registration = await navigator.serviceWorker.ready
        await registration.sync.register('quote-request')
        await registration.sync.register('message-send')
        console.log('Background sync registered')
      } catch (error) {
        console.error('Background sync registration failed:', error)
      }
    }
  }
  
  // Store data for offline sync
  async storePendingQuoteRequest(quoteData, authToken) {
    const pendingData = {
      id: Date.now(),
      type: 'quote-request',
      data: quoteData,
      auth: `Bearer ${authToken}`,
      timestamp: new Date().toISOString()
    }
    
    // Store in IndexedDB (simplified for now)
    localStorage.setItem(`pending-quote-${pendingData.id}`, JSON.stringify(pendingData))
    
    // Register background sync
    this.syncPendingData()
  }
  
  async storePendingMessage(messageData, authToken) {
    const pendingData = {
      id: Date.now(),
      type: 'message',
      data: messageData,
      auth: `Bearer ${authToken}`,
      timestamp: new Date().toISOString()
    }
    
    localStorage.setItem(`pending-message-${pendingData.id}`, JSON.stringify(pendingData))
    this.syncPendingData()
  }
  
  // Get app info
  getAppInfo() {
    return {
      isInstalled: this.isInstalled,
      isOnline: this.isOnline,
      canInstall: !!this.deferredPrompt,
      hasServiceWorker: 'serviceWorker' in navigator,
      hasNotifications: 'Notification' in window,
      hasPushManager: 'PushManager' in window
    }
  }
}

// Initialize PWA Manager
const pwaManager = new PWAManager()

// Export for use in components
export default pwaManager

// Utility functions for React components
export const usePWA = () => {
  const [appInfo, setAppInfo] = useState(pwaManager.getAppInfo())
  
  useEffect(() => {
    const updateAppInfo = () => {
      setAppInfo(pwaManager.getAppInfo())
    }
    
    window.addEventListener('online', updateAppInfo)
    window.addEventListener('offline', updateAppInfo)
    
    return () => {
      window.removeEventListener('online', updateAppInfo)
      window.removeEventListener('offline', updateAppInfo)
    }
  }, [])
  
  return {
    ...appInfo,
    installApp: () => pwaManager.installApp(),
    showInstallInstructions: () => pwaManager.showInstallInstructions()
  }
}

// Install button component data
export const InstallButton = ({ className = '' }) => {
  const { canInstall, isInstalled, installApp } = usePWA()
  
  if (isInstalled || !canInstall) {
    return null
  }
  
  return (
    <button
      onClick={installApp}
      className={`bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors ${className}`}
    >
      📱 Uygulamayı Yükle
    </button>
  )
}

// Offline indicator component
export const OfflineIndicator = () => {
  const { isOnline } = usePWA()
  
  if (isOnline) {
    return null
  }
  
  return (
    <div className="fixed top-0 left-0 right-0 bg-orange-600 text-white text-center py-2 z-50">
      🔴 Çevrimdışı - Bazı özellikler sınırlı olabilir
    </div>
  )
}