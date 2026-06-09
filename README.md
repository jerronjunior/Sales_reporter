# Sales Reporter — Flutter Assessment
> Cyber Mas Solutions (Pvt) Ltd | Flutter Developer / Trainee

A clean, production-ready Sales Reporting mobile application built with Flutter.

---

## Demo credentials
```
Email:    test@test.com
Password: 123456
```

---


---

## Setup instructions

### Prerequisites
- Flutter SDK ≥ 3.2.0
- Dart SDK ≥ 3.2.0
- Android Studio / VS Code with Flutter plugin

### Run the app
```bash
# 1. Clone / unzip the project
cd sales_reporter

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# 4. Run tests
flutter test
```

### Connect to a real backend
In `lib/services/api_service.dart`, swap `MockApiService` for `HttpApiService`:

```dart
// lib/providers/app_providers.dart
final apiServiceProvider = Provider<ApiService>(
  (_) => HttpApiService(baseUrl: 'https://your-api.com/api'),
);
```

---

## Architecture

### Folder structure
```
lib/
├── models/           # Pure data classes (User, Customer, Report)
├── services/         # API layer (abstract + Mock + HTTP) and StorageService
├── repositories/     # Business logic between providers and services
├── providers/        # All Riverpod state notifiers and providers
├── screens/          # Full-page UI (Splash, Login, Home, Dashboard, Customers, Reports)
├── widgets/          # Reusable UI components (StatCard, CustomerTile, ErrorWidget)
└── utils/            # Theme definitions
```

### Layer overview
```
UI Screens
    │
    ▼
Riverpod Providers  ← StateNotifiers holding app state
    │
    ▼
Repositories        ← Orchestrate data access; one per domain
    │
    ▼
Services            ← ApiService (HTTP / Mock) + StorageService
```

---

## State management: Riverpod

**Why Riverpod?**
- Type-safe providers with no context dependency
- Clean separation: `StateNotifier` holds logic, UI just watches state
- Easy to test — providers can be overridden in tests
- Scales well from small to large apps without restructuring

**Providers used:**
| Provider | Type | Purpose |
|---|---|---|
| `apiServiceProvider` | `Provider` | ApiService instance (Mock or HTTP) |
| `storageServiceProvider` | `Provider` | SharedPreferences wrapper |
| `authProvider` | `StateNotifierProvider<AuthNotifier>` | Login / logout / stored user |
| `customerProvider` | `StateNotifierProvider<CustomerNotifier>` | Customer list + search + pagination |
| `reportProvider` | `StateNotifierProvider<ReportNotifier>` | Reports + dashboard stats |
| `themeModeProvider` | `StateProvider` | Light / dark mode toggle |

---

## API layer

`ApiService` is an **abstract interface** with two implementations:
- `MockApiService` — returns realistic mock data with simulated delays (used now)
- `HttpApiService` — real HTTP client using the `http` package, ready to plug in

This makes swapping to a real backend a one-line change.

---

## Local storage (SharedPreferences)

`StorageService` wraps SharedPreferences and stores:
- `auth_token` — JWT token from login response
- `user_id`, `user_name`, `user_email` — user info for offline display

On app start, `SplashScreen` reads the stored token and routes directly to `HomeScreen` if still logged in — no re-login needed.

---

## Error handling

| Scenario | Handling |
|---|---|
| Invalid login | `ApiException` shown as error banner on login screen with shake animation |
| Network failure | `NetworkException` shown via `AppErrorWidget` with retry button |
| API error | `AppErrorWidget` with retry on all data screens |
| Empty response | `EmptyStateWidget` shown on customers and reports screens |
| Loading | `CircularProgressIndicator` on all async operations |

---

## Features implemented

### Required
- [x] Login screen with email + password validation
- [x] Save token and keep user logged in after restart
- [x] Dashboard with user name, total customers, sales, revenue stats
- [x] Customers screen with name, email, phone
- [x] Search customers by name
- [x] Pull to refresh on all screens
- [x] Reports screen with monthly sales, revenue, orders
- [x] Logout — clears token, redirects to login

### Bonus
- [x] **fl_chart** — bar chart for monthly revenue on Reports screen
- [x] **Dark mode** — full light/dark theme support, toggle in app bar
- [x] **Pagination** — customers load 20 at a time with infinite scroll
- [x] **Unit tests** — login service, auth repository, customers, reports
- [x] Smooth animations (shake on invalid login, AnimatedSwitcher on tab change)
- [x] Responsive layout — works on phones and tablets
- [x] Mini progress bars on report rows showing relative revenue

---

## Assumptions made

1. No real backend URL was provided — `MockApiService` simulates all API calls with realistic delays (500–1000ms)
2. Dashboard stats (`/dashboard`) are included as an extra endpoint not listed in the spec but implied by the dashboard requirements
3. Pagination page size is set to 20 (configurable in `CustomerRepository.pageSize`)
4. Auth token is stored in `SharedPreferences`; for a production app, `flutter_secure_storage` would be preferred for security

---

## Running tests
```bash
flutter test
```
Tests cover:
- Valid and invalid login via `MockApiService`
- Token save/clear via `AuthRepository`
- Customer pagination
- Report data integrity

---

*Built by Velu Spencer Jerom*
