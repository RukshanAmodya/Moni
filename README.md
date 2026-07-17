# 👑 Moni — Premium Personal & Collaborative Wealth Ledger

Moni is a production-ready, beautiful, and secure Flutter personal finance manager. It offers real-time ledger tracking, dynamic portfolio management, collaborative shared budgeting via native hardware QR camera scanners, and interactive gamified savings challenges.

---

## 🌟 Premium Features

### 1. 📊 Real-Time Ledger Math & Insights
- **Zero Mock Data**: Fully functional transaction log (income, expense, transfer) loaded and saved dynamically using robust local file systems.
- **Smart Analytics**: Beautiful interactively-swapping Bar Charts and Pie Charts representing category distributions and cash flow.
- **Dynamic Budgets**: Real-time spending trackers that compute remaining balances and issue warning notifications when exceeding thresholds.

### 2. 👥 Shared Ledgers & Live Collaboration
- **QR Identity Network**: Generates a unique user identity QR code in the Profile screen using custom vector grid drawing.
- **Native QR Camera Scanner**: Integrates `mobile_scanner` hardware configurations to scan partner identities and link budgets in real-time.
- **Dynamic Empty States**: Automatically enforces empty state overlays when no partner is linked, prompting connection before showing collaborative screens.
- **Real-Time Group Feed**: Displays aggregated combined spending metrics and live collaborative transaction logs.

### 3. 🪙 Portfolio & Wealth Tracker
- **Real Investments Tracking**: Registers custom assets under Stocks, Cryptocurrencies, Commodities, or Real Estate.
- **Live Net Worth Calculator**: Aggregates asset valuations vs liabilities in a premium, dark-glass dashboard.
- **Swipe to Dismiss**: Allows quick asset updates and removals with swipe gestures synchronized to dynamic storage.

### 4. 🏆 Gamified Savings Challenges
- **52-Week Challenge**: Automatically evaluates progress against a target saving amount using actual Piggy Bank savings.
- **No-Spend Weekends**: Evaluates the ledger to check if any weekend expenses were logged.
- **30-Day Budget Champ**: Dynamically tracks how many active monthly budgets have stayed within their set limits.
- **Rare Achievement Badges**: Unlocks badges such as *Frugal King* or *Incognito Saver* based on real transaction habits.

### 5. 🛡️ Security & Privacy
- **Biometric authentication & PIN Locks**: Guards sensitive ledgers with Touch ID/Face ID integration.
- **Privacy Vaults (Incognito Mode)**: Conceals balances from being visible during public app usages.
- **Self-Destruct Protocol**: Erases local databases on multiple incorrect PIN attempts.

---

## 🛠️ Tech Stack & Architecture

- **Frontend Core**: Flutter & Dart (Material 3 components, Inter typography, sleek card gradients).
- **State Management**: Provider architecture pattern.
- **Storage Engine**: Flat-file JSON buffers for data persistence, SharedPreferences for configurations.
- **Auth & Cloud**: Firebase Authentication (with customized Display Names registration) & Firestore backup synchronization.
- **Camera Scanning**: Native iOS/Android camera preview via `mobile_scanner`.

---

## 📱 Project Directory structure

```
lib/
├── main.dart                      # App entry & theme initialization
├── models/
│   └── finance_models.dart        # Core structures: Transaction, Budget, PortfolioAsset
├── providers/
│   ├── auth_provider.dart         # Authentication state & displayName configuration
│   └── finance_provider.dart      # Core ledger math, portfolio actions, and partner linking
├── screens/
│   ├── home_screen.dart           # Dashboard & Piggy Bank Piggy bank
│   ├── shared_ledgers_screen.dart # Connected partner feeds & empty layouts
│   ├── wealth_tracker_screen.dart # Portfolio distribution & Net Worth calculators
│   ├── profile_screen.dart        # QR grid rendering & scanner controllers
│   ├── qr_scanner_screen.dart     # Hardware mobile camera & animated scanner overlay
│   └── savings_challenges_screen.dart # Real-time streak tracking & unlocked badges
├── services/
│   └── storage_service.dart       # Read/Write filesystem JSON streams
└── theme/
    └── moni_theme.dart            # Custom Material Design palette (Slate/Sage/Violet)
```

---

## ⚙️ Setup & Configurations

1. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Signing Report (For Firebase Credentials)**:
   ```bash
   cd android
   ./gradlew signingReport
   ```

3. **Run Unit Tests**:
   ```bash
   flutter test
   ```

4. **Launch Application**:
   ```bash
   flutter run
   ```

---
*Created by Google Antigravity AI Coding Assistant.*
