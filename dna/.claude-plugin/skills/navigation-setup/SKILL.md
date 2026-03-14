# /navigation-setup

Set up or refactor app navigation with type-safe routing, guards, deep links, and transitions.

## Trigger

`/navigation-setup [--router go_router|auto_route|navigator] [--guards <guard_list>]`

## Instructions

You are a Flutter navigation architect. When the user invokes `/navigation-setup`:

1. **Audit current navigation.** Read the project to find:
   - Existing route definitions (named routes, `onGenerateRoute`, GoRouter, AutoRoute).
   - Navigation calls (`Navigator.push`, `context.go`, etc.).
   - Any deep link configuration.

2. **Choose the router** (from `--router` flag or auto-detect):
   - **GoRouter** (recommended default) — declarative, deep-link-ready.
   - **AutoRoute** — code-generated, type-safe.
   - **Navigator 2.0 raw** — only if already in use.

3. **Generate route configuration:**
   ```dart
   // lib/router/app_router.dart
   final appRouter = GoRouter(
     initialLocation: '/',
     redirect: _globalRedirect,
     routes: [
       GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
       GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
       GoRoute(
         path: '/analysis/:id',
         builder: (_, state) => AnalysisResultScreen(id: state.pathParameters['id']!),
       ),
     ],
   );
   ```

4. **Add route guards** (from `--guards` flag):
   - `auth` — redirect to `/login` if not authenticated.
   - `onboarding` — redirect to `/onboarding` if first launch.
   - `role` — restrict routes by user role.

5. **Generate navigation helpers:**
   ```dart
   // lib/router/routes.dart
   abstract class AppRoutes {
     static const splash = '/';
     static const home = '/home';
     static String analysis(String id) => '/analysis/$id';
   }
   ```

6. **Add page transitions:**
   - Default: platform-native (Material on Android, Cupertino on iOS).
   - Provide `fadeTransition`, `slideTransition` helpers for special cases.

7. **Wire into `MaterialApp`:**
   - Replace `MaterialApp` with `MaterialApp.router` (for GoRouter).
   - Set `routerConfig: appRouter`.

8. **Migrate existing navigation calls** — replace `Navigator.push(context, MaterialPageRoute(...))` with `context.go(AppRoutes.home)`.

9. **Run `dart format` and `flutter analyze`.**

10. **Print summary:** routes created, guards added, calls migrated.

## Example

```
/navigation-setup --router go_router --guards auth,onboarding
/navigation-setup
```

## Tags
`navigation`, `routing`, `go_router`, `deep-links`, `guards`
