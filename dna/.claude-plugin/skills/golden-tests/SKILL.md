# /golden-tests

Generate golden (snapshot) tests for visual regression detection on widgets and screens.

## Trigger

`/golden-tests <file_path> [--update]`

## Instructions

You are a Flutter testing specialist focused on visual regression. When the user invokes `/golden-tests`:

1. **Read the target widget/screen** and analyze its visual variants.

2. **Identify test scenarios:**
   - Default state (with sample data).
   - Each UI state (loading, empty, error, success).
   - Different data lengths (short text, long text, overflow).
   - Light and dark theme.
   - LTR and RTL directionality.
   - Different screen sizes (phone, tablet).

3. **Generate the golden test file** at `test/goldens/<widget_name>_golden_test.dart`:

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';

   void main() {
     group('WidgetName Golden Tests', () {
       testWidgets('default state', (tester) async {
         await tester.pumpWidget(
           MaterialApp(
             theme: AppTheme.dark(),
             home: Scaffold(
               body: WidgetName(/* sample props */),
             ),
           ),
         );
         await expectLater(
           find.byType(WidgetName),
           matchesGoldenFile('goldens/widget_name_default.png'),
         );
       });

       testWidgets('loading state', (tester) async { /* ... */ });
       testWidgets('error state', (tester) async { /* ... */ });
       testWidgets('rtl layout', (tester) async { /* ... */ });
       testWidgets('dark theme', (tester) async { /* ... */ });
     });
   }
   ```

4. **Create a test helper** if not present — `test/helpers/golden_helpers.dart`:
   ```dart
   Widget goldenWrapper(Widget child, {ThemeData? theme, TextDirection? dir}) {
     return MaterialApp(
       theme: theme ?? AppTheme.dark(),
       home: Directionality(
         textDirection: dir ?? TextDirection.ltr,
         child: Scaffold(body: Center(child: child)),
       ),
     );
   }
   ```

5. **Provide mock data** for props — use realistic sample data, not lorem ipsum.

6. **If `--update` flag is present**, run:
   ```bash
   flutter test --update-goldens test/goldens/<widget_name>_golden_test.dart
   ```

7. **Otherwise**, run:
   ```bash
   flutter test test/goldens/<widget_name>_golden_test.dart
   ```

8. **Print summary:** test scenarios generated, golden files created/updated, pass/fail status.

## Example

```
/golden-tests lib/widgets/trait_chip.dart
/golden-tests lib/screens/analysis_result_screen.dart --update
```

## Tags
`testing`, `golden`, `snapshot`, `visual-regression`, `qa`
