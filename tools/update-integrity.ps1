$ErrorActionPreference = 'Stop'

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$sourceRoot = Join-Path $repoRoot 'src'
$utf8NoBom = New-Object Text.UTF8Encoding($false)

$assets = @(
    'index.html'
    'run_lapse.html'
    'run_poops.html'
    'theme.css'
    'fonts/VT323-Regular.ttf'
    'fonts/JetBrainsMono-Regular.ttf'
    'fonts/JetBrainsMono-Bold.ttf'
    'chain_lapse.js'
    'chain_poops.js'
    'core.js'
    'mem.js'
    'int64.js'
    'ps4_offsets.js'
    'rpc_worker.js'
    'payload.bin'
    'patches/1100.bin'
    'patches/1150.bin'
    'patches/1200.bin'
    'patches/1250.bin'
    'patches/1300.bin'
)

$hashes = [ordered]@{}
$ledgerLines = foreach ($asset in $assets) {
    $absolutePath = Join-Path $sourceRoot $asset
    if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        throw "Runtime asset missing: src/$asset"
    }

    $hash = (Get-FileHash -LiteralPath $absolutePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $hashes[$asset] = $hash
    "$hash  src/$asset"
}

$ledgerText = ($ledgerLines -join "`n") + "`n"
$ledgerPath = Join-Path $repoRoot 'checksums.sha256'
[IO.File]::WriteAllText($ledgerPath, $ledgerText, $utf8NoBom)

$sha256 = [Security.Cryptography.SHA256]::Create()
try {
    $ledgerBytes = $utf8NoBom.GetBytes($ledgerText)
    $buildHash = [BitConverter]::ToString($sha256.ComputeHash($ledgerBytes)).Replace('-', '').ToLowerInvariant()
}
finally {
    $sha256.Dispose()
}
$buildId = $buildHash.Substring(0, 16)

$manifestLines = @(
    'CACHE MANIFEST'
    "# build $buildId"
    ''
)
foreach ($asset in $assets) {
    $manifestLines += "$asset #$($hashes[$asset])"
}
$manifestLines += "core.js?v=10 #$($hashes['core.js'])"
$manifestLines += @(
    ''
    'NETWORK:'
    '*'
    ''
    'FALLBACK:'
    'index.html index.html'
    'run_lapse.html run_lapse.html'
    'run_poops.html run_poops.html'
)

$manifestText = ($manifestLines -join "`n") + "`n"
$manifestPath = Join-Path $sourceRoot 'cache.appcache'
[IO.File]::WriteAllText($manifestPath, $manifestText, $utf8NoBom)

Write-Output "Generated build=$buildId checksums=$($assets.Count) cache_entries=$($assets.Count + 1)"
