# MGRS-HEN Terminal UI Redesign

## Goal

Give the existing PS4 WebKit host a complete retro-terminal visual shell inspired by `C:\Users\ogi\MGRS-HEN`, without changing firmware detection, cache handling, redirects, exploit chains, payloads, offsets, or patch files.

## Direction

Use a black-green CRT console with a centered terminal frame, macOS-style traffic-light markers, a compact MGRS-HEN wordmark, explicit status hierarchy, and a scrollable chain log. The matrix reference becomes a static CSS texture rather than a canvas or timer so the surface remains offline-safe and does not add JavaScript execution beside the exploit runtime.

## Scope

- Modify `src/index.html`, `src/run_lapse.html`, `src/run_poops.html`, and `src/theme.css` only for presentation.
- Preserve the existing IDs consumed by the detector and chain runtime: `brand`, `wrap`, `state`, `det`, `cache`, and `out`.
- Keep all runtime JavaScript and binary assets byte-identical.
- Use local system fonts only; no Google Fonts or other network requests.
- Keep the cache manifest and checksum ledger generated after the visual changes.

## Responsive behavior

The terminal frame fills the viewport with a 12px outer gutter on narrow screens and a 24px gutter on larger screens. The log owns vertical scrolling, status content wraps naturally, and no horizontal overflow is allowed at 375px, 768px, or 1280px.

## Accessibility and safety

Status text remains explicit and is never communicated by color alone. The MH mark stays decorative with `aria-hidden`. Focus and keyboard behavior in the existing cache continuation handler remain unchanged. No animation, remote font, third-party script, or exploit control flow is introduced.

## Acceptance criteria

1. Existing detector routes all supported firmware to the same chain pages as before.
2. All runtime and binary hashes remain unchanged.
3. The three pages share one token-driven terminal shell and render without horizontal overflow at the three QA widths.
4. Local HTTP serving returns every generated asset and the Vercel MIME/cache contract remains valid.
