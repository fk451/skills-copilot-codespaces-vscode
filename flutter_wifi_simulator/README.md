# Flutter Wi‑Fi Simulator

Sahte (fake) verilerle Wi‑Fi tarama, listeleme ve bağlanma senaryolarını **simüle** etmek için minimal bir Flutter uygulaması.

## Özellikler

- Tarama simülasyonu (2 sn gecikme ile)
- Sinyale göre sıralı listeleme, arama filtresi
- Sadece açık ağları gösterme filtresi
- Güvenli ağlarda parola diyaloğu (en az 8 karakter kuralı)
- Rastgele başarısızlık (yaklaşık %10) ile gerçekçi bağlanma deneyimi
- Bağlan/Kes akışı ve durum geri bildirimleri (SnackBar)

## Kurulum ve Çalıştırma

> Not: Bu repo içinde Flutter SDK bulunmaz. Aşağıdaki adımlar için sisteminizde Flutter kurulu olmalıdır.

1. Flutter kurulumunu yapın: `https://docs.flutter.dev/get-started/install`
2. Proje klasörüne geçin:

```bash
cd /workspace/flutter_wifi_simulator
```

3. Eksik platform dosyalarını oluşturun (ilk kez yapmanız yeterli):

```bash
flutter create .
```

4. Bağımlılıkları indirin ve çalıştırın:

```bash
flutter pub get
flutter run -d chrome   # Web için
# veya
flutter run             # Bağlı cihaz/emülatör için
```

## Yapı

- `lib/main.dart`: Uygulamanın tamamı; sahte tarama ve bağlanma mantığı ile arayüz.
- `pubspec.yaml`: Proje tanımı.

## Uyarı

Bu uygulama gerçek Wi‑Fi arayüzlerine erişmez; tüm veriler ve işlemler simüle edilir. Gerçek cihazınızın Wi‑Fi ayarlarını etkilemez.