

## for message boxes
Add-Type -AssemblyName PresentationFramework 
## for screen detection
Add-Type -AssemblyName System.Windows.Forms

## get screen resolution
[System.Windows.Forms.Screen]::AllScreens


$focusedAppTrackFrequency = 1000 #in ms
$mouseTrackFrequency = 10 #in ms




$mouseTrack = @()
$focusedAppTrack = @()



$promptRecordingBox =  [System.Windows.MessageBox]::Show('Start recording','RecordWhatIDo','OkCancel','Asterisk')

switch  ($promptRecordingBox) {

  'Ok' {

    ## FOCUSED APP TRACKING
    $focusedAppRecordJob = Start-Job -filePath .\focusRecord.ps1 -ArgumentList $focusedAppTrackFrequency

    ## MOUSE TRACKING
    $mouseRecordJob = Start-Job -filePath .\mouseRecord.ps1 -ArgumentList $mouseTrackFrequency

    ## RECORDING BOX
      $recordingBox = [System.Windows.MessageBox]::Show('RECORDING - Click "Ok" when you are done recording','RecordWhatIDo','Ok','Warning')
      switch ($recordingBox) {

          'Ok' {
              ## CREATING DIRECTORY FOR STORING TRACK FILES
              $dirName = "trackFiles"
              New-Item -Path "./" -Name $dirName -ItemType "directory" -Force


              ## RECEIVE FOCUSED APP TRACKING INFO
              $focusedAppTrack += Receive-Job $focusedAppRecordJob
              Stop-Job $focusedAppRecordJob
              Remove-Job $focusedAppRecordJob
              $focusedAppTrackFile = New-Item -Path "./$dirName" -Name "focusedAppTrack.txt" -Force # -Force for overwrite file
              $focusedAppTrack | Out-File $focusedAppTrackFile

              ## RECEIVE MOUSE TRACKING INFO
              $mouseTrack += Receive-Job $mouseRecordJob
              Stop-Job $mouseRecordJob
              Remove-Job $mouseRecordJob
              $mouseTrackFile = New-Item -Path "./$dirName" -Name "mouseTrack.txt" -Force # -Force for overwrite file
              $mouseTrack | Out-File $mouseTrackFile

              exit

          }

      }


    
    
  }

  'Cancel' {

  exit

  }

  }