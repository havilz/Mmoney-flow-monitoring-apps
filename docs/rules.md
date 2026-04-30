# Development Rules

## 1. Coding Standards
- **Naming**: 
  - Classes: `PascalCase`
  - Variables/Functions: `camelCase`
  - Files: `snake_case.dart`
- **Immutability**: Use `final` whenever possible.
- **Null Safety**: Always use Dart null-safety features. Avoid `!`.
- **Formatting**: Always run `flutter format .` before committing.

## 2. UI/UX Principles (Premium Design)
- **Colors**: Use a curated palette. Avoid default colors.
- **Spacing**: Use a consistent spacing scale (e.g., multiples of 8px).
- **Typography**: Use `GoogleFonts.outfit` or `GoogleFonts.inter` for a modern look.
- **Feedback**: Every interactive element must have a hover/tap effect.
- **Loading**: Use shimmer effects instead of simple spinners where appropriate.

## 3. Database Rules
- **Migrations**: Handle database versioning properly in `DatabaseHelper`.
- **Async**: Always use `Future` for database operations to avoid UI jank.
- **Precision**: Store currency amounts as integers (cents) to avoid floating-point errors, or use `double` with careful rounding.

## 4. Documentation
- Keep `/docs` updated as features are added.
- Use meaningful comments for complex business logic.
- Document every public API/Method in the repositories.
