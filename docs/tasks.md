# Task List - Money Monitoring App

## Phase 1: Project Setup & Foundation
- [x] Initialize project documentation in `/docs`
- [x] Add dependencies to `pubspec.yaml` (`sqflite`, `path`, `provider`, `intl`, `google_fonts`, `csv`, `path_provider`)
- [x] Configure project structure (Clean Architecture)
- [x] Define global theme and color palette (Premium Design)

## Phase 2: Database Layer
- [x] Design SQLite Schema (Transactions, Categories, Wallets)
- [x] Implement `DatabaseHelper` class
- [x] Create Repositories for data access
- [ ] Write unit tests for database operations and repositories
- [ ] Enable SQLite Foreign Key constraints (`PRAGMA foreign_keys = ON;`)
- [ ] Create default wallet ("Cash") on database creation

## Phase 3: Core Logic & State Management
- [x] Define Models (`Transaction`, `Category`, `Wallet`)
- [x] Setup State Management (Provider)
- [x] Implement Business Logic (Calculating balance, filtering by date/category)
- [ ] Implement Wallet Provider & state management (supporting multi-wallet selection/management)

## Phase 4: UI Implementation
- [x] Build **Dashboard Page** (Balance overview, recent transactions, navigation drawer)
- [x] Build **Add/Edit Transaction Page** (Form with category selection)
- [x] Build **Transaction History Page** (List with detailed filters)
- [x] Build **Category Management Page** (View and Add categories)
- [/] Add micro-animations and transitions (In progress)
  - [ ] Implement Splash Screen with Lottie animation (`Money Bag.lottie`)
  - [ ] Implement page transitions and list animations for a premium feel
- [ ] Build **Wallet Selection/Management UI** in add/edit transaction and settings

## Phase 5: Polishing & Finalization
- [x] Implement "Premium" UI touches (Gradients, custom fonts)
- [x] Add data export/import (CSV Export implemented)
- [ ] Perform final testing on Windows/Android/iOS
- [ ] Refactor and organize codebase:
  - [ ] Move theme configuration to `lib/core/theme`
  - [ ] Clean up unused resources and formats
