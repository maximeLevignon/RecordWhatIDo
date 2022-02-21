
  # Signatures for API Calls
  $signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

  # load signatures and make members available
  $API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
    
  # create output file

    # Write-Host 'Recording key presses. Press CTRL+C to see results.' -ForegroundColor Red

    # create endless loop. When user presses CTRL+C, finally-block
    # executes and shows the collected key presses

'Starting Keyboard Special Recording'

$recording = $true
while ($recording) {
    
  # scan all ASCII codes above 8
  for ($ascii = 7; $ascii -le 254; $ascii++) {
    # get current key state
    $state = $API::GetAsyncKeyState($ascii)
    #$state

    # is key pressed?
    if ($state -eq -32767) {
      $null = [console]::CapsLock

      # translate scan code to real code
      
      # $ascii

      switch ($ascii) 
      # refered to https://docs.microsoft.com/en-us/uwp/api/windows.system.virtualkey?view=winrt-20348
      {
         8 { $key = 'Back' ; $newKey = $true }
         13 { $key = 'Enter' ; $newKey = $true }
         162 { $key = 'LeftControl' ; $newKey = $true }
         163 { $key = 'RightControl' ; $newKey = $true }
         160 { $key = 'LeftShift' ; $newKey = $true }
         161 { $key = 'RightShift' ; $newKey = $true }
         27 { $key = 'Escape' ; $newKey = $true }
         46 { $key = 'Delete' ; $newKey = $true }     
         9 { $key = 'Tab' ; $newKey = $true } 
         20 { $key = 'CapitalLock' ; $newKey = $true }
         164 { $key = 'LeftAlt' ; $newKey = $true } # LeftMenu
         # 165 { $key = 'RightAlt' ; $newKey = $true } # RightMenu
      } 

      if ($newKey) {
        (Get-Date -Format FileDateTime) + '-' + $key + '-KS'
        $newKey = $false
      }
      
      }
    }

    #Start-Sleep -Milliseconds 100

  }
