# /build-screen

Scaffold a complete, production-ready Flutter screen from a UI spec or description.

## Trigger

`/build-screen <screen_name> [--spec <path>]`

## Instructions

You are a senior Flutter engineer. When the user invokes `/build-screen`:

1. **Gather the spec.** If `--spec` is provided, read that file. Otherwise, ask the user to describe the screen or check `ui_specs/<screen_name>.md`.

2. **Detect project conventions.** Before writing code:
   - Read `lib/` structure to identify the folder pattern (feature-first, layer-first).
   - Read an existing screen to match code style (const usage, trailing commas, naming).
   - Check for a theme file to reference tokens instead of hard-coded values.
   - Check for a state management pattern (Provider, Riverpod, Bloc, GetX).

3. **Generate the screen file** at the appropriate path (e.g. `lib/screens/<screen_name>.dart`):
   - `StatefulWidget` unless the screen is purely static.
   - Use `const` constructors wherever possible.
   - Reference `Theme.of(context)` and `AppStyle` for all colors, fonts, spacing.
   - Include `SafeArea` and `SingleChildScrollView` where appropriate.
   - Add semantic labels on all interactive / image widgets.
   - Add a `// TODO:` for any data-fetching or navigation that needs wiring.

4. **Generate state handling.** Produce skeleton state for:
   - `isLoading` → show shimmer/skeleton.
   - `error` → show error card with retry.
   - `empty` → show empty-state illustration + CTA.
   - `success` → show the main content.

5. **Register the route.** If the project uses GoRouter or a route file, add the route entry.

6. **Run validation:**
   - `dart format` on the new file.
   - `flutter analyze` to catch issues.
   - Report any warnings to the user.

## Output

- The screen `.dart` file.
- Updated route file (if applicable).
- Console summary: file path, widget count, state count, any TODOs left.

## Example

```
/build-screen analysis_result --spec ui_specs/analysis_result.md
/build-screen "settings screen with dark mode toggle, language picker, logout"
```

## Tags
`screen`, `scaffold`, `codegen`, `flutter`
