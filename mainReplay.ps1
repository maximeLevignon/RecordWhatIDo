## ADDING TYPES AND IMPORTS
Import-Module .\Imported-Functions.ps1

Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WinAp {
      [DllImport("user32.dll")]
      [return: MarshalAs(UnmanagedType.Bool)]
      public static extern bool SetForegroundWindow(IntPtr hWnd);

      [DllImport("user32.dll")]
      [return: MarshalAs(UnmanagedType.Bool)]
      public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@

Add-Type -AssemblyName System.Windows.Forms
Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;


## GET ALL DATA

$mouseEvents = Get-Content .\trackFiles\mouseTrack.txt
$focusEvents = Get-Content .\trackFiles\focusedAppTrack.txt
$keyboardEvents = Get-Content .\trackFiles\keyboardTrack.txt


## APPEND ALL DATA IN AN ARRAY

$allEvents = @()

$first, $rest = $mouseEvents
$mouseEvents = $rest
$allEvents += $mouseEvents
$first, $rest = $focusEvents
$focusEvents = $rest
$allEvents += $focusEvents
$first, $rest = $keyboardEvents
$keyboardEvents = $rest
$allEvents += $keyboardEvents


## SORT ALL DATA

$allEventsSorted = $allEvents | Sort-Object
#$allEventsSorted


## LAUNCH ALL APPS IF NOT ALREADY OPENED, AND BRING FIRST APP IN FOCUS
<#
$allApps = @()
foreach ($item in $focusEvents) {
    $split = $item.Split('--')
    if($split[1].length -lt 50 -AND ($split[1]) -ne 'powershell') {
        $allApps += ($split[1] + '--' + $split[2] + '--' + $split[3])
    }
}
#$allApps = $allApps | Select-Object -Unique
foreach ($item in $allApps) {
    $item = ($item.Split('--'))[0]
    try {
        if (!(Get-Process $item)) {
            Start-Process $item
        }
    } catch {
        Write-Host "ERROR : could not launch $item"
    }
}
# bringing first application in focus
if($allApps.length -gt 1){
    $firstApp = $allApps[0].Split('--')
} elseif($allApps.length -gt 0) {
    $firstApp = $allApps.Split('--')
}
try{
    if($firstApp[0] -ne '') {
        $process = Get-Process $firstApp[0]
        $shell = New-Object -ComObject "Shell.Application"
        $shell.minimizeall()
        Start-Sleep -Milliseconds 1
        Show-Process -Process $process
        $topLeftX = ($firstApp[1].Split(';'))[0].Replace('TopLeft{','')
        $topLeftY = ($firstApp[1].Split(';'))[1].Replace('}','')
        $bottomRightX = ($firstApp[2].Split(';'))[0].Replace('BottomRight{','')
        $bottomRightY = ($firstApp[2].Split(';'))[1].Replace('}','')
        Set-Window -ProcessName $process.Id -X $topLeftX -Y $topLeftY -Width ($bottomRightX - $topLeftX) -Height ($bottomRightY - $topLeftY)
    }
} catch {
    "Error : no app to launch"
}
#>

## GET TIME = 0 AND INITIALISING VARIABLES

$first, $rest = $allEventsSorted
$timeOld = $first.Split("--")[0]

$oldMouseX = $null
$oldMouseY = $null
$mouseLeftPressed = $false
$mouseRightPressed = $false

$oldProcess = $null


## REPLAYING EVENTS

foreach($item in $allEventsSorted){

    $item
    $item = $item.Split('--')


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
            $mouseButton = $item[2]

            if(($mouseX -ne $oldMouseX) -OR ($mouseY -ne $oldMouseY)) {
                Write-Host "Placing cursor at [ $mouseX ; $mouseY ]"
                [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($mouseX, $mouseY)
                $oldMouseX = $mouseX
                $oldMouseY = $mouseY
            }
            
            # https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-mouse_event?redirectedfrom=MSDN
            if(($mouseButton -eq "Left") -AND (!$mouseLeftPressed)){
                Write-Host "Pressing left at  [ $mouseX ; $mouseY ]"
                #left mouse press
                [W.U32]::mouse_event(0x0002,0,0,0,0);
                $mouseLeftPressed = $true
            }
            if(($mouseButton -eq "None") -AND ($mouseLeftPressed)){
                Write-Host "Releasing left at  [ $mouseX ; $mouseY ]"
                #left mouse release
                [W.U32]::mouse_event(0x0004,0,0,0,0);
                $mouseLeftPressed = $false
            }

            if(($mouseButton -eq "Right") -AND (!$mouseRightPressed)){
                Write-Host "Pressing right at  [ $mouseX ; $mouseY ]"
                #right mouse press
                [W.U32]::mouse_event(0x0008,0,0,0,0);
                $mouseRightPressed = $true
            }
            if(($mouseButton -eq "None") -AND ($mouseRightPressed)){
                Write-Host "Releasing right at  [ $mouseX ; $mouseY ]"
                #right mouse release
                [W.U32]::mouse_event(0x0010,0,0,0,0);
                $mouseRightPressed = $false
            }

            
            
            
        }
        'F' {  
            Write-Host 'Replaying an application in focus event'
            if (!(Get-Process $item[1]) -AND ($item[1] -ne 'powershell')) {
                Start-Process $item[1]
                Start-Sleep -Milliseconds 1
            }
            $process = Get-Process $item[1]
            if($process.ProcessName -ne $oldProcess.ProcessName) {
                $shell = New-Object -ComObject "Shell.Application"
                $shell.minimizeall()
                Start-Sleep -Milliseconds 1
                Show-Process -Process $process
                $topLeftX = ($item[2].Split(';'))[0].Replace('TopLeft{','')
                $topLeftY = ($item[2].Split(';'))[1].Replace('}','')
                $bottomRightX = ($item[3].Split(';'))[0].Replace('BottomRight{','')
                $bottomRightY = ($item[3].Split(';'))[1].Replace('}','')
                Set-Window -ProcessName $process.Id -X $topLeftX -Y $topLeftY -Width ($bottomRightX - $topLeftX) -Height ($bottomRightY - $topLeftY)
                $oldProcess = $process
            }
        }
        'KL' {  
            Write-Host 'Replaying an keyboard letter key event' 
            $key = $item[1]
            [System.Windows.Forms.SendKeys]::SendWait($key)
        }
        'KS' {  
            Write-Host 'Replaying an keyboard special key event'
            $key = $item[1]
            switch($key){
                'Back' {
                    [System.Windows.Forms.SendKeys]::SendWait("{BACKSPACE}")
                }
                'Enter' {
                    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
                }
                'LeftControl' {
                    [System.Windows.Forms.SendKeys]::SendWait("^")
                }
                'RightControl' {
                    [System.Windows.Forms.SendKeys]::SendWait("^")
                }
                'LeftShift' {
                    [System.Windows.Forms.SendKeys]::SendWait("+")
                }
                'RightShift' {
                    [System.Windows.Forms.SendKeys]::SendWait("+")
                }
                'Escape' {
                    [System.Windows.Forms.SendKeys]::SendWait("{ESC}")
                }
                'Delete' {
                    [System.Windows.Forms.SendKeys]::SendWait("{DELETE}")
                }
                'Tab' {
                    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
                }
                'CapitalLock' {
                    [System.Windows.Forms.SendKeys]::SendWait("{CAPSLOCK}")
                }
                'LeftWindows' {
                    [System.Windows.Forms.SendKeys]::SendWait("^{ESC}")
                }
                'LeftMenu' {
                    [System.Windows.Forms.SendKeys]::SendWait("%")
                }
            }
        }
        Default {
            Write-Host 'Error : event not recognize' 
        }
    }

}



