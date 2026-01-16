# Travel Booking App - Flutter UI Components

Bu Flutter projesi, gösterilen görseldeki seyahat rezervasyon uygulamasının tüm UI bileşenlerini içermektedir. Modern ve kullanıcı dostu arayüz tasarımı ile geliştirilmiştir.

## Özellikler

- **Arama Çubuğu**: Destinasyon arama özelliği
- **Alt Navigasyon**: Explore, Wishlist, Trips, Inbox, Profile sekmeli navigasyon
- **Mülk Kartları**: Otel/villa listesi kartları (resim, rating, fiyat bilgileri ile)
- **Tarih Seçici**: İnteraktif takvim ile tarih seçimi
- **Süre Seçici**: Dairesel progress indicator ile süre seçimi
- **Modal Pencereler**: Bottom sheet tarzı modal pencereler

## Kurulum

1. Flutter SDK'nın yüklü olduğundan emin olun
2. Proje dizinine gidin:
   ```bash
   cd travel_booking_app
   ```
3. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
4. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## Proje Yapısı

```
lib/
├── main.dart                          # Ana uygulama dosyası
├── screens/
│   └── travel_booking_screen.dart     # Ana ekran
└── components/
    ├── search_bar_component.dart      # Arama çubuğu bileşeni
    ├── filter_tabs_component.dart     # Alt navigasyon sekmeleri
    ├── property_card_component.dart   # Mülk kartı bileşeni
    ├── trip_date_selector.dart        # Tarih seçici bileşeni
    └── duration_selector.dart         # Süre seçici bileşeni
```

## Bileşen Detayları

### SearchBarComponent
- Destinasyon arama özelliği
- "Clear all" butonu
- Beyaz arka plan, gölge efekti

### FilterTabsComponent
- 5 sekme: Explore, Wishlist, Trips, Inbox, Profile
- Inbox sekmesinde bildirim göstergesi
- Seçili sekme pembe renkte vurgulanır

### PropertyCardComponent
- Mülk resmi (carousel göstergeleri ile)
- Rating ve yorum sayısı
- Konum, başlık, yatak bilgisi
- Mesafe ve tarih bilgileri
- Fiyat bilgileri (gecelik ve toplam)
- Favori butonu

### TripDateSelector
- Bottom sheet modal
- 3 sekme: Dates, Months, Flexible
- İnteraktif takvim
- Tarih aralığı seçimi

### DurationSelector
- Süre seçenekleri (Weekend, Week, Month)
- Ay seçici kartları
- Dairesel progress indicator (animasyonlu)
- Skip ve Next butonları

## Renk Paleti

- **Ana Renk**: #E91E63 (Pembe)
- **Arka Plan**: #F8F8F8 (Açık gri)
- **Metin**: Siyah ve gri tonları
- **Kartlar**: Beyaz arka plan

## Kullanım

1. Ana ekranda mülk kartlarını görüntüleyebilirsiniz
2. Mülk kartına tıklayarak tarih seçici modalını açabilirsiniz
3. Tarih seçtikten sonra süre seçici modalı açılır
4. Alt navigasyon ile farklı sekmeler arasında geçiş yapabilirsiniz

## Özelleştirme

Bileşenler tamamen özelleştirilebilir parametreler ile tasarlanmıştır. Her bileşenin kendi constructor parametreleri vardır ve kolayca değiştirilebilir.

## Gereksinimler

- Flutter SDK 3.0.0 veya üzeri
- Dart 3.0.0 veya üzeri

## Notlar

- Resimler için Unsplash URL'leri kullanılmıştır
- Font olarak Roboto kullanılmıştır
- Responsive tasarım için MediaQuery kullanımı önerilir
- Gerçek bir uygulamada state management (Provider, Bloc, Riverpod) kullanılması önerilir
