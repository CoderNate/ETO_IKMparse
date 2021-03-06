Param(
	[Parameter(Mandatory=$true)]$nugetPath,
	[Parameter(Mandatory=$true)]$nugetPackageOutDir,
	[Parameter(Mandatory=$true)]
	[string]$pushURL,
	[string]$msBuildPath = $env:systemroot + "\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe",
	$pushToNugetServer = $true,
	[string]$nugetApiKey = ""
)
# You don't need to specify the nuget api key parameter if you've configured it using the nuget command like this:
# nuget.exe" setApiKey YOUR_API_KEY_HERE -Source NAME_OF_YOUR_PACKAGE_SOURCE_HERE

If ((Test-Path $nugetPath) -eq $false) { throw "Nuget.exe: File '" + $nugetPath + "' doesn't exist." }
If ((Test-Path $nugetPackageOutDir) -eq $false) { throw "nugetPackageOutDir: '" + $nugetPackageOutDir + "' doesn't exist." }
If ((Test-Path $MsBuildPath) -eq $false) { throw "MsBuildPath: File '" + $MsBuildPath + "' doesn't exist." }

$projPath = Get-ChildItem | Where-Object { $_.Name -match '^.*\.((cs)|(vb))PROJ$' }
if (($projPath | measure).count -ne 1)
{
	throw "Expected to find exactly one project file to build."
}
& $msBuildPath $projPath "/property:Configuration=Release;Platform=AnyCPU" "/verbosity:minimal"
if ($LastExitCode -ne 0)
{
	throw "MSBuild failed!"
}

# Determine the path to the nuget packages that get created based on the output from the nuget 'pack' command.
$outPackagePaths = & $nugetPath pack -OutputDirectory $nugetPackageOutDir `
	-basepath ".\bin\Release" -Properties "Configuration=Release;Platform=AnyCPU" -symbols `
	| Select-String -Pattern "^Successfully created package '([^']+)'\.$" `
	| select -ExpandProperty Matches | foreach {$_.groups[1].value}

$outPackagePath = """" + $outPackagePaths[-1] + """" #The last output path is the symbols package

if ($pushToNugetServer -eq $true)
{
	#The following will fail if you haven't specified credentials for the NAME_OF_YOUR_PACKAGE_SOURCE_HERE nuget server using
	# the following command:  & Nuget.exe Sources Update -Name NAME_OF_YOUR_PACKAGE_SOURCE_HERE -UserName USER -Password SECRET [-Source "http://YOUR_PACKAGE_SOURCE_URL_HERE"]
	#You have to have separate entries in your Nuget config for getting packages and for pushing packages because they
	# use different URLs
	# This page has info about the Nuget config file:  https://docs.nuget.org/consume/nuget-config-file
	# Do NOT manually edit the nuget config file because it'll cause all your hashed passwords to stop working.
	# You aren't supposed to need the api/v2/package/ part but this post says it might be needed in some cases: https://nuget.codeplex.com/discussions/290974
	& $nugetPath push $outPackagePath $nugetApiKey -Source $pushURL
}

