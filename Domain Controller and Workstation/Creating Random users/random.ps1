param([parameter(Mandatory=$true)] $OutputJSONFile)

$group_names = [System.Collections.ArrayList](Get-Content "C:/Users/local_admin/Downloads/Active-Directory-Home-Lab-Setup/Domain Controller and Workstation/Creating Random users/data/groupnames.txt")
$first_names = [System.Collections.ArrayList](Get-Content "C:/Users/local_admin/Downloads/Active-Directory-Home-Lab-Setup/Domain Controller and Workstation/Creating Random users/data/firstnames.txt")
$last_names = [System.Collections.ArrayList](Get-Content "C:/Users/local_admin/Downloads/Active-Directory-Home-Lab-Setup/Domain Controller and Workstation/Creating Random users/data/lastnames.txt")
$passwords = [System.Collections.ArrayList](Get-Content "C:/Users/local_admin/Downloads/Active-Directory-Home-Lab-Setup/Domain Controller and Workstation/Creating Random users/data/passwords.txt")

$groups = @()
$users = @()

$num_groups = 10

for ($i=0; $i -lt $num_groups; $i++){
    
        $new_group = (Get-Random -InputObject $group_names)
        $groups += @{"name" = $new_group}
        $group_names.Remove($new_group)
    }
echo $group_names 

$num_users = 50

for ($i=0; $i -lt $num_users; $i++){

        $first_name = (Get-Random -InputObject $first_names)
        $last_name = (Get-Random -InputObject $last_names)
        $password = (Get-Random -InputObject $passwords)
        $new_user = @{  

            "name" = "$first_name $last_name"
            "password" = $password
            "groups" = @((Get-Random -InputObject $groups).name)
        }
        echo $new_user

        $users += $new_user

        $first_names.Remove($first_name)
        $last_names.Remove($last_name)
        $passwords.Remove($password)
    }


ConvertTo-Json @{
    "domain" = "hackerspace.com"
    "groups" = $groups
    "users" = $users
} | Out-File $OutputJSONFile