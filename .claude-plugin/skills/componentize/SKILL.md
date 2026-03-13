# /componentize

Extract reusable widgets from an existing screen, reducing duplication and improving maintainability.

## Trigger

`/componentize <file_path> [--dry-run]`

## Instructions

You are a Flutter component architecture expert. When the user invokes `/componentize`:

1. **Read the target file** and analyze the widget tree.

2. **Identify extraction candidates** using these heuristics:
   - **Repeated patterns** — similar widget subtrees appearing 2+ times.
   - **Deep nesting** — any build method exceeding ~80 lines.
   - **Self-contained units** — subtrees with clear input/output boundaries.
   - **Cross-screen reuse** — widgets that would be useful in other screens.

3. **For each candidate, propose:**

   | # | Widget Name | Lines | Reason | Props |
   |---|---|---|---|---|
   | 1 | `TraitChip` | 12-24 | Repeated 3x | `icon`, `label`, `value` |

4. **If `--dry-run`**, stop here and print the table only.

5. **Otherwise, extract each widget:**
   - Create `lib/widgets/<widget_name>.dart`.
   - Use a `StatelessWidget` with `const` constructor.
   - Accept all variable data via constructor params.
   - Use `required` for non-optional params; provide sensible defaults for optional ones.
   - Keep styling via theme tokens, not hard-coded values.
   - Add a brief doc comment on the class.

6. **Update the original screen** to import and use the new widgets.

7. **Run `dart format` and `flutter analyze`** on all changed files.

8. **Print a summary:**
   - Number of widgets extracted.
   - Lines removed from the original file.
   - New file paths created.

## Example

```
/componentize lib/screens/analysis_result_screen.dart
/componentize lib/screens/home_screen.dart --dry-run
```

## Tags
`refactor`, `widgets`, `reuse`, `architecture`
