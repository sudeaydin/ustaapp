const CACHE_NAME = 'ustamapp-v1.0.0'
const STATIC_CACHE = 'ustamapp-static-v1.0.0'
const API_CACHE = 'ustamapp-api-v1.0.0'

// Files to cache for offline use
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/offline.html',
  // Add other critical assets
]

// API endpoints to cache
const API_ENDPOINTS = [
  '/api/search/categories',
  '/api/search/locations',
  '/api/quotes/budget-ranges',
  '/api/quotes/area-types'
]

// Install event - cache static assets
self.addEventListener('install', event => {
  console.log('Service Worker installing...')
  
  event.waitUntil(
    Promise.all([
      caches.open(STATIC_CACHE).then(cache => {
        return cache.addAll(STATIC_ASSETS)
      }),
      caches.open(API_CACHE).then(cache => {
        return Promise.all(
          API_ENDPOINTS.map(endpoint => {
            return fetch(endpoint)
              .then(response => cache.put(endpoint, response))
              .catch(err => console.log('Failed to cache:', endpoint))
          })
        )
      })
    ])
  )
  
  // Force activation
  self.skipWaiting()
})

// Activate event - clean old caches
self.addEventListener('activate', event => {
  console.log('Service Worker activating...')
  
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== STATIC_CACHE && 
              cacheName !== API_CACHE && 
              cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName)
            return caches.delete(cacheName)
          }
        })
      )
    })
  )
  
  // Take control of all pages
  self.clients.claim()
})

// Fetch event - serve from cache with network fallback
self.addEventListener('fetch', event => {
  const { request } = event
  const url = new URL(request.url)
  
  // Skip non-GET requests
  if (request.method !== 'GET') {
    return
  }
  
  // Handle API requests
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(handleApiRequest(request))
    return
  }
  
  // Handle static assets
  event.respondWith(handleStaticRequest(request))
})

// Handle API requests with cache-first strategy for specific endpoints
async function handleApiRequest(request) {
  const url = new URL(request.url)
  
  // Cache-first for static data
  if (API_ENDPOINTS.some(endpoint => url.pathname.includes(endpoint))) {
    try {
      const cachedResponse = await caches.match(request)
      if (cachedResponse) {
        // Serve from cache and update in background
        updateCacheInBackground(request)
        return cachedResponse
      }
    } catch (err) {
      console.log('Cache error:', err)
    }
  }
  
  // Network-first for dynamic data
  try {
    const networkResponse = await fetch(request)
    
    if (networkResponse.ok) {
      // Cache successful responses
      const cache = await caches.open(API_CACHE)
      cache.put(request, networkResponse.clone())
    }
    
    return networkResponse
  } catch (err) {
    console.log('Network error:', err)
    
    // Fallback to cache
    const cachedResponse = await caches.match(request)
    if (cachedResponse) {
      return cachedResponse
    }
    
    // Return offline response
    return new Response(JSON.stringify({
      success: false,
      error: true,
      message: 'İnternet bağlantınızı kontrol edin',
      code: 'OFFLINE'
    }), {
      status: 503,
      headers: { 'Content-Type': 'application/json' }
    })
  }
}

// Handle static requests with cache-first strategy
async function handleStaticRequest(request) {
  try {
    // Try cache first
    const cachedResponse = await caches.match(request)
    if (cachedResponse) {
      return cachedResponse
    }
    
    // Fallback to network
    const networkResponse = await fetch(request)
    
    if (networkResponse.ok) {
      // Cache the response
      const cache = await caches.open(STATIC_CACHE)
      cache.put(request, networkResponse.clone())
    }
    
    return networkResponse
  } catch (err) {
    console.log('Static request error:', err)
    
    // Serve offline page for navigation requests
    if (request.mode === 'navigate') {
      const offlineResponse = await caches.match('/offline.html')
      if (offlineResponse) {
        return offlineResponse
      }
    }
    
    throw err
  }
}

// Update cache in background
async function updateCacheInBackground(request) {
  try {
    const networkResponse = await fetch(request)
    if (networkResponse.ok) {
      const cache = await caches.open(API_CACHE)
      cache.put(request, networkResponse)
    }
  } catch (err) {
    console.log('Background update failed:', err)
  }
}

// Handle background sync
self.addEventListener('sync', event => {
  console.log('Background sync:', event.tag)
  
  if (event.tag === 'quote-request') {
    event.waitUntil(syncQuoteRequests())
  }
  
  if (event.tag === 'message-send') {
    event.waitUntil(syncMessages())
  }
})

// Sync quote requests when back online
async function syncQuoteRequests() {
  try {
    // Get pending quote requests from IndexedDB
    const pendingRequests = await getPendingQuoteRequests()
    
    for (const request of pendingRequests) {
      try {
        await fetch('/api/quotes/create-request', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': request.auth
          },
          body: JSON.stringify(request.data)
        })
        
        // Remove from pending after successful sync
        await removePendingQuoteRequest(request.id)
      } catch (err) {
        console.log('Failed to sync quote request:', err)
      }
    }
  } catch (err) {
    console.log('Sync error:', err)
  }
}

// Sync messages when back online
async function syncMessages() {
  try {
    const pendingMessages = await getPendingMessages()
    
    for (const message of pendingMessages) {
      try {
        await fetch('/api/messages', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': message.auth
          },
          body: JSON.stringify(message.data)
        })
        
        await removePendingMessage(message.id)
      } catch (err) {
        console.log('Failed to sync message:', err)
      }
    }
  } catch (err) {
    console.log('Message sync error:', err)
  }
}

// IndexedDB helpers (simplified)
async function getPendingQuoteRequests() {
  // Implementation would use IndexedDB
  return []
}

async function removePendingQuoteRequest(id) {
  // Implementation would use IndexedDB
}

async function getPendingMessages() {
  // Implementation would use IndexedDB
  return []
}

async function removePendingMessage(id) {
  // Implementation would use IndexedDB
}

// Push notification handler
self.addEventListener('push', event => {
  console.log('Push notification received')
  
  if (!event.data) {
    return
  }
  
  const data = event.data.json()
  
  const options = {
    body: data.body,
    icon: '/icons/icon-192x192.png',
    badge: '/icons/badge-72x72.png',
    data: data.data,
    actions: data.actions || [],
    tag: data.tag,
    renotify: true,
    requireInteraction: data.requireInteraction || false
  }
  
  event.waitUntil(
    self.registration.showNotification(data.title, options)
  )
})

// Notification click handler
self.addEventListener('notificationclick', event => {
  console.log('Notification clicked:', event.notification.data)
  
  event.notification.close()
  
  const data = event.notification.data
  
  event.waitUntil(
    clients.openWindow(data.url || '/')
  )
})