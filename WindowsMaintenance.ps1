param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

'running with full privileges'

Start-Process sfc /scannow 
write-Host "Running SFC" -ForegroundColor Red
Start-Process CHKDSK 
write-Host "Running CHKDSK" -ForegroundColor Blue
Start-Process ipconfig /flushdns 
write-Host "Running DNS Flush" -ForegroundColor Yellow

#1# Remove Temp Files
Set-Location “C:\Windows\Temp”
Remove-Item * -Recurse -Force -ErrorAction SilentlyContinue

$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace(0xA)
$WinTemp = "c:\Windows\Temp\*"

#3# Running Disk Clean up Tool 
write-Host "Removing Temp" -ForegroundColor Red
Set-Location “C:\Windows\Temp”
Remove-Item * -Recurse -Force -ErrorAction SilentlyContinue

#2# Empty Recycle Bin #
write-Host "Emptying Recycle Bin." -ForegroundColor Green
$objFolder.items() | %{ remove-item $_.path -Recurse -Confirm:$false}

$([char]7)
Sleep 3
write-Host "Windows Cleanup Task Complete" -ForegroundColor Magenta
Sleep 10
