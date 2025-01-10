param( [Parameter(Mandatory=$true)] $JSONFile )

function CreateADUser(){
    param( [Parameter(Mandatory=$true)] $userobject )
            
    echo $userobject
}



$json = (Get-Content $JSONFile | ConvertFrom-Json)
foreach ($user in $json.users){
    CreateADUser $user
}