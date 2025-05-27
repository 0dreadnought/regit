$localpath = "\regit\x64\Debug\regit.exe"
$scriptRoot = $PSScriptRoot
$sourceExePath = Join-Path -Path $scriptRoot -ChildPath "\regit\x64\Debug\regit.exe"
$exeName = "regit.exe"
$installDir = [System.IO.Path]::Combine($env:LOCALAPPDATA, "regit")

if (-not (Test-Path $sourceExePath -PathType Leaf)) {
    Write-Error ".exe not found at '$sourceExePath'. Please check the path."
    exit 1
}
if (-not (Test-Path $installDir -PathType Container)) {
    try {
        New-Item -ItemType Directory -Path $installDir -Force -ErrorAction Stop | Out-Null
        Write-Host " '$installDir' created successfully."
    } catch {
        Write-Error "Failed to create directory '$installDir'. Error: $_"
        exit 1
    }
}

$destinationExePath = [System.IO.Path]::Combine($installDir, $exeName)
try {
    Write-Host "Copying '$sourceExePath' to '$destinationExePath'..."
    Copy-Item -Path $sourceExePath -Destination $destinationExePath -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to copy '$sourceExePath' to '$destinationExePath'. Error: $_"
    exit 1
}

$currentUserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

if (-not ($currentUserPath -split ';' -contains $installDir)) {
    Write-Host "Adding '$installDir' to User PATH..."
    $newPath = $currentUserPath + ";" + $installDir
    if ([string]::IsNullOrEmpty($currentUserPath)) {
        $newPath = $installDir
    }
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "'$installDir' added to User PATH."
[System.Environment]::GetEnvironmentVariable('Path', 'User')"
} else {
    Write-Host "'$installDir' is already in User PATH."
}

Write-Host "Done. regit will be callable after terminal restart."