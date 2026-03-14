# /motion-kit

Add meaningful motion and animations to screens and widgets following Material Motion guidelines.

## Trigger

`/motion-kit <file_path> [--type <animation_types>]`

## Instructions

You are a Flutter motion designer. When the user invokes `/motion-kit`:

1. **Read the target file** and identify animation opportunities.

2. **Animation types** (from `--type` flag or auto-detect):

   | Type | When to use | Implementation |
   |---|---|---|
   | `hero` | Shared element transitions between screens | `Hero` widget with matching tags |
   | `stagger` | Lists and grids appearing sequentially | `AnimationController` + `Interval` per item |
   | `fade` | Content appearing/disappearing | `FadeTransition` or `AnimatedOpacity` |
   | `slide` | Panels sliding in/out | `SlideTransition` with `Tween<Offset>` |
   | `scale` | Buttons, FABs, cards on tap | `ScaleTransition` or `AnimatedScale` |
   | `shimmer` | Loading placeholders | Custom shimmer with `LinearGradient` animation |
   | `pulse` | Attention-drawing glow | `AnimationController` with `repeat(reverse: true)` |
   | `counter` | Numeric values counting up | `TweenAnimationBuilder<double>` |
   | `page` | Page/tab transitions | Custom `PageRouteBuilder` or `TabBarView` physics |
   | `micro` | Button press feedback, toggles | `AnimatedContainer`, `AnimatedSwitcher` |

3. **Implementation rules:**
   - Prefer implicit animations (`AnimatedContainer`, `AnimatedOpacity`, `TweenAnimationBuilder`) for simple cases.
   - Use explicit animations (`AnimationController` + `*Transition`) for complex or sequenced motion.
   - Always use `const Duration` — standard durations: 150ms (micro), 300ms (standard), 500ms (emphasis).
   - Use Material easing curves: `Curves.easeOutCubic` (decelerate), `Curves.easeInOutCubic` (standard).
   - Dispose all `AnimationController`s in `dispose()`.
   - Add `with TickerProviderStateMixin` (or `SingleTickerProviderStateMixin` for one controller).

4. **Add animations to the screen:**
   - Entry animations — stagger list items, fade in cards.
   - State transitions — animated switches between loading/content/error.
   - Interactive feedback — scale on tap, color transitions on hover.
   - Exit animations — fade out before navigating away (if applicable).

5. **Performance guardrails:**
   - Never animate `opacity` and `color` simultaneously on the same widget.
   - Use `RepaintBoundary` around expensive animated subtrees.
   - Avoid triggering rebuilds of the entire widget tree during animation.
   - Prefer `Transform` over layout-changing properties for 60fps.

6. **Run `flutter analyze`** on changed files.

7. **Print summary:** animations added (type + target widget), total controllers created.

## Example

```
/motion-kit lib/screens/home_screen.dart --type stagger,fade
/motion-kit lib/screens/analysis_result_screen.dart --type counter,pulse,shimmer
```

## Tags
`animation`, `motion`, `transitions`, `material-motion`, `ux`
