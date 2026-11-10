### Mark Gabryjelski 2022-01-03 (Linux-aware version)
#### Execution #########################################################

Start-Documentation

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server vc11.vmware.wei


$DomainControllerWithDNStoRunOn = "dc11"
$ZoneName = "vmware.wei"
$TimeToLive = "1:00:00"
### create CSV File, with Multiple entries for adding A Records with PTR records
### Column 1 = hostname
### Column 2 = IPv4Address
### First line in the file should have :  hostname,IPv4Address
### tested on a Windows 2016 DC, obtained docs from Windows 2012R2 
$aRecordsList = Import-Csv "C:\scripts\dns-entries.csv"

### Do NOT Modify below this line
ForEach ($record in $aRecordsList){
	$hostname = $($record.hostname)
	$ipToAssign = $($record.IPv4Address)
	Add-DnsServerResourceRecordA -Name "$hostname" -IPv4Address "$ipToAssign" -ZoneName "$ZoneName" -ComputerName "$DomainControllerWithDNStoRunOn" -CreatePtr  -AllowUpdateAny  -TimeToLive "$TimeToLive"
	Write-host $hostname done!
}

Write-Host "DNS entries configured" -foreground green
Read-Host "...hit Enter to close this window..."