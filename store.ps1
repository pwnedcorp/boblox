$ErrorActionPreference = "Stop"
# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$BaseRepoURL = "https://raw.githubusercontent.com/kkkgo/LTSC-Add-MicrosoftStore/master"
$MainScriptURL = "$BaseRepoURL/Add-Store.cmd"
$Packages = @(
    "Microsoft.DesktopAppInstaller_1.6.29000.1000_neutral_~_8wekyb3d8bbwe.AppxBundle",
    "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml",
    "Microsoft.NET.Native.Framework.1.6_1.6.24903.0_x64__8wekyb3d8bbwe.Appx",
    "Microsoft.NET.Native.Framework.1.6_1.6.24903.0_x86__8wekyb3d8bbwe.Appx",
    "Microsoft.NET.Native.Runtime.1.6_1.6.24903.0_x64__8wekyb3d8bbwe.Appx",
    "Microsoft.NET.Native.Runtime.1.6_1.6.24903.0_x86__8wekyb3d8bbwe.Appx",
    "Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml",
    "Microsoft.StorePurchaseApp_11808.1001.413.0_neutral_~_8wekyb3d8bbwe.AppxBundle",
    "Microsoft.VCLibs.140.00_14.0.26706.0_x64__8wekyb3d8bbwe.Appx",
    "Microsoft.VCLibs.140.00_14.0.26706.0_x86__8wekyb3d8bbwe.Appx",
    "Microsoft.WindowsStore_8wekyb3d8bbwe.xml",
    "Microsoft.WindowsStore_11809.1001.713.0_neutral_~_8wekyb3d8bbwe.AppxBundle",
    "Microsoft.XboxIdentityProvider_8wekyb3d8bbwe.xml",
    "Microsoft.XboxIdentityProvider_12.45.6001.0_neutral_~_8wekyb3d8bbwe.AppxBundle"
)

$rand = Get-Random -Maximum 99999999
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$BaseFilePath = if ($isAdmin) {
    "$env:SystemRoot\Temp"
} else {
    "$env:TEMP"
}

$ScriptFilePath = "$BaseFilePath\aktivierenMsStore_$rand.cmd"
$response = Invoke-WebRequest -Uri $MainScriptURL -UseBasicParsing

$CurrentPackage = 1
$TotalPackages = $Packages.Count
foreach ($Package in $Packages) {
    echo "Downloading '$Package' ($CurrentPackage/$TotalPackages)..."
    Invoke-WebRequest -Uri "$BaseRepoURL/$Package" -OutFile "$BaseFilePath\$Package"
    $CurrentPackage += 1
}

$ScriptArgs = "$args "
$prefix = "@REM $rand `r`n"
$content = $prefix + $response
Set-Content -Path $ScriptFilePath -Value $content

Start-Process $ScriptFilePath $ScriptArgs -Wait
Get-Item $ScriptFilePath | Remove-Item

foreach ($Package in $Packages) {
    $Path = "$BaseFilePath\$Package"
    echo "Deleting '$Path'..."
    Get-Item $Path | Remove-Item
}
