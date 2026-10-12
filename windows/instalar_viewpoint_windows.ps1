# ============================================================================
#  instalar_viewpoint_windows.ps1
#  (Re)instala ZombieBuddy + Project Viewpoint (3D) en una carpeta de Project
#  Zomboid para WINDOWS. Idempotente: se puede ejecutar varias veces.
#
#  Uso normal:  doble clic en INSTALAR_VIEWPOINT_WINDOWS.bat
#  Manual:      powershell -ExecutionPolicy Bypass -File instalar_viewpoint_windows.ps1 [-GameDir "C:\ruta\ProjectZomboid"]
# ============================================================================
param(
    [string]$GameDir = ""
)

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[*]  $m" -ForegroundColor Cyan }
function Ok($m){   Write-Host "[OK] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[!]  $m" -ForegroundColor Yellow }
function Die($m){  Write-Host "[ERROR] $m" -ForegroundColor Red; exit 1 }

# --- localizar la carpeta del juego ---
if ([string]::IsNullOrWhiteSpace($GameDir)) {
    $GameDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}
$GameDir = (Resolve-Path $GameDir).Path

if (-not (Test-Path (Join-Path $GameDir "projectzomboid.jar"))) {
    Die "$GameDir no contiene projectzomboid.jar (no parece la carpeta del juego). Pasa la ruta con -GameDir."
}
Info "Carpeta del juego: $GameDir"

# --- origen de los mods ---
$zbSrc = Join-Path $GameDir "mods\ZombieBuddy"
$vpSrc = Join-Path $GameDir "mods\Viewpoint"
if (-not (Test-Path $zbSrc)) { Die "No encuentro el mod ZombieBuddy en $zbSrc" }
if (-not (Test-Path $vpSrc)) { Die "No encuentro el mod Viewpoint en $vpSrc" }

# --- 1) copiar mods a %USERPROFILE%\Zomboid\mods ---
$userMods = Join-Path $env:USERPROFILE "Zomboid\mods"
New-Item -ItemType Directory -Force -Path $userMods | Out-Null
foreach ($m in @("ZombieBuddy","Viewpoint")) {
    $dst = Join-Path $userMods $m
    if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
    Copy-Item -Recurse -Force (Join-Path $GameDir "mods\$m") $dst
    Ok "Mod $m  ->  $dst"
}

# --- 2) agente ZombieBuddy en la raiz del juego ---
$zbJar = Join-Path $zbSrc "libs\ZombieBuddy.jar"
$zbDll = Join-Path $zbSrc "libs\zbNative.dll"
if ((Test-Path $zbJar) -and (Test-Path $zbDll)) {
    Copy-Item -Force $zbJar (Join-Path $GameDir "ZombieBuddy.jar")
    Copy-Item -Force $zbDll (Join-Path $GameDir "zbNative.dll")
    Ok "Agente ZombieBuddy copiado a la raiz (ZombieBuddy.jar + zbNative.dll)."
} elseif (-not (Test-Path (Join-Path $GameDir "ZombieBuddy.jar"))) {
    Warn "Falta ZombieBuddy.jar y no hay copia en el mod."
}

# --- 3) parchear ProjectZomboid64.json (agente) ---
$json = Join-Path $GameDir "ProjectZomboid64.json"
if (Test-Path $json) {
    $raw = [IO.File]::ReadAllText($json)
    if ($raw -match 'agentlib:zbNative') {
        Ok "ProjectZomboid64.json ya tenia el agente."
    } else {
        $nl = if ($raw -match "`r`n") { "`r`n" } else { "`n" }
        $pattern = '("vmArgs"\s*:\s*\[[ \t]*)(' + [regex]::Escape($nl) + ')([ \t]*)'
        $m = [regex]::Match($raw, $pattern)
        if ($m.Success) {
            $ins = $m.Groups[1].Value + $m.Groups[2].Value + $m.Groups[3].Value + '"-agentlib:zbNative",' + $nl + $m.Groups[3].Value
            $raw = $raw.Substring(0, $m.Index) + $ins + $raw.Substring($m.Index + $m.Length)
            [IO.File]::WriteAllText($json, $raw)
            Ok "ProjectZomboid64.json: agente insertado en vmArgs."
        } else {
            Warn "No encontre vmArgs en el JSON; edita -agentlib:zbNative a mano."
        }
    }
} else {
    Warn "No existe ProjectZomboid64.json."
}

# --- 4) parchear los .bat (SET _JAVA_OPTIONS=-agentlib:zbNative) ---
foreach ($b in @("ProjectZomboid64.bat","ProjectZomboid64ShowConsole.bat","ProjectZomboidOpenGLDebug64.bat")) {
    $p = Join-Path $GameDir $b
    if (-not (Test-Path $p)) { continue }
    $lines = [System.Collections.Generic.List[string]]::new()
    $has = $false
    foreach ($ln in [IO.File]::ReadAllLines($p)) {
        if ($ln -match '^SET _JAVA_OPTIONS=') { $lines.Add('SET _JAVA_OPTIONS=-agentlib:zbNative'); $has = $true }
        else { $lines.Add($ln) }
    }
    if (-not $has) {
        $out = [System.Collections.Generic.List[string]]::new(); $done = $false
        foreach ($ln in $lines) {
            $out.Add($ln)
            if (-not $done -and $ln -match '@cd /d "%~dp0"') { $out.Add('SET _JAVA_OPTIONS=-agentlib:zbNative'); $done = $true }
        }
        $lines = $out
    }
    [IO.File]::WriteAllLines($p, $lines)
    Ok "$b parcheado."
}

# --- 5) versionMin del mod Viewpoint ---
foreach ($mi in @((Join-Path $GameDir "mods\Viewpoint\common\mod.info"), (Join-Path $userMods "Viewpoint\common\mod.info"))) {
    if (Test-Path $mi) {
        $t = [IO.File]::ReadAllText($mi)
        if ($t -match '(?m)^versionMin=') { $t = [regex]::Replace($t, '(?m)^versionMin=[^\r\n]*', 'versionMin=42.21') }
        else { $t = $t.TrimEnd() + "`r`nversionMin=42.21`r`n" }
        [IO.File]::WriteAllText($mi, $t)
    }
}
Ok "Viewpoint versionMin = 42.21"

Write-Host ""
Ok "LISTO. En el juego: Mods -> activa 'ZombieBuddy' y luego 'Viewpoint' -> aprueba los JAR (SHA-256)."
