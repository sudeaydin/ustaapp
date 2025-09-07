# 📱 Mobile App Production Test Guide

## ✅ **CURRENT STATUS**
- **Backend**: https://ustaapp-analytics.uc.r.appspot.com ✅ LIVE
- **Mobile API Config**: ✅ Updated to production
- **Database**: In-memory SQLite (resets on restart)

---

## 🧪 **TEST SCENARIOS**

### **1. App Startup Test**
```bash
# Start mobile app
cd ustam_mobile_app
flutter run -d chrome --web-port=8080
```

**Expected:**
- ✅ App loads without errors
- ✅ No API connection errors
- ✅ Login/Register screens accessible

### **2. Registration Test**
**Steps:**
1. Open app → Register
2. Fill form:
   - Email: test@example.com
   - Password: 123456
   - Name: Test User
   - Phone: 5551234567
   - User Type: Customer

**Expected:**
- ✅ Registration succeeds
- ✅ JWT token received
- ✅ Redirect to dashboard

### **3. Login Test**
**Steps:**
1. Use registered credentials
2. Login

**Expected:**
- ✅ Login succeeds
- ✅ Dashboard loads
- ✅ Profile data accessible

### **4. API Endpoints Test**
**Test these endpoints via mobile app:**
- `/api/auth/register` ✅
- `/api/auth/login` ✅  
- `/api/profile/me` ✅
- `/api/craftsmen` ✅
- `/api/legal/privacy-policy` ✅

---

## 🔧 **TROUBLESHOOTING**

### **Common Issues:**

#### **1. "Network Error"**
- **Cause**: API URL wrong or backend down
- **Fix**: Check `lib/core/config/app_config.dart`
- **Verify**: https://ustaapp-analytics.uc.r.appspot.com/api/health

#### **2. "401 Unauthorized"**
- **Cause**: Database is empty (in-memory SQLite)
- **Fix**: Register new user first, then login

#### **3. "CORS Error"**
- **Cause**: CORS not configured for Flutter web
- **Fix**: Backend CORS already configured for '*'

#### **4. "SSL Certificate Error"**
- **Cause**: Development environment SSL issues
- **Fix**: Use `--ignore-certificate-errors` flag

---

## 📊 **SUCCESS METRICS**

### **✅ App Performance:**
- Startup time: <3 seconds
- API response time: <500ms
- No console errors
- Smooth navigation

### **✅ Backend Integration:**
- Registration works
- Login works  
- Profile loading works
- Legal documents accessible

### **✅ BigQuery Logging:**
- User registration logged
- Login events logged
- API calls tracked
- Error events captured

---

## 🚀 **NEXT STEPS AFTER MOBILE TEST**

### **1. Flutter Web Build**
```bash
flutter build web --release
```

### **2. Deploy Web to Google Cloud Storage**
```bash
gsutil -m cp -r build/web/* gs://ustancepte-web/
```

### **3. Final Integration Test**
- Mobile ✅
- Web ✅  
- Backend ✅
- BigQuery ✅

---

## 🎯 **PRODUCTION READINESS CHECKLIST**

- ✅ Backend deployed and running
- ✅ Mobile app configured for production
- ⏳ Mobile app functionality tested
- ⏳ Flutter web built and deployed
- ⏳ BigQuery logging verified
- ⏳ Error handling tested
- ⏳ Performance optimized

---

**🧪 Ready to test mobile app with production backend!**
**Run the Flutter app and try registration/login flow.**