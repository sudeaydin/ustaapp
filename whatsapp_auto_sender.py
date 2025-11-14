#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
WhatsApp Otomatik Mesaj Gönderici
PyWhatKit kullanarak basit WhatsApp mesaj gönderimi

Kullanım:
1. pip install pywhatkit
2. Python script'ini çalıştır
3. WhatsApp Web otomatik olarak açılacak ve mesaj gönderilecek
"""

import pywhatkit as pwk
import time
from datetime import datetime, timedelta
import json
import os

class WhatsAppAutoSender:
    def __init__(self):
        self.contacts_file = "contacts.json"
        self.messages_file = "messages.json"
        self.setup_files()
    
    def setup_files(self):
        """Gerekli dosyaları oluştur"""
        # Kişiler dosyası
        if not os.path.exists(self.contacts_file):
            sample_contacts = {
                "contacts": [
                    {
                        "name": "Ahmet",
                        "phone": "+905551234567",
                        "active": True
                    },
                    {
                        "name": "Ayşe", 
                        "phone": "+905559876543",
                        "active": True
                    }
                ]
            }
            with open(self.contacts_file, 'w', encoding='utf-8') as f:
                json.dump(sample_contacts, f, ensure_ascii=False, indent=2)
        
        # Mesajlar dosyası
        if not os.path.exists(self.messages_file):
            sample_messages = {
                "messages": [
                    "Merhaba! Nasılsınız?",
                    "İyi günler! Size özel bir teklifimiz var.",
                    "Selam! Bugün nasıl geçiyor?",
                    "Merhaba! Yeni hizmetlerimizi duydunuz mu?"
                ]
            }
            with open(self.messages_file, 'w', encoding='utf-8') as f:
                json.dump(sample_messages, f, ensure_ascii=False, indent=2)
    
    def load_contacts(self):
        """Kişileri yükle"""
        try:
            with open(self.contacts_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return [contact for contact in data['contacts'] if contact.get('active', True)]
        except Exception as e:
            print(f"Kişiler yüklenirken hata: {e}")
            return []
    
    def load_messages(self):
        """Mesajları yükle"""
        try:
            with open(self.messages_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return data['messages']
        except Exception as e:
            print(f"Mesajlar yüklenirken hata: {e}")
            return ["Merhaba! Test mesajı."]
    
    def send_immediate_message(self, phone_number, message):
        """Hemen mesaj gönder"""
        try:
            print(f"Mesaj gönderiliyor: {phone_number}")
            print(f"Mesaj: {message}")
            
            # 2 dakika sonra gönder (WhatsApp Web açılması için zaman tanı)
            now = datetime.now()
            send_time = now + timedelta(minutes=2)
            
            pwk.sendwhatmsg(
                phone_number, 
                message, 
                send_time.hour, 
                send_time.minute,
                15,  # 15 saniye bekle
                True,  # Tab'ı kapat
                5  # 5 saniye bekle
            )
            
            print(f"✅ Mesaj gönderildi: {phone_number}")
            return True
            
        except Exception as e:
            print(f"❌ Mesaj gönderilemedi {phone_number}: {e}")
            return False
    
    def send_scheduled_message(self, phone_number, message, hour, minute):
        """Zamanlanmış mesaj gönder"""
        try:
            print(f"Zamanlanmış mesaj: {phone_number} - {hour}:{minute}")
            print(f"Mesaj: {message}")
            
            pwk.sendwhatmsg(
                phone_number,
                message,
                hour,
                minute,
                15,  # 15 saniye bekle
                True,  # Tab'ı kapat
                5  # 5 saniye bekle
            )
            
            print(f"✅ Zamanlanmış mesaj gönderildi: {phone_number}")
            return True
            
        except Exception as e:
            print(f"❌ Zamanlanmış mesaj gönderilemedi {phone_number}: {e}")
            return False
    
    def send_bulk_messages(self, message_index=0, delay_minutes=1):
        """Toplu mesaj gönder"""
        contacts = self.load_contacts()
        messages = self.load_messages()
        
        if not contacts:
            print("❌ Kişi bulunamadı!")
            return
        
        if not messages:
            print("❌ Mesaj bulunamadı!")
            return
        
        message = messages[message_index % len(messages)]
        
        print(f"📱 {len(contacts)} kişiye mesaj gönderiliyor...")
        print(f"📝 Mesaj: {message}")
        print(f"⏰ Kişiler arası {delay_minutes} dakika bekleme")
        
        now = datetime.now()
        
        for i, contact in enumerate(contacts):
            send_time = now + timedelta(minutes=(i * delay_minutes) + 2)
            
            print(f"\n🔄 {i+1}/{len(contacts)} - {contact['name']}")
            print(f"📞 Telefon: {contact['phone']}")
            print(f"⏰ Gönderim zamanı: {send_time.strftime('%H:%M')}")
            
            success = self.send_scheduled_message(
                contact['phone'],
                message,
                send_time.hour,
                send_time.minute
            )
            
            if success:
                print(f"✅ {contact['name']} için mesaj zamanlandı")
            else:
                print(f"❌ {contact['name']} için mesaj zamanlanamadı")
            
            # Kısa bekleme
            time.sleep(2)
    
    def send_group_message(self, group_name, message):
        """Grup mesajı gönder"""
        try:
            now = datetime.now()
            send_time = now + timedelta(minutes=2)
            
            print(f"Grup mesajı gönderiliyor: {group_name}")
            print(f"Mesaj: {message}")
            
            pwk.sendwhatmsg_to_group(
                group_name,
                message,
                send_time.hour,
                send_time.minute,
                15,  # 15 saniye bekle
                True  # Tab'ı kapat
            )
            
            print(f"✅ Grup mesajı gönderildi: {group_name}")
            return True
            
        except Exception as e:
            print(f"❌ Grup mesajı gönderilemedi {group_name}: {e}")
            return False

def main():
    """Ana fonksiyon"""
    sender = WhatsAppAutoSender()
    
    print("🚀 WhatsApp Otomatik Mesaj Gönderici")
    print("=" * 50)
    
    while True:
        print("\n📋 Seçenekler:")
        print("1. Tek mesaj gönder")
        print("2. Toplu mesaj gönder")
        print("3. Grup mesajı gönder")
        print("4. Kişileri görüntüle")
        print("5. Mesajları görüntüle")
        print("6. Çıkış")
        
        choice = input("\n🔢 Seçiminiz (1-6): ").strip()
        
        if choice == "1":
            phone = input("📞 Telefon numarası (+90XXXXXXXXXX): ").strip()
            message = input("📝 Mesaj: ").strip()
            
            if phone and message:
                sender.send_immediate_message(phone, message)
            else:
                print("❌ Telefon numarası ve mesaj gerekli!")
        
        elif choice == "2":
            messages = sender.load_messages()
            
            print("\n📝 Mevcut mesajlar:")
            for i, msg in enumerate(messages):
                print(f"{i+1}. {msg[:50]}...")
            
            try:
                msg_index = int(input("\n🔢 Mesaj numarası: ").strip()) - 1
                delay = int(input("⏰ Kişiler arası bekleme (dakika): ").strip())
                
                if 0 <= msg_index < len(messages):
                    sender.send_bulk_messages(msg_index, delay)
                else:
                    print("❌ Geçersiz mesaj numarası!")
            except ValueError:
                print("❌ Geçersiz sayı!")
        
        elif choice == "3":
            group_name = input("👥 Grup adı: ").strip()
            message = input("📝 Mesaj: ").strip()
            
            if group_name and message:
                sender.send_group_message(group_name, message)
            else:
                print("❌ Grup adı ve mesaj gerekli!")
        
        elif choice == "4":
            contacts = sender.load_contacts()
            print(f"\n👥 Toplam {len(contacts)} aktif kişi:")
            for i, contact in enumerate(contacts, 1):
                print(f"{i}. {contact['name']} - {contact['phone']}")
        
        elif choice == "5":
            messages = sender.load_messages()
            print(f"\n📝 Toplam {len(messages)} mesaj:")
            for i, message in enumerate(messages, 1):
                print(f"{i}. {message}")
        
        elif choice == "6":
            print("👋 Görüşürüz!")
            break
        
        else:
            print("❌ Geçersiz seçim!")

if __name__ == "__main__":
    main()