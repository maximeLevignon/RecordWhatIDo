
while($true){ 
    if ([System.Windows.Forms.UserControl]::MouseButtons -ne "None"){
        [System.Windows.Forms.UserControl]::MouseButtons
        [System.Windows.Forms.Cursor]::Position
    }
}

1,2 | foreach-object -parallel {
  switch ($_) {
    1 { while ($true) { write-host Doing first task; Start-Sleep 2 } }
    2 { while ($true) { write-host Doing second task; Start-Sleep 2 } }
  }
}