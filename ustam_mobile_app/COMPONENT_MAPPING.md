# iOS + Airbnb Component Mapping Guide

Bu dokümanda mevcut component'ların yeni iOS + Airbnb tasarım sistemine nasıl dönüştürüldüğü açıklanmaktadır.

## 🎨 Design System Overview

### Renk Paleti
- **Primary**: `#FF5A5F` (Airbnb Coral)
- **Accent**: `#00A699` (Teal)
- **Text Primary**: `#111827` (iOS Label Primary)
- **Text Secondary**: `#4B5563` (iOS Label Secondary)
- **Success**: `#34C759` (iOS Green)
- **Warning**: `#FFCC00` (iOS Yellow)
- **Error**: `#FF3B30` (iOS Red)

### Tipografi
- **Font Family**: SF Pro Text/Display (iOS System Font)
- **Scale**: iOS Typography Scale (34/28/22/20/17/16/15/13/12/11 pt)
- **Weights**: Regular (400), Medium (500), Semibold (600), Bold (700)

### Spacing
- **Base Unit**: 4pt Grid System
- **Scale**: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64pt
- **Screen Edges**: 16pt
- **Card Padding**: 16pt

### Border Radius
- **Cards**: 16pt
- **Buttons**: 12pt
- **Inputs**: 12pt
- **Small Elements**: 8pt

## 📱 Component Mappings

### 1. Buttons

#### Primary Button (CTA)
**Eski → Yeni**
```dart
// ESKI
ElevatedButton(
  style: AppColors.getPrimaryButtonStyle(),
  child: Text('Button'),
)

// YENİ
ElevatedButton(
  // Otomatik olarak theme'den alır
  child: Text('Button'),
)
```

**Özellikler:**
- Height: 44pt (iOS Standard)
- Border Radius: 12pt
- Background: Coral (#FF5A5F)
- Text: White, Semibold, 16pt
- Shadow: Coral 30% opacity

#### Secondary Button
**Eski → Yeni**
```dart
// ESKI
OutlinedButton(
  style: ButtonStyle(/* custom style */),
  child: Text('Button'),
)

// YENİ
OutlinedButton(
  // Otomatik olarak theme'den alır
  child: Text('Button'),
)
```

**Özellikler:**
- Height: 44pt
- Border: Coral 1.5pt
- Text: Coral, Semibold, 16pt
- Background: Transparent

#### Tertiary Button
**Eski → Yeni**
```dart
// ESKI
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: AppColors.primary,
  ),
  child: Text('Button'),
)

// YENİ
TextButton(
  // Otomatik olarak theme'den alır
  child: Text('Button'),
)
```

**Özellikler:**
- Height: 44pt
- Text: Coral, Semibold, 16pt
- No underline
- Opacity states for interaction

### 2. Cards

#### Standard Card
**Eski → Yeni**
```dart
// ESKI
Container(
  decoration: BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: AppSpacing.cardShadow,
  ),
  child: content,
)

// YENİ
Card(
  // Otomatik olarak theme'den alır
  child: content,
)
```

**Özellikler:**
- Border Radius: 16pt
- Background: White
- Shadow: Soft, 8% opacity, 12pt blur
- Padding: 16pt
- Margin: 8pt

#### Elevated Card
**Eski → Yeni**
```dart
// ESKI
Container(
  decoration: BoxDecoration(
    boxShadow: AppSpacing.elevatedShadow,
  ),
  child: content,
)

// YENİ
Card(
  elevation: 4,
  child: content,
)
```

### 3. Text Styles

#### Headings
**Eski → Yeni**
```dart
// ESKI
Text(
  'Heading',
  style: AppTypography.headlineLarge,
)

// YENİ
Text(
  'Heading',
  style: Theme.of(context).textTheme.headlineLarge,
)
```

**Mapping:**
- `displayLarge`: 34pt, Bold (iOS Large Title)
- `displayMedium`: 28pt, Semibold (iOS Title 1)
- `displaySmall`: 22pt, Semibold (iOS Title 2)
- `headlineLarge`: 22pt, Semibold
- `headlineMedium`: 20pt, Semibold (iOS Title 3)
- `headlineSmall`: 17pt, Semibold
- `titleLarge`: 17pt, Semibold (iOS Body)
- `titleMedium`: 16pt, Medium (iOS Callout)
- `titleSmall`: 15pt, Medium (iOS Subhead)
- `bodyLarge`: 17pt, Regular
- `bodyMedium`: 15pt, Regular
- `bodySmall`: 13pt, Regular (iOS Footnote)
- `labelLarge`: 16pt, Semibold
- `labelMedium`: 13pt, Medium
- `labelSmall`: 11pt, Medium (iOS Caption)

### 4. Input Fields

#### Text Field
**Eski → Yeni**
```dart
// ESKI
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: AppColors.cardBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)

// YENİ
TextField(
  decoration: InputDecoration(
    // Otomatik olarak theme'den alır
    labelText: 'Label',
  ),
)
```

**Özellikler:**
- Height: 44pt (iOS Standard)
- Border Radius: 12pt
- Fill Color: Light Gray (#FAFAFA)
- Border: Gray (#D1D5DB) 1pt
- Focus Border: Coral 2pt
- Padding: 16pt horizontal, 12pt vertical

#### Search Bar
**Eski → Yeni**
```dart
// ESKI
Container(
  decoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(20),
  ),
  child: TextField(/* ... */),
)

// YENİ
TextField(
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.search),
    hintText: 'Search...',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(999), // Pill shape
    ),
  ),
)
```

**Özellikler:**
- Pill shape (999pt radius)
- Left icon: Search
- Right icon: Clear (when text exists)
- Padding: 12-14pt internal

### 5. Navigation

#### App Bar (iOS Large Title)
**Eski → Yeni**
```dart
// ESKI
AppBar(
  title: Text('Title'),
  backgroundColor: AppColors.background,
)

// YENİ
AppBar(
  title: Text('Title'),
  // Otomatik olarak theme'den alır
)
```

**Özellikler:**
- Background: White
- Title: 22pt, Semibold, Dark Gray
- Icons: 24pt
- Actions: Coral color
- Elevation: 0 (flat)
- Scrolled Under Elevation: 1

#### Bottom Navigation Bar (iOS Tab Bar)
**Eski → Yeni**
```dart
// ESKI
BottomNavigationBar(
  selectedItemColor: AppColors.primary,
  unselectedItemColor: Colors.grey,
)

// YENİ
BottomNavigationBar(
  // Otomatik olarak theme'den alır
  items: [...],
)
```

**Özellikler:**
- Background: White
- Selected: Coral
- Unselected: Gray (#4B5563)
- Labels: 11pt
- Max 5 tabs
- Fixed type

### 6. List Items

#### List Tile
**Eski → Yeni**
```dart
// ESKI
ListTile(
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  title: Text('Title'),
  subtitle: Text('Subtitle'),
)

// YENİ
ListTile(
  title: Text('Title'),
  subtitle: Text('Subtitle'),
  // Otomatik olarak theme'den alır
)
```

**Özellikler:**
- Height: 56-64pt
- Padding: 16pt horizontal, 8pt vertical
- Title: 17pt, Regular
- Subtitle: 15pt, Regular, Secondary color
- Leading: Icon/Avatar
- Trailing: Chevron right

### 7. Feedback Components

#### Snack Bar
**Eski → Yeni**
```dart
// ESKI
SnackBar(
  content: Text('Message'),
  backgroundColor: Colors.black87,
)

// YENİ
SnackBar(
  content: Text('Message'),
  // Otomatik olarak theme'den alır
)
```

**Özellikler:**
- Background: Dark Gray (#111827)
- Text: White, 15pt
- Shape: Rounded 12pt
- Behavior: Floating
- Margin: 16pt all sides
- Action Color: Coral

#### Dialog/Modal
**Eski → Yeni**
```dart
// ESKI
AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
)

// YENİ
AlertDialog(
  // iOS style automatic
)
```

**Özellikler:**
- Border Radius: 16pt
- Background: White
- Shadow: Heavy (16% opacity)
- iOS-style button layout

### 8. Form Elements

#### Switch (iOS Style)
**Eski → Yeni**
```dart
// ESKI
Switch(
  activeColor: AppColors.primary,
  value: value,
  onChanged: onChanged,
)

// YENİ
Switch(
  value: value,
  onChanged: onChanged,
  // Otomatik olarak theme'den alır
)
```

**Özellikler:**
- Active Track: Coral
- Active Thumb: White
- Inactive Track: Gray (#D1D5DB)
- Inactive Thumb: Gray (#D1D5DB)

#### Checkbox
**Eski → Yeni**
```dart
// ESKI
Checkbox(
  activeColor: AppColors.primary,
  value: value,
  onChanged: onChanged,
)

// YENİ
Checkbox(
  value: value,
  onChanged: onChanged,
  // Otomatik olarak theme'den alır
)
```

### 9. Badges & Chips

#### Chip
**Eski → Yeni**
```dart
// ESKI
Chip(
  backgroundColor: AppColors.primaryLight,
  label: Text('Chip'),
)

// YENİ
Chip(
  label: Text('Chip'),
  // Otomatik olarak theme'den alır
)
```

**Özellikler:**
- Height: 20-28pt
- Border Radius: Pill (999pt)
- Padding: 8pt horizontal
- Background: Light coral
- Text: Dark, 13pt, Medium

### 10. Loading States

#### Progress Indicator
**Eski → Yeni**
```dart
// ESKI
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
)

// YENİ
CircularProgressIndicator(
  // Otomatik olarak theme'den alır
)
```

**Özellikler:**
- Color: Coral
- iOS-style animation
- Size: 24pt standard

## 🎯 Migration Checklist

### Phase 1: Core Theme
- [x] Design tokens oluşturuldu
- [x] iOS theme sistemi oluşturuldu
- [ ] Main app'e entegre edildi
- [ ] Light/Dark mode test edildi

### Phase 2: Components
- [ ] Button styles güncellendi
- [ ] Card styles güncellendi
- [ ] Text styles güncellendi
- [ ] Input styles güncellendi
- [ ] Navigation styles güncellendi

### Phase 3: Screens
- [ ] Welcome/Auth screens
- [ ] Dashboard screens
- [ ] Search screens
- [ ] Profile screens
- [ ] Calendar screens

### Phase 4: Accessibility
- [ ] Contrast ratios kontrol edildi (AA: ≥4.5:1)
- [ ] Dynamic Type desteği eklendi
- [ ] VoiceOver labels güncellendi
- [ ] RTL desteği test edildi

### Phase 5: Testing
- [ ] Light/Dark mode geçişleri
- [ ] iPhone farklı boyutlarda test
- [ ] Accessibility audit
- [ ] Performance test

## 🚀 Usage Examples

### Theme Kullanımı
```dart
// Main app'de
MaterialApp(
  theme: iOSTheme.lightTheme,
  darkTheme: iOSTheme.darkTheme,
  home: MyApp(),
)

// Component'lerde
Container(
  decoration: BoxDecoration(
    boxShadow: Theme.of(context).iOSExtension.cardShadow,
  ),
)

// Renk kullanımı
Container(
  color: DesignTokens.primaryCoral,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.titleLarge,
  ),
)
```

### Responsive Design
```dart
// Spacing kullanımı
Padding(
  padding: DesignTokens.getEdgeInsets(all: DesignTokens.space16),
  child: child,
)

// Adaptive colors
Container(
  color: DesignTokens.getAdaptiveColor(
    DesignTokens.surfacePrimary,
    DesignTokens.darkSurfacePrimary,
    Theme.of(context).brightness,
  ),
)
```

## 📝 Notes

1. **Backward Compatibility**: Eski `AppColors` ve `AppSpacing` sınıfları geçici süre korunacak
2. **Migration Strategy**: Gradual migration, screen by screen
3. **Testing**: Her screen migration sonrası visual regression test
4. **Documentation**: Component kullanım örnekleri sürekli güncellenecek

Bu guide, iOS + Airbnb tasarım sistemine geçiş sürecinde referans olarak kullanılacaktır.