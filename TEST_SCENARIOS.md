# 🧪 UstamApp Test Scenarios - Yeni Özellikler

Bu dokümanda eklediğimiz tüm yeni özelliklerin test senaryolarını bulabilirsin kanka! 🚀

## 🎨 UI/UX Enhancements

### 1. Dark Mode (Karanlık Mod)
**Test Scenarios:**
- ✅ Header'da dark mode toggle butonu var mı?
- ✅ Toggle'a tıklandığında tema değişiyor mu?
- ✅ Tercihi localStorage'da saklanıyor mu?
- ✅ Sayfa yenilendiğinde ayar korunuyor mu?
- ✅ Tüm componentler dark mode'da düzgün görünüyor mu?
- ✅ Color palette doğru uygulanıyor mu? (poppy, mint-green, vs.)

**Test Steps:**
1. Web uygulamasını aç
2. Header'da moon/sun icon'unu bul
3. Toggle'a tıkla
4. Tüm renklerin değiştiğini kontrol et
5. Sayfayı yenile, ayarın korunduğunu kontrol et

### 2. Multi-Language Support (Çoklu Dil)
**Test Scenarios:**
- ✅ Header'da dil seçici var mı?
- ✅ TR/EN arasında geçiş yapılıyor mu?
- ✅ Tüm metinler çevriliyor mu?
- ✅ Dil tercihi localStorage'da saklanıyor mu?
- ✅ Browser dili otomatik algılanıyor mu?

**Test Steps:**
1. Dil seçiciyi bul (TR/EN flags)
2. English'e geç
3. Navigation menüsünün İngilizce olduğunu kontrol et
4. Sayfayı yenile, ayarın korunduğunu kontrol et
5. Tüm form label'ları, button'ları kontrol et

### 3. Onboarding Tutorial (Kullanıcı Rehberi)
**Test Scenarios:**
- ✅ İlk giriş yapan kullanıcıya tutorial gösteriliyor mu?
- ✅ Customer ve Craftsman için farklı adımlar var mı?
- ✅ Tutorial tamamlandıktan sonra bir daha gösterilmiyor mu?
- ✅ Skip butonu çalışıyor mu?
- ✅ Progress bar doğru ilerliyor mu?

**Test Steps:**
1. Yeni bir hesap oluştur
2. Login ol
3. Tutorial'ın başladığını kontrol et
4. Her adımı geç
5. Tutorial'ı tamamla
6. Çıkış yap, tekrar giriş yap - tutorial görünmemeli

### 4. Gesture Controls (Jest Kontrolleri)
**Test Scenarios:**
- ✅ Swipe left/right navigation çalışıyor mu?
- ✅ Pull-to-refresh çalışıyor mu?
- ✅ Double tap zoom çalışıyor mu?
- ✅ Long press actions çalışıyor mu?
- ✅ Pinch zoom çalışıyor mu?

**Test Steps:**
1. Mobile view'da sağa/sola swipe yap
2. Listelerde yukarı çek (pull to refresh)
3. Resimlerde double tap yap
4. Long press ile context menu'yu test et

### 5. Haptic Feedback (Titreşim)
**Test Scenarios:**
- ✅ Button click'lerde titreşim var mı?
- ✅ Success/error actions'da titreşim var mı?
- ✅ Pull-to-refresh'te titreşim var mı?
- ✅ Gesture'larda titreşim var mı?

**Test Steps:**
1. Mobile device'da test et
2. Button'lara bas, titreşimi hisset
3. Pull-to-refresh yap
4. Success/error durumlarını test et

### 6. Animation Library (Animasyon Kütüphanesi)
**Test Scenarios:**
- ✅ Page transitions smooth mu?
- ✅ Loading animations çalışıyor mu?
- ✅ Hover effects var mı?
- ✅ Card animations çalışıyor mu?
- ✅ Reduce motion ayarı respect ediliyor mu?

**Test Steps:**
1. Sayfalar arası geçiş yap
2. Loading state'leri gözlemle
3. Card'lara hover yap
4. Accessibility ayarlarını kontrol et

## 📱 Mobile Enhancements

### 7. PWA Features (Progressive Web App)
**Test Scenarios:**
- ✅ App install edilebiliyor mu?
- ✅ Offline mode çalışıyor mu?
- ✅ Push notifications çalışıyor mu?
- ✅ Background sync çalışıyor mu?
- ✅ App shortcuts çalışıyor mu?

**Test Steps:**
1. Chrome'da "Install App" seçeneğini bul
2. App'i install et
3. Offline olup çalışmasını test et
4. Push notification permission iste

### 8. Push Notifications (Anlık Bildirimler)
**Test Scenarios:**
- ✅ Notification permission isteniyor mu?
- ✅ Yeni mesaj bildirimi geliyor mu?
- ✅ Quote update bildirimi geliyor mu?
- ✅ Job status change bildirimi geliyor mu?
- ✅ Notification settings çalışıyor mu?

**Test Steps:**
1. Notification permission ver
2. Başka hesaptan mesaj gönder
3. Quote durumu değiştir
4. Job status güncelle
5. Bildirimlerin geldiğini kontrol et

## 🔒 Security & Legal

### 9. KVKK Compliance (GDPR Uyumluluğu)
**Test Scenarios:**
- ✅ User Agreement gösteriliyor mu?
- ✅ Privacy Policy erişilebiliyor mu?
- ✅ Cookie Policy var mı?
- ✅ Data export çalışıyor mu?
- ✅ Account deletion çalışıyor mu?
- ✅ Consent tracking çalışıyor mu?

**Test Steps:**
1. İlk kayıt sırasında agreement'ları kontrol et
2. Settings'den Privacy Policy'ye git
3. Data export iste
4. Account deletion test et (dikkatli!)
5. Consent history'yi kontrol et

### 10. Enhanced Authentication (Gelişmiş Kimlik Doğrulama)
**Test Scenarios:**
- ✅ JWT token refresh çalışıyor mu?
- ✅ Session timeout çalışıyor mu?
- ✅ Rate limiting çalışıyor mu?
- ✅ Security headers var mı?
- ✅ Password validation güçlü mu?

**Test Steps:**
1. Login ol, token'ın expire olmasını bekle
2. Çok fazla login denemesi yap (rate limit)
3. Zayıf şifre ile kayıt olmaya çalış
4. Network tab'da security header'ları kontrol et

## 💼 Job Management

### 11. Job Tracking (İş Takibi)
**Test Scenarios:**
- ✅ Job oluşturma çalışıyor mu?
- ✅ Status update'leri çalışıyor mu?
- ✅ Progress tracking çalışıyor mu?
- ✅ Job history görüntüleniyor mu?
- ✅ Job filtering çalışıyor mu?

**Test Steps:**
1. Yeni job oluştur
2. Status'u güncelle (pending → in_progress → completed)
3. Progress percentage'ı güncelle
4. Job history'yi kontrol et
5. Filter'ları test et (status, date, category)

### 12. Materials List (Malzeme Listesi)
**Test Scenarios:**
- ✅ Material ekleme çalışıyor mu?
- ✅ Material editing çalışıyor mu?
- ✅ Cost calculation doğru mu?
- ✅ Supplier tracking çalışıyor mu?
- ✅ Material status updates çalışıyor mu?

**Test Steps:**
1. Job'a material ekle
2. Quantity ve cost bilgilerini gir
3. Total cost'un doğru hesaplandığını kontrol et
4. Material status'u güncelle
5. Supplier bilgilerini ekle

### 13. Time Tracking (Zaman Takibi)
**Test Scenarios:**
- ✅ Time entry oluşturma çalışıyor mu?
- ✅ Start/stop timer çalışıyor mu?
- ✅ Billable hours calculation doğru mu?
- ✅ Time reports oluşturuluyor mu?
- ✅ Break time tracking çalışıyor mu?

**Test Steps:**
1. Job için time tracking başlat
2. Work, break, travel entry'leri ekle
3. Total hours'ın doğru hesaplandığını kontrol et
4. Billable vs non-billable ayrımını test et
5. Time reports'u export et

### 14. Warranty System (Garanti Sistemi)
**Test Scenarios:**
- ✅ Warranty creation çalışıyor mu?
- ✅ Warranty tracking çalışıyor mu?
- ✅ Warranty notifications çalışıyor mu?
- ✅ Warranty expiry alerts çalışıyor mu?
- ✅ Warranty claims çalışıyor mu?

**Test Steps:**
1. Completed job için warranty oluştur
2. Warranty period'u set et
3. Warranty status'u track et
4. Warranty expiry notification'ını test et
5. Warranty claim süreci test et

### 15. Emergency Service (Acil Servis)
**Test Scenarios:**
- ✅ Emergency request oluşturma çalışıyor mu?
- ✅ Emergency priority levels çalışıyor mu?
- ✅ Emergency notifications çalışıyor mu?
- ✅ Emergency response tracking çalışıyor mu?
- ✅ Emergency contact info çalışıyor mu?

**Test Steps:**
1. Emergency service request oluştur
2. High priority level seç
3. Emergency contact bilgilerini ekle
4. Craftsman'a emergency notification gittiğini kontrol et
5. Response time'ı track et

## 📊 Analytics & Reports

### 16. Craftsman Dashboard (Usta Dashboard'u)
**Test Scenarios:**
- ✅ Performance metrics gösteriliyor mu?
- ✅ Revenue tracking çalışıyor mu?
- ✅ Job completion stats doğru mu?
- ✅ Customer satisfaction scores gösteriliyor mu?
- ✅ Monthly/weekly reports çalışıyor mu?

**Test Steps:**
1. Craftsman hesabıyla login ol
2. Dashboard metrics'leri kontrol et
3. Revenue chart'ları incele
4. Job completion rate'leri kontrol et
5. Customer feedback'leri gör

### 17. Customer History (Müşteri Geçmişi)
**Test Scenarios:**
- ✅ Past jobs gösteriliyor mu?
- ✅ Spending history çalışıyor mu?
- ✅ Favorite craftsmen listesi var mı?
- ✅ Review history gösteriliyor mu?
- ✅ Repeat customer detection çalışıyor mu?

**Test Steps:**
1. Customer hesabıyla login ol
2. Past jobs listesini kontrol et
3. Total spending'i görüntüle
4. Favorite craftsmen'i kontrol et
5. Verdiğin review'ları gör

### 18. Trend Analysis (Trend Analizi)
**Test Scenarios:**
- ✅ Popular categories gösteriliyor mu?
- ✅ Seasonal trends çalışıyor mu?
- ✅ Price trends gösteriliyor mu?
- ✅ Demand forecasting çalışıyor mu?
- ✅ Market insights çalışıyor mu?

**Test Steps:**
1. Analytics dashboard'a git
2. Popular categories chart'ını kontrol et
3. Seasonal trends'i incele
4. Price trend graph'larını gör
5. Market insights'ları oku

### 19. Performance Reports (Performans Raporları)
**Test Scenarios:**
- ✅ Response time metrics çalışıyor mu?
- ✅ Completion rate reports doğru mu?
- ✅ Quality scores tracked mu?
- ✅ Customer satisfaction trends gösteriliyor mu?
- ✅ Performance comparisons çalışıyor mu?

**Test Steps:**
1. Performance reports sayfasına git
2. Response time chart'ını kontrol et
3. Completion rate trends'i incele
4. Quality score history'sini gör
5. Benchmark comparisons'ı kontrol et

### 20. Cost Calculator (Maliyet Hesaplayıcı)
**Test Scenarios:**
- ✅ Material cost calculation doğru mu?
- ✅ Labor cost calculation çalışıyor mu?
- ✅ Additional costs ekleniyor mu?
- ✅ Tax calculations doğru mu?
- ✅ Quote generation çalışıyor mu?

**Test Steps:**
1. Cost calculator'ı aç
2. Material costs ekle
3. Labor hours ve rates gir
4. Additional costs ekle
5. Final quote'un doğru hesaplandığını kontrol et

## 📱 Mobile-Specific Features

### 21. Location Sharing (Konum Paylaşımı)
**Test Scenarios:**
- ✅ Location permission isteniyor mu?
- ✅ Current location alınıyor mu?
- ✅ Location sharing çalışıyor mu?
- ✅ Real-time location updates çalışıyor mu?
- ✅ Location privacy settings var mı?

**Test Steps:**
1. Location permission ver
2. Current location'ı al
3. Craftsman ile location share et
4. Real-time updates'i kontrol et
5. Privacy settings'i test et

### 22. Calendar Integration (Takvim Entegrasyonu)
**Test Scenarios:**
- ✅ Appointment scheduling çalışıyor mu?
- ✅ Calendar sync çalışıyor mu?
- ✅ Reminder notifications çalışıyor mu?
- ✅ Availability checking çalışıyor mu?
- ✅ Recurring appointments çalışıyor mu?

**Test Steps:**
1. Appointment oluştur
2. Calendar'a sync olduğunu kontrol et
3. Reminder notification'ını bekle
4. Availability check et
5. Recurring appointment set et

## 🔄 Real-time Features

### 23. Real-time Chat (Anlık Mesajlaşma)
**Test Scenarios:**
- ✅ Mesajlar real-time geliyor mu?
- ✅ Typing indicators çalışıyor mu?
- ✅ Online status gösteriliyor mu?
- ✅ Message delivery status var mı?
- ✅ File sharing çalışıyor mu?

**Test Steps:**
1. İki farklı hesapla chat aç
2. Mesaj gönder, anlık geldiğini kontrol et
3. Typing indicator'ı test et
4. Online/offline status'u kontrol et
5. Resim/dosya gönder

### 24. Live Notifications (Canlı Bildirimler)
**Test Scenarios:**
- ✅ Quote notifications real-time mu?
- ✅ Job update notifications çalışıyor mu?
- ✅ System notifications çalışıyor mu?
- ✅ Notification badges güncelleniyor mu?
- ✅ Sound/vibration çalışıyor mu?

**Test Steps:**
1. Quote request gönder
2. Notification'ın geldiğini kontrol et
3. Job status değiştir
4. Badge count'un güncellendiğini gör
5. Sound/vibration settings'i test et

## 🔍 Search & Discovery

### 25. Advanced Search (Gelişmiş Arama)
**Test Scenarios:**
- ✅ Category filtering çalışıyor mu?
- ✅ Location filtering çalışıyor mu?
- ✅ Price range filtering çalışıyor mu?
- ✅ Rating filtering çalışıyor mu?
- ✅ Availability filtering çalışıyor mu?
- ✅ Search suggestions çalışıyor mu?

**Test Steps:**
1. Search page'e git
2. Category filter'ı seç
3. Location filter'ı seç
4. Price range set et
5. Rating filter'ı uygula
6. Search results'ı kontrol et

### 26. SEO Optimizations (SEO İyileştirmeleri)
**Test Scenarios:**
- ✅ Meta tags doğru mu?
- ✅ Structured data var mı?
- ✅ Sitemap oluşturuluyor mu?
- ✅ Page titles dynamic mu?
- ✅ Open Graph tags var mı?

**Test Steps:**
1. View page source yap
2. Meta tags'leri kontrol et
3. /sitemap.xml'e git
4. Social media'da link share et
5. SEO tools ile test et

## 🔧 Technical Features

### 27. Database Optimizations (Veritabanı İyileştirmeleri)
**Test Scenarios:**
- ✅ Query performance iyileşti mi?
- ✅ Indexing çalışıyor mu?
- ✅ Connection pooling aktif mi?
- ✅ Caching çalışıyor mu?
- ✅ Database monitoring çalışıyor mu?

**Test Steps:**
1. Large data set'ler ile test et
2. Query execution time'ları ölç
3. Concurrent user'lar ile test et
4. Cache hit/miss ratios kontrol et

### 28. CI/CD Pipeline (Sürekli Entegrasyon)
**Test Scenarios:**
- ✅ Automated tests çalışıyor mu?
- ✅ Build process başarılı mu?
- ✅ Deployment automatic mu?
- ✅ Rollback mechanism var mı?
- ✅ Health checks çalışıyor mu?

**Test Steps:**
1. Code push et
2. CI pipeline'ın çalıştığını kontrol et
3. Tests'lerin geçtiğini gör
4. Deployment'ın başarılı olduğunu kontrol et

### 29. Testing Infrastructure (Test Altyapısı)
**Test Scenarios:**
- ✅ Unit tests çalışıyor mu?
- ✅ Integration tests çalışıyor mu?
- ✅ E2E tests çalışıyor mu?
- ✅ Test coverage yeterli mi?
- ✅ Performance tests çalışıyor mu?

**Test Steps:**
1. `npm test` çalıştır
2. `flutter test` çalıştır
3. Coverage report'u kontrol et
4. E2E test suite'i çalıştır

## 📈 Business Features

### 30. Payment Integration (Ödeme Entegrasyonu)
**Test Scenarios:**
- ✅ iyzico integration çalışıyor mu?
- ✅ Payment flow smooth mu?
- ✅ Payment status tracking çalışıyor mu?
- ✅ Refund process çalışıyor mu?
- ✅ Payment history gösteriliyor mu?

**Test Steps:**
1. Quote accept et
2. Payment flow'a git
3. Test card ile ödeme yap
4. Payment status'u track et
5. Payment history'yi kontrol et

## 🎯 Test Checklist

### Günlük Test Rutini:
- [ ] Dark mode toggle test et
- [ ] Language switching test et
- [ ] Mobile responsive design kontrol et
- [ ] Real-time chat test et
- [ ] Push notifications test et
- [ ] Job creation/update test et
- [ ] Quote system test et
- [ ] Search functionality test et

### Haftalık Test Rutini:
- [ ] Performance monitoring kontrol et
- [ ] Security scans çalıştır
- [ ] Database backup'ları kontrol et
- [ ] Analytics data'yı incele
- [ ] User feedback'leri oku
- [ ] Error logs'u kontrol et

### Aylık Test Rutini:
- [ ] Full E2E test suite çalıştır
- [ ] Security audit yap
- [ ] Performance benchmarks'ı karşılaştır
- [ ] User retention metrics'leri incele
- [ ] Feature usage analytics'leri kontrol et

## 🚀 Yeni Özellik Test Rehberi

Kanka, eklediğimiz yeni özellikler şunlar:

1. **🎨 UI Enhancements**: Dark mode, multi-language, onboarding, gestures, haptics, animations
2. **📱 Mobile Features**: PWA, push notifications, location sharing, calendar integration
3. **💼 Job Management**: Job tracking, materials, time tracking, warranty, emergency service
4. **📊 Analytics**: Craftsman dashboard, customer history, trend analysis, performance reports, cost calculator
5. **🔒 Security**: KVKK compliance, enhanced auth, rate limiting, security headers
6. **🔧 Technical**: Database optimizations, CI/CD, testing infrastructure, monitoring

**Her birini yukarıdaki test scenarios'lara göre test edebilirsin!** 🧪✨

İstersen specific bir özelliği daha detaylı test edelim? 🎯