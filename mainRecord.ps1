

## for message boxes
Add-Type -AssemblyName PresentationFramework 
## for screen detection
Add-Type -AssemblyName System.Windows.Forms


$focusedAppTrackFrequency = 1000 #in ms
$mouseTrackFrequency = 10 #in ms




$mouseTrack = @()
$focusedAppTrack = @()
$keyboardTrack = @()


$keyboardTracking = $true



$promptRecordingBox =  [System.Windows.MessageBox]::Show('Start recording','RecordWhatIDo','OkCancel','Asterisk')

switch  ($promptRecordingBox) {

  'Ok' {

    ## FOCUSED APP TRACKING
    $focusedAppRecordJob = Start-Job -filePath .\focusRecord.ps1 -ArgumentList $focusedAppTrackFrequency

    ## MOUSE TRACKING
    $mouseRecordJob = Start-Job -filePath .\mouseRecord.ps1 -ArgumentList $mouseTrackFrequency

    if ($keyboardTracking) {
      ## KEYBOARD LETTER TRACKING
      $keyboardRecordJob = Start-Job -filePath .\keyboardRecord.ps1
    }

    ## RECORDING BOX
      $recordingBox = [System.Windows.MessageBox]::Show('RECORDING - Click "Ok" when you are done recording - Do not enter any sort of credentials during recording','RecordWhatIDo','Ok','Warning')
      switch ($recordingBox) {

          'Ok' {
              ## CREATING DIRECTORY FOR STORING TRACK FILES
              $dirName = "trackFiles"
              New-Item -Path "./" -Name $dirName -ItemType "directory" -Force

              ## STORING GLOBAL INFORAMATIONS
              $globalInfosFile = New-Item -Path "./$dirName" -Name "globalInfo.txt" -Force # Force to overwrite file
              [System.Windows.Forms.Screen]::AllScreens | Out-File $globalInfosFile


              ## RECEIVE FOCUSED APP TRACKING INFO
              $focusedAppTrack += Receive-Job $focusedAppRecordJob
              Stop-Job $focusedAppRecordJob
              Remove-Job $focusedAppRecordJob
              $focusedAppTrackFile = New-Item -Path "./$dirName" -Name "focusedAppTrack.txt" -Force # -Force to overwrite file
              $focusedAppTrack | Out-File $focusedAppTrackFile

              ## RECEIVE MOUSE TRACKING INFO
              $mouseTrack += Receive-Job $mouseRecordJob
              Stop-Job $mouseRecordJob
              Remove-Job $mouseRecordJob
              $mouseTrackFile = New-Item -Path "./$dirName" -Name "mouseTrack.txt" -Force # -Force for overwrite file
              $mouseTrack | Out-File $mouseTrackFile

              if ($keyboardTracking) {
                ## RECEIVE KEYBOARD LETTER TRACKING INFO
                $keyboardTrack += Receive-Job $keyboardRecordJob
                Stop-Job $keyboardRecordJob
                Remove-Job $keyboardRecordJob
                $keyboardTrackFile = New-Item -Path "./$dirName" -Name "keyboardTrack.txt" -Force # -Force for overwrite file
                $keyboardTrack | Out-File $keyboardTrackFile
              }

              exit 

          }

      }
    
  }

  'Cancel' {

  exit

  }

  }