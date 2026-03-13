# /rtl-polish

Add or fix right-to-left (RTL) language support throughout the UI for Arabic, Hebrew, and other RTL locales.

## Trigger

`/rtl-polish <file_or_directory>`

## Instructions

You are an RTL internationalization expert for Flutter. When the user invokes `/rtl-polish`:

1. **Read the target files** and analyze every widget for RTL correctness.

2. **Check for these RTL issues:**

   | Issue | What to look for |
   |---|---|
   | Directional padding | `EdgeInsets.only(left:)` instead of `EdgeInsetsDirectional.start()` |
   | Directional margin | Same — `left/right` vs `start/end` |
   | Directional alignment | `Alignment.centerLeft` instead of `AlignmentDirectional.centerStart` |
   | Directional positioning | `Positioned(left:)` instead of `PositionedDirectional(start:)` |
   | Directional icons | Arrow icons (→) that should flip in RTL |
   | Text alignment | `TextAlign.left` instead of `TextAlign.start` |
   | Row ordering | Rows where semantic order matters but won't auto-flip |
   | Border sides | `Border(left:)` instead of `BorderDirectional(start:)` |
   | Transform translate | Horizontal translations that should negate in RTL |
   | Hard-coded TextDirection | Overriding `textDirection:` without reason |

3. **Generate a report table:**

   ```
   | File:Line | Issue | Before | After |
   |---|---|---|---|
   | home:34 | Directional padding | EdgeInsets.only(left: 16) | EdgeInsetsDirectional.only(start: 16) |
   ```

4. **Apply all fixes automatically.**

5. **Add a test helper** if not present — a utility to run any screen in both LTR and RTL for visual comparison:
   ```dart
   Widget testDirectionality(Widget child, TextDirection dir) =>
     Directionality(textDirection: dir, child: child);
   ```

6. **Run `dart format` and `flutter analyze`** on changed files.

7. **Print summary:** total issues found, auto-fixed count, any manual-review items.

## Example

```
/rtl-polish lib/screens/home_screen.dart
/rtl-polish lib/screens/
```

## Tags
`rtl`, `i18n`, `arabic`, `directionality`, `localization`
