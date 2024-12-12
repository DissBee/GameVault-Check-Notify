######## NOTES ########
#@DissBee
#Send message to discord with list of new games
#Provided with no warranty of any sort - run at your own risk.
#I will not make any changes/updates/etc. upon request. If I update it for myself I will push changes to github for anyone else to have.
#Put this script in a folder somewhere and always run it from that folder. Script will create extra files that will be used in future runs.
#Map your share that contains the games folder using the same user you run this script as

######## Variables - change as needed ########

#Define Location to save list of current games.
$CurrentListPath = ".\CurrentList.txt"

#Define Location to save NEW list of games.
$NewListPath = ".\NewList.txt"

#Define Location to save the path to the games folder.
$GamesPath = ".\GamesPath.txt"

#History - not used yet. Might add this later if I get around to it.
$HistoryPath = ".\History"

#Define Discord WebHook URL - paste yours here
$DiscordHookURL = "your webhook URL goes here"

#Define the message you want to send - put your @ codes here in this format <@&rolenumber> (game list will be added automatically) - Blank will not @ anyone
$DiscordRoleID = ""

######## Functions ########
Function Get-GamesPath(){
    if(Test-Path -Path $GamesPath){
        Write-Output "GamesPath already exists. Checking for Games."
    }
    else{
        Write-Output "GamesPath does not exist. Please select your games folder."
        $workingDirectory = Get-Folder
        "$workingDirectory" | Out-File -FilePath ".\GamesPath.txt"
        Write-Output "Created GamesPath.txt file. This location will be used in future runs. Checking for Games."
    }
}


Function Get-GamesListInitial(){
$workingDirectory = Get-Content -Path $GamesPath
Get-ChildItem -Path $workingDirectory -Name | Out-File -FilePath $CurrentListPath
Write-Output "Initial Games List has been generated."
}

Function Get-GamesListNew(){
$workingDirectory = Get-Content -Path $GamesPath
Get-ChildItem -Path $workingDirectory -Name | Out-File -FilePath $NewListPath
Write-Output "New Games List has been generated. Proceeding to check differences."
}

Function Get-GamesDiff(){
    $hash1 = Get-FileHash -Path $CurrentListPath
    $hash2 = Get-FileHash -Path $NewListPath
    if($hash1.Hash -eq $hash2.Hash){
        Remove-Item -Path ".\NewList.txt"
        Read-Host "No changes were detected. Press anything to quit."
        Exit
    }
    else{
        $original = Get-Content -Path $CurrentListPath
        $new = Get-Content -Path $NewListPath

        $differenceNew = Compare-Object -ReferenceObject $original -DifferenceObject $new | Where-Object { $_.SideIndicator -eq "=>" } | Select-Object -ExpandProperty InputObject
        $differenceRemoved = Compare-Object -ReferenceObject $original -DifferenceObject $new | Where-Object { $_.SideIndicator -eq "<=" } | Select-Object -ExpandProperty InputObject

        # Create a new text file with the new items
        $differenceNew | Out-File ".\NewItems.txt"
        $differenceRemoved | Out-File ".\RemovedItems.txt"

        Write-Output "New games detected:`n$differenceNew"
        Write-Output "Removed games detected:`n$differenceRemoved"
        $answer = Read-Host "`n`nDo you want to send notification with this information? (Y/n)"
        if($answer.ToLower() -eq "y" -or $answer -eq ""){
            Send-DiscordNotif
            Write-Output "Done!"
            UpdateListsNoSave
            Read-Host "Press anything to quit"
            Exit
        }
        elseif($answer.ToLower() -eq "n"){
            Read-Host "Press anything to quit"
            Exit
        }
        else{
            Read-Host "Bad input - Press anything to quit"
            Exit
        }
    }
}

Function Send-DiscordNotif(){
    $content = Build-DiscordNotif

    if($content.length -gt 2000){
        Read-Host "Message is too long and needs to be split. Press anything to continue or exit app to quit"
        $lines = $content -split '\r?\n'

        # Get the middle line index
        $middleIndex = [Math]::Ceiling($lines.Count / 2)

        # Get the first half
        $firstHalf = $lines[0..($middleIndex - 1)] -join "`r`n"

        # Get the second half
        $secondHalf = $lines[$middleIndex..($lines.Count - 1)] -join "`r`n"

        $payload1 = [PSCustomObject]@{

        content = $firstHalf

        }
        $payload2 = [PSCustomObject]@{

        content = $secondHalf

        }
        Invoke-RestMethod -Uri $DiscordHookURL -Method Post -Body ($payload1 | ConvertTo-Json) -ContentType 'Application/Json'
        Invoke-RestMethod -Uri $DiscordHookURL -Method Post -Body ($payload2 | ConvertTo-Json) -ContentType 'Application/Json'

    }
    else{

        $payload = [PSCustomObject]@{

        content = $content

        }
        Invoke-RestMethod -Uri $DiscordHookURL -Method Post -Body ($payload | ConvertTo-Json) -ContentType 'Application/Json'
    }
}

Function Build-DiscordNotif(){
    #build the text for the notif here
    $addedGames = Get-Content -Path ".\NewItems.txt"
    $addedGames = $addedGames -split ".zip " -join "`n"
    $addedGames = $addedGames -split ".7z " -join "`n"
    $removedGames = Get-Content -Path ".\RemovedItems.txt"
    $removedGames = $removedGames -split ".zip " -join "`n"
    $removedGames = $removedGames -split ".7z " -join "`n"
    $messageText = "$DiscordRoleID`n"

    if($addedGames.Length -gt 0){
        $messageText += "New Games Added!`n$addedGames"
    }
    else{
        Write-Output "No new games were detected."
    }

    if($removedGames.Length -gt 0){
        $messageText +="`n`nGames Removed:`n$removedGames"
    }
    else{
        Write-Output "No removed games were detected."
    }

    return $messageText
}

Function Get-Folder(){
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select your Games folder"
    $foldername.ShowNewFolderButton = $false

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
        return $folder
    }
    else
    {
        Exit
    }
}

Function UpdateListsNoSave(){
    Remove-Item -Path $CurrentListPath
    Remove-Item -Path ".\NewItems.txt"
    Remove-Item -Path ".\RemovedItems.txt"
    Rename-Item -Path $NewListPath -NewName "CurrentList.txt"
    Write-Output "Current games list has been updated."
}


######## Script Start ########

if(Test-Path -Path $CurrentListPath){
    #run like normal and send notif
    Write-Output "Current Games List exists. Checking for Games Path."
    Get-GamesPath
    Get-GamesListNew
    Get-GamesDiff
}
else{
    #just generate the initial list and do nothing else
    Write-Output "Current Games List does NOT exist. Checking for Games Path."
    Get-GamesPath
    Get-GamesListInitial
}
# @DissBee 