# MGRS-HEN Design System (Retro Terminal)

## 1. Atmosphere & Identity

MGRS-HEN is a retro diagnostic terminal inspired by classic CRT phosphor monitors and modern floating window chrome: black-green CRT contrast, a compact framed console, and explicit state language. Its signature features include traffic-light status markers, a static CSS scanline texture, stacked boot sequence lines, a blocky ASCII logo, and a dominant state line followed by technical diagnostic evidence. The reference terminal's atmosphere is translated into pure CSS without remote fonts or runtime canvas so the PS4 host stays offline-safe and the exploit runtime remains completely isolated.

## 2. Color Tokens

The interface uses a dedicated phosphor green CRT dark palette.

| Role | Token | Value | Usage |
|---|---|---:|---|
| Primary accent | `--color-primary` | `#00ff66` | Active text, prompt, ASCII banner, highlight |
| Secondary accent | `--color-secondary` | `#00b347` | Boot logs, subtitles, diagnostic labels |
| Dimmed accent | `--color-dim` | `#006626` | Scrollbars and quiet details |
| Background canvas | `--color-bg` | `#111417` | Fullscreen canvas background |
| Terminal surface | `--color-terminal-bg` | `#060907` | Deep obsidian terminal screen |
| Header surface | `--color-header-bg` | `#0b100d` | Title bar surface |
| Footer surface | `--color-footer-bg` | `#002b11` | Status footer strip |
| Log surface | `--color-log-bg` | `#040705` | Exploit chain output stream |
| Border | `--color-border` | `rgba(0, 255, 102, 0.22)` | Window and panel outlines |
| Glow | `--color-glow` | `rgba(0, 255, 102, 0.45)` | Subtle text & marker glow |
| Close dot | `--dot-close` | `#ff5f56` | Window red traffic dot |
| Minimize dot | `--dot-min` | `#ffbd2e` | Window yellow traffic dot |
| Maximize dot | `--dot-max` | `#27c93f` | Window green traffic dot |
| Status success | `--status-success` | `#00ff66` | Cached and operational states |
| Status warning | `--status-warning` | `#ffbd2e` | Waiting, caching, and active work |
| Status error | `--status-error` | `#ff5f56` | Unsupported and failure states |

## 3. Typography

| Level | Size | Weight | Line Height | Tracking | Usage |
|---|---:|---:|---:|---:|---|
| Status | `18px` | `700` | `1.45` | `0` | Primary status (`#state`) |
| ASCII Banner | `14px` | `700` | `1.15` | `0` | Blocky RETRO logo |
| Body / Boot | `13.5px` | `400` | `1.5` | `0` | Default logs & shell text |
| Diagnostic | `12.5px` | `400` | `1.45` | `0` | Firmware evidence (`#det`) |
| Cache / Note | `12px` | `400` | `1.45` | `0` | Cache status (`#cache`) |
| Log | `12.5px` | `400` | `1.45` | `0` | Exploit output (`#out`) |
| Header Title | `12px` | `700` | `1.2` | `0.1em` | Window title bar |
| Footer / Status | `11px` | `400` | `1.4` | `0` | Manual page status line |

- Primary Font: `Consolas, "Courier New", monospace`
- No remote fonts or Google Fonts are used in production runtime.

## 4. Spacing & Layout

| Token | Value | Usage |
|---|---:|---|
| `--space-1` | `4px` | Tight separation |
| `--space-2` | `8px` | Small gap / traffic lights |
| `--space-3` | `12px` | Moderate separation |
| `--space-4` | `16px` | Container padding & section spacing |
| `--space-5` | `24px` | Screen body padding |

- Terminal Frame max width: `780px` (centered floating window).
- Responsive breakpoint at `768px` and `375px` with fluid text wrapping.

## 5. Components & IDs

- `#brand`: Terminal window header (`.retro-header`) containing traffic lights and title.
- `#wrap`: Console screen container (`.retro-screen`).
- `#state`: Dominant status line (`.status-block`).
- `#det`: Technical firmware and bug explanation.
- `#cache`: Application cache state.
- `#out`: Monospace pre-wrapped stdout stream for exploit chains.
