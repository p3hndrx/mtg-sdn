#system definitions
$approot = "D:\Program Files (x86)\Steam\steamapps\common\Magic 2014"
$backup = "D:\Program Files (x86)\Steam\steamapps\common\Magic 2014\Backups"
$CWArt = "C:\Users\Richard\Google Drive\MtG\Duels of the Planeswalkers 2014 Mods\Community Wad\Community Wad Art"
$CWCore = "C:\Users\Richard\Google Drive\MtG\Duels of the Planeswalkers 2014 Mods\Community Wad\Community Wad Core"
$excluded = @("*.cs", "*.tt", "*.xaml", "*.csproj", "*.sln", "*.xml", "*.cmd", "*.txt") #file exclusions



Write-Host "`n
*************************************`n
****WELCOME TO DotPW Sync Script*****`n
*************************************`n"



#MENU
function menu {
    Do {
    Write-Host " 
---Community WAD Operations--- 
1 = Exit 
2 = View Information
3 = Compare CORE Files
4 = Compare ART Files
5 = Synchronize Files
------------------------------"

    $choice1 = read-host -prompt "Select number & press enter" } 
 until ($choice1 -eq "1" -or $choice1 -eq "2" -or $choice1 -eq "3" -or $choice1 -eq "4"  -or $choice1 -eq "5")   
 

 

Switch ($choice1) 
{ 
"1" {
Exit-PSSession 
clear
    } 
"2" {
    clear
    Write-Host "`n`n Application Root:"
    $appinfo = Get-ItemProperty -Path $approot
    $approot
    Write-Host "Last Write-time of Magic App Root:" $appinfo.LastWriteTimeUtC -f "cyan"
    Write-Host "`n -------------------- `n"
   
    Write-Host "`n Directory Information:"
    #Display Art Info
    Write-Host "`n-- Community WAD Art Directory:`n $CWArt"
    $artinfo = Get-Item $CWart
    Write-Host "Last Modified:" $artinfo.LastWriteTime -f "yellow"
    

    #Display Core Info
    Write-Host "`n-- Community WAD Core Directory:`n" $CWCore
    $coreinfo = Get-Item $CWCore
    Write-Host "Last Modified:" $coreinfo.LastWriteTime -f "yellow"


    menu
    }
 
"3" {
    clear
    #Start CORE Compare
    Write-Host "-----------COMPARE FILES"

    $newCore = Get-ChildItem -Path $CWCore -exclude $excluded  #Read CORE Files
    $newCore
    Write-Host "`nChecking to see if they exist...`n"    
    
    $newCore | ForEach-Object {
    $target = $_.FullName.Replace($CWCore, $approot)
    If (Test-Path ($target)) #Does it exist in the Approot?
        { 
        $targetcheck = Get-Item $target
        $corecheck = Get-Item $_.FullName

        If ($targetcheck.Length -eq $corecheck.Length)  #Check Size
            { Write-Host "Skipping - OK - "$_.Name  "`n"}
        else {
        Write-Host "MISMATCH:" -f "red"        
        Write-Host $target -f "yellow"
        '{0:F2} KB' -f ($targetcheck.Length/1KB) 
        $targetcheck.LastWriteTime.DateTime
        Write-Host "`nNEW:" -f "cyan"
        Write-Host $_.FullName -f "green"        
        '{0:F2} KB' -f ($corecheck.Length/1KB)
        $corecheck.LastWriteTime.DateTime
            } 
        
        } else {
            Write-Host "Missing  - NA - " $_.Name -f "green" #If doesn't exist in Approot
           }  
        }
    menu
    #End CORE Compare
    } 

"4" {
    clear
    #Start ART Compare
    Write-Host "-----------COMPARE FILES"

    $newArt = Get-ChildItem -Path $CWArt -exclude $excluded  #Read ART Files
    $newArt.count
    Write-Host "`nChecking to see if they exist...`n"    
    
    $newArt | ForEach-Object {
    $target = $_.FullName.Replace($CWArt, $approot)
    If (Test-Path ($target)) #Does it exist in the Approot?
        { 
        $targetcheck = Get-Item $target
        $artcheck = Get-Item $_.FullName

        If ($targetcheck.Length -eq $artcheck.Length)  #Check Size
            { Write-Host "Skipping - OK -"$_.Name }
        else {

        $targetsize = '{0:F2} KB' -f ($targetcheck.Length/1KB) #calculate human-readable
        $artsize = '{0:F2} KB' -f ($artcheck.Length/1KB)

        Write-Host "MISMATCH - OLD-" $targetcheck.Name "-"$targetcheck.LastWriteTime.ToString('MMddyyyy HH:MM')"-"$targetsize -f "red" -NoNewline; Write-Host " << NEW: "$artcheck.LastWriteTime.ToString('MMddyyyy HH:MM')"-"$artsize -f "yellow"
                
            } 
        
        } else {
            Write-Host "MISSING  - NA -" $_.Name -f "green" #If doesn't exist in Approot
           }  
        }
    menu
    #End ART Compare
    }

"5" {
        Do { clear
        Write-Host "
    ***** RUNNING SYNC TO FOLDER------

    Which are you trying to Sync? 
        1 = Community WAD - CORE
        2 = Community WAD - ART
        3 = Exit`n"

    $choice = read-host -prompt "Select Number and Press Enter:"
    } 
    until ($choice -eq "1" -or $choice -eq "2" -or $choice -eq "3") 

    Switch ($choice) { 
    "1" {
            clear
            Write-Host "-----------Writing CORE Files"

            $newCore = Get-ChildItem -Path $CWCore -exclude $excluded  #Read CORE Files
            
            $newCore | ForEach-Object {
            $target = $_.FullName.Replace($CWCore, $approot)
            If (Test-Path ($target)) #Does it exist in the Approot?
                { 
                $targetcheck = Get-Item $target
                $corecheck = Get-Item $_.FullName

                If ($targetcheck.Length -eq $corecheck.Length)  #Check Size
                    { 
                    Write-Host "Skipping - OK - "$_.Name 
                    }
                else {
                    Write-Host "Copying - OK - " $target -f "green"
                    Write-Host "From:" $_.FullName
                    $date = (Get-Date).ToString('MMddyyyy-HHmmss')
                    $bak = $_.FullName.Replace($CWCore, $backup)
                    Copy-Item -Path $target -Destination "$bak.bak.$date" #Create a Backup
                    Copy-Item -Path $_.FullName -Destination $target -Force
                    } 
        
                } 
            else {
                    Write-Host "Copying - OK - " $_.Name -f "green" #If doesn't exist in Approot
                    Copy-Item -Path $_.FullName -Destination $target -Force
                   }  
                }
            Write-Host "`nCOMPLETED" -f "cyan"
            menu
         } 
    "2" {
        clear
            Write-Host "-----------Writing ART Files"

            $newArt = Get-ChildItem -Path $CWArt -exclude $excluded  #Read ART Files
            
            $newArt | ForEach-Object {
            $target = $_.FullName.Replace($CWArt, $approot)
            If (Test-Path ($target)) #Does it exist in the Approot?
                { 
                $targetcheck = Get-Item $target
                $artcheck = Get-Item $_.FullName

                If ($targetcheck.Length -eq $artcheck.Length)  #Check Size
                    { 
                    Write-Host "Skipping - OK - "$_.Name
                    }
                else {
                    Write-Host "Copying - OK - " $target -f "green"
                    Write-Host "From:" $_.FullName
                    $date = (Get-Date).ToString('MMddyyyy-HHmmss')
                    $bak = $_.FullName.Replace($CWArt, $backup)
                    Copy-Item -Path $target -Destination "$bak.bak.$date" #Create a Backup
                    Copy-Item -Path $_.FullName -Destination $target -Force
                    } 
        
                } 
            else {
                    Write-Host "Copying - OK - " $_.Name -f "green" #If doesn't exist in Approot
                    Copy-Item -Path $_.FullName -Destination $target -Force
                   }  
                }
            Write-Host "`nCOMPLETED" -f "cyan"
            menu
        }
    "3" {
        clear
        menu
        }
    }


}
} 


}
menu