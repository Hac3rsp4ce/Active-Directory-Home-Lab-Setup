param([parameter(Mandatory=$true)] $OutputJSONFile)

$group_names = [System.Collections.ArrayList](Get-Content "C:/Users/local_admin/Downloads/Active-Directory-Home-Lab-Setup/Domain Controller and Workstation/Creating Random users/data/groupnames.txt")
$first_names = [System.Collections.ArrayList](Get-Content "C:/Users/local_admin/Downloads/Active-Directory-Home-Lab-Setup/Domain Controller and Workstation/Creating Random users/data/firstnames.txt")
$last_names = [System.Collections.ArrayList](Get-Content "C:/Users/local_admin/Downloads/Active-Directory-Home-Lab-Setup/Domain Controller and Workstation/Creating Random users/data/lastnames.txt")
$passwords = [System.Collections.ArrayList](Get-Content "C:/Users/local_admin/Downloads/Active-Directory-Home-Lab-Setup/Domain Controller and Workstation/Creating Random users/data/passwords.txt")

$groups = @()
$users = @()

$num_groups = 10

for ($i=0; $i -lt $num_groups; $i++){
    
        $group_name = (Get-Random -InputObject $group_names)
        $group = @{"name" = "$group_name"}
        $groups += $group
        $group_names.Remove($group_name)
    } 

$num_users = 75

for ($i=0; $i -lt $num_users; $i++){

        $first_name = (Get-Random -InputObject $first_names)
        $last_name = (Get-Random -InputObject $last_names)
        $password = (Get-Random -InputObject $passwords)
        $new_user = @{  

            "name" = "$first_name $last_name"
            "password" = "$password"
            "groups" = @((Get-Random -InputObject $groups).name)
        }

        $users += $new_user

        $first_names.Remove($first_name)
        $last_names.Remove($last_name)
        $passwords.Remove($password)
    }


# Convert to JSON and write to file
ConvertTo-Json -InputObject @{
    "domain" = "h4ckerspace.com"
    "groups" = $groups
    "users" = $users
} | Out-File $OutputJSONFile