param(
    [string]$ExePath = 'D:\Program Files (x86)\Steam\steamapps\common\eFootball\eFootball\Binaries\Win64\eFootball.exe',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function HexBytes([string]$Hex) {
    [byte[]]($Hex.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object {
        [Convert]::ToByte($_, 16)
    })
}

function Find-AllPattern([byte[]]$Data, [byte[]]$Pattern) {
    $hits = New-Object System.Collections.Generic.List[long]
    $start = 0
    while ($start -le ($Data.Length - $Pattern.Length)) {
        $i = [Array]::IndexOf($Data, $Pattern[0], $start)
        if ($i -lt 0 -or $i -gt ($Data.Length - $Pattern.Length)) { break }
        $ok = $true
        for ($j = 1; $j -lt $Pattern.Length; $j++) {
            if ($Data[$i + $j] -ne $Pattern[$j]) { $ok = $false; break }
        }
        if ($ok) { $hits.Add([long]$i) }
        $start = $i + 1
    }
    return $hits.ToArray()
}

Write-Host ''
Write-Host 'NOVRAM - eFootball VRAM warning bypass' -ForegroundColor Cyan
Write-Host 'Skips only the startup TaskDialog that handles OK / Retry / Close.'
Write-Host ''

if (-not (Test-Path -LiteralPath $ExePath)) { throw "eFootball.exe not found: $ExePath" }
if (Get-Process -Name 'eFootball' -ErrorAction SilentlyContinue) { throw 'eFootball is running. Close the game before patching.' }

# Stable context immediately before TaskDialogIndirect.
$anchor = HexBytes 'B8 08 00 00 00 89 45 B8 89 74 24 38 45 33 C9 45 33 C0 48 8D 54 24 38 48 8D 4C 24 70'
# Stable logic immediately after the call+result load.
$suffix = HexBytes '83 E9 01 74 19 83 F9 03 0F 85'
# Original middle is: FF 15 <rel32> 8B 4C 24 38
# Replacement is: mov ecx,1 + NOP padding. Then existing `sub ecx,1; je ...` follows the normal OK path.
$patchedMiddle = HexBytes 'B9 01 00 00 00 90 90 90 90 90'

$data = [System.IO.File]::ReadAllBytes($ExePath)
$anchors = @(Find-AllPattern $data $anchor)
$candidates = New-Object System.Collections.Generic.List[object]

foreach ($a in $anchors) {
    $mid = $a + $anchor.Length
    $suf = $mid + 10
    if ($suf + $suffix.Length -gt $data.Length) { continue }
    $suffixOk = $true
    for ($i=0; $i -lt $suffix.Length; $i++) {
        if ($data[$suf+$i] -ne $suffix[$i]) { $suffixOk=$false; break }
    }
    if (-not $suffixOk) { continue }

    $state = 'unknown'
    if ($data[$mid] -eq 0xFF -and $data[$mid+1] -eq 0x15 -and
        $data[$mid+6] -eq 0x8B -and $data[$mid+7] -eq 0x4C -and
        $data[$mid+8] -eq 0x24 -and $data[$mid+9] -eq 0x38) {
        $state = 'original'
    } else {
        $same = $true
        for ($i=0; $i -lt 10; $i++) {
            if ($data[$mid+$i] -ne $patchedMiddle[$i]) { $same=$false; break }
        }
        if ($same) { $state='patched' }
    }
    if ($state -ne 'unknown') {
        $candidates.Add([pscustomobject]@{ Anchor=[long]$a; Patch=[long]$mid; State=$state })
    }
}

Write-Host "Matching warning call-sites: $($candidates.Count)"
if ($candidates.Count -ne 1) {
    Write-Host 'PATCH NOT APPLIED: expected exactly one matching TaskDialog call-site.' -ForegroundColor Yellow
    Write-Host 'KONAMI may have changed this function in an update. No bytes were modified.'
    exit 2
}

$c = $candidates[0]
Write-Host ("Warning call offset: 0x{0:X}" -f $c.Patch)
Write-Host "State              : $($c.State)"

if ($c.State -eq 'patched') {
    Write-Host 'Already patched.' -ForegroundColor Green
    exit 0
}

$hashBefore = (Get-FileHash -LiteralPath $ExePath -Algorithm SHA256).Hash
Write-Host "SHA-256 before     : $hashBefore"

if ($DryRun) {
    Write-Host 'Dry run OK. Nothing was changed.' -ForegroundColor Green
    exit 0
}

$backup = "$ExePath.warning-bypass.$($hashBefore.Substring(0,12)).bak"
Copy-Item -LiteralPath $ExePath -Destination $backup -Force
Write-Host "Backup             : $backup"

$fs = [System.IO.File]::Open($ExePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::Read)
try {
    [void]$fs.Seek($c.Patch, [System.IO.SeekOrigin]::Begin)
    $fs.Write($patchedMiddle, 0, $patchedMiddle.Length)
    $fs.Flush($true)
} finally {
    $fs.Dispose()
}

$verify = [System.IO.File]::ReadAllBytes($ExePath)
for ($i=0; $i -lt 10; $i++) {
    if ($verify[$c.Patch+$i] -ne $patchedMiddle[$i]) {
        throw 'Post-write verification failed. Restore the warning-bypass backup.'
    }
}
$hashAfter = (Get-FileHash -LiteralPath $ExePath -Algorithm SHA256).Hash
Write-Host "SHA-256 after      : $hashAfter"
Write-Host ''
Write-Host 'PATCH APPLIED: the specific VRAM startup TaskDialog will be treated as if OK was pressed.' -ForegroundColor Green
