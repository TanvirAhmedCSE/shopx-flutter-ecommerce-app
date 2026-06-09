<div align="center">

<br/>

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/GetX-8B5CF6?style=for-the-badge&logo=getx&logoColor=white" />
<img src="https://img.shields.io/badge/Hive-FFB300?style=for-the-badge&logo=hive&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/FakeStore_API-E8472A?style=for-the-badge&logo=shopify&logoColor=white" />

<br/><br/>

# ShopX — A Flutter E-Commerce App

### A clean, full-featured shopping app built with Flutter & GetX MVC

*Browse · Wishlist · Cart · Checkout · Order History · Live Chat — beautifully crafted, offline-ready.*

</div>

---

## Features

- **Authentication** — Email/password sign up & sign in via Firebase Auth, email verification flow, password strength indicator, session persistence across restarts
- **Profile Setup** — Display name + avatar picker (25 avatars) on first launch; profile synced to Firestore and cached locally with Hive
- **Home Screen** — Category filter tabs (All, Electronics, Jewellery, Men's Clothing, Women's Clothing), product grid with live wishlist & cart status badges, time-aware greeting
- **Search** — Instant product search with result count and cart badge display with filtered searches
- **Product Detail** — Full-page view with hero image, star rating, review count, description, and dynamic add-to-cart button state
- **Wishlist** — Save and manage favourite products; count badge updates in real-time; persisted locally with Hive
- **Cart** — Quantity increment/decrement/delete, real-time total calculation, item count badge; persisted locally with Hive
- **Checkout — Shipping** — Delivery address form (name, street, city, zip) + selectable shipping methods (Standard Free / Express $5.99 / Next Day $12.99)
- **Checkout — Payment** — Card number/expiry/CVV form with auto-formatting + full order summary with per-item breakdown, subtotal, shipping, and grand total
- **Order Confirmation** — Clean success screen; order saved to Hive and Firestore simultaneously
- **Order History** — Latest orders shown first; tap any order to see the full detail summary; Hive-first loading with Firestore fallback on fresh install
- **Live Support Chat** — Real-time customer ↔ employee chat powered by Firestore; role switcher and bubble colour picker; unread message badge on bottom nav
- **Bottom Navigation** — Home · Chat · Orders · Profile with animated active state and unread chat badge
- **Profile Screen** — Avatar, name, email display; links to Edit Profile, Notifications, Favourites, Order History, Sign Out
- **Local Persistence** — Cart, wishlist, orders, and profile stored offline with Hive; survive app restarts and re-installs (Firestore restore on fresh install)
- **API Integration** — Products fetched from [FakeStore API](https://fakestoreapi.com) via `http`
- **Image Caching** — Smooth & efficient image loading with `cached_network_image`
- **Star Ratings** — Beautiful rating display with `flutter_rating_bar`

---

## Screenshots

<table>
  <tr>
    <td align="center"><img src="app screenshots/1.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/2.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/3.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/4.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/5.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/6a.jpg" width="220"/><br/><b>Showing Promo Banner after Sign Up</b></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/6b.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/6c.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/7.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/7a.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/8.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/8a.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/8b.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/8c.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/9.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/10.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/11.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/12.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/13.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/14.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/15.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/16.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/17.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/18.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/19.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/20.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/21.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/22.jpg" width="220"/></td>
    <td align="center"></td>
    <td align="center"></td>
  </tr>
</table>

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart |
| State Management | GetX |
| Architecture | MVC (Model-View-Controller) |
| Local Storage | Hive + Hive Flutter |
| Auth & Backend | Firebase Auth + Cloud Firestore |
| Networking | http |
| Image Caching | cached_network_image |
| Ratings | flutter_rating_bar |
| Icons | iconsax |
| API | FakeStore API |

---

## Project Structure

```
lib/
├── app/
│   ├── bindings.dart               # GetX dependency injection
│   ├── routes.dart                 # Named routes
│   └── theme.dart                  # App colors & theme
├── data/
│   ├── models/
│   │   ├── product_model.dart      # Product Hive model
│   │   ├── cart_item_model.dart    # Cart item Hive model
│   │   └── order_model.dart        # Order + OrderItem Hive model
│   ├── providers/
│   │   └── product_provider.dart   # FakeStore API calls
│   └── services/
│       ├── firebase_service.dart   # Firebase Auth, Firestore operations
│       └── hive_service.dart       # Hive read/write helpers
├── modules/
│   ├── auth/
│   │   ├── auth_controller.dart    # Sign out logic
│   │   ├── login_view.dart
│   │   ├── signup_view.dart        # Email verification flow
│   │   └── setup_profile_view.dart # Name + avatar picker
│   ├── bottom_nav/
│   │   ├── app_bottom_nav_bar.dart # Bottom nav with chat badge
│   │   └── bottom_nav_controller.dart
│   ├── cart/
│   │   ├── cart_controller.dart
│   │   └── cart_view.dart
│   ├── chat/
│   │   ├── chat_controller.dart    # Unread badge tracking
│   │   └── chat_view.dart          # Real-time Firestore chat
│   ├── checkout/
│   │   └── checkout_view.dart      # Shipping → Payment → Success
│   ├── favorites/
│   │   ├── favorites_controller.dart
│   │   └── favorites_view.dart
│   ├── home/
│   │   ├── home_controller.dart
│   │   └── home_view.dart          # Shell with bottom nav
│   ├── order_history/
│   │   ├── order_history_controller.dart
│   │   ├── order_history_view.dart
│   │   └── order_detail_view.dart
│   ├── product/
│   │   └── product_detail_view.dart
│   ├── profile/
│   │   └── profile_view.dart
│   ├── search/
│   │   ├── search_controller.dart
│   │   └── search_view.dart
│   └── splash/
│       └── splash_view.dart        # Session check on launch
├── widgets/
│   └── product_card.dart
├── firebase_options.dart
└── main.dart
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.x`
- Dart SDK `^3.11.3`
- A Firebase project with **Authentication** (Email/Password) and **Firestore** enabled

### Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (interactive — select your project)
flutterfire configure
```

Add Firestore security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /support_chat/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/TanvirAhmedCSE/shopx-flutter-ecommerce-app.git
cd shopx-flutter-ecommerce-app

# 2. Install dependencies
flutter pub get

# 3. Generate Hive type adapters
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

### Build APK

```bash
flutter build apk --release
```

---

## Dependencies

```yaml
dependencies:
  get: ^4.7.2                    # State management, routing, DI
  hive: ^2.2.3                   # Local NoSQL database
  hive_flutter: ^1.1.0           # Hive Flutter integration
  firebase_core: ^3.0.0          # Firebase core
  firebase_auth: ^5.0.0          # Email/password authentication
  cloud_firestore: ^5.0.0        # Real-time database (chat, orders, profile)
  http: ^1.5.0                   # HTTP networking (FakeStore API)
  cached_network_image: ^3.4.1   # Efficient network image caching
  flutter_rating_bar: ^4.0.1     # Star rating widget
  iconsax: ^0.0.8                # Beautiful icon pack
  uuid: ^4.4.0                   # Order ID generation

dev_dependencies:
  hive_generator: ^2.0.1         # Hive TypeAdapter code generator
  build_runner: ^2.4.13          # Code generation runner
```

---

## Design Decisions

- **Warm neutral palette** — Off-white `#F8F7F4` background with `#FF6B35` primary accent gives a premium, warm shopping feel
- **Hive-first, Firestore fallback** — Orders and profile load instantly from Hive; Firestore only fetched on fresh install, keeping the app snappy and offline-capable
- **Auth flow** — Email verification required before accessing the app; `SplashView` handles session restoration on every launch so no user sees a blank screen
- **Bottom nav shell** — Home, Chat, Orders, Profile tabs managed by `BottomNavController`; unread chat badge driven by `ChatController` which only listens to Firestore after the user is verified
- **Cart & wishlist badges** — Live count badges on the home app bar give instant feedback without navigating away
- **Two-step checkout** — Shipping and payment separated into distinct steps with a progress indicator for a clean, guided UX
- **Category filter chips** — Horizontal scrollable chips for fast category switching without leaving the home screen

---

## License

```
MIT License

Copyright (c) 2026 TanvirAhmedCSE

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
```

---

<div align="center">

Made with ❤️ and Flutter by **[TanvirAhmedCSE](https://github.com/TanvirAhmedCSE)**

*If you like this project, give it a ⭐ on GitHub!*

</div>
