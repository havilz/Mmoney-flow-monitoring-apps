# Technical Dictionary & Implementation Details

## Domain Terminology

| Term | Description |
| :--- | :--- |
| **Transaction** | A single record of money movement (either Income or Expense). |
| **Income** | Money received (e.g., Salary, Gift, Dividend). |
| **Expense** | Money spent (e.g., Food, Rent, Entertainment). |
| **Category** | A grouping for transactions (e.g., "Food & Drinks", "Utilities"). |
| **Wallet/Account** | The source/destination of funds (e.g., Cash, Bank, E-Wallet). |
| **Balance** | The net amount of money available (Total Income - Total Expense). |

## Technology Stack

- **Framework**: Flutter (Cross-platform)
- **Language**: Dart
- **Database**: SQLite (via `sqflite` package)
- **State Management**: Provider (Simple, robust, and well-supported)
- **Local Storage**: `path_provider` for finding database locations
- **Formatting**: `intl` for currency and date formatting
- **UI/UX**: `google_fonts` and custom animations for a premium feel

## Database Schema (Proposed)

### Transactions Table
- `id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `amount`: REAL (or INTEGER in cents for precision)
- `type`: TEXT (INCOME/EXPENSE)
- `category_id`: INTEGER (FK)
- `date`: TEXT (ISO8601 string)
- `note`: TEXT
- `wallet_id`: INTEGER (FK)

### Categories Table
- `id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `name`: TEXT
- `icon`: TEXT (Icon identifier)
- `color`: TEXT (Hex color code)
- `type`: TEXT (INCOME/EXPENSE/BOTH)

### Wallets Table
- `id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `name`: TEXT
- `balance`: REAL (Initial balance)
