$ErrorActionPreference = 'Stop'

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$sourceRoot = Join-Path $repoRoot 'src'

$requiredFiles = @(
    'vercel.json'
    'checksums.sha256'
    'src/cache.appcache'
)

foreach ($relativePath in $requiredFiles) {
    $absolutePath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        throw "Missing deployment artifact: $relativePath"
    }
}

$pinnedHashes = [ordered]@{
    'src/chain_lapse.js' = 'fd0cc044e03be88d1c89089a7d8dbb2d2c9ea2f3a485f0ab9089bb36d92d1a34'
    'src/chain_poops.js' = 'c41d147644d97656ba2f6c85ba1b61f3c8315e16c2367772035d56d2336babdd'
    'src/core.js' = '3acf7e09988f10f800ca22bac1d4965b89ebb5ce2da4850089918fd1a457df4e'
    'src/mem.js' = '4a1b688e8061372bc8400e911c8e191b7e19e4b6286dcdeb3eef4971c5168a22'
    'src/int64.js' = 'a79a3334a3f2c75b9a238ab1093796e326251c97ac5d02663eae5b14bf80f652'
    'src/ps4_offsets.js' = '1edbbc68e5b37de8d18755c9250736c0db9524bccda87f226f738c4f0daa8fcb'
    'src/rpc_worker.js' = '483925eafec03037596a71b95f046ba0ed1ab9018300ffd5ff718e2ce8c181dd'
    'src/payload.bin' = 'c6329401d1810e16c84e6474ac30977dbdc951987c10cdb559370de7d59db0b0'
    'src/patches/1100.bin' = '15497a2b748dafd49bfb89c51ed048d0c5ba3c5092c5254da46dd4443f80983b'
    'src/patches/1150.bin' = 'd4e3a514e462b973842e634eba6c90136dbfd864a208f8c39c229055e5f2e1f9'
    'src/patches/1200.bin' = '87f1d40aea8fbf3adee7b8b5599d90c9d868436c15a498f2dce6bf5d96ae4d27'
    'src/patches/1250.bin' = '5baaf0bb2663064db1eb1bfd976bc3aa5087ab7f0963648cb6fcb216adce714d'
    'src/patches/1300.bin' = 'be70930d96c40b8d7ba03a57e2ea5c834b606fb74ed118756b4dea7fffaa1d57'
}

foreach ($entry in $pinnedHashes.GetEnumerator()) {
    $absolutePath = Join-Path $repoRoot $entry.Key
    $actualHash = (Get-FileHash -LiteralPath $absolutePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne $entry.Value) {
        throw "Pinned runtime mismatch: $($entry.Key)"
    }
}

$allowedFirmware = @('11.00', '11.50', '12.00', '12.02', '12.50', '12.52', '13.00')
$offsetText = Get-Content -LiteralPath (Join-Path $sourceRoot 'ps4_offsets.js') -Raw
$baseKeys = [regex]::Matches($offsetText, '(?m)^\s*"(\d+\.\d+)"\s*:\s*\{') |
    ForEach-Object { $_.Groups[1].Value }
$aliasKeys = [regex]::Matches($offsetText, 'PS4\["(\d+\.\d+)"\]\s*=') |
    ForEach-Object { $_.Groups[1].Value }
$actualFirmware = @($baseKeys + $aliasKeys | Sort-Object -Unique)

if (($actualFirmware -join ',') -ne (($allowedFirmware | Sort-Object) -join ',')) {
    throw "Unexpected firmware table: $($actualFirmware -join ', ')"
}

foreach ($page in @('index.html', 'run_lapse.html', 'run_poops.html')) {
    $html = Get-Content -LiteralPath (Join-Path $sourceRoot $page) -Raw
    if ($html -notmatch 'MGRS-HEN') {
        throw "Missing MGRS-HEN brand in src/$page"
    }
    if ($html -match 'RAW GAME|CloudInfra|logo_raw\.png') {
        throw "Unexpected upstream brand in src/$page"
    }
}

$ledgerPath = Join-Path $repoRoot 'checksums.sha256'
$ledgerLines = Get-Content -LiteralPath $ledgerPath
$ledgerCount = 0
foreach ($line in $ledgerLines) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    if ($line -notmatch '^([0-9a-f]{64})  (.+)$') {
        throw "Malformed checksum line: $line"
    }

    $expectedHash = $Matches[1]
    $relativePath = $Matches[2].Replace('/', [IO.Path]::DirectorySeparatorChar)
    $absolutePath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        throw "Checksum target missing: $relativePath"
    }

    $actualHash = (Get-FileHash -LiteralPath $absolutePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne $expectedHash) {
        throw "Checksum mismatch: $relativePath"
    }
    $ledgerCount++
}

if ($ledgerCount -lt 16) {
    throw "Checksum ledger is incomplete: $ledgerCount entries"
}

$manifestPath = Join-Path $sourceRoot 'cache.appcache'
$manifestLines = Get-Content -LiteralPath $manifestPath
if ($manifestLines[0] -ne 'CACHE MANIFEST') {
    throw 'cache.appcache is missing CACHE MANIFEST header'
}
if (-not ($manifestLines -contains 'NETWORK:') -or -not ($manifestLines -contains 'FALLBACK:')) {
    throw 'cache.appcache is missing NETWORK or FALLBACK section'
}

$inCacheSection = $true
$cacheEntries = 0
foreach ($line in $manifestLines | Select-Object -Skip 1) {
    $trimmed = $line.Trim()
    if ($trimmed -eq 'NETWORK:') {
        $inCacheSection = $false
        continue
    }
    if (-not $inCacheSection -or $trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) {
        continue
    }

    $entry = ($trimmed -split '\s+')[0]
    $filePart = ($entry -split '\?')[0]
    $absolutePath = Join-Path $sourceRoot $filePart
    if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        throw "Manifest target missing: $entry"
    }
    $cacheEntries++
}

if ($cacheEntries -lt 17) {
    throw "Application Cache manifest is incomplete: $cacheEntries entries"
}

$vercel = Get-Content -LiteralPath (Join-Path $repoRoot 'vercel.json') -Raw
if ($vercel -notmatch 'text/cache-manifest' -or $vercel -notmatch 'no-cache') {
    throw 'vercel.json does not define the Application Cache response contract'
}

Write-Output "PASS pinned=$($pinnedHashes.Count) firmware=$($actualFirmware.Count) checksums=$ledgerCount cache_entries=$cacheEntries"
