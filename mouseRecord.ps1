#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$mouseRecordFrequency = $args[0]

#Write-Host $mouseRecordFrequency

#Start-Sleep -s 10

'Starting Mouse Recording'

$recording = $true
while($recording){
    ((Get-Date -Format FileDateTime) + '--' + ([System.Windows.Forms.Cursor]::Position) + '--' + [System.Windows.Forms.UserControl]::MouseButtons + '--M')
    
    Start-Sleep -Milliseconds $mouseRecordFrequency
}
