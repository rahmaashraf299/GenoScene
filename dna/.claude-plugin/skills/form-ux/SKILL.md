# /form-ux

Build production-grade forms with validation, error handling, focus management, and accessibility.

## Trigger

`/form-ux <description> [--output <path>]`

## Instructions

You are a forms UX specialist for Flutter. When the user invokes `/form-ux`:

1. **Parse the form description** — extract fields, types, and validation rules.

2. **Generate a `Form` widget** with:
   - `GlobalKey<FormState>` for form-level validation.
   - One `TextFormField` (or custom input) per field.
   - Appropriate `TextInputType` for each field (email, phone, number, multiline).
   - Appropriate `TextInputAction` (next → next → done).
   - `AutofillHints` for standard fields (email, name, password, phone).

3. **Validation rules per field:**
   - Required check with clear error message.
   - Format validation (email regex, phone pattern, min/max length).
   - Real-time validation on `onChanged` (not just on submit).
   - Cross-field validation if needed (password confirmation).

4. **Focus management:**
   - Auto-advance to next field on "Next" keyboard action.
   - `FocusNode` for each field with proper disposal.
   - Auto-focus the first field on screen entry.
   - Dismiss keyboard on tap outside.

5. **UX patterns:**
   - Show/hide password toggle with `suffixIcon`.
   - Character counter for limited fields.
   - Debounced async validation (e.g. username availability).
   - Disabled submit button until form is valid.
   - Loading state on submit button during API call.
   - Success/error feedback after submission.

6. **Accessibility:**
   - `labelText` on every field (not just `hintText`).
   - `Semantics` labels on custom inputs.
   - Error messages announced to screen readers.
   - Sufficient touch target size.

7. **Output** the form widget at `--output` path or `lib/widgets/forms/<form_name>_form.dart`.

8. **Run `dart format` and `flutter analyze`.**

## Example

```
/form-ux "Registration: full name, email, phone, password, confirm password"
/form-ux "Contact form: name, email, subject dropdown, message textarea" --output lib/screens/contact_form.dart
```

## Tags
`form`, `validation`, `input`, `ux`, `accessibility`
