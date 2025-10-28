#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
WhatsApp Web Selenium Bot
Selenium ile WhatsApp Web otomasyonu

Kurulum:
pip install selenium webdriver-manager

Kullanım:
1. Chrome tarayıcısı yüklü olmalı
2. İlk çalıştırmada WhatsApp Web'e QR kod ile giriş yapın
3. Bot otomatik olarak mesajları gönderecek
"""

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time
import json
import os
from datetime import datetime
import logging

# Logging ayarları
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('whatsapp_bot.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)

class WhatsAppSeleniumBot:
    def __init__(self, headless=False):
        self.driver = None
        self.wait = None
        self.headless = headless
        self.contacts_file = "selenium_contacts.json"
        self.messages_file = "selenium_messages.json"
        self.setup_files()
        
    def setup_files(self):
        """Gerekli dosyaları oluştur"""
        if not os.path.exists(self.contacts_file):
            sample_contacts = {
                "contacts": [
                    {
                        "name": "Test Kişi",
                        "phone": "+905551234567",
                        "active": True,
                        "last_sent": None
                    }
                ]
            }
            with open(self.contacts_file, 'w', encoding='utf-8') as f:
                json.dump(sample_contacts, f, ensure_ascii=False, indent=2)
        
        if not os.path.exists(self.messages_file):
            sample_messages = {
                "templates": [
                    {
                        "name": "Selamlama",
                        "message": "Merhaba {name}! Nasılsınız?",
                        "active": True
                    },
                    {
                        "name": "Teklif",
                        "message": "Merhaba {name}! Size özel bir teklifimiz var. Detaylar için bize ulaşın.",
                        "active": True
                    },
                    {
                        "name": "Hatırlatma",
                        "message": "Merhaba {name}! Randevunuz yaklaşıyor. Lütfen onaylayın.",
                        "active": True
                    }
                ]
            }
            with open(self.messages_file, 'w', encoding='utf-8') as f:
                json.dump(sample_messages, f, ensure_ascii=False, indent=2)
    
    def setup_driver(self):
        """Chrome driver'ı ayarla"""
        try:
            chrome_options = Options()
            
            # Kullanıcı verilerini sakla (QR kod tekrar istemez)
            user_data_dir = os.path.join(os.getcwd(), "chrome_user_data")
            chrome_options.add_argument(f"--user-data-dir={user_data_dir}")
            chrome_options.add_argument("--profile-directory=WhatsAppBot")
            
            if self.headless:
                chrome_options.add_argument("--headless")
            
            # Diğer ayarlar
            chrome_options.add_argument("--no-sandbox")
            chrome_options.add_argument("--disable-dev-shm-usage")
            chrome_options.add_argument("--disable-gpu")
            chrome_options.add_argument("--window-size=1920,1080")
            
            # WebDriver'ı başlat
            service = Service(ChromeDriverManager().install())
            self.driver = webdriver.Chrome(service=service, options=chrome_options)
            self.wait = WebDriverWait(self.driver, 30)
            
            logging.info("✅ Chrome driver başlatıldı")
            return True
            
        except Exception as e:
            logging.error(f"❌ Driver başlatılamadı: {e}")
            return False
    
    def login_whatsapp(self):
        """WhatsApp Web'e giriş yap"""
        try:
            logging.info("🔄 WhatsApp Web'e bağlanılıyor...")
            self.driver.get("https://web.whatsapp.com")
            
            # QR kod taraması veya otomatik giriş bekleme
            try:
                # Eğer QR kod varsa bekle
                qr_code = self.wait.until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, "[data-ref]"))
                )
                logging.info("📱 QR kodu tarayın...")
                
                # QR kod kaybolana kadar bekle
                self.wait.until(
                    EC.invisibility_of_element_located((By.CSS_SELECTOR, "[data-ref]"))
                )
                
            except:
                # QR kod yoksa zaten giriş yapılmış
                pass
            
            # Ana sayfa yüklenene kadar bekle
            self.wait.until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "[data-testid='chat-list']"))
            )
            
            logging.info("✅ WhatsApp Web'e giriş başarılı")
            return True
            
        except Exception as e:
            logging.error(f"❌ WhatsApp Web giriş hatası: {e}")
            return False
    
    def search_contact(self, contact_name_or_phone):
        """Kişi ara"""
        try:
            # Arama kutusunu bul ve temizle
            search_box = self.wait.until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, "[data-testid='chat-list-search']"))
            )
            search_box.clear()
            search_box.send_keys(contact_name_or_phone)
            time.sleep(2)
            
            # İlk sonuca tıkla
            first_result = self.wait.until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, "[data-testid='cell-frame-container']"))
            )
            first_result.click()
            time.sleep(2)
            
            logging.info(f"✅ Kişi bulundu: {contact_name_or_phone}")
            return True
            
        except Exception as e:
            logging.error(f"❌ Kişi bulunamadı {contact_name_or_phone}: {e}")
            return False
    
    def send_message(self, message):
        """Mesaj gönder"""
        try:
            # Mesaj kutusunu bul
            message_box = self.wait.until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, "[data-testid='conversation-compose-box-input']"))
            )
            
            # Mesajı yaz
            message_box.clear()
            message_box.send_keys(message)
            time.sleep(1)
            
            # Gönder butonuna bas
            send_button = self.driver.find_element(By.CSS_SELECTOR, "[data-testid='send']")
            send_button.click()
            time.sleep(2)
            
            logging.info(f"✅ Mesaj gönderildi: {message[:50]}...")
            return True
            
        except Exception as e:
            logging.error(f"❌ Mesaj gönderilemedi: {e}")
            return False
    
    def send_message_to_contact(self, contact_name_or_phone, message):
        """Belirli kişiye mesaj gönder"""
        try:
            if self.search_contact(contact_name_or_phone):
                return self.send_message(message)
            return False
        except Exception as e:
            logging.error(f"❌ Kişiye mesaj gönderilemedi {contact_name_or_phone}: {e}")
            return False
    
    def send_bulk_messages(self, template_name, delay_seconds=10):
        """Toplu mesaj gönder"""
        try:
            # Kişileri yükle
            with open(self.contacts_file, 'r', encoding='utf-8') as f:
                contacts_data = json.load(f)
            
            # Mesaj şablonunu yükle
            with open(self.messages_file, 'r', encoding='utf-8') as f:
                messages_data = json.load(f)
            
            # Şablonu bul
            template = None
            for tmpl in messages_data['templates']:
                if tmpl['name'] == template_name and tmpl.get('active', True):
                    template = tmpl
                    break
            
            if not template:
                logging.error(f"❌ Şablon bulunamadı: {template_name}")
                return False
            
            # Aktif kişileri filtrele
            active_contacts = [c for c in contacts_data['contacts'] if c.get('active', True)]
            
            logging.info(f"📱 {len(active_contacts)} kişiye mesaj gönderiliyor...")
            logging.info(f"📝 Şablon: {template['name']}")
            
            success_count = 0
            
            for i, contact in enumerate(active_contacts):
                try:
                    # Mesajı kişiselleştir
                    personalized_message = template['message'].format(
                        name=contact['name']
                    )
                    
                    logging.info(f"🔄 {i+1}/{len(active_contacts)} - {contact['name']}")
                    
                    # Mesaj gönder
                    if self.send_message_to_contact(contact['phone'], personalized_message):
                        success_count += 1
                        
                        # Son gönderim zamanını güncelle
                        contact['last_sent'] = datetime.now().isoformat()
                        
                        logging.info(f"✅ Başarılı: {contact['name']}")
                    else:
                        logging.error(f"❌ Başarısız: {contact['name']}")
                    
                    # Bekleme
                    if i < len(active_contacts) - 1:
                        logging.info(f"⏰ {delay_seconds} saniye bekleniyor...")
                        time.sleep(delay_seconds)
                
                except Exception as e:
                    logging.error(f"❌ Kişi işlenirken hata {contact['name']}: {e}")
            
            # Güncellenmiş kişileri kaydet
            with open(self.contacts_file, 'w', encoding='utf-8') as f:
                json.dump(contacts_data, f, ensure_ascii=False, indent=2)
            
            logging.info(f"📊 Özet: {success_count}/{len(active_contacts)} mesaj başarılı")
            return True
            
        except Exception as e:
            logging.error(f"❌ Toplu mesaj gönderimi hatası: {e}")
            return False
    
    def get_unread_messages(self):
        """Okunmamış mesajları al"""
        try:
            unread_chats = self.driver.find_elements(
                By.CSS_SELECTOR, 
                "[data-testid='cell-frame-container'] [data-testid='icon-unread-count']"
            )
            
            logging.info(f"📬 {len(unread_chats)} okunmamış sohbet bulundu")
            
            unread_messages = []
            for chat in unread_chats[:5]:  # İlk 5 sohbet
                try:
                    chat.click()
                    time.sleep(2)
                    
                    # Son mesajları al
                    messages = self.driver.find_elements(
                        By.CSS_SELECTOR,
                        "[data-testid='conversation-panel-messages'] [data-testid='msg-container']"
                    )
                    
                    if messages:
                        last_message = messages[-1]
                        message_text = last_message.find_element(
                            By.CSS_SELECTOR, 
                            "[data-testid='conversation-text-content']"
                        ).text
                        
                        unread_messages.append({
                            'text': message_text,
                            'timestamp': datetime.now().isoformat()
                        })
                
                except Exception as e:
                    logging.error(f"Mesaj okunurken hata: {e}")
            
            return unread_messages
            
        except Exception as e:
            logging.error(f"❌ Okunmamış mesajlar alınamadı: {e}")
            return []
    
    def close(self):
        """Bot'u kapat"""
        if self.driver:
            self.driver.quit()
            logging.info("👋 Bot kapatıldı")

def main():
    """Ana fonksiyon"""
    bot = WhatsAppSeleniumBot(headless=False)
    
    try:
        print("🚀 WhatsApp Selenium Bot Başlatılıyor...")
        
        if not bot.setup_driver():
            print("❌ Driver başlatılamadı!")
            return
        
        if not bot.login_whatsapp():
            print("❌ WhatsApp Web'e giriş yapılamadı!")
            return
        
        while True:
            print("\n📋 Seçenekler:")
            print("1. Tek mesaj gönder")
            print("2. Toplu mesaj gönder")
            print("3. Okunmamış mesajları kontrol et")
            print("4. Çıkış")
            
            choice = input("\n🔢 Seçiminiz (1-4): ").strip()
            
            if choice == "1":
                contact = input("📞 Kişi adı veya telefon: ").strip()
                message = input("📝 Mesaj: ").strip()
                
                if contact and message:
                    bot.send_message_to_contact(contact, message)
                else:
                    print("❌ Kişi ve mesaj gerekli!")
            
            elif choice == "2":
                print("\n📝 Mevcut şablonlar:")
                try:
                    with open(bot.messages_file, 'r', encoding='utf-8') as f:
                        messages_data = json.load(f)
                    
                    for i, template in enumerate(messages_data['templates'], 1):
                        if template.get('active', True):
                            print(f"{i}. {template['name']}: {template['message'][:50]}...")
                    
                    template_name = input("\n📝 Şablon adı: ").strip()
                    delay = int(input("⏰ Mesajlar arası bekleme (saniye): ").strip())
                    
                    bot.send_bulk_messages(template_name, delay)
                    
                except Exception as e:
                    print(f"❌ Hata: {e}")
            
            elif choice == "3":
                unread = bot.get_unread_messages()
                print(f"\n📬 {len(unread)} okunmamış mesaj:")
                for i, msg in enumerate(unread, 1):
                    print(f"{i}. {msg['text'][:100]}...")
            
            elif choice == "4":
                print("👋 Görüşürüz!")
                break
            
            else:
                print("❌ Geçersiz seçim!")
    
    except KeyboardInterrupt:
        print("\n⏹️ Bot durduruldu")
    
    finally:
        bot.close()

if __name__ == "__main__":
    main()