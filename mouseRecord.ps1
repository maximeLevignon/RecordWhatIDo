#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$mouseRecordFrequency = $args[0]

#Write-Host $mouseRecordFrequency

#Start-Sleep -s 10

$recording = $true
while($recording){
    Start-Sleep -Milliseconds $mouseRecordFrequency
    ((Get-Date -Format FileDateTime) + '-' + ([System.Windows.Forms.Cursor]::Position) + '-' + [System.Windows.Forms.UserControl]::MouseButtons)
}
