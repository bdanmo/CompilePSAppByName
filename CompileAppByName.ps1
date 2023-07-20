
Install-Module ps2exe
Import-Module ps2exe

#prompt user for script name to search for
$search = Read-Host "Enter script name to search for"
#search for script in the same directory that this .exe is saved in, add all results to collection
$ScriptPath = Get-ChildItem -Path $PSScriptRoot -Filter "*$search*.ps1" -Recurse
#allow user to select which script to compile from a table of results
$ScriptPath = $ScriptPath | Select-Object -ExpandProperty FullName | Out-GridView -Title "Select script to compile" -PassThru
#remove extension from script name on path
$ScriptPath = $ScriptPath -replace ".ps1",""
#pull the name of the script from the end of the path
$ScriptName = $ScriptPath -replace ".*\\","" -replace ".ps1",""


function getTargetPath() {
    #prompt user for target path, allow user to skip and use same base path as $PSscriptRoot
    $TargetPath = Read-Host "Enter target path and name. Press enter to use same path and name as the original script"
    #if user skips, use same name as original script
    if (!$TargetPath) {
        $TargetPath = "$ScriptName"
    }
    #if user enters only name, append it to the base path
    if ($TargetPath -match ".*\\") {
        $TargetPath = "$TargetPath.exe"
    }
    else {
        $TargetPath = "$PSScriptRoot\$TargetPath.exe"
    }
    #test path to make sure it is valid; if it is not, reprompt user
    if (Test-Path $TargetPath) {
        $overwrite = Read-Host "File already exists. Overwrite? (y/n)"
        if ($overwrite -eq "y") {
            return $TargetPath
        } else {
            getTargetPath
        }
    } else {
        return $TargetPath
    }
}

getTargetPath

#prompt user for app icon path, allow user to skip
$AppIcon = Read-Host "Enter app icon path. Press enter to skip"

#prompt user for app description, allow user to skip
$AppDescription = Read-Host "Enter app description. Press enter to skip"

#prompt user for app version, allow user to skip
$AppVersion = Read-Host "Enter app version. Press enter to skip"

#compile script to exe based on what parameters were entered; be sure to append .ps1 and .exe where needed
if ($AppIcon) {
    if ($AppDescription) {
        if ($AppVersion) {
            ps2exe -inputFile "$ScriptPath.ps1" -outputFile "$TargetPath" -iconFile "$AppIcon" -description "$AppDescription" -version "$AppVersion" -requireAdmin
        } else {
            ps2exe -inputFile "$ScriptPath.ps1" -outputFile "$TargetPath" -iconFile "$AppIcon" -description "$AppDescription" -requireAdmin
        }
    } else {
        ps2exe -inputFile "$ScriptPath.ps1" -outputFile "$TargetPath" -iconFile "$AppIcon" -requireAdmin
    }
} else {
    ps2exe -inputFile "$ScriptPath.ps1" -outputFile "$TargetPath" -requireAdmin
}

#keep window open to see errors
Read-Host "Press enter to exit"




