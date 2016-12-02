#<bcarter-htv>
 # Imports
Import-Module ActiveDirectory

$computers = "localhost"
#Test network connection before making connection
If ($computers -ne $Env:Computername) {
    If (!(Test-Connection -comp $computers -count 1 -quiet)) {
        Write-Warning "$computers is not accessible, please try a different computer or verify it is powered on."
        Break
        }
    }

# Get profiles on the computer
Try {
    $users = Get-WmiObject -ComputerName $computers Win32_UserProfile -filter "LocalPath Like 'C:\\Users\\%'" -ea stop

    }
Catch {
    Write-Warning "$($error[0]) "
    Break
    }    

#echo $users
#$userPaths = $users.LocalPath
#echo $users.LocalPath

ForEach ($user in $users){
    # check if the user is a an active AD member, if not delete the profile.
    try     {
            $userBaseName = (New-Object System.Security.Principal.SecurityIdentifier($user.SID)).Translate([System.Security.Principal.NTAccount]).Value.Split("\")[-1]
            if (-Not ((Get-ADUser $userBaseName).Enabled)) {
                Write-Host "Removing AD user:  "$userBaseName}
            }
    catch   {
                # Exception is raided with 
                Write-Host "Deleting non AD user:  "$user.LocalPath
              
            }
}
#</bcarter-htv>
#<amintz-htv>
$ComputerName = "wxyz-machine"
$CutOffDays = 30
$CutOffDate = (Get-Date).addDays(-$CutOffDays)


$profiles = Get-WmiObject -ComputerName $ComputerName -Class Win32_UserProfile 

# list profiles with no LastUseDate
Write-Host "*** No LastUseDate found: "
$profiles | ForEAch-Object {
        $username =  $_.LocalPath.substring( $_.LocalPath.LastIndexOf("\") + 1 , $_.LocalPath.Length -  $_.LocalPath.LastIndexOf("\") - 1)
        if ($_.LastUseTime -eq "")
        {
            Write-Host "$username"
        }
}

# list profiles with LastUseDate sooner than CutOffDate
Write-Host "`n`r`n*** Profiles used in last $CutOffDays days:`r`n"
$profiles | ForEAch-Object {
        $username =  $_.LocalPath.substring( $_.LocalPath.LastIndexOf("\") + 1 , $_.LocalPath.Length -  $_.LocalPath.LastIndexOf("\") - 1)        

        if (-not $_.LastUseTime -eq "")
        {
            $Lastuse = $_.ConvertToDateTime($_.LastUseTime)

            if ($Lastuse -gt $CutOffDate)
            {
                Write-Host "$username - $LastUse - $CutOffDate"            
            }
        }
}

# list profiles with LastUseDate after CutOffDate ... and delete them!!! (dun dun dun)
Write-Host "`r`n`r`n*** Profiles NOT used in last $CutOffDays days:`r`n"
$profiles | ForEAch-Object {
    $username =  $_.LocalPath.substring( $_.LocalPath.LastIndexOf("\") + 1 , $_.LocalPath.Length -  $_.LocalPath.LastIndexOf("\") - 1)

    if (-not $_.LastUseTime -eq "")
    {
        $Lastuse = $_.ConvertToDateTime($_.LastUseTime)
                    
        if ($Lastuse -le $CutOffDate)
        {         
            
            Write-Host "$username - $LastUse"
            <#don't uncomment unless you know what you're doing <#$_.Delete()#>#>    
        }
    }
}
#</amintz-htm>
  
