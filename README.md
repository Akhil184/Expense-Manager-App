<img width="200" height="300" alt="WhatsApp Image 2026-11-19 at 6 45 15 PM" src="https://github.com/user-attachments/assets/a3f53c48-0ec6-403d-9f91-e3e61ddbc241" />

<img width="200" height="300" alt="WhatsApp Image 2026-11-19 at 6 45 15 PM (1)" src="https://github.com/user-attachments/assets/c9183034-3bf5-41e0-a4b1-a67ffc112a2d" />

<img width="200" height="300" alt="WhatsApp Image 2026-11-19 at 6 45 15 PM (2)" src="https://github.com/user-attachments/assets/4fdbd09c-3f2e-466e-999b-c847d21580ee" />

<img width="200" height="300" alt="WhatsApp Image 2026-11-19 at 6 45 15 PM (3)" src="https://github.com/user-attachments/assets/362e3322-0fa6-4423-bedb-4dfc8d70c53a" />

<img width="200" height="300" alt="WhatsApp Image 2026-11-19 at 6 45 16 PM (1)" src="https://github.com/user-attachments/assets/d00df583-abe3-4e28-ba3b-19b87440b82a" />






Expense Manager App

A Flutter-based Expense Manager application that helps users track income and expenses, manage budgets, organize transactions, and monitor their financial activities.

Features

1. Dashboard
- View total balance.
- View total income and expenses.
- Display recent transactions.
- Navigate between app sections.

2. Transaction Management
- Add income and expense transactions.
- Enter transaction title, amount, category, date and notes.
- View transaction history.
- Search and filter transactions.
- Edit and delete transactions.

3. Budget Management
- Create monthly budgets.
- Set budgets by category.
- Track spending against budgets.
- View remaining budget amounts.
- Edit and delete budgets.

4. Recurring Transactions
- Create recurring income and expense schedules.
- Support daily, weekly, monthly and yearly frequencies.
- View recurring transaction schedules.
- Pause and resume recurring schedules.
- Delete recurring schedules.
- Generate due transactions when the app starts or resumes.

5. Category Management
- Manage custom income and expense categories.
- Add and delete custom categories.
- Use categories when creating transactions.

6. Analytics
- View income, expenses and savings summaries.
- Analyze expenses by category.
- View spending distribution.

 7. Theme Settings
- Support light and dark themes.
- Save theme preferences locally.

 Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Provider | State management |
| Drift | Local database |
| SQLite | Local data storage |
| SharedPreferences | Theme preference storage |
| Flutter Secure Storage | Secure local key storage |

 Project Architecture

The application follows a layered architecture to separate UI, business logic and data management.

```text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── services/
│
├── data/
│   ├── models/
│   ├── local/
│   │   ├── database/
│   │   └── dao/
│   ├── remote/
│   └── repositories/
│
├── providers/
│
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── transactions/
│   ├── analytics/
│   ├── budgets/
│   ├── accounts/
│   ├── goals/
│   ├── categories/
│   └── settings/
│
├── sync/
├── widgets/
└── main.dart
```

 Architecture Flow

```text
User Interface
      |
      v
   Provider
      |
      v
  Repository
      |
      v
   DAO Layer
      |
      v
  Drift / SQLite
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or physical device

### Installation

1. Clone the repository:

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

2. Open the project directory:

```bash
cd expense_manager_app
```

3. Install dependencies:

```bash
flutter pub get
```

4. Generate Drift database code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

5. Run the application:

```bash
flutter run
```

## Database

The application uses Drift with SQLite for local data persistence.

Database tables currently include:

- Transactions
- Budgets
- Categories
- Recurring Transactions

Drift DAOs handle database operations, while repositories provide data access to the providers.

## State Management

Provider is used for application state management.

The application includes providers for:

- Transactions
- Budgets
- Categories
- Recurring Transactions
- Theme Settings

## Recurring Transaction Processing

Recurring transactions support four frequencies:

- Daily
- Weekly
- Monthly
- Yearly

When the application starts or resumes, it checks active recurring schedules for due dates and generates the corresponding transactions.

The application uses deterministic transaction IDs to help prevent duplicate occurrences.

**Note:** Due-date processing currently runs when the app is active. Background processing while the app is completely closed requires additional background scheduling.

## Future Improvements

The following features can be added or completed as the project develops:

- Cloud synchronization using Firebase or Supabase.
- User authentication.
- Offline synchronization and conflict resolution.
- JSON backup and restore.
- CSV transaction export.
- Savings goals.
- Multiple accounts and wallets.
- Local notifications.
- App lock and biometric authentication.
- Automated unit and integration tests.
- CI/CD using GitHub Actions.

## Screenshots

Add application screenshots here.

```text
screenshots/
├── dashboard.png
├── transactions.png
├── budgets.png
├── analytics.png
├── recurring_transactions.png
└── settings.png
```

## Development Commands

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Generate database code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## License

This project is developed for educational and learning purposes.

---

**Expense Manager App**  
Built with Flutter and Dart.
