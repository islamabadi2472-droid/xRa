# xRa – Video Downloader, Player & Vault

## Features
- 📥 Video Downloader (YouTube, Instagram, TikTok, Facebook, Twitter, Vimeo)
- ▶️ Modern Video Player (speed control, subtitle, night mode, EQ, PiP)
- 📋 Playlist Management
- 🔒 Individual Playlist PIN Lock + Biometric
- 🔐 App-level PIN Lock

## Developer Setup

### Requirements
- Flutter SDK 3.10+
- Android Studio / VS Code
- Android SDK (API 21+)

### Steps to Build APK

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Run: flutter pub get
3. Build APK: flutter build apk --release
4. APK location: build/app/outputs/flutter-apk/app-release.apk

### For Video Download Feature
Integrate yt-dlp binary for Android:
- Add yt-dlp ARM binary to assets/
- Use flutter_process or method channel to run it

## Project Structure
lib/
  main.dart              - App entry & theme
  models/models.dart     - Data models
  utils/
    database_helper.dart - SQLite database
    lock_helper.dart     - PIN & biometric auth
  screens/
    splash_screen.dart
    home_screen.dart
    downloader_screen.dart
    player_screen.dart
    playlist_screen.dart
    playlist_lock_screen.dart
    playlist_detail_screen.dart
    app_lock_screen.dart
    settings_screen.dart
