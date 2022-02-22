Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class UserWindow {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
}
  public struct RECT
    {
      public int Left;        // x position of upper-left corner
      public int Top;         // y position of upper-left corner
      public int Right;       // x position of lower-right corner
      public int Bottom;      // y position of lower-right corner
    }
"@

#$focusRecordFrequency = $args[0]
$focusRecordFrequency = 1000 #in ms

$rectangle = New-Object RECT

'Starting Focused App Recording'

$recording = $true
while($recording){
  $silent = [UserWindow]::GetWindowRect((Get-Process | Where-Object { $_.mainWindowHandle -eq [UserWindow]::GetForegroundWindow()}).MainWindowHandle,[ref]$rectangle)
  ((Get-Date -Format FileDateTime) + '--' + ((Get-Process | Where-Object { $_.mainWindowHandle -eq [UserWindow]::GetForegroundWindow() }).Name) + '--TopLeft{' + $rectangle.Left + ';' + $rectangle.Top + '}--BottomRight{' + $rectangle.Right + ';' + $rectangle.Bottom) + '}--F'
  Start-Sleep -Milliseconds $focusRecordFrequency
}