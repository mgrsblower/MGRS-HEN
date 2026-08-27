# MGRS-HEN Self-Host Design

## Goal

Create a private, deployment-ready Vercel repository that mirrors the verified behavior of `raw-game.com/zrm`: detect the PS4 firmware automatically, select the matching Lapse or Poops chain, cache all required assets for offline use, and load the bundled payload without runtime dependencies on third-party domains.

## Scope

- Target Vercel as the primary host.
- Keep every runtime asset in the repository.
- Support only firmware entries present in the inspected RAW GAME offset table: 11.00, 11.50, 12.00, 12.02, 12.50, 12.52, and 13.00.
- Exclude the untested 11.52 alias from the comparison repository.
- Bundle the payload and patch binaries that matched RAW GAME byte-for-byte during inspection.
- Do not add analytics, authentication, remote update logic, or external scripts.

## Architecture

The repository is a static site. `vercel.json` routes requests to `src/`, sets the Application Cache manifest content type, and applies conservative caching headers. The root page reads the PS4 user-agent and selects `run_lapse.html` for firmware through 12.02 or `run_poops.html` for firmware from 12.50 onward. Each chain checks that an exact offset block exists before proceeding.

All JavaScript, firmware patches, imagery, and `payload.bin` are served from the same origin. `cache.appcache` lists every runtime asset. A generated build identifier and file fingerprints change whenever an asset changes, causing the PS4 browser to refresh its offline cache.

## Components

- `src/index.html`: firmware detection, chain routing, and cache status.
- `src/run_lapse.html` and `src/run_poops.html`: chain entry pages.
- `src/chain_*.js`, `src/core.js`, `src/mem.js`, `src/int64.js`, and `src/rpc_worker.js`: inspected exploit runtime.
- `src/ps4_offsets.js`: exact supported firmware table without the experimental 11.52 alias.
- `src/patches/*.bin`: firmware-specific kernel patches.
- `src/payload.bin`: bundled payload whose SHA-256 matched the inspected RAW GAME and GitHub copies.
- `src/cache.appcache`: offline asset manifest.
- `checksums.sha256`: repository-level audit record for deployable assets.
- `vercel.json`: static routing, MIME, and cache policy.
- `README.md`: local preview, Vercel deployment, updating, verification, and PS4 usage notes.

## Runtime Flow

1. The PS4 loads `/` and Application Cache checks the manifest.
2. The page derives the firmware key from the PS4 browser user-agent.
3. Unsupported or missing firmware entries stop before an exploit chain runs.
4. Supported firmware selects Lapse or Poops automatically.
5. The selected chain obtains its browser memory primitive, resolves the matching offsets, executes the kernel chain, applies the matching patch blob, and loads the same-origin payload.
6. After the first successful cache fill, the static assets remain available offline until the manifest changes or browser data is cleared.

## Error Handling

- Non-PS4 user-agents show an unsupported message.
- Firmware in the 12.03-12.49 gap is rejected.
- Firmware without an exact offset table entry is rejected inside the chain.
- Missing patch or payload assets are surfaced by the existing chain output.
- A cache failure allows an explicit user gesture to continue online, matching the inspected host behavior.
- No query parameter will be documented as a supported way to force the wrong exploit chain.

## Verification

- Compare SHA-256 for the copied runtime against the inspected source set.
- Validate that every Application Cache entry resolves with HTTP 200.
- Confirm the manifest is served as `text/cache-manifest` in Vercel configuration.
- Run a local HTTP server and request the root page, both chain entry pages, JavaScript, every patch, and the payload.
- Simulate supported, unsupported, and non-PS4 user-agents against the detector logic.
- Verify repository status and checksum output are clean after generation.
- Physical kernel exploitation is outside desktop QA and must be confirmed on the owner's matching PS4 firmware.

## Delivery

The completed repository will be stored at `outputs/MGRS-HEN` on this laptop. It will contain a local Git history and be ready for the user to create a remote repository or import directly into Vercel.

## Safety and Maintenance

The deployment is intended for hardware owned or authorized by the user. The README will warn that kernel exploitation can crash the console and that updating firmware can remove exploit compatibility. Future payload or chain updates must be reviewed and followed by regeneration of both `checksums.sha256` and `cache.appcache`; silent remote updates are prohibited by design.
