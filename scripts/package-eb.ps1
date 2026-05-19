param(
    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$apiDir = Join-Path $root "book-management-api"
$jarPath = Join-Path $apiDir "build\libs\book-management-api-1.0.0.jar"
$appJarPath = Join-Path $root "app.jar"
$bundlePath = Join-Path $root "backend-eb.zip"

if (-not $SkipBuild) {
    Push-Location $apiDir
    try {
        & .\gradlew.bat bootJar
        if ($LASTEXITCODE -ne 0) {
            throw "Gradle build failed with exit code $LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path $jarPath)) {
    throw "Backend jar was not found at $jarPath. Run book-management-api\gradlew.bat bootJar first."
}

Copy-Item $jarPath $appJarPath -Force

if (Test-Path $bundlePath) {
    Remove-Item $bundlePath -Force
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::Open($bundlePath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $appJarPath, "app.jar") | Out-Null
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, (Join-Path $root "Procfile"), "Procfile") | Out-Null
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $zip,
        (Join-Path $root ".ebextensions\healthcheck.config"),
        ".ebextensions/healthcheck.config"
    ) | Out-Null
}
finally {
    $zip.Dispose()
}

Write-Host "Created Elastic Beanstalk bundle:"
Write-Host $bundlePath
