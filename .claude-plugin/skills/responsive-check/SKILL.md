# /responsive-check

Audit and fix responsive layout issues across mobile breakpoints and orientations.

## Trigger

`/responsive-check <file_or_directory> [--breakpoints <widths>]`

## Instructions

You are a responsive mobile UI specialist. When the user invokes `/responsive-check`:

1. **Read the target files** (single file or all `.dart` files in a directory).

2. **Analyze for responsive issues:**

   | Issue | What to look for |
   |---|---|
   | Fixed widths | Hard-coded `width:` values that won't adapt |
   | Overflow risk | `Row` children without `Flexible`/`Expanded` wrapping |
   | Text overflow | Long text without `maxLines`, `overflow`, or `AutoSizeText` |
   | Small-screen squeeze | Content that assumes ≥360dp width |
   | Landscape breakage | Layouts that only work in portrait |
   | Large-screen waste | No `ConstrainedBox` / `maxWidth` on tablets |
   | Font scaling | Text that breaks at system font scale 1.5x or 2x |
   | Image sizing | Images without `fit:` or using fixed pixel dimensions |
   | Bottom overflow | Column children that exceed screen height without scrolling |

3. **Generate a report** as a table:

   ```
   | File:Line | Issue | Severity | Fix |
   |---|---|---|---|
   | home:45 | Fixed width 300 | High | Use MediaQuery or Expanded |
   ```

4. **Auto-fix** each issue:
   - Replace fixed widths with `MediaQuery.of(context).size.width * fraction` or `Expanded`.
   - Wrap overflow-risk `Row` children in `Flexible`.
   - Add `overflow: TextOverflow.ellipsis` and `maxLines` to unbounded text.
   - Wrap non-scrollable `Column` bodies in `SingleChildScrollView`.
   - Add `ConstrainedBox(constraints: BoxConstraints(maxWidth: 600))` for tablet.

5. **Default breakpoints** (can be overridden with `--breakpoints`):
   - Small phone: 320dp
   - Standard phone: 375dp
   - Large phone: 428dp
   - Tablet: 768dp

6. **Run `flutter analyze`** after fixes.

7. **Print summary:** files checked, issues found, issues fixed, remaining manual items.

## Example

```
/responsive-check lib/screens/
/responsive-check lib/screens/home_screen.dart --breakpoints 320,375,428
```

## Tags
`responsive`, `layout`, `overflow`, `breakpoints`, `adaptive`
