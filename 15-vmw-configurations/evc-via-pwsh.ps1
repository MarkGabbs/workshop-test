<#
Mark Gabryjelski 2025-11-22
Turning on EVC mode (auto determines the Lowest Common Processor)
#>

$vCenter = "vc11.vmware.wei"
$vCenterDatacenter = "Datacenter"
$vCenterCluster = "mngt-cluster"

Write-Host "Enter the password for the vCenter administrator@vsphere.local account..." -ForeGroundcolor Yellow
Connect-VIServer $vCenter -User "administrator@vsphere.local" -ErrorAction Stop

### Make sure Datacetner Objects already exist
Write-Host "...Making sure the Datacenter already exist..." -ForegroundColor Green
    try { $vCenterDatacenter = Get-Datacenter $vCenterDatacenter -ErrorAction Stop}
    catch { Write-Host "Could not find the Datacenter: $vCenterDatacenter.  You must have a typo in the datacenter name you typed...exiting"  -BackgroundColor Red
    Read-Host "Press Enter to exit OR use CTRL+C to keep the PowerShell Window open"
    exit }

### Configure EVC Mode
### Identify the lowest common EVC Mode
$minEvc = (Get-VMHost | Select-Object -ExpandProperty MaxEVCMode | Sort-Object | Select-Object -First 1)

### Set the EVC Mode
Set-Cluster -Cluster $vCenterCluster -EVCMode "$minEvc" -Confirm:$false
Write-Host "$vCenterCluster EVC mode is now set to $minEvc. "

Write-Host "Disconnecting from vCenter Server $vCenter" -ForeGroundColor Green
Disconnect-VIServer -confirm:$false
Read-Host "Hit Enter to close this window...."
