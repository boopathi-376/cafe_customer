# ☕ Happy Mug — Cafe Customer App

A production-grade Flutter application for ordering food and beverages from a cafe. Built with a clean architecture, real-time Firebase backend, and a polished dark-themed UI designed for a smooth customer experience.

---

## What This App Does

Happy Mug lets customers browse a cafe menu, add items to their cart, place orders, and track those orders in real time — all from their phone. Think of it as a lightweight Swiggy or Zomato, purpose-built for a single cafe brand.

The app handles the full customer journey:

- Create an account and verify your email
- Browse the menu by category or search by name
- Add items to your cart and save it across sessions
- Choose delivery or pickup at checkout
- Track your order status live as the cafe prepares it
- Rate your order after delivery
- Manage your delivery addresses from your profile

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider + ChangeNotifier |
| Backend | Firebase (Auth, Firestore) |
| Image Hosting | Cloudinary |
| Architecture | Feature-aware layered architecture |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/          # Firestore collection paths
│   ├── error/              # Typed exception handling
│   └── utils/              # App logger
├── models/                 # Data models (Order, MenuItem, User, Cart, Rating)
├── provider/               # State management (Auth, Menu, Cart, Order, User, Rating)
├── service/                # Firebase & Cloudinary business logic
├── theme/                  # App colors and theme
├── view/
│   ├── auth_screen/        # Login, Register, Email Verification
│   ├── notification_screen/
│   ├── order_update_screen/ # Real-time order tracking
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   ├── home_screen.dart
│   ├── product_screen.dart
│   ├── profile_screen.dart
│   ├── rate_order_screen.dart
│   ├── splash_screen.dart
│   └── view_orders_screen.dart
├── widget/                 # Reusable UI components
├── components/             # Cards, bottom nav, animations
├── helper/                 # Date utilities
├── firebase_options.dart
└── main.dart
```

---

## Architecture

The app follows a clean layered architecture:

```
UI (View) → Provider (State) → Service (Business Logic) → Firebase
```

- **Views** only read from providers — they never call Firebase directly
- **Providers** hold state and call services — they never import `cloud_firestore`
- **Services** own all Firebase interactions — they are the only layer that talks to the backend
- **Models** are pure Dart classes with `fromFirestore`, `toMap`, and `copyWith`

This separation makes the code easy to test, easy to change, and easy to scale.

---

## Key Features in Detail

### Authentication
- Email and password registration with email verification
- Auto-detects when the user clicks the verification link — no manual button tap needed
- Polling every 3 seconds after registration to catch verification automatically
- Secure sign-in that checks email verification before granting access


### Menu & Home
- Lazy-rendered grid using `SliverGrid` — handles large menus without performance issues
- Category filter chips for quick browsing
- Search with 300ms debounce — no lag while typing
- Error state with retry button if the menu fails to load

### Cart
- Cart persists to Firestore so it survives app restarts
- Quantity controls with instant UI feedback
- Cart loads from saved Firestore data on screen open

### Orders
- Real-time order stream — the orders list updates live without refresh
- Order cancellation with reason selection (only available while pending)
- Full order history with item breakdown

### Order Tracking
- Live status updates using Firestore snapshots — the stepper updates the moment the cafe changes the order status
- Handles all statuses: Pending → Accepted → Preparing → Ready → Out for Delivery → Delivered
- Cancelled orders show a dedicated cancelled state

### Ratings
- Rate an order after delivery with a star rating and optional comment
- Rating provider is scoped to the rating screen — no stale state between sessions
- Prevents duplicate ratings per order

### Profile
- Edit name and phone number
- Add, delete, and set a default delivery address
- Addresses persist to Firestore

---

## Firebase Setup

The app uses the following Firestore collections:

| Collection | Purpose |
|---|---|
| `customeruser` | User profiles and addresses |
| `menuItems` | Cafe menu with categories, pricing, ratings |
| `orders` | Customer orders with status tracking |
| `carts` | Persisted cart per user |
| `ratings` | Order ratings and comments |

Firestore security rules ensure:
- Users can only read and write their own data
- Menu items are read-only for customers
- Order status updates are blocked from the client (admin/backend only)
- Ratings can only be created, never edited or deleted

---

## Getting Started

### Prerequisites

- Flutter SDK 3.29.0 or later
- Android Studio or VS Code with Flutter extension
- A Firebase project with Authentication and Firestore enabled
- A Cloudinary account for image uploads

### Installation

```bash
# Clone the repository
git clone https://github.com/boopathi-376/cafe_customer.git
cd cafe_customer

# Install dependencies
flutter pub get
```

### Firebase Configuration

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** and **Google** sign-in under Authentication
3. Create a Firestore database in production mode
4. Download `google-services.json` and place it in `android/app/`
5. Run `flutterfire configure` to generate `lib/firebase_options.dart`
6. Deploy the security rules: `firebase deploy --only firestore:rules`

> **Important:** Never commit `google-services.json` or `firebase_options.dart` to version control. Both are listed in `.gitignore`.

### Run the App

```bash
# Debug mode
flutter run

# Release build
flutter build apk --release
```

---

## Environment Notes

The app currently uses a single Firebase environment. For a production setup, separate Firebase projects for `dev`, `staging`, and `production` are recommended using Flutter flavors.

---

## Known Limitations

- Payment integration is UI-only — no real payment gateway is connected yet
- Push notifications are not yet implemented
- Rider location tracking is not available in this version

These are planned for the next release.

---

## Contributing

This is a private project. If you have access and want to contribute, create a branch from `main`, make your changes, and open a pull request with a clear description of what you changed and why.

---

## License

Private repository. All rights reserved.
