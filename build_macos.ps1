# Builds the macOS export of Neon Velocity (as a .zip containing Neon Velocity.app).
# Can be cross-compiled from Windows using Godot's export templates.
# Run from PowerShell: .\build_macos.ps1
#
# Note: this produces an ad-hoc signed, non-notarized build. Gatekeeper will show
# an "unidentified developer" warning on first launch (right-click -> Open bypasses
# it). Full notarization requires an Apple Developer account and Apple's own
# signing tools, which aren't available from Windows.

$ProjectPath = $PSScriptRoot
$OutputDir = Join-Path $ProjectPath "builds\macos"
$OutputZip = Join-Path $OutputDir "NeonVelocity.zip"

# Update this path if Godot is installed somewhere else on this machine.
$GodotExe = "D:\downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe"
if (-not (Test-Path $GodotExe)) {
    $onPath = Get-Command godot -ErrorAction SilentlyContinue
    if ($onPath) { $GodotExe = $onPath.Source }
}
if (-not (Test-Path $GodotExe)) {
    Write-Error "Godot executable not found. Edit `$GodotExe at the top of build_macos.ps1 to point to your Godot install."
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

& $GodotExe --headless --path $ProjectPath --export-release "macOS" $OutputZip

if ($LASTEXITCODE -eq 0) {
    Write-Output "macOS build succeeded: $OutputZip"
} else {
    Write-Error "macOS export failed (exit code $LASTEXITCODE)"
    exit $LASTEXITCODE
}
