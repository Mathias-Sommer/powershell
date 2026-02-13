<#
.Synopsis
Created on:   13-02-2026
Created by:   Mathias Sommer
Filename:     Install-Printer.ps1

.Description
Deploy to Microsoft 365 Intune as Win32 Application.

You are required to have IntuneWinAppUtil.exe installed on your system. This is to package Install-Printer.ps1, Remove-Printer.ps1 and driver files to .intunewin format.
IntuneWinAppUtil is a free tool and can be downloaded here: https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool

Keep in mind you will need to put Install-Printer.ps1, Remove-Printer.ps1 and driver files in the same folder when packaging to intunewin.
When prompted to specify the Setup file, provide: Install-Printer.ps1

Minimum file structure setup:
Name
----
cabfile.cab
inffile.inf
Install-Printer.ps1
Remove-Printer.ps1

.PARAMETER IP
This is the IP-Address the printer will be assigned.

.PARAMETER Name
This is the name the printer will be assigned.

.PARAMETER Driver
This is the name of the driver which the printer will be installed with.

.PARAMETER INF
This is the .inf file that will contain details about the driver and other packages 
required for driver installation.

.Example
# Install:
powershell.exe -executionpolicy bypass -file .\Install-Printer.ps1 -IP "192.168.1.175" -Name "HP - A4 Printer" -Driver "HP Universal Printing PCL 6" -INF "hpcu345u.inf"

# Detection:
1. Rules format: Manually configure detection rules
2. (+ Add) -> Rule type: Registry
3. Key path: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Print\Printers\HP - A4 Printer
4. Value name: Name
5. Detection method: String comparison
6. Operator: Equals
7. Value: HP - A4 Printer

# Uninstall:
powershell.exe -executionpolicy bypass -file .\Remove-Printer.ps1 -PrinterName "HP - A4 Printer"

#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)]
    [String]$IP,
    [Parameter(Mandatory = $True)]
    [String]$Name,
    [Parameter(Mandatory = $True)]
    [String]$Driver,
    [Parameter(Mandatory = $True)]
    [String]$INF
)

$PortName = "IP_" + $IP

# Add driver to driverstore
C:\Windows\SysNative\pnputil.exe /add-driver $INF /install

# Add printer driver
Add-PrinterDriver -Name $Driver

# Add printer port
Add-PrinterPort -Name $PortName -PrinterHostAddress $IP

# Add printer
Add-Printer -Name $Name -DriverName $Driver -PortName $PortName
