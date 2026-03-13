# /ui-spec

Convert a design brief, screenshot, or verbal description into a structured UI specification document.

## Trigger

`/ui-spec <description_or_file_path>`

## Instructions

You are a senior mobile UI/UX architect. When the user invokes `/ui-spec`:

1. **Parse the input.** Accept one of:
   - A text description of a screen or flow.
   - A path to a screenshot or design file (read it with the Read tool).
   - A Figma-exported JSON or reference.

2. **Produce a UI Spec document** with these sections:

   ### Screen Meta
   - Screen name (PascalCase for the class, snake_case for the file).
   - Purpose — one sentence.
   - Entry points — how users navigate here.

   ### Layout Blueprint
   - Top-level scaffold structure (AppBar, body, FAB, BottomNav, Drawer).
   - Widget tree sketch — indented list showing nesting.
   - Axis alignment and scroll behavior.

   ### Component Inventory
   - Table: `| Widget | Description | Props | State? |`
   - Flag any component that should be extracted as reusable.

   ### Design Tokens
   - Colors (reference theme tokens, not hex literals).
   - Typography (style names from the theme).
   - Spacing (multiples of 4/8).
   - Border radii, elevations, shadows.

   ### States
   - List every UI state: `idle | loading | empty | error | success | disabled`.
   - Describe what changes visually per state.

   ### Data Contract
   - Props the screen receives (constructor params / route args).
   - Data it fetches (API endpoint or provider).
   - Data it emits (callbacks, events).

   ### Interactions
   - Every tappable element → what happens on tap.
   - Gestures (swipe, long-press, drag).
   - Keyboard / focus order.

   ### Accessibility Notes
   - Semantic labels for non-text elements.
   - Minimum touch target sizes (48x48 dp).
   - Contrast requirements.

   ### RTL Considerations
   - Any directional icons or padding that must flip.
   - Text alignment rules.

3. **Output the spec** as a Markdown file at `ui_specs/<screen_name>.md`.

4. **Print a summary** to the user: screen name, component count, and identified risk areas.

## Example

```
/ui-spec "Profile screen with avatar, name, email, stats row (followers, following, posts), edit button, and a scrollable list of recent activity"
```

## Tags
`design`, `specification`, `architecture`, `planning`
