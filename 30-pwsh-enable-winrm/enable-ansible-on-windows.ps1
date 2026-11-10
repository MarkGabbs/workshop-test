#Requires -RunAsAdministrator
<#
.EXAMPLE Command....
	# From a machine that can reach the targets
	.\Enable-WinRM.ps1 -CsvPath .\servers.csv
.SYNOPSIS
    Enables WinRM on a list of Windows servers from a CSV.
.DESCRIPTION
    Uses Enable-PSRemoting (current recommended approach).
    Assumes you can reach the targets (e.g. already domain-joined with some remoting,
    or run via another deployment method).
.NOTES
    CSV must contain a column named ComputerName
#>

param(
    [Parameter(Mandatory)]
    [string]$CsvPath = ".\servers.csv"
)

$ErrorActionPreference = 'Stop'

# Import server list
if (-not (Test-Path $CsvPath)) {
    throw "CSV file not found: $CsvPath"
}
$servers = Import-Csv -Path $CsvPath | Select-Object -ExpandProperty ComputerName

Write-Host "Targeting $($servers.Count) servers..." -ForegroundColor Cyan

$scriptBlock = {
    # Enable PowerShell Remoting (creates HTTP listener, starts service, sets firewall)
    Enable-PSRemoting -Force -SkipNetworkProfileCheck

    # Ensure service is Automatic and running
    Set-Service -Name WinRM -StartupType Automatic
    if ((Get-Service WinRM).Status -ne 'Running') {
        Start-Service WinRM
    }

    # Explicitly ensure firewall rules are present (Enable-PSRemoting usually does this)
    $rules = @(
        @{ Name = 'WINRM-HTTP-In-TCP';  Port = 5985; Display = 'Windows Remote Management (HTTP-In)' }
        @{ Name = 'WINRM-HTTPS-In-TCP'; Port = 5986; Display = 'Windows Remote Management (HTTPS-In)' }
    )

    foreach ($rule in $rules) {
        if (-not (Get-NetFirewallRule -Name $rule.Name -ErrorAction SilentlyContinue)) {
            New-NetFirewallRule -Name $rule.Name `
                -DisplayName $rule.Display `
                -Enabled True -Direction Inbound -Protocol TCP `
                -Action Allow -LocalPort $rule.Port -Profile Any | Out-Null
        } else {
            Enable-NetFirewallRule -Name $rule.Name -ErrorAction SilentlyContinue
        }
    }

    # Optional: allow local accounts (useful for workgroup or local admin scenarios)
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    if (-not (Get-ItemProperty -Path $regPath -Name LocalAccountTokenFilterPolicy -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $regPath -Name LocalAccountTokenFilterPolicy -Value 1 -PropertyType DWORD -Force | Out-Null
    }

    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        Status       = 'Success'
        WinRMStatus  = (Get-Service WinRM).Status
        Time         = Get-Date
    }
}

# Run against all servers
$results = Invoke-Command -ComputerName $servers -ScriptBlock $scriptBlock -ErrorAction SilentlyContinue -ErrorVariable failures

# Output results
Write-Host "`n=== Results ===" -ForegroundColor Green
$results | Format-Table -AutoSize

if ($failures) {
    Write-Host "`n=== Failures ===" -ForegroundColor Red
    $failures | ForEach-Object {
        [PSCustomObject]@{
            ComputerName = $_.TargetObject
            Error        = $_.Exception.Message
        }
    } | Format-Table -AutoSize
}

Write-Host "`nDone." -ForegroundColor Cyan
Read-Host "...hit Enter to close this window..."