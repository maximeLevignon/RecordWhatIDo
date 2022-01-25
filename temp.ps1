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

Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class Tricks {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
}
"@

$a = [tricks]::GetForegroundWindow()

$WH = get-process | Where-Object { $_.mainwindowhandle -eq $a }

$processName = "mintty"
$process = Get-Process | Where-Object { $_.MainWindowTitle } | Where-Object {$_.Name -like "$processName"}

$processWindow = $process.MainWindowHandle

[void] [WinAp]::SetForegroundWindow($processWindow)
[void] [WinAp]::ShowWindow($processWindow, 4)


Get-Process | Where-Object {$_.MainWindowTitle} | Where-Object {$_.Name -like "Discord"} | Set-Window

$Host.UI.RawUI.WindowSize.Width

$Host.UI.RawUI.WindowSize.Height


Add-Type @"
              using System;
              using System.Runtime.InteropServices;
              public class Window {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

                [DllImport("User32.dll")]
                public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);
              }
              public struct RECT
              {
                public int Left;        // x position of upper-left corner
                public int Top;         // y position of upper-left corner
                public int Right;       // x position of lower-right corner
                public int Bottom;      // y position of lower-right corner
              }
"@

$process = Get-Process | Where-Object {$_.MainWindowTitle} | Where-Object {$_.Name -like "Discord"}
$processHandle = $process.MainWindowHandle
$rectangle = New-Object RECT
[Window]::GetWindowRect($processHandle,[ref]$rectangle)
$rectangle