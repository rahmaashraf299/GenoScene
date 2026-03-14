# /states-pack

Wire up all UI states for a screen: loading, empty, error, success, and skeleton shimmer.

## Trigger

`/states-pack <file_path> [--provider|--bloc|--riverpod]`

## Instructions

You are a Flutter state-management and UX specialist. When the user invokes `/states-pack`:

1. **Read the target screen** and identify the primary data it displays.

2. **Create a state enum** (or sealed class for Dart 3):
   ```dart
   sealed class ScreenState<T> {
     const ScreenState();
   }
   class ScreenLoading<T> extends ScreenState<T> { const ScreenLoading(); }
   class ScreenEmpty<T> extends ScreenState<T> { const ScreenEmpty(); }
   class ScreenError<T> extends ScreenState<T> {
     final String message;
     final VoidCallback? onRetry;
     const ScreenError(this.message, {this.onRetry});
   }
   class ScreenSuccess<T> extends ScreenState<T> {
     final T data;
     const ScreenSuccess(this.data);
   }
   ```

3. **Build UI for each state:**

   - **Loading** — Skeleton shimmer placeholders matching the content layout shape. Use `Container` with shimmer animation, not just a centered spinner.
   - **Empty** — Illustration (or icon), headline, subtitle, CTA button. Example: "No results yet — try uploading a file."
   - **Error** — Error icon, message text, "Retry" button that calls `onRetry`. Red accent from theme.
   - **Success** — The existing main content, wrapped to only render when data is available.

4. **Wire the state into the screen's `build()` method:**
   ```dart
   switch (state) {
     case ScreenLoading(): return _buildSkeleton();
     case ScreenEmpty(): return _buildEmpty();
     case ScreenError(:final message, :final onRetry): return _buildError(message, onRetry);
     case ScreenSuccess(:final data): return _buildContent(data);
   }
   ```

5. **If `--provider` is specified**, create/update a `ChangeNotifier` with state transitions. Same for `--bloc` or `--riverpod`.

6. **Create reusable state widgets** in `lib/widgets/`:
   - `shimmer_box.dart` — configurable shimmer placeholder.
   - `empty_state.dart` — icon + message + CTA.
   - `error_state.dart` — icon + message + retry button.

7. **Run `dart format` and `flutter analyze`.**

8. **Print summary:** states added, new files created, integration points.

## Example

```
/states-pack lib/screens/analysis_result_screen.dart --provider
/states-pack lib/screens/home_screen.dart
```

## Tags
`states`, `loading`, `error`, `empty`, `skeleton`, `shimmer`, `ux`
