# Andalus Smart POS

A mobile-first Point of Sale application for Ethiopian small shops, built with Flutter.

## Features

- 📱 Mobile-first POS with large touch targets
- 📴 Offline-first with SQLite local database
- 🔄 Background sync to Laravel backend
- 💳 Telebirr payment integration
- 🖨️ Bluetooth thermal printing
- 🔔 FCM push notifications
- 🌐 Multilingual (English + Amharic)
- 🔒 Secure token storage

## Tech Stack

- **Flutter 3.x** with Material 3
- **Riverpod** for state management
- **sqflite** for local database
- **Dio** for HTTP client
- **flutter_secure_storage** for security
- **blue_thermal_printer** for receipt printing

## Development Setup

### Prerequisites

- Flutter SDK 3.0+
- Android Studio / VS Code
- Android Emulator or physical device

### Installation

1. **Create and setup the project:**
   ```bash
   flutter create andalus_smart_pos
   cd andalus_smart_pos
   ```
