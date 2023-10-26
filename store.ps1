$ErrorActionPreference = "Stop"
# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$DownloadURL = 'https://raw.githubusercontent.com/kkkgo/LTSC-Add-MicrosoftStore/master/Add-Store.cmd'

$rand = Get-Random -Maximum 99999999
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\aktivierenMsStore_$rand.cmd" } else { "$env:TEMP\aktivierenMsStore_$rand.cmd" }

$response = Invoke-WebRequest -Uri $DownloadURL -UseBasicParsing

$ScriptArgs = "$args "
$prefix = "@REM $rand `r`n"
$content = $prefix + $response
Set-Content -Path $FilePath -Value $content

Start-Process $FilePath $ScriptArgs -Wait

$FilePaths = @("$env:TEMP\aktivierenMsStore*.cmd", "$env:SystemRoot\Temp\aktivierenMsStore*.cmd")
foreach ($FilePath in $FilePaths) { Get-Item $FilePath | Remove-Item }
