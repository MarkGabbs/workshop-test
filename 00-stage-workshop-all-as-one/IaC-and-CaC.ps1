### Mark Gabryjelski 2022-01-03 (Linux-aware version)
#### Execution #########################################################
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server vc11.vmware.wei

$NewVMs = Import-Csv "C:\scripts\IaC-and-CaC.csv"

foreach ($NewVM in $NewVMs) {
    $Template   = $NewVM.template
    $Datastore  = $NewVM.datastore
    $DiskFormat = $NewVM.diskformat
    $VMHost     = $NewVM.vmhost
    $CustSpec   = $NewVM.custspec
    $VmName     = $NewVM.vmname
    $ipAddr     = $NewVM.ipaddress
    $Subnet     = $NewVM.subnet
    $Gateway    = $NewVM.gateway
    $pDns       = $NewVM.pdns
    $sDns       = $NewVM.sdns
    $DestFolder = $NewVM.folder
    $PG         = $NewVM.pg
    $MemSize    = $NewVM.memsize
    $CpuCount   = $NewVM.cpucount

    # Get base customization specification
    $baseSpec = Get-OSCustomizationSpec -Name $CustSpec -ErrorAction Stop
    $tempSpecName = "Temp-$VmName-$(Get-Random -Maximum 99999)"

    # Clone to a temporary non-persistent spec
    $null = $baseSpec | New-OSCustomizationSpec -Name $tempSpecName -Type NonPersistent

    if ($baseSpec.OSType -eq "Linux") {
        # Linux: Domain is mandatory when updating; set hostname + DNS at the spec level
        Get-OSCustomizationSpec $tempSpecName |
            Set-OSCustomizationSpec `
                -Domain $baseSpec.Domain `
                -NamingScheme Fixed `
                -NamingPrefix $VmName `
                -DnsServer @($pDns, $sDns) `
                -Confirm:$false |
            Out-Null

        # Linux NIC mapping: do NOT pass -Dns
        Get-OSCustomizationSpec $tempSpecName |
            Get-OSCustomizationNicMapping |
            Set-OSCustomizationNicMapping `
                -IpMode UseStaticIp `
                -IpAddress $ipAddr `
                -SubnetMask $Subnet `
                -DefaultGateway $Gateway `
                -Confirm:$false |
            Out-Null
    }
    else {
        # Windows path (original behavior)
        Get-OSCustomizationSpec $tempSpecName |
            Get-OSCustomizationNicMapping |
            Set-OSCustomizationNicMapping `
                -IpMode UseStaticIp `
                -IpAddress $ipAddr `
                -SubnetMask $Subnet `
                -DefaultGateway $Gateway `
                -Dns $pDns, $sDns `
                -Confirm:$false |
            Out-Null
    }

    # Re-fetch the fully updated temporary spec
    $specToUse = Get-OSCustomizationSpec -Name $tempSpecName

    # Deploy with the customization applied at creation time
    $vm = New-VM -Name $VmName `
                 -Template $Template `
                 -Datastore $Datastore `
                 -DiskStorageFormat $DiskFormat `
                 -VMHost $VMHost `
                 -Location $DestFolder `
                 -OSCustomizationSpec $specToUse

    # Configure network, CPU, and memory
    $vm | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup $PG -Confirm:$false | Out-Null
    $vm | Set-VM -MemoryMB $MemSize -NumCpu $CpuCount -Confirm:$false | Out-Null

    Start-Sleep -Seconds 5

    if ($VmName -like "sql??") {
        Write-Host "This is sql11 .... Adding a few more HDDs...." -ForegroundColor Green
        New-HardDisk -VM $VmName -CapacityGB 50 -StorageFormat Thin -Controller "SCSI Controller 0"
        New-HardDisk -VM $VmName -CapacityGB 55 -StorageFormat Thin | New-ScsiController -Type ParaVirtual
        New-HardDisk -VM $VmName -CapacityGB 60 -StorageFormat Thin -Controller "SCSI Controller 1"
        New-HardDisk -VM $VmName -CapacityGB 65 -StorageFormat Thin -Controller "SCSI Controller 1"
    }

    Start-VM $VmName
    Write-Host "$VmName deployed & powering on...." -ForegroundColor Green

    # Clean up temporary spec
    Remove-OSCustomizationSpec -OSCustomizationSpec $tempSpecName -Confirm:$false -ErrorAction SilentlyContinue
}

Write-Host "Disconnecting from vCenter Server" -ForegroundColor Green
Disconnect-VIServer -Confirm:$false | Out-Null
Read-Host "Hit Enter to close this window...."