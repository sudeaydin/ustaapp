#!/usr/bin/env python3
import json
import os
import time
from http.server import HTTPServer, SimpleHTTPRequestHandler
from datetime import datetime
import threading

class DashboardHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

def update_progress():
    """Auto-update progress every 60 seconds"""
    while True:
        try:
            with open('progress.json', 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Update timestamp
            data['last_update'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            
            # Simulate progress updates (you can modify this)
            current_progress = data['overall_progress']
            if current_progress < 100:
                # Small incremental progress
                data['overall_progress'] = min(100, current_progress + 1)
            
            with open('progress.json', 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                
            print(f"📊 Progress updated: {data['overall_progress']}% - {data['current_task']}")
            
        except Exception as e:
            print(f"❌ Update error: {e}")
        
        time.sleep(60)  # Update every minute

if __name__ == '__main__':
    port = 8080
    
    # Start auto-updater in background
    updater_thread = threading.Thread(target=update_progress, daemon=True)
    updater_thread.start()
    
    # Start web server
    server = HTTPServer(('localhost', port), DashboardHandler)
    
    print(f"""
🚀 Ustalar App Dashboard Başlatıldı!

📊 Dashboard URL: http://localhost:{port}/dashboard.html
📁 Progress JSON: http://localhost:{port}/progress.json

✨ Özellikler:
- ⚡ Otomatik güncelleme (30 saniyede bir)
- 📈 Real-time progress tracking
- 📱 Responsive design
- 🎨 Ustalar App teması

🔄 Dashboard her 30 saniyede otomatik güncellenir
📝 Progress JSON her dakika güncellenir

Durdurmak için: Ctrl+C
    """)
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 Dashboard kapatılıyor...")
        server.shutdown()
