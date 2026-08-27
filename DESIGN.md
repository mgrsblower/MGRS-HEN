# MGRS-HEN Design System

## 1. Atmosphere & Identity

MGRS-HEN is a restrained diagnostic console: dark, compact, and explicit about state. Its signature is a small `MH` monogram beside a high-tracking wordmark, followed by one dominant status line and terse technical evidence. The system preserves the inspected RAW GAME layout grammar while removing third-party branding and imagery.

## 2. Color

The interface has one dark theme, extracted from the rendered reference at `https://raw-game.com/zrm/` on 2026-08-28.

| Role | Token | Value | Usage |
|---|---|---:|---|
| Surface/root | `--surface-root` | `#0b0d10` | Page background |
| Surface/header | `--surface-header` | `#0e1116` | Brand bar |
| Surface/log | `--surface-log` | `#11151b` | Chain output panel |
| Text/primary | `--text-primary` | `#c8ced8` | Body and primary labels |
| Text/secondary | `--text-secondary` | `#8b95a3` | Firmware detail |
| Text/tertiary | `--text-tertiary` | `#5c6672` | Cache progress |
| Border/default | `--border-default` | `#1e2732` | Header and log outline |
| Border/mark | `--border-mark` | `#3b4a5d` | Monogram outline |
| Status/success | `--status-success` | `#7fd0a0` | Success and cached states |
| Status/warning | `--status-warning` | `#d8c07f` | Waiting and active work |
| Status/error | `--status-error` | `#d08a7f` | Unsupported and failure states |

Only these tokens may supply interface colors. Status colors carry meaning and are not decorative accents.

## 3. Typography

| Level | Size | Weight | Line Height | Tracking | Usage |
|---|---:|---:|---:|---:|---|
| Status | `22px` | `700` | `1.45` | `0` | Current state |
| Body | `15px` | `400` | `1.45` | `0` | Default shell text |
| Brand | `15px` | `700` | `1.45` | `0.14em` | MGRS-HEN wordmark |
| Detail | `13px` | `400` | `1.45` | `0` | Firmware explanation |
| Caption | `12px` | `400` | `1.45` | `0` | Cache status |
| Log | `12px` | `400` | `1.45` | `0` | Exploit-chain output |
| Monogram | `10px` | `700` | `28px` | `0` | MH mark |

- Primary: `"Segoe UI", system-ui, sans-serif`.
- Mono: `Consolas, monospace`.
- No remote fonts are allowed.

## 4. Spacing & Layout

The working base unit is `4px`, with three reference-fidelity exceptions: `6px`, `10px`, and `18px` are retained because they are observable values in the supplied live reference.

| Token | Value | Usage |
|---|---:|---|
| `--space-1` | `4px` | Tight status separation |
| `--space-reference-6` | `6px` | Status-to-detail margin |
| `--space-2` | `8px` | Brand vertical padding |
| `--space-reference-10` | `10px` | Header horizontal and cache bottom spacing |
| `--space-4` | `16px` | Content vertical padding |
| `--space-reference-18` | `18px` | Content horizontal padding |

- Content fills the viewport; there is no artificial maximum width.
- The header spans the viewport and the content uses a single vertical stack.
- At 375px, 768px, and 1280px the hierarchy and spacing remain unchanged.
- Chain output owns vertical scrolling inside `#out`; the root page remains document-scrolled.

## 5. Components

### Brand Bar

- **Structure:** `#brand > .mark + strong`.
- **Variants:** one MGRS-HEN variant.
- **Spacing:** `--space-2` vertically and `--space-reference-10` horizontally.
- **States:** static; no hover, focus, active, or disabled behavior.
- **Accessibility:** the decorative `MH` mark is hidden from assistive technology; the text wordmark remains readable.
- **Motion:** none.
- **Layout:** centered inline cluster.

### Status Stack

- **Structure:** `#state`, optional `#det`, and optional `#cache` inside `#wrap`.
- **Variants:** success, warning, error, and neutral.
- **States:** class-driven `.ok`, `.warn`, `.bad`; cache success uses `.cacheok`.
- **Accessibility:** status meaning is repeated in text, never conveyed by color alone.
- **Motion:** none; state text changes immediately.
- **Layout:** single vertical stack that reflows naturally.

### Chain Log

- **Structure:** `#out` below `#state`.
- **Variants:** Lapse and Poops share the same visual primitive.
- **States:** neutral log lines plus success, warning, and error spans.
- **Accessibility:** pre-wrapped text, selectable content, status words in every colored line.
- **Motion:** none; scrolling follows appended output.
- **Layout:** bordered scroll region sized to the viewport.

## 6. Motion & Interaction

The reference has no decorative motion and MGRS-HEN adds none. Cache completion may wait for a click or keypress because PS4 WebKit requires a user gesture; the status line must explain that action. State changes are instantaneous. `prefers-reduced-motion` therefore needs no override.

## 7. Depth & Surface

Strategy: **borders-only with tonal shifts**.

| Treatment | Value | Usage |
|---|---|---|
| Header divider | `1px solid var(--border-default)` | Separates brand bar |
| Log outline | `1px solid var(--border-default)` | Defines scroll region |
| Monogram outline | `1px solid var(--border-mark)` | Distinguishes the CSS mark |
| Radius | `5px` | Log panel only |

No shadows, gradients, blur, or ornamental effects are allowed.

## 8. Accessibility Constraints & Accepted Debt

### Constraints

- Target WCAG 2.2 AA for the static shell.
- Keep status wording explicit so color is supplementary.
- Preserve natural wrapping with no fixed horizontal dimensions.
- Maintain keyboard activation for the existing cache continuation handler.
- Do not introduce flashing, auto-playing motion, or remote fonts.

### Accepted Debt

| Item | Location | Why accepted | Owner / Exit |
|---|---|---|---|
| Browser-level status is not announced through an ARIA live region | `src/*.html` | The target PS4 WebKit is old and the inspected reference uses plain text status nodes; changing semantics may be evaluated after device compatibility testing | Project owner after physical PS4 QA |
| Full exploit-state visual QA cannot run on desktop Chrome | `run_lapse.html`, `run_poops.html` | The chain requires PS4-specific WebKit and kernel behavior | Project owner validates on owned PS4 hardware |
