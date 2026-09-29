<div align="center">
  <img src="assets/fintra_dark.png" alt="Fintra Logo" width="160" />

  # Fintra — Personal Expense Tracker
  **Track your money. Own your future.**

  A modern, high-performance personal finance mobile application built with Flutter and Cloud Firestore. 

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%26%20Auth-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)]()
  [![License](https://img.shields.io/badge/License-MIT-blue.svg)]()
</div>

---

## 📥 Quick Links & Submission Deliverables

- 📦 **Release APK Download:** [Download Fintra APK](https://drive.google.com/file/d/1gq_cyNAfQWI3xjcyVy-xZ_KRC8aqnWAg/view?usp=sharing)

---

## ✨ Features Implemented

### 🌟 Core Requirements (100% Implemented)

- **Full Expense CRUD Operations:**
  - **Create:** Add new transactions with title, amount (in Rs.), category, date, and optional notes.
  - **Edit:** Tap any transaction tile to pre-fill the modal sheet and update existing Firestore documents without duplicates.
  - **Delete:** Swipe-to-dismiss (`Dismissible`) gesture with immediate Firestore synchronization and confirmation.
- **Visual Category System:** Interactive category selector with custom icons and color schemes (`Food & Dining`, `Shopping`, `Transport`, `Bills & Utilities`, `Entertainment`, `Healthcare`, `Other`).
- **Cloud Firestore Storage:** Per-user isolated sub-collection architecture (`/users/{uid}/expenses/{expenseId}`) ensuring private, encrypted storage.
- **Dynamic Monthly Aggregations:** Pitch-dark hero cards on Dashboard and Expenses screen displaying live sums calculated from Firestore streams.
- **Real-Time Expense History:** Chronological expense stream with reactive UI updates.
- **Advanced Multi-Filtering & Search:**
  - Real-time search by title and note content with dedicated `FocusNode` management.
  - Scrollable horizontal category filter chips.
  - Date Range Picker with active filter status chips and a one-tap reset action.
- **Strict Form Validation:** Email regex checks, title minimum length validation, and positive numeric constraints.
- **State Handling:** Shimmer/circular loaders, empty state views (`ExpensesEmptyView`), and custom `FintraDialog` alerts for error handling.

### 🎁 Additional & Optional Features

- **📊 7-Day Activity Chart:** Dynamic daily activity bar chart with automatic green gradient highlighting on peak spending days.
- **🍩 Spending Distribution Donut Chart:** Interactive `fl_chart` donut visualization with touch inspection and category percentage breakdowns.
- **🌙 Light & Dark Mode:** Global `ThemeController` utilizing a `ValueNotifier` for instant, app-wide reactive theme switching.
- **🔐 Firebase Authentication:** Complete Email/Password Registration, Login, and Password Reset flow.
- **👆 Biometric Authentication (Fingerprint / Face ID):** Secure hardware biometric app unlock via `local_auth` (`AppSessionGate`) preventing unauthorized access while preserving sessions.
- **💬 Custom Adaptive Dialogs (`FintraDialog`):** Scale-in animated modal dialogs with contextual color themes (`danger`, `success`, `warning`, `info`).
- **🌊 Staggered Cascade Animations:** Fluid, natural top-to-bottom entrance animations (`StaggeredSlideFade`) using customized easing curves.
- **👤 Live Profile Management:** Edit name and email with real-time stream sync across the AppBar, Sidebar, and Settings.

---

## 🏛️ Architecture & Project Structure

Fintra utilizes a **Layered Architecture (Layer-First)** for separation of concerns, scalability, and maintainability.

```text
lib/
├── core/
│   ├── animations/          # StaggeredSlideFade & custom curve physics
│   ├── constants/           # AppColors (extracted from brand logo)
│   ├── theme/               # Light & Dark ThemeData, AppTypography, ThemeController
│   └── utils/               # BiometricService, Formatters
├── data/
│   ├── models/              # ExpenseModel, CategoryType
│   └── repositories/        # AuthRepository, ExpenseRepository (Firestore streams)
└── presentation/
    ├── screens/             # SplashScreen, Login, SignUp, Dashboard, Expenses, Categories, Settings, AppSessionGate(Biometric + Auth), MainShellScreen
    └── widgets/             # Reusable UI components, Charts, Common Tiles, FintraDialog
```

---

## 🛠️ Technologies & Packages Used

| **Package** | **Version** | **Purpose** |
|---|---|---|
| **flutter** | SDK | Core UI framework |
| **firebase_core** | ^3.12.1 | Firebase initialization & configuration |
| **firebase_auth** | ^5.5.1 | User authentication & session management |
| **cloud_firestore** | ^5.6.5 | Cloud database with real-time reactive streams |
| **fl_chart** | ^0.70.2 | Interactive charts (Donut chart & 7-Day Bar chart) |
| **local_auth** | ^2.3.0 | Native biometric security (Fingerprint / Face ID) |
| **google_fonts** | ^6.2.1 | Typography using the Inter font family |
| **intl** | ^0.19.0 | Currency (Rs.) and localized date formatting |

---

## 🤖 AI Tools Used

In accordance with CyphLab's guidelines on modern development workflows, AI tools were leveraged to accelerate development:

1. **Architecture & Schema Planning:** Used generative AI (Gemini / Claude) to architect a layered separation of concerns and define Firestore sub-collection schemas (`/users/{uid}/expenses`).
2. **Brand & Color System Extraction:** Generated cohesive dark/light color palettes and gradient coordinates directly derived from the Fintra logo artwork.
3. **Animation Physics & Curve Optimization:** Assisted in fine-tuning StaggeredSlideFade spring curves (`Curves.easeOutCubic`) and managing `ValueKey` invalidation to eliminate frame stutters.
4. **Build Toolchain Debugging:** Solved cross-drive Kotlin Gradle incremental cache collisions on Windows development environments.

---

## 🚀 Setup & Installation Instructions

### Prerequisites

- [**Flutter SDK**](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android Device or Emulator (API 23+)

### Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/fintra_mobile_app.git
   cd fintra_mobile_app
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the application:**

   ```bash
   flutter run
   ```

4. **Build Release APK:**

   ```bash
   flutter build apk --release
   ```

   The generated APK will be available at:

   ```text
   build/app/outputs/flutter-apk/app-release.apk
   ```

---

## 🔒 Firestore Security Rules

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      match /expenses/{expenseId} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
  }
}
```

---

<div align="center">

</div>
