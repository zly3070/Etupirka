param(
	[string]$Version,
	[switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$workspace = $PSScriptRoot
$releaseDirectory = Join-Path $workspace 'Etupirka\bin\Release'
$artifactsDirectory = Join-Path $workspace 'artifacts'

if (!$Version) {
	$assemblyInfo = Get-Content -LiteralPath (Join-Path $workspace 'Etupirka\Properties\AssemblyInfo.cs') -Raw
	$versionMatch = [regex]::Match($assemblyInfo, 'AssemblyInformationalVersion\("([^"]+)"\)')
	if (!$versionMatch.Success) {
		throw 'Could not determine the application version from AssemblyInfo.cs.'
	}

	$Version = $versionMatch.Groups[1].Value
}

if (!$SkipBuild) {
	& (Join-Path $workspace 'build.ps1') -Configuration Release -Target Rebuild
	if ($LASTEXITCODE -ne 0) {
		throw 'The Release build failed.'
	}
}

$requiredFiles = @(
	'Etupirka.exe',
	'Etupirka.exe.config',
	'x86\SQLite.Interop.dll',
	'x64\SQLite.Interop.dll'
)

foreach ($relativePath in $requiredFiles) {
	if (!(Test-Path -LiteralPath (Join-Path $releaseDirectory $relativePath))) {
		throw "Required release file is missing: $relativePath"
	}
}

$packageName = "Etupirka-$Version-portable"
$stagingDirectory = Join-Path $artifactsDirectory $packageName
$archivePath = Join-Path $artifactsDirectory "$packageName.zip"

New-Item -ItemType Directory -Path $artifactsDirectory -Force | Out-Null
if (Test-Path -LiteralPath $stagingDirectory) {
	Remove-Item -LiteralPath $stagingDirectory -Recurse -Force
}
if (Test-Path -LiteralPath $archivePath) {
	Remove-Item -LiteralPath $archivePath -Force
}
New-Item -ItemType Directory -Path $stagingDirectory | Out-Null

# Only publish runtime files. Build symbols, XML documentation and local databases
# intentionally remain in bin\Release and are not copied into the portable package.
Get-ChildItem -LiteralPath $releaseDirectory -File |
	Where-Object { $_.Extension -in @('.exe', '.dll', '.config') } |
	Copy-Item -Destination $stagingDirectory

Get-ChildItem -LiteralPath $releaseDirectory -Directory | ForEach-Object {
	$sourceDirectory = $_.FullName
	$relativeDirectory = $_.Name
	$runtimeFiles = Get-ChildItem -LiteralPath $sourceDirectory -Recurse -File -Filter '*.dll'
	foreach ($runtimeFile in $runtimeFiles) {
		$relativePath = $runtimeFile.FullName.Substring($sourceDirectory.Length).TrimStart('\')
		$destinationDirectory = Join-Path $stagingDirectory (Join-Path $relativeDirectory (Split-Path $relativePath -Parent))
		New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
		Copy-Item -LiteralPath $runtimeFile.FullName -Destination (Join-Path $destinationDirectory $runtimeFile.Name)
	}
}

Copy-Item -LiteralPath (Join-Path $workspace 'LICENSE') -Destination $stagingDirectory

$unwantedFiles = Get-ChildItem -LiteralPath $stagingDirectory -Recurse -File |
	Where-Object { $_.Extension -in @('.pdb', '.xml') -or $_.Name -in @('user.db', 'data.db') }
if ($unwantedFiles) {
	throw "Unexpected development or database files were staged: $($unwantedFiles.FullName -join ', ')"
}

Compress-Archive -LiteralPath $stagingDirectory -DestinationPath $archivePath -CompressionLevel Optimal

Write-Host "Portable package created: $archivePath"
