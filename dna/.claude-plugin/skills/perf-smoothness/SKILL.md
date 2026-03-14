# /perf-smoothness

Profile and optimize UI rendering performance — reduce jank, unnecessary rebuilds, and shader compilation stutter.

## Trigger

`/perf-smoothness <file_or_directory>`

## Instructions

You are a Flutter performance specialist. When the user invokes `/perf-smoothness`:

1. **Read the target files** and analyze the widget tree for performance anti-patterns.

2. **Check for these issues:**

   ### Rebuild Waste
   - [ ] `setState` that rebuilds the entire screen instead of a targeted subtree.
   - [ ] Missing `const` constructors on stateless subtrees.
   - [ ] Builder callbacks creating new widget instances every frame.
   - [ ] `MediaQuery.of(context)` high in the tree (triggers rebuild on keyboard).
   - [ ] Missing `const` on `EdgeInsets`, `BorderRadius`, `BoxDecoration`, `TextStyle`.

   ### List Performance
   - [ ] `ListView` without `itemExtent` or `prototypeItem` for fixed-height items.
   - [ ] `ListView` using `children: []` instead of `ListView.builder` for large lists.
   - [ ] Missing `key` on list items that get reordered.
   - [ ] Heavy widgets inside list items without `RepaintBoundary`.
   - [ ] `AutomaticKeepAliveClientMixin` missing on tab views with expensive content.

   ### Image & Asset Performance
   - [ ] Network images without `cacheWidth`/`cacheHeight` for decode-time reduction.
   - [ ] Missing `Image.asset` `cacheWidth` for oversized assets.
   - [ ] SVGs rendered at runtime instead of pre-rasterized.
   - [ ] No image placeholder/fade-in for network images.

   ### Animation Performance
   - [ ] Animated widgets not wrapped in `RepaintBoundary`.
   - [ ] `Opacity` widget used instead of `FadeTransition` (causes saveLayer).
   - [ ] `ClipRRect` used excessively (triggers saveLayer).
   - [ ] `BackdropFilter` without bounded area (full-screen blur).

   ### Build Method Hygiene
   - [ ] Build methods exceeding 100 lines (extract widgets).
   - [ ] Object allocation inside `build()` (move to `initState` or class level).
   - [ ] String concatenation/formatting inside `build()` on every frame.

3. **Generate a performance report:**

   ```
   ## Performance Report

   **Estimated Impact: Medium** (8 issues found)

   | # | File:Line | Issue | Impact | Fix |
   |---|---|---|---|---|
   | 1 | home:45 | setState rebuilds entire screen | High | Extract stateful subtree |
   | 2 | home:78 | ListView without builder | Medium | Use ListView.builder |
   ```

4. **Apply optimizations:**
   - Add `const` to all eligible constructors and literals.
   - Replace `ListView(children: [...])` with `ListView.builder`.
   - Wrap animated subtrees in `RepaintBoundary`.
   - Extract frequently-rebuilding subtrees into separate widgets.
   - Add `cacheWidth`/`cacheHeight` to images.

5. **Run `flutter analyze`.**

6. **Print summary:** issues found, optimizations applied, estimated frame-time improvement.

## Example

```
/perf-smoothness lib/screens/
/perf-smoothness lib/screens/feed_screen.dart
```

## Tags
`performance`, `jank`, `rebuild`, `optimization`, `profiling`
