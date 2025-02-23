param (
    [switch]$Destroy
)

# Function to prompt user for Static IP configuration
function Get-StaticIP {
    $IP = Read-Host "Enter the Static IP for this Domain Controller (Example: 192.168.1.10)"
    $SubnetMask = Read-Host "Enter the Subnet Mask (e.g., 255.255.255.0)"
    $Gateway = Read-Host "Enter the Default Gateway (Example: 192.168.1.1)"
    $DNS = Read-Host "Enter the DNS Server (Root DC IP, Example: 192.168.1.155)"
    return @{
        IP = $IP
        Gateway = $Gateway
        SubnetMask = $SubnetMask
        DNS = $DNS
    }
}

# If Destroy switch is used, execute cleanup
if ($Destroy) {
    Write-Host "Destroying domain and cleaning up..."
    
    # Demote Domain Controller
    Uninstall-ADDSDomainController -DemoteOperationMasterRole -RemoveApplicationPartitions -Force -Credential (Get-Credential)

    # Clean up AD Metadata
    ntdsutil metadata cleanup connections "connect to server <RootDC>" quit select operation target list domains remove selected domain quit quit

    # Stop and remove VM
    Stop-VM -Name $env:COMPUTERNAME -Force
    Remove-VM -Name $env:COMPUTERNAME -Force
    Remove-Item -Path "C:\Users\Amaan Mohammed\Documents\Virtual Machines\$env:COMPUTERNAME" -Recurse -Force

    Write-Host "Domain and VM successfully destroyed."
    exit
}

# Ask for new VM Name
$NewVMName = Read-Host "Enter the name for the new VM (Example: DC01)"

# Clone the VM
New-VM -Name $NewVMName -MemoryStartupBytes 8GB -NewVHDPath "C:\Users\Amaan Mohammed\Documents\Virtual Machines\$NewVMName.vhdx" -NewVHDSizeBytes 100GB -Generation 2 -SwitchName "InternalSwitch"

# Start the VM
Start-VM -Name $NewVMName
Write-Host "VM '$NewVMName' has been created and started."

# Get Static IP details
$IPConfig = Get-StaticIP

# Set up static IP
New-NetIPAddress -IPAddress $IPConfig.IP -PrefixLength $IPConfig.SubnetMask -DefaultGateway $IPConfig.Gateway -InterfaceAlias "Ethernet"
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $IPConfig.DNS

Write-Host "Static IP Configured: $($IPConfig.IP) / $($IPConfig.SubnetMask) Gateway: $($IPConfig.Gateway) DNS: $($IPConfig.DNS)"

# Ask user for the domain type
$DomainType = Read-Host "Choose domain type: [1] Root Domain [2] Child Domain [3] Tree Domain [4] New Forest"

# Prompt for domain name dynamically
if ($DomainType -eq "1") {
    $DomainName = Read-Host "Enter the Root Domain Name (Example: hackerspace.com)"
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssword123" -AsPlainText -Force) -Force
}
elseif ($DomainType -eq "2") {
    $ChildDomainName = Read-Host "Enter the Child Domain Name (Example: child.hackerspace.com)"
    $ParentDomain = Read-Host "Enter the Parent (Root) Domain Name (Example: hackerspace.com)"
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Install-ADDSDomain -NewDomainName $ChildDomainName -ParentDomainName $ParentDomain -DomainType ChildDomain -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssword321" -AsPlainText -Force) -Force
}
elseif ($DomainType -eq "3") {
    $TreeDomainName = Read-Host "Enter the Tree Domain Name (Example: tree.hackerspace.net)"
    $ParentDomain = Read-Host "Enter the Parent (Root) Domain Name (Example: hackerspace.com)"
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Install-ADDSDomain -NewDomainName $TreeDomainName -ParentDomainName $ParentDomain -DomainType TreeDomain -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssword231" -AsPlainText -Force) -Force
}
elseif ($DomainType -eq "4") {
    $ForestDomainName = Read-Host "Enter the New Forest Domain Name (Example: newforest.com)"
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Install-ADDSForest -DomainName $ForestDomainName -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force) -Force
}

# Restart after promotion
Restart-Computer -Force

# Enable Replication for Child or Tree Domains
if ($DomainType -eq "2" -or $DomainType -eq "3") {
    repadmin /syncall /AeD
    Write-Host "Replication successfully enabled!"
}
