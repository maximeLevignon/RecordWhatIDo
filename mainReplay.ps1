$mouseEventsFile = Get-Content .\trackFiles\mouseTrack.txt
$focusEventsFile = Get-Content .\trackFiles\focusedAppTrack.txt

$indexMouse = 0 
$indexFocus = 0

$tailleFocusEventsFile = $mouseEventsFile.Length 
$tailleMouseEventsFile = $focusEventsFile.Length 

$delai 

#On parcourt les fichiers tant que les index sont différents de la dernière ligne


while($true){
    
    $dateFocusSplit = $focusEventsFile[$indexFocus] -Split("-") #on recupere la ligne de chaque fichier
    $dateMouseSplit = $mouseEventsFile[$indexMouse] -Split("-") #

    $dateFocus = $dateFocusSplit[0]
    $dateMouse = $dateMouseSplit[0]
 
   
 
    if($dateMouse -lt $dateFocus){#Si c'est vrai, on fait l'action, on augmente l'index du fichier réalisé
        Add-Type -AssemblyName System.Windows.Forms
        $splittedShit = $dateMouseSplit[1] -Split {$_ -eq "=" -or $_ -eq "," -or $_ -eq "}"} 
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($splittedShit[1], $splittedShit[3])

        $indexMouse++
        if($indexMouse -eq $tailleFocusEventsFile){
            $mouseRead= $true
            break
        }

       
    } else {
        #Changer focus   

        #$silent = [UserWindow]::GetWindowRect((Get-Process | Where-Object { $_.mainWindowHandle -eq [UserWindow]::GetForegroundWindow()}).MainWindowHandle,[ref]$rectangle)

        $indexFocus++
        $indexFocus  
        if($indexFocus -eq $tailleMouseEventsFile){#On a atteint la fin de focus, on ne lit plus que mouse
            $focusRead = $true
            break
        }
    }
}

if($focusRead -eq $true){ #Si on a fini de lire focus, on deroule mouse
    while($indexMouse -ne $tailleMouseEventsFile){
        $eventMouse =  $mouseEventsFile[$indexFocus]
        #faire l'action
        $indexMouse++
    }
} 

if($mouseRead = $true){ #Si on a fini de lire mouse, on deroule focus
    while($indexFocus -ne $tailleFocusEventsFile){
        $eventFocus =  $focusEventsFile[$indexFocus]
        #faire l'action
        $indexFocus++
    }
}