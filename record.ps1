    
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class UserWindows {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
}
"@

$record = @()
$image = [object[]]::new(6)



while($true){

    ## print date and time
    "DATE"
    $date = Get-Date
    Write-Output $date
    $image[0] = $date
    
    ## get screen resolution
    $screen = Get-WmiObject -Class Win32_DesktopMonitor 
    $screen | Format-Table ScreenWidth,ScreenHeight
    $image[1] = $screen

    ## print current cursor position
    "CURSOR POSITION"
    $cursor = [System.Windows.Forms.Cursor]::Position
    Write-Output $cursor
    $image[2] = $cursor

    ## print current pressed mouse button
    "PRESSED MOUSE BUTTON"
    $button = [System.Windows.Forms.UserControl]::MouseButtons
    Write-Output $button
    $image[3] = $button

    ## lists all opened windows
    "ALL OPENED APPS"
    $process = Get-Process | Where-Object { $_.MainWindowTitle } 
    $process | Format-Table ID,Name,Mainwindowtitle
    $image[4] = $process


    ## shows the focus app
    "FOCUSED APP"            
    $ActiveHandle = [UserWindows]::GetForegroundWindow()
    $focused = Get-Process | Where-Object {$_.MainWindowHandle -eq $ActiveHandle} 
    $focused | Format-Table ID,Name,Mainwindowtitle
    ##Deactivate because it was stopping the Get-Date from Working
    ##$Process | Select ProcessName, @{Name="AppTitle";Expression= {($_.MainWindowTitle)}}            
    $image[5] = $focused


    $record = $record + $image
    sleep 1
}


foreach($_ in $record){
    $cursorTrack
}
