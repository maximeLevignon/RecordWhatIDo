Add-Type -AssemblyName System.Windows.Forms

function Click-MouseButton
{
    $signature=@' 
      [DllImport("user32.dll",CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
      public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@ 

    $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru 

        $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
}
## GET ALL DATA

$mouseEvents = Get-Content .\trackFiles\mouseTrack.txt
$focusEvents = Get-Content .\trackFiles\focusedAppTrack.txt
$keyboardEvents = Get-Content .\trackFiles\keyboardTrack.txt


## APPEND ALL DATA IN AN ARRAY

$allEvents = @()

$first, $rest = $mouseEvents
$allEvents += $rest
$first, $rest = $focusEvents
$allEvents += $rest
$first, $rest = $keyboardEvents
$allEvents += $rest


## SORT ALL DATA

$allEventsSorted = $allEvents | sort
#$allEventsSorted


## LAUNCH ALL APPS IF NOT ALREADY OPENED

$allApps = @()
foreach ($item in $focusEvents) {
    $split = $item.Split('-')
    $allApps += $split[1]
}
$allApps = $allApps | select -Unique
foreach ($item in $allApps) {
    try {
        if (!(Get-Process $item)) {
            Start-Process $item
        }
    } catch {
        Write-Host "ERROR : could not launch $item"
    }
}


## GET TIME = 0

$first, $rest = $allEventsSorted
$timeOld = $first.Split("-")[0]


## REPLAYING EVENTS

foreach($item in $allEventsSorted){

    $item
    $item = $item.Split('-')


    ## APPLYING DELAY BETWEEN EVENTS

    $itemNewDate = [datetime]::ParseExact($item[0], 'yyyyMMddTHHmmssffff', $null)
    $timeOldDate = [datetime]::ParseExact($timeOld, 'yyyyMMddTHHmmssffff', $null)
    $delayTimespawn = New-TimeSpan -Start $timeOldDate -End $itemNewDate
    $delayMilliseconds = $delayTimespawn.TotalMilliseconds
    Write-Host "Sleeping $delayMilliseconds"
    Start-Sleep -Milliseconds $delayMilliseconds
    $timeOld = $item[0]


    ## SWITCH CASING DEPENDING ON EVENT TYPE

    switch ($item[$item.length - 1]) {
        ## REPLAYING MOUSE EVENTS
        'M' { 
            Write-Host 'Replaying a mouse event'
            $mouseX = ($item[1].Split(','))[0].Replace('{X=','')
            $mouseY = ($item[1].Split(','))[1].Replace('Y=','').Replace('}','')
            $button = $item[2]
            if($button -eq "None"){
                Write-Host "Placing cursor at [ $mouseX ; $mouseY ]"
                [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($mouseX, $mouseY)
            }
            if($button -eq "Left"){
                Write-Host "Clicking left at  [ $mouseX ; $mouseY ] "
                Click-MouseButton
            }
            
            
        }
        'F' {  
            Write-Host 'Replaying an application in focus event' 
        }
        'KL' {  
            Write-Host 'Replaying an keyboard letter key event' 
            $key = $item[1]
            [System.Windows.Forms.SendKeys]::SendKeys("$key")
        }
        'KS' {  
            Write-Host 'Replaying an keyboard special key event'
            switch($key){
                'Backspace' {
                    [System.Windows.Forms.SendKeys]::SendKeys({BACKSPACE})
                }
                'Enter' {
                    [System.Windows.Forms.SendKeys]::SendKeys({~})
                }
                'LeftControl' {
                    [System.Windows.Forms.SendKeys]::SendKeys({^})
                }
                'RightControl' {
                    [System.Windows.Forms.SendKeys]::SendKeys({BACKSPACE})
                }
                'LeftShift' {
                    [System.Windows.Forms.SendKeys]::SendKeys("+")
                }
                'RightShift' {
                    [System.Windows.Forms.SendKeys]::SendKeys({BACKSPACE})
                }
                'Escape' {
                    [System.Windows.Forms.SendKeys]::SendKeys({ESCAPE})
                }
                'Delete' {
                    [System.Windows.Forms.SendKeys]::SendKeys({DELETE})
                }
                'Tab' {
                    [System.Windows.Forms.SendKeys]::SendKeys({TAB})
                }
                'CapitalLock' {
                    [System.Windows.Forms.SendKeys]::SendKeys({CAPSLOCK})
                }
                'LeftWindows' {
                    [System.Windows.Forms.SendKeys]::SendKeys({BACKSPACE})
                }
                'LeftMenu' {
                    [System.Windows.Forms.SendKeys]::SendKeys({BACKSPACE})
                }
            }
        }
        Default {
            Write-Host 'Error replaying an : event - not recognize' 
        }
    }

}



