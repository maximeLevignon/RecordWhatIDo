$mouseTrackFrequency = 100 #in ms

$mouseRecordJob = Start-Job -filepath .\mouseRecord.ps1 -ArgumentList $mouseTrackFrequency

Start-Sleep -s 5

$mouseTrack = Receive-Job $mouseRecordJob
Stop-Job $mouseRecordJob
Remove-Job $mouseRecordJob

$mouseTrack
