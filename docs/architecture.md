# Project Structure & Pattern

## Architectural Pattern: Clean Architecture (Simplified)

We will use a layered approach to ensure the code is maintainable and testable, even for a personal project.

### Layers:
1. **Data Layer**:
   - `repositories/`: Concrete implementation of data access (SQLite calls).
   - `models/`: Data transfer objects (DTOs) and database entities.
   - `datasources/`: `database_helper.dart` for direct SQLite interaction.
2. **Domain Layer**:
   - `entities/`: Core business objects (Plain Dart classes).
   - `repositories_interfaces/`: Abstract classes defining data operations.
3. **Presentation Layer**:
   - `providers/`: State management logic.
   - `screens/`: High-level page widgets.
   - `widgets/`: Reusable UI components.
   - `themes/`: Styling, colors, and typography.

## Directory Structure

```text
lib/
├── core/               # App-wide constants, themes, and utils
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/               # Data layer implementation
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/             # Business logic and entities
│   ├── entities/
│   └── repositories/   # Interfaces
├── presentation/       # UI and State
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── main.dart           # Entry point
```

## Pattern: MVVM (Model-View-ViewModel)
- **Model**: Data entities in `domain/entities`.
- **View**: Widgets in `presentation/screens`.
- **ViewModel**: ChangeNotifiers in `presentation/providers`.
