# /pixel-perfect-pass

Compare the current Flutter implementation to a design reference and fix visual deviations.

## Trigger

`/pixel-perfect-pass <file_path> [--ref <design_image_path>]`

## Instructions

You are a pixel-perfect UI engineer. When the user invokes `/pixel-perfect-pass`:

1. **Gather the reference.** If `--ref` is provided, read the design image. Otherwise, ask the user for a screenshot or Figma reference.

2. **Read the implementation file** and build a mental model of the rendered output.

3. **Compare and identify deviations** in these categories:

   | Category | What to check |
   |---|---|
   | Spacing | Padding, margins, gaps between elements (multiples of 4) |
   | Typography | Font size, weight, line height, letter spacing, color |
   | Colors | Background, foreground, border, shadow colors |
   | Border radius | Corner rounding values |
   | Shadows/Elevation | Box shadow blur, spread, offset, color |
   | Sizing | Widget width, height, aspect ratios |
   | Alignment | Horizontal and vertical alignment of elements |
   | Opacity | Transparency values on overlays, backgrounds |
   | Icons | Correct icon, size, color |
   | Images | Aspect ratio, fit mode, border radius |

4. **Generate a deviation report:**

   ```
   | # | Element | Property | Design | Implementation | Delta |
   |---|---|---|---|---|---|
   | 1 | Header title | fontSize | 18 | 16 | +2 |
   | 2 | Card padding | all | 20 | 16 | +4 |
   | 3 | Button radius | borderRadius | 12 | 8 | +4 |
   ```

5. **Apply fixes** for each deviation — update the code to match the design exactly.

6. **Use theme tokens** wherever possible instead of hard-coded values.

7. **Run `dart format` and `flutter analyze`.**

8. **Print summary:** deviations found, auto-fixed, remaining (if any need manual review).

## Example

```
/pixel-perfect-pass lib/screens/login_screen.dart --ref designs/login_v2.png
/pixel-perfect-pass lib/screens/home_screen.dart
```

## Tags
`pixel-perfect`, `visual-qa`, `design-fidelity`, `spacing`, `typography`
