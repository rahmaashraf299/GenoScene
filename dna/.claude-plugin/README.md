# mobile-frontend-designer v1.0.0

A Claude Code plugin that turns Claude into a **code-first mobile frontend designer expert**. It ships 16 slash-command skills, 5 specialized agents, and automatic hooks for formatting, static analysis, and testing — all tuned for Flutter/Dart projects on Windows.

---

## Quick Start

1. Copy the `.claude-plugin/` folder into your Flutter project root.
2. Claude Code will auto-detect the plugin on the next session.
3. Use any skill with its slash command (e.g. `/build-screen`).

---

## Skills (16)

| Command | Purpose |
|---|---|
| `/ui-spec` | Convert a design brief or screenshot into a structured UI specification document |
| `/build-screen` | Scaffold a complete Flutter screen from a spec or description |
| `/componentize` | Extract reusable widgets from an existing screen |
| `/theme-system` | Create or extend a design-token-based ThemeData system |
| `/responsive-check` | Audit and fix responsive layout issues across breakpoints |
| `/rtl-polish` | Add or fix RTL (right-to-left) language support throughout the UI |
| `/states-pack` | Wire up all UI states: loading, empty, error, success, skeleton |
| `/form-ux` | Build production-grade forms with validation, UX patterns, and a11y |
| `/microcopy-ar` | Write or review Arabic micro-copy for UI strings and labels |
| `/navigation-setup` | Set up or refactor app navigation (GoRouter, Navigator 2.0, etc.) |
| `/motion-kit` | Add meaningful motion and animations to screens and widgets |
| `/pixel-perfect-pass` | Compare implementation to a design reference and fix deviations |
| `/a11y-audit` | Run a full accessibility audit (semantics, contrast, touch targets) |
| `/perf-smoothness` | Profile and optimize UI rendering performance (jank, rebuilds) |
| `/golden-tests` | Generate golden (snapshot) tests for visual regression |
| `/assets-pipeline` | Organize, optimize, and code-gen asset references |

### Usage Examples

```bash
# Generate a UI spec from a description
> /ui-spec "Login screen with email + password, social login buttons, forgot password link"

# Build the screen from that spec
> /build-screen login_screen --spec ui_specs/login.md

# Extract reusable widgets
> /componentize lib/screens/login_screen.dart

# Set up the theme system
> /theme-system --colors brand --typography poppins --mode dark

# Check RTL support
> /rtl-polish lib/screens/login_screen.dart

# Add all UI states
> /states-pack lib/screens/home_screen.dart --provider

# Build a form
> /form-ux "Contact form: name, email, phone, message"

# Arabic micro-copy review
> /microcopy-ar lib/l10n/app_ar.arb

# Set up navigation
> /navigation-setup --router go_router --guards auth

# Add animations
> /motion-kit lib/screens/home_screen.dart --type hero,stagger

# Pixel-perfect audit
> /pixel-perfect-pass lib/screens/profile_screen.dart --ref designs/profile.png

# Accessibility audit
> /a11y-audit lib/screens/

# Performance profiling
> /perf-smoothness lib/screens/feed_screen.dart

# Golden tests
> /golden-tests lib/widgets/custom_card.dart

# Asset pipeline
> /assets-pipeline assets/ --gen
```

---

## Agents (5)

| Agent | Role |
|---|---|
| **ui-architect** | High-level screen layout decisions, widget tree design, state management strategy |
| **component-engineer** | Reusable widget extraction, API surface design, composability patterns |
| **a11y-auditor** | Accessibility compliance — semantics, contrast, screen reader, touch targets |
| **performance** | Render performance — rebuild reduction, shader warmup, image optimization |
| **ui-qa** | Visual QA — golden tests, responsive snapshots, RTL/LTR parity checks |

---

## Hooks (Automatic)

| Event | Action |
|---|---|
| **PostToolUse** (Edit/Write) | `dart format` on changed files + `flutter analyze` on the project |
| **Stop** (session end) | `flutter test` to catch regressions before you leave |

Hooks auto-detect Flutter projects by looking for `pubspec.yaml`. If not found, they skip gracefully.

---

## Project Structure

```
.claude-plugin/
├── plugin.json                 # Plugin manifest
├── README.md                   # This file
├── skills/
│   ├── ui-spec/SKILL.md
│   ├── build-screen/SKILL.md
│   ├── componentize/SKILL.md
│   ├── theme-system/SKILL.md
│   ├── responsive-check/SKILL.md
│   ├── rtl-polish/SKILL.md
│   ├── states-pack/SKILL.md
│   ├── form-ux/SKILL.md
│   ├── microcopy-ar/SKILL.md
│   ├── navigation-setup/SKILL.md
│   ├── motion-kit/SKILL.md
│   ├── pixel-perfect-pass/SKILL.md
│   ├── a11y-audit/SKILL.md
│   ├── perf-smoothness/SKILL.md
│   ├── golden-tests/SKILL.md
│   └── assets-pipeline/SKILL.md
├── agents/
│   ├── ui-architect.md
│   ├── component-engineer.md
│   ├── a11y-auditor.md
│   ├── performance.md
│   └── ui-qa.md
└── hooks/
    ├── post-edit.sh
    └── pre-stop.sh
```

---

## Requirements

- Flutter SDK on PATH
- Dart SDK on PATH
- Windows 10/11 (bash via Git Bash or WSL)
- Claude Code CLI

---

## License

Internal tool — all rights reserved.
