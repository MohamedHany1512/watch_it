# Watch IT App

A modern, responsive Flutter application designed for streaming entertainment content, featuring a clean UI, custom Arabic typography, and smooth media navigation.

---

## 📸 Screenshots

| Screen 1 | Screen 2 | Screen 3 |
| :---: | :---: | :---: |
| <img src="assets/screenshots/Screenshot%202026-09-30%20112258.png" width="230" alt="Screen 1"> | <img src="assets/screenshots/Screenshot%202026-09-30%20112349.png" width="230" alt="Screen 2"> | <img src="assets/screenshots/Screenshot%202026-09-30%20112422.png" width="230" alt="Screen 3"> |

---

## 🎥 Video Demo

> Watch the app demonstration in the path below:  
> `assets/video/Android Emulator - Pixel_6_2_5554 2026-09-30 21-49-14.mp4`

---

## ✨ Features

- **Streaming Interface**: Browse movies, series, and live shows with clean category layouts.
- **Custom Arabic Typography**: Full integration with the Tajawal font family (Light, Regular, Medium, Bold, ExtraBold) for localized Arabic UI support.
- **Responsive Design**: Mobile-first layouts optimized across various screen sizes.
- **Asset & Media Management**: Structured folder architecture for images, custom fonts, and video recordings[cite: 1].

---

## 📂 Project Structure

```text
├── assets/
│   ├── fonts/
│   │   ├── Tajawal-Bold.ttf
│   │   ├── Tajawal-ExtraBold.ttf
│   │   ├── Tajawal-Light.ttf
│   │   ├── Tajawal-Medium.ttf
│   │   └── Tajawal-Regular.ttf
│   ├── screenshots/
│   │   ├── Screenshot 2026-09-30 112258.png
│   │   ├── Screenshot 2026-09-30 112349.png
│   │   └── Screenshot 2026-09-30 112422.png
│   └── video/
│       └── Android Emulator - Pixel_6_2_5554 2026-09-30 21-49-14.mp4
├── lib/
│   └── main.dart
└── pubspec.yaml



🚀 Getting Started
Prerequisites
Ensure you have the following installed on your system:

Flutter SDK (>=3.0.0)

Dart SDK

Android Studio / VS Code with Flutter and Dart plugins

Installation
Clone the repository

Bash
git clone [https://github.com/your-username/watch_it_app.git](https://github.com/your-username/watch_it_app.git)
cd watch_it_app
Install dependencies

Bash
flutter pub get
Verify Asset Configuration (pubspec.yaml)
Ensure all screenshot and video asset folders are correctly registered in your pubspec.yaml:

YAML
flutter:
  uses-material-design: true

  assets:
    - assets/screenshots/
    - assets/video/

  fonts:
    - family: Tajawal
      fonts:
        - asset: assets/fonts/Tajawal-Light.ttf
          weight: 300
        - asset: assets/fonts/Tajawal-Regular.ttf
          weight: 400
        - asset: assets/fonts/Tajawal-Medium.ttf
          weight: 500
        - asset: assets/fonts/Tajawal-Bold.ttf
          weight: 700
        - asset: assets/fonts/Tajawal-ExtraBold.ttf
          weight: 800
Run the application

Bash
flutter run
