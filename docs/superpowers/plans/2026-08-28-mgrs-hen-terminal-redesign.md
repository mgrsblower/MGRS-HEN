# MGRS-HEN Terminal Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the plain host shell with the approved retro-terminal reference direction while preserving the PS4 workflow and runtime bytes.

**Architecture:** Keep the existing detector and chain entry points intact. Wrap the same IDs in a shared semantic terminal frame, centralize all visual tokens in `theme.css`, and regenerate the existing integrity artifacts after the HTML/CSS change.

**Tech Stack:** Static HTML, token-driven CSS, existing vanilla JavaScript runtime, Application Cache, Vercel static hosting.

## Global Constraints

- Modify presentation only: `src/index.html`, `src/run_lapse.html`, `src/run_poops.html`, `src/theme.css`, `DESIGN.md`, and generated cache/checksum files.
- Preserve `brand`, `wrap`, `state`, `det`, `cache`, and `out` IDs.
- Do not edit exploit JavaScript, payload, offsets, or patch binaries.
- Use local fonts and no third-party network requests.
- Keep the status wording explicit and preserve keyboard/tap cache continuation.

### Task 1: Implement the shared terminal frame

**Files:**
- Modify: `src/index.html`
- Modify: `src/run_lapse.html`
- Modify: `src/run_poops.html`
- Modify: `src/theme.css`

- [x] **Step 1: Replace the three body shells with shared semantic frame markup**

Preserve the existing IDs and inline/runtime script tags. Add a decorative `.crt-texture`, a `.terminal-frame`, a `header` brand bar with MH mark and traffic-light spans, a `.terminal-kicker`, and a `.terminal-footer`. Keep `#state`, `#det`, `#cache`, and `#out` as the live content nodes.

- [x] **Step 2: Add token-driven retro terminal styles**

Use the tokens declared in `DESIGN.md`: black-green surfaces, green accent ramp, local `Consolas`/system fonts, 4px spacing base, 5px radius, static scanline texture, and responsive gutters. Style warning/error/success state classes without changing their meaning.

- [x] **Step 3: Remove page-local style duplication**

Move all repeated `#state` and `#out` presentation rules into `theme.css`; retain only runtime markup in the HTML files.

### Task 2: Regenerate and verify deployment artifacts

**Files:**
- Modify: `src/cache.appcache`
- Modify: `checksums.sha256`

- [x] **Step 1: Generate deterministic cache and checksum ledgers**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File tools/update-integrity.ps1` from the repository root and confirm a new build ID with all HTML/CSS assets present.

- [x] **Step 2: Run the project verifier and runtime byte checks**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File tools/verify-project.ps1`, `node --check` on each runtime JavaScript file, and confirm the pinned runtime hashes still pass.

### Task 3: Browser visual QA and final handoff

**Files:**
- Evidence: `work/mgrs-hen-redesign-visual-qa/`

- [x] **Step 1: Serve the static root and capture all three pages**

Run `py -m http.server 8765 --directory src`, capture `/`, `/run_lapse.html`, and `/run_poops.html` at 375px, 768px, and 1280px, and check no horizontal overflow.

- [x] **Step 2: Exercise interaction states without running exploit chains**

Block chain scripts in the browser, verify detector text, cache status, keyboard focus, and warning/error/success classes. Record console errors and responsive evidence.

- [x] **Step 3: Commit and push the redesign**

Run `git diff --check`, commit the visual changes and generated ledgers, then push `main` to `origin/main` after the final verifier is green.
