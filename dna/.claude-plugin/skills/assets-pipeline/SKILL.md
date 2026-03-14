# /assets-pipeline

Organize, optimize, and code-generate type-safe asset references for images, icons, fonts, and data files.

## Trigger

`/assets-pipeline <assets_directory> [--gen] [--optimize]`

## Instructions

You are a Flutter asset management specialist. When the user invokes `/assets-pipeline`:

1. **Scan the assets directory** and catalog all files by type:
   - Images: `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif`, `.svg`
   - Icons: `.svg` icon files
   - Fonts: `.ttf`, `.otf`
   - Data: `.json`, `.csv`, `.xml`
   - Lottie: `.json` (animation files)

2. **Audit asset organization:**

   ```
   assets/
   ├── images/           # Raster images
   │   ├── 1.5x/         # Resolution variants
   │   ├── 2.0x/
   │   ├── 3.0x/
   │   └── *.png
   ├── icons/            # SVG icons
   ├── fonts/            # Custom fonts
   ├── data/             # JSON, CSV data files
   └── animations/       # Lottie files
   ```

   - Flag misplaced files (images in root, missing resolution variants).
   - Flag oversized images (>500KB for mobile).
   - Flag unused assets (not referenced in any `.dart` file).

3. **If `--optimize`:**
   - Report images that should be compressed (suggest tools: `pngquant`, `jpegoptim`).
   - Flag PNGs that could be WebP for smaller size.
   - Flag SVGs that could be simplified.
   - Report missing resolution variants (1.5x, 2.0x, 3.0x).

4. **If `--gen`**, generate a type-safe asset class at `lib/gen/assets.gen.dart`:

   ```dart
   /// Auto-generated asset references. Do not edit manually.
   abstract class AppAssets {
     // Images
     static const String logo = 'assets/images/genoscene_logo.png';
     static const String learn = 'assets/images/learn.png';
     static const String home = 'assets/images/home.png';

     // Data
     static const String dnaFacts = 'assets/data/dna_facts.json';
     static const String privacyPolicy = 'assets/data/privacy_policy.json';
   }
   ```

5. **Update `pubspec.yaml`** — ensure all asset paths are declared under `flutter.assets`.

6. **Migrate hard-coded paths** — find all `'assets/...'` string literals in `lib/` and replace with `AppAssets.*` references.

7. **Print summary:**
   - Total assets found (by type).
   - Unused assets.
   - Missing resolution variants.
   - Optimization opportunities.
   - Generated class path.

## Example

```
/assets-pipeline assets/ --gen --optimize
/assets-pipeline assets/ --gen
/assets-pipeline assets/images/ --optimize
```

## Tags
`assets`, `images`, `codegen`, `optimization`, `pubspec`
