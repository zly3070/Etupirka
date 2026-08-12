param(
	[ValidateSet('Debug', 'Release')]
	[string]$Configuration = 'Debug',
	[ValidateSet('Build', 'Rebuild', 'Clean')]
	[string]$Target = 'Build'
)

$ErrorActionPreference = 'Stop'
$workspace = $PSScriptRoot
$toolRoot = Join-Path $env:LOCALAPPDATA 'EtupirkaBuildTools'
$compilerVersion = '4.14.0'
$referenceVersion = '1.0.3'
$compilerDirectory = Join-Path $toolRoot 'compilers'
$referenceDirectory = Join-Path $toolRoot 'net48refs'
$sdkToolsDirectory = Join-Path $toolRoot 'sdktools'
$compiler = Join-Path $compilerDirectory 'tasks\net472\csc.exe'
$referenceAssembly = Join-Path $referenceDirectory 'build\.NETFramework\v4.8\mscorlib.dll'
$assemblyLinker = Join-Path $sdkToolsDirectory 'AL.exe'

function Install-NuGetArchive([string]$Url, [string]$PackageName, [string]$Destination) {
	New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null
	$package = Join-Path $toolRoot $PackageName
	$archive = [System.IO.Path]::ChangeExtension($package, '.zip')
	Invoke-WebRequest -Uri $Url -OutFile $package
	Copy-Item -LiteralPath $package -Destination $archive -Force
	Expand-Archive -LiteralPath $archive -DestinationPath $Destination -Force
}

if (!(Test-Path -LiteralPath $compiler)) {
	Install-NuGetArchive `
		"https://api.nuget.org/v3-flatcontainer/microsoft.net.compilers.toolset/$compilerVersion/microsoft.net.compilers.toolset.$compilerVersion.nupkg" `
		"Microsoft.Net.Compilers.Toolset.$compilerVersion.nupkg" `
		$compilerDirectory
}

if (!(Test-Path -LiteralPath $referenceAssembly)) {
	Install-NuGetArchive `
		"https://api.nuget.org/v3-flatcontainer/microsoft.netframework.referenceassemblies.net48/$referenceVersion/microsoft.netframework.referenceassemblies.net48.$referenceVersion.nupkg" `
		"Microsoft.NETFramework.ReferenceAssemblies.net48.$referenceVersion.nupkg" `
		$referenceDirectory
}

New-Item -ItemType Directory -Path $sdkToolsDirectory -Force | Out-Null
$assemblyLinkerSource = Join-Path $workspace '.buildtools\AssemblyLinker.cs'
if (!(Test-Path -LiteralPath $assemblyLinker) -or
	(Get-Item -LiteralPath $assemblyLinkerSource).LastWriteTimeUtc -gt (Get-Item -LiteralPath $assemblyLinker).LastWriteTimeUtc) {
	& $compiler /nologo /target:exe /out:$assemblyLinker $assemblyLinkerSource
	if ($LASTEXITCODE -ne 0) {
		throw 'Failed to build the local assembly linker.'
	}
}

$msbuild = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe'
if (!(Test-Path -LiteralPath $msbuild)) {
	$msbuild = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe'
}
if (!(Test-Path -LiteralPath $msbuild)) {
	throw '.NET Framework MSBuild was not found.'
}

$referenceRoot = (Join-Path $referenceDirectory 'build') + '\'
$frameworkPath = Join-Path $referenceDirectory 'build\.NETFramework\v4.8'
$compilerRoot = (Join-Path $compilerDirectory 'tasks\net472') + '\'
$sdkToolsRoot = $sdkToolsDirectory + '\'

& $msbuild (Join-Path $workspace 'Etupirka.sln') `
	"/t:$Target" `
	"/p:Configuration=$Configuration" `
	"/p:TargetFrameworkRootPath=$referenceRoot" `
	"/p:FrameworkPathOverride=$frameworkPath" `
	"/p:CscToolPath=$compilerRoot" `
	'/p:CscToolExe=csc.exe' `
	"/p:AlToolPath=$sdkToolsRoot" `
	'/p:AlToolExe=AL.exe' `
	'/m'

exit $LASTEXITCODE
