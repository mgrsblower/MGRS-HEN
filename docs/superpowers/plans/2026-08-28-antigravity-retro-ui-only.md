# MGRS-HEN Retro UI-Only Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Copy the verified MGRS-HEN runtime into the Antigravity project at `C:\Users\ogi\MGRS-HEN`, then rebuild its presentation using the existing local Retro Terminal project files as the style source while keeping firmware detection, cache behavior, redirects, exploit chains, payloads, offsets, and patch selection exactly unchanged.

**Architecture:** `C:\Users\ogi\MGRS-HEN` is the Antigravity working directory. First copy the repository files from `C:\Users\ogi\Documents\Codex\2026-08-28\ht\outputs\MGRS-HEN` into that project without deleting its root `index.html`, `style.css`, or `app.js`; those three existing files are the local style reference and must remain read-only. The runtime lives in the copied `src/` tree. Treat it as a sealed black box: replace only the DOM shell and CSS around its live nodes, preserving detector and chain entry scripts byte-for-byte.

**Tech Stack:** Static HTML, vanilla CSS, existing vanilla JavaScript runtime, Application Cache, Vercel static hosting. No framework, bundler, package install, remote font, or third-party asset.

## Global Constraints

- **Antigravity working directory:** `C:\Users\ogi\MGRS-HEN`.
- **Local style reference (read-only):** `C:\Users\ogi\MGRS-HEN\index.html`, `C:\Users\ogi\MGRS-HEN\style.css`, and `C:\Users\ogi\MGRS-HEN\app.js`. Read these files directly; do not use or request a screenshot.
- **Copied runtime source:** `C:\Users\ogi\MGRS-HEN\src\` from the verified repo at `C:\Users\ogi\Documents\Codex\2026-08-28\ht\outputs\MGRS-HEN\src\`.
- **Allowed presentation files after the copy:** `C:\Users\ogi\MGRS-HEN\src\index.html`, `C:\Users\ogi\MGRS-HEN\src\run_lapse.html`, `C:\Users\ogi\MGRS-HEN\src\run_poops.html`, `C:\Users\ogi\MGRS-HEN\src\theme.css`, and `C:\Users\ogi\MGRS-HEN\DESIGN.md`.
- **Generated files allowed after UI edits:** `src/cache.appcache` and `checksums.sha256`, regenerated only with `tools/update-integrity.ps1`.
- **Forbidden runtime files inside the Antigravity project:** `src/chain_lapse.js`, `src/chain_poops.js`, `src/core.js`, `src/mem.js`, `src/int64.js`, `src/ps4_offsets.js`, `src/rpc_worker.js`, `src/payload.bin`, and every file under `src/patches/`.
- Do not alter firmware numbers, offset tables, chain selection, cache events, redirect destinations, query forwarding, payload loading, or POST/worker behavior.
- Preserve these live IDs exactly: `brand`, `wrap`, `state`, `det`, `cache`, and `out`.
- Preserve the contents of the existing inline detector script in `src/index.html` byte-for-byte. Only move the surrounding markup if needed, and do not rename the IDs it queries.
- Preserve the chain entry tags exactly: `import "./chain_lapse.js";` and `import "./chain_poops.js";`.
- No Google Fonts, CDN assets, images, canvas, matrix timers, `setInterval`, `fetch`, `XMLHttpRequest`, WebSocket, analytics, or new runtime JavaScript.
- No emoji in new markup. The reference’s palette and terminal feel must be expressed with CSS and semantic DOM.
- Keep status wording explicit; color is supplementary. Keep keyboard/tap activation for cache continuation unchanged.

## Reference mapping

Implement the local reference project’s visual grammar, not its unrelated CLI behavior:

- Full-viewport near-black background with a subtle green matrix-like texture made from static CSS only.
- Centered floating terminal window, approximately 780px wide on desktop, with a thin green border, small radius, and restrained green glow.
- Header with red/yellow/green traffic-light dots on the left and `RETRO TERMINAL` on the right.
- Monospace terminal typography, bright green primary text, dim green secondary text, and a darker green footer strip.
- Stacked boot/status lines, a large MGRS-HEN ASCII/wordmark treatment, a clear firmware/cache status area, and a bottom prompt-like status row.
- On chain pages, keep the scrollable exploit output inside the terminal body and visually label it as chain output; do not change what the chain writes to `#out`.
- At 375px, collapse the frame to safe margins, allow natural wrapping, and keep all text readable without horizontal overflow.

## Task 1: Copy the repo into the Antigravity project and lock runtime baseline

**Files:**
- Copy: `C:\Users\ogi\Documents\Codex\2026-08-28\ht\outputs\MGRS-HEN\` into `C:\Users\ogi\MGRS-HEN\`, excluding `.git/`, and preserve the root reference files `index.html`, `style.css`, and `app.js`.
- Read: `C:\Users\ogi\MGRS-HEN\index.html`, `C:\Users\ogi\MGRS-HEN\style.css`, `C:\Users\ogi\MGRS-HEN\app.js` as the visual source of truth.
- Read: `C:\Users\ogi\MGRS-HEN\src\index.html`, `C:\Users\ogi\MGRS-HEN\src\run_lapse.html`, `C:\Users\ogi\MGRS-HEN\src\run_poops.html`
- Read: all forbidden runtime files listed above
- Create: temporary baseline ledger outside the project, e.g. `C:\Users\ogi\Documents\Codex\2026-08-28\ht\work\mgrs-hen-antigravity-baseline\runtime-sha256.txt`

- [ ] **Step 1: Copy the verified repo into the Antigravity workspace**

From PowerShell, run from a directory outside either project:

```powershell
$source = 'C:\Users\ogi\Documents\Codex\2026-08-28\ht\outputs\MGRS-HEN'
$target = 'C:\Users\ogi\MGRS-HEN'
robocopy $source $target /E /XD .git /XF index.html style.css app.js
if ($LASTEXITCODE -gt 7) { exit $LASTEXITCODE }
```

This copies the verified runtime and repo configuration into the Antigravity project while leaving its three root style-reference files untouched. The agent must work on the copied `src/` tree, not on the output checkout.

- [ ] **Step 2: Record baseline runtime hashes**

Run from the repository root:

```powershell
$files = @(
  'src/chain_lapse.js','src/chain_poops.js','src/core.js','src/mem.js',
  'src/int64.js','src/ps4_offsets.js','src/rpc_worker.js','src/payload.bin',
  'src/patches/1100.bin','src/patches/1150.bin','src/patches/1200.bin',
  'src/patches/1250.bin','src/patches/1300.bin'
)
Get-FileHash -Algorithm SHA256 $files | Sort-Object Path | Format-Table -AutoSize
```

Save the output outside the repository. These hashes must be identical after the redesign.

- [ ] **Step 3: Snapshot the detector script and chain tags**

Copy only the inline `<script>` body from `src/index.html` and the two module import lines to the same temporary baseline folder. Do not format, minify, or normalize them.

## Task 2: Build the visual shell without changing workflow

**Files:**
- Modify: `src/index.html`
- Modify: `src/run_lapse.html`
- Modify: `src/run_poops.html`
- Modify: `src/theme.css`
- Modify: `DESIGN.md`

- [ ] **Step 1: Replace only the surrounding DOM shell**

Use a shared structure in all three pages:

```html
<body>
  <div class="crt-texture" aria-hidden="true"></div>
  <main class="retro-terminal">
    <header id="brand" class="retro-header">…</header>
    <div id="wrap" class="retro-screen">…existing live nodes…</div>
    <footer class="retro-footer">…</footer>
  </main>
</body>
```

The detector page must retain `#state`, `#det`, and `#cache`. Chain pages must retain `#state` and `#out`. Any decorative labels must be static and must not impersonate exploit output.

- [ ] **Step 2: Make the local reference shell token-driven**

Declare all colors, typography, spacing, borders, radii, and responsive gutters in `src/theme.css` and document them in `DESIGN.md`. Use local `Consolas, "Courier New", monospace` fallbacks; do not import fonts. Use only transform/opacity-free static decoration; no animation is required for this UI-only pass.

- [ ] **Step 3: Remove all accidental workflow changes**

Compare the inline detector script and module import lines against Task 1 snapshots. If any character differs, restore the original runtime text and keep the visual change in markup/CSS only.

## Task 3: Verify UI-only scope and deployment artifacts

**Files:**
- Modify: `src/cache.appcache`
- Modify: `checksums.sha256`
- Read: `tools/update-integrity.ps1`, `tools/verify-project.ps1`

- [ ] **Step 1: Regenerate deterministic ledgers**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/update-integrity.ps1
```

Do not hand-edit either generated file.

- [ ] **Step 2: Run the project verifier and syntax checks**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/verify-project.ps1
node --check src/chain_lapse.js
node --check src/chain_poops.js
node --check src/core.js
node --check src/mem.js
node --check src/int64.js
node --check src/ps4_offsets.js
node --check src/rpc_worker.js
```

Expected: verifier reports `PASS pinned=13 firmware=7`, and every `node --check` exits 0.

- [ ] **Step 3: Prove forbidden files are unchanged**

Re-run the Task 1 hash command and compare it with the baseline ledger. Also run:

```powershell
git diff -- src/chain_lapse.js src/chain_poops.js src/core.js src/mem.js src/int64.js src/ps4_offsets.js src/rpc_worker.js src/payload.bin src/patches
```

Expected: no diff output for forbidden runtime paths.

## Task 4: Browser QA against the local reference project

**Files:**
- Evidence: `C:\Users\ogi\Documents\Codex\2026-08-28\ht\work\mgrs-hen-antigravity-qa\\`

- [ ] **Step 1: Capture all pages at all required widths**

Serve `src` with `py -m http.server 8765 --directory src`. Capture `/index.html`, `/run_lapse.html`, and `/run_poops.html` at 375px, 768px, and 1280px. Compare the render against the local reference files in the project root: centered terminal, matrix atmosphere, traffic lights, terminal header/footer, readable green hierarchy, and no accidental empty full-screen shell.

- [ ] **Step 2: Exercise the real detector routes**

Using representative PS4 user agents, confirm `11.00` and `12.02` still route to `run_lapse.html`, `12.50` and `13.00` still route to `run_poops.html`, and `12.03` remains unsupported. Confirm query strings are forwarded unchanged.

- [ ] **Step 3: Check runtime console and scroll behavior**

Confirm the detector page has no console errors. On chain pages, any `POST /t` failure from Python’s static preview server is an environment limitation, not a UI regression; do not “fix” it by editing runtime code. Confirm `#out` scrolls vertically and the page has no horizontal overflow.

## Task 5: Commit only after the user reviews the screenshot

- [ ] **Step 1: Show fresh screenshots to the user**

Do not commit or push until the user confirms the visual direction is acceptable. If the visual is still too far from the reference, revise only allowed UI files and repeat Task 4.

- [ ] **Step 2: Commit the UI-only change**

Before committing, verify:

```powershell
git status --short
git diff --check
git diff --name-only
```

The changed file list may contain only the allowed presentation files and generated ledgers. Never include forbidden runtime files in the commit.

- [ ] **Step 3: Push only after explicit approval**

Push `main` only after the user approves the fresh screenshot and all verification steps pass.

## Antigravity handoff prompt

Paste this message together with the plan:

```text
Implement docs/superpowers/plans/2026-08-28-antigravity-retro-ui-only.md.

This is a UI-ONLY redesign. Treat the exploit runtime as sealed.

DO NOT MODIFY, FORMAT, MINIFY, REORDER, OR REGENERATE:
- src/chain_lapse.js
- src/chain_poops.js
- src/core.js
- src/mem.js
- src/int64.js
- src/ps4_offsets.js
- src/rpc_worker.js
- src/payload.bin
- src/patches/*
- the inline detector script in src/index.html
- the module import statements for chain_lapse.js and chain_poops.js

You MAY modify only:
- src/index.html (surrounding markup only)
- src/run_lapse.html (surrounding markup only)
- src/run_poops.html (surrounding markup only)
- src/theme.css
- DESIGN.md
- generated src/cache.appcache and checksums.sha256, but only by running tools/update-integrity.ps1

Read-only style source: C:\Users\ogi\MGRS-HEN\index.html, C:\Users\ogi\MGRS-HEN\style.css, C:\Users\ogi\MGRS-HEN\app.js

First copy the verified repo from C:\Users\ogi\Documents\Codex\2026-08-28\ht\outputs\MGRS-HEN into C:\Users\ogi\MGRS-HEN with robocopy, excluding .git and excluding the root style-reference files index.html, style.css, and app.js. Then work only in C:\Users\ogi\MGRS-HEN. Read the existing root style-reference files directly and reproduce their centered retro terminal, matrix atmosphere, traffic-light header, bright green monospace hierarchy, terminal footer, and compact proportions in the copied src/ pages. Do not use a screenshot as the design source and do not copy the reference CLI workflow. Preserve these IDs exactly: brand, wrap, state, det, cache, out. Preserve automatic firmware routing and cache behavior exactly.

Before any commit, run tools/verify-project.ps1, all node --check commands from the plan, the baseline hash comparison, and browser QA at 375/768/1280. Show fresh screenshots for review. If a forbidden file changes, stop and restore only that accidental change; do not continue with a partial runtime diff.
```
