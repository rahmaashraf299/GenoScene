# /theme-system

Create or extend a design-token-based ThemeData system with colors, typography, spacing, and component themes.

## Trigger

`/theme-system [--colors <palette>] [--typography <font>] [--mode dark|light|both]`

## Instructions

You are a design-systems engineer for Flutter. When the user invokes `/theme-system`:

1. **Audit the current theme.** Read `lib/styles.dart`, `lib/theme/`, or `main.dart` to find existing theme definitions.

2. **Design the token architecture:**

   ```
   lib/theme/
   ├── app_colors.dart        # Color palette + semantic aliases
   ├── app_typography.dart     # TextTheme with named styles
   ├── app_spacing.dart        # EdgeInsets / SizedBox constants (4, 8, 12, 16, 24, 32, 48)
   ├── app_radius.dart         # BorderRadius tokens
   ├── app_shadows.dart        # BoxShadow presets
   ├── app_theme.dart          # ThemeData builder combining all tokens
   └── app_style.dart          # Legacy compat / glass-card helpers (if existing)
   ```

3. **Generate color tokens:**
   - Primary, secondary, tertiary, error, success, warning, info.
   - Surface, background, onPrimary, onSurface, etc.
   - Support both light and dark mode via `ColorScheme.fromSeed()` or manual definition.
   - Never expose raw hex in screens — always `AppColors.primary` or `Theme.of(context).colorScheme.primary`.

4. **Generate typography tokens:**
   - Use the specified font family (default: Poppins via `google_fonts`).
   - Define semantic names: `displayLarge`, `headlineMedium`, `titleSmall`, `bodyLarge`, `labelSmall`, etc.
   - Include `fontWeight`, `fontSize`, `letterSpacing`, `height`.

5. **Generate spacing tokens:**
   - `AppSpacing.xs` (4), `sm` (8), `md` (16), `lg` (24), `xl` (32), `xxl` (48).
   - Provide `EdgeInsets` helpers: `AppSpacing.horizontalMd`, `AppSpacing.allLg`.

6. **Wire into `MaterialApp`:**
   - Update `main.dart` to use `AppTheme.dark()` / `AppTheme.light()`.
   - Ensure `useMaterial3: true`.

7. **Migrate existing hard-coded values** — find all hex colors and magic numbers in `lib/` and replace with tokens. Print a migration report.

## Example

```
/theme-system --colors brand --typography poppins --mode dark
/theme-system --mode both
```

## Tags
`theme`, `design-tokens`, `colors`, `typography`, `material3`
