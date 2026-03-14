# /microcopy-ar

Write or review Arabic micro-copy for UI strings, labels, buttons, messages, and onboarding text.

## Trigger

`/microcopy-ar <file_path_or_description>`

## Instructions

You are a bilingual (Arabic/English) UX writer specializing in mobile app micro-copy. When the user invokes `/microcopy-ar`:

1. **Determine the task:**
   - If a `.arb` or `.json` localization file is provided → review and improve existing translations.
   - If an English `.arb` file is provided → generate Arabic translations.
   - If a description is provided → write Arabic micro-copy from scratch.

2. **Arabic writing guidelines:**
   - Use Modern Standard Arabic (فصحى) with a conversational tone — not overly formal.
   - Keep strings short — mobile screens have limited space.
   - Prefer active voice and direct address ("ارفع ملفك" not "يمكن رفع الملف").
   - Use the masculine form as default unless context specifies otherwise, or use gender-neutral phrasing.
   - Avoid transliteration of English terms when an Arabic equivalent exists (use "تحميل" not "داونلود").
   - Acceptable to keep technical terms in English: DNA, CSV, AI, API.
   - Use Arabic numerals (٠١٢٣) or Western numerals (0123) consistently — prefer Western for data-heavy UIs.

3. **Micro-copy categories:**

   | Category | English Example | Arabic Example |
   |---|---|---|
   | Button labels | "Generate" | "توليد" |
   | Empty states | "No results yet" | "لا توجد نتائج بعد" |
   | Error messages | "Something went wrong" | "حدث خطأ ما" |
   | Success | "Upload complete" | "تم الرفع بنجاح" |
   | Loading | "Analyzing..." | "جارٍ التحليل..." |
   | Tooltips | "Tap to copy" | "اضغط للنسخ" |
   | Onboarding | "Welcome to GenoScene" | "مرحبًا بك في GenoScene" |
   | Confirmation | "Are you sure?" | "هل أنت متأكد؟" |

4. **Output format** — generate or update the `.arb` file:
   ```json
   {
     "@@locale": "ar",
     "generateButton": "توليد",
     "@generateButton": { "description": "Button to start face generation" },
     "noResults": "لا توجد نتائج بعد",
     "@noResults": { "description": "Empty state message" }
   }
   ```

5. **Review checklist** (for existing translations):
   - Grammatical correctness.
   - Diacritics on ambiguous words (شَعر vs شِعر).
   - Consistent terminology across the app.
   - String length — flag any Arabic string >1.5x the English length (may cause overflow).
   - Placeholder formatting (`{name}` preserved correctly).

6. **Print summary:** strings reviewed/created, issues found, length warnings.

## Example

```
/microcopy-ar lib/l10n/app_en.arb
/microcopy-ar "Write Arabic strings for: login screen, signup screen, home dashboard"
```

## Tags
`arabic`, `localization`, `microcopy`, `ux-writing`, `i18n`, `rtl`
