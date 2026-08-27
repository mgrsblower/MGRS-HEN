# MGRS-HEN Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a private Vercel-ready PS4 jailbreak host that automatically selects the supported Lapse or Poops chain, keeps every runtime asset local, and works from Application Cache after the first successful load.

**Architecture:** Vendor the inspected static runtime from commit `56a5d7697234246b9739e6aaafb0c70adae66a57` of `lutfailham96/PS4-JB-WebKit`, remove its explicitly untested 11.52 alias, and brand only the HTML shell as MGRS-HEN. Serve `src/` through Vercel with a generated offline manifest and independent SHA-256 ledger; use PowerShell maintenance scripts because the delivery environment is Windows.

**Tech Stack:** Static HTML and JavaScript, PS4 WebKit Application Cache, PowerShell 7/Windows PowerShell maintenance scripts, Vercel static hosting, Git.

## Global Constraints

- Target Vercel as the primary host.
- Keep every runtime asset in the repository and make no runtime request to a third-party domain.
- Support only 11.00, 11.50, 12.00, 12.02, 12.50, 12.52, and 13.00.
- Exclude the untested 11.52 alias.
- Preserve the inspected chain, patch, and payload bytes unless a task explicitly names a shell-only branding edit.
- Do not add analytics, authentication, remote update logic, external scripts, or a documented force-exploit query parameter.
- Record desktop QA separately from physical PS4 kernel-exploit QA.

---

### Task 1: Vendored Runtime Baseline

**Files:**
- Create: `src/index.html`
- Create: `src/run_lapse.html`
- Create: `src/run_poops.html`
- Create: `src/chain_lapse.js`
- Create: `src/chain_poops.js`
- Create: `src/core.js`
- Create: `src/mem.js`
- Create: `src/int64.js`
- Create: `src/ps4_offsets.js`
- Create: `src/rpc_worker.js`
- Create: `src/payload.bin`
- Create: `src/patches/1100.bin`
- Create: `src/patches/1150.bin`
- Create: `src/patches/1200.bin`
- Create: `src/patches/1250.bin`
- Create: `src/patches/1300.bin`

**Interfaces:**
- Consumes: pinned GitHub raw URLs under commit `56a5d7697234246b9739e6aaafb0c70adae66a57`.
- Produces: a same-origin static runtime rooted at `src/index.html`.

- [x] **Step 1: Prove the runtime is absent**

Run:

```powershell
$required = 'src/index.html','src/chain_lapse.js','src/chain_poops.js','src/payload.bin','src/patches/1300.bin'
$missing = $required | Where-Object { -not (Test-Path -LiteralPath $_) }
if ($missing.Count -ne $required.Count) { throw 'Runtime unexpectedly exists before acquisition' }
```

Expected: exit 0 with every required path absent.

- [x] **Step 2: Acquire the pinned runtime**

Download only the files listed above from:

```text
https://raw.githubusercontent.com/lutfailham96/PS4-JB-WebKit/56a5d7697234246b9739e6aaafb0c70adae66a57/src/<path>
```

Use `Invoke-WebRequest -UseBasicParsing -OutFile` for binary-safe acquisition. Do not download `src/core.js?v=10`, `favicon.ico`, or the upstream logo because the query-named duplicate is unnecessary and MGRS-HEN will use a CSS monogram.

- [x] **Step 3: Remove only the experimental 11.52 alias**

Apply a targeted textual patch that removes the `PS4["11.52"] = Object.assign(...)` block and its adjacent `// Hack` comment from `src/ps4_offsets.js`. Do not change any other offset or status string.

- [x] **Step 4: Verify the security-sensitive bytes**

Run `Get-FileHash -Algorithm SHA256` and require these hashes:

```text
chain_lapse.js  fd0cc044e03be88d1c89089a7d8dbb2d2c9ea2f3a485f0ab9089bb36d92d1a34
chain_poops.js  c41d147644d97656ba2f6c85ba1b61f3c8315e16c2367772035d56d2336babdd
core.js         3acf7e09988f10f800ca22bac1d4965b89ebb5ce2da4850089918fd1a457df4e
mem.js          4a1b688e8061372bc8400e911c8e191b7e19e4b6286dcdeb3eef4971c5168a22
int64.js        a79a3334a3f2c75b9a238ab1093796e326251c97ac5d02663eae5b14bf80f652
rpc_worker.js   483925eafec03037596a71b95f046ba0ed1ab9018300ffd5ff718e2ce8c181dd
payload.bin     c6329401d1810e16c84e6474ac30977dbdc951987c10cdb559370de7d59db0b0
1100.bin        15497a2b748dafd49bfb89c51ed048d0c5ba3c5092c5254da46dd4443f80983b
1150.bin        d4e3a514e462b973842e634eba6c90136dbfd864a208f8c39c229055e5f2e1f9
1200.bin        87f1d40aea8fbf3adee7b8b5599d90c9d868436c15a498f2dce6bf5d96ae4d27
1250.bin        5baaf0bb2663064db1eb1bfd976bc3aa5087ab7f0963648cb6fcb216adce714d
1300.bin        be70930d96c40b8d7ba03a57e2ea5c834b606fb74ed118756b4dea7fffaa1d57
```

Expected: every comparison is true.

- [x] **Step 5: Commit the vendored baseline**

```bash
git add src
git commit -m "Vendor verified PS4 exploit runtime"
```

---

### Task 2: MGRS-HEN Shell, Offline Manifest, and Vercel Contract

**Files:**
- Modify: `src/index.html`
- Modify: `src/run_lapse.html`
- Modify: `src/run_poops.html`
- Create: `tools/update-integrity.ps1`
- Create: `tools/verify-project.ps1`
- Create: `src/cache.appcache`
- Create: `checksums.sha256`
- Create: `vercel.json`
- Create: `.gitattributes`
- Create: `.gitignore`

**Interfaces:**
- Consumes: the complete runtime from Task 1.
- Produces: `tools/update-integrity.ps1` for deterministic manifest/ledger generation and `tools/verify-project.ps1` for a zero-exit validation gate.

- [x] **Step 1: Write the failing project verifier**

Create `tools/verify-project.ps1` so it fails when `vercel.json`, `src/cache.appcache`, or `checksums.sha256` is missing; parses every non-section cache entry; asserts the corresponding file exists; recomputes `checksums.sha256`; asserts `ps4_offsets.js` has the seven allowed keys and no `11.52`; and asserts all three HTML pages say `MGRS-HEN` without `RAW GAME` or `CloudInfra`.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/verify-project.ps1
```

Expected: non-zero exit naming the first missing deployment artifact.

- [x] **Step 2: Brand the three HTML shells**

Replace the upstream brand image and label with a CSS-only `MH` monogram plus the text `MGRS-HEN`. Preserve the firmware detector, cache state machine, module imports, and chain routing exactly.

- [x] **Step 3: Implement deterministic integrity generation**

Create `tools/update-integrity.ps1` with no network calls. It must enumerate the explicit runtime list, compute lowercase SHA-256, write `checksums.sha256` in `<hash>  <relative-path>` format, derive a build identifier from the ordered ledger, and write `src/cache.appcache` with `CACHE MANIFEST`, the build line, explicit entries, `NETWORK: *`, and the three same-file fallback rules.

- [x] **Step 4: Add the Vercel static contract**

Create `vercel.json` with a `/src/$1` rewrite, a root route to `/src/index.html`, `Content-Type: text/cache-manifest` plus `Cache-Control: no-cache` for `/cache.appcache`, and immutable caching for fingerprint-controlled JS and binary assets. Add `.gitattributes` to keep binaries binary and text files normalized to LF. Add `.gitignore` for `.vercel/`, temporary logs, and editor files.

- [x] **Step 5: Generate artifacts and turn the verifier green**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/update-integrity.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/verify-project.ps1
```

Expected: generation exits 0; verification reports every required asset and checksum valid with exit 0.

- [x] **Step 6: Commit the deployable shell**

```bash
git add .gitattributes .gitignore checksums.sha256 src tools vercel.json
git commit -m "Add MGRS-HEN offline Vercel host"
```

---

### Task 3: Documentation and Observable QA

**Files:**
- Create: `README.md`
- Modify: `docs/superpowers/plans/2026-08-28-mgrs-hen-implementation.md`

**Interfaces:**
- Consumes: the deployable repository and verification commands from Tasks 1-2.
- Produces: operator instructions and an evidence-backed final repository state.

- [x] **Step 1: Write operator documentation**

Document direct Vercel import, optional GitHub push, local preview, integrity regeneration, firmware table, first-load/offline behavior, payload provenance hash, kernel-panic risk, and the boundary between desktop validation and physical-PS4 validation. Do not document `?bug=` forcing.

- [x] **Step 2: Run the static verification gate**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/update-integrity.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/verify-project.ps1
git diff --exit-code -- checksums.sha256 src/cache.appcache
```

Expected: all commands exit 0 and regeneration produces no diff.

- [x] **Step 3: Run the local HTTP Manual QA Gate**

Start a local static server rooted at `src/`, request `/`, both run pages, all seven JavaScript files, all five patch blobs, `payload.bin`, and `cache.appcache`, and assert HTTP 200 plus expected byte lengths. Fetch `/` using representative PS4 user-agent strings for 11.00, 12.02, 12.50, 12.52, and 13.00 to prove the shell is deliverable; record that browser-side routing itself requires a PS4 WebKit runtime.

- [x] **Step 4: Inspect the final repository**

```bash
git diff --check
git status --short
git log --oneline --decorate -5
```

Expected: no whitespace errors; only the README and checked plan remain before the final documentation commit.

- [x] **Step 5: Commit documentation and checked plan**

```bash
git add README.md docs/superpowers/plans/2026-08-28-mgrs-hen-implementation.md
git commit -m "Document MGRS-HEN deployment and verification"
```

- [x] **Step 6: Re-run the final gate after the last commit**

Run the verifier, local HTTP QA, `git diff --check`, and `git status --short` again. Expected: all validation exits 0 and the worktree is clean. Physical PS4 exploitation remains explicitly unverified until the user tests the deployed URL on owned hardware.
