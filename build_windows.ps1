# Builds the Windows Desktop export of Neon Velocity.
# Run from PowerShell: .\build_windows.ps1

$ProjectPath = $PSScriptRoot
$OutputDir = Join-Path $ProjectPath "builds\windows"
$OutputExe = Join-Path $OutputDir "NeonVelocity.exe"

# Update this path if Godot is installed somewhere else on this machine.
$GodotExe = "D:\downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe"
if (-not (Test-Path $GodotExe)) {
    $onPath = Get-Command godot -ErrorAction SilentlyContinue
    if ($onPath) { $GodotExe = $onPath.Source }
}
if (-not (Test-Path $GodotExe)) {
    Write-Error "Godot executable not found. Edit `$GodotExe at the top of build_windows.ps1 to point to your Godot install."
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

& $GodotExe --headless --path $ProjectPath --export-release "Windows Desktop" $OutputExe

if ($LASTEXITCODE -eq 0) {
    Write-Output "Windows build succeeded: $OutputExe"
} else {
    Write-Error "Windows export failed (exit code $LASTEXITCODE)"
    exit $LASTEXITCODE
}
