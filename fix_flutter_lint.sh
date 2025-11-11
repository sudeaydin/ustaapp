#!/bin/bash
# Flutter Lint Hatalarını Toplu Düzeltme Scripti

cd /workspace/ustam_mobile_app

echo "🧹 1. Kullanılmayan import'ları temizliyorum..."
# dart fix --dry-run --apply

echo "🔧 2. Otomatik düzeltmeler yapılıyor..."
dart fix --apply

echo "📝 3. Kod formatı düzenleniyor..."
dart format lib/ --fix

echo "✅ Tamamlandı! Şimdi analiz ediliyor..."
flutter analyze --no-fatal-infos
