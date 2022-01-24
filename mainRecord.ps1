

## for message boxes
Add-Type -AssemblyName PresentationFramework 
## for screen detection
Add-Type -AssemblyName System.Windows.Forms

## get screen resolution
[System.Windows.Forms.Screen]::AllScreens



$mouseTrack = @()



$promptRecordingBox =  [System.Windows.MessageBox]::Show('Start recording','RecordWhatIDo','OkCancel','Asterisk')

switch  ($promptRecordingBox) {

  'Ok' {

    ## MOUSE TRACKING
    $mouseTrackFrequency = 10 #in ms
    $mouseRecordJob = Start-Job -filepath .\mouseRecord.ps1 -ArgumentList $mouseTrackFrequency
    #$mouseTrack = Receive-Job $mouseRecordJob

    ## RECORDING BOX
      $recordingBox = [System.Windows.MessageBox]::Show('RECORDING - Click "Ok" when you are done recording','RecordWhatIDo','Ok','Warning')
      switch ($recordingBox) {

          'Ok' {
              ## RECEIVE MOUSE TRACKING INFO
              $mouseTrack = Receive-Job $mouseRecordJob
              Stop-Job $mouseRecordJob
              Remove-Job $mouseRecordJob
              $mouseTrack


              exit

          }

      }


    
    
  }

  'Cancel' {

  exit

  }

  }