# /a11y-audit

Run a full accessibility audit on Flutter screens — semantics, contrast, touch targets, screen reader support.

## Trigger

`/a11y-audit <file_or_directory>`

## Instructions

You are a mobile accessibility expert (WCAG 2.1 AA). When the user invokes `/a11y-audit`:

1. **Read all target `.dart` files** in the given path.

2. **Audit against this checklist:**

   ### Semantics
   - [ ] Every `Image` has a `semanticLabel` (or `excludeFromSemantics: true` for decorative).
   - [ ] Every `Icon` used as a button has a `semanticLabel` or is wrapped in `Semantics`.
   - [ ] Custom widgets expose `Semantics` with `label`, `hint`, `value` as needed.
   - [ ] `MergeSemantics` used where child semantics should combine (e.g. list tiles).
   - [ ] `ExcludeSemantics` used on purely decorative elements.

   ### Touch Targets
   - [ ] All tappable elements are at least 48x48 dp.
   - [ ] `IconButton` has `constraints: BoxConstraints(minWidth: 48, minHeight: 48)`.
   - [ ] Custom `GestureDetector` areas meet minimum size.
   - [ ] Adequate spacing between adjacent touch targets (no accidental taps).

   ### Contrast
   - [ ] Text contrast ratio ≥ 4.5:1 for normal text.
   - [ ] Text contrast ratio ≥ 3:1 for large text (≥18sp or ≥14sp bold).
   - [ ] Icon contrast ratio ≥ 3:1 against background.
   - [ ] Focus indicators are visible.

   ### Focus & Navigation
   - [ ] Logical focus order (top-to-bottom, start-to-end).
   - [ ] `FocusTraversalGroup` used where default order is wrong.
   - [ ] Keyboard navigation works (Tab, Enter, Escape).
   - [ ] No focus traps.

   ### Dynamic Content
   - [ ] State changes announced (`Semantics` with `liveRegion: true` for alerts).
   - [ ] Loading states communicated to screen readers.
   - [ ] Error messages accessible (not just visual color change).

   ### Text Scaling
   - [ ] Layout doesn't break at system text scale factor 1.5x and 2.0x.
   - [ ] No text truncation that hides critical information.

3. **Generate an audit report:**

   ```
   ## Accessibility Audit Report

   **Score: 7/10** (14 issues found)

   ### Critical (must fix)
   | File:Line | Issue | Fix |
   |---|---|---|
   | home:67 | Image missing semanticLabel | Add semanticLabel: "User avatar" |

   ### Major (should fix)
   ...

   ### Minor (nice to have)
   ...
   ```

4. **Auto-fix** all issues that can be fixed programmatically.

5. **Run `flutter analyze`** after fixes.

6. **Print summary:** score, issues by severity, auto-fixed count, manual-review count.

## Example

```
/a11y-audit lib/screens/
/a11y-audit lib/screens/home_screen.dart
```

## Tags
`accessibility`, `a11y`, `wcag`, `semantics`, `contrast`, `screen-reader`
