param([parameter(Mandatory=$true)] $JSONFile)

function CreateADGroup(){
    param([parameter(Mandatory=$true)] $groupObject)

    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope Global
}

function CreateADUser(){

    param([parameter(Mandatory=$true)] $userObject)

    # Pulling out the name from the JSON File
    $name = $userObject.name
    $password = $userObject.password

    # Creating the username using the first letter of the last name and the first name
    
    $firstname,$lastname = $name.Split(" ")
    $username =  ($lastname[0] + $firstname).ToLower()
    $samAccountName = $username
    $principalName = $username

    # Creating the user in Active Directory
     New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $Principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount 
    #Add the user to appropriate groups
    foreach ($group_name in $userObject.groups){

        try {
            Get-ADGroup -Identity "$group_name"
            Add-ADGroupMember -Identity $group_name -Members $username

        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]  
        {
            Write-Warning "User $username not added to $group_name because the group does not exist"
            <#Do this if a terminating exception happens#>
        }
    }

}

$json = ( Get-Content $JSONFile | ConvertFrom-JSON)

$Global:Domain = $json.domain

foreach ($group in $json.groups){
    CreateADGroup $group
}
foreach ($user in $json.users){
    CreateADUser  $user
}
