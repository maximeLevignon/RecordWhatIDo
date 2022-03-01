# RecordWhatIDo

I) Pour tester le projet, vous devez préalablement désactiver Windows Defender :
  1) allez dans les paramètres Windows -> "Virus & threat protection" -> "Virus & threat protection settings" -> "Manage settings"
  2) désactivez "Real-Time protection"
  3) sous "Exclusions" -> "Add or remove exclusions"
  4) "Add an exclusion" puis ajoutez le dossier dans lequel vous téléchargez le Git.

Sans ces étapes, le sous-programme keyboardRecord.ps1 sera bloqué ou supprimé par Windows Defender.


II) Test du projet :

  1) Ouvrez le projet sous Powershell ISE ou sous Visual Studio Code avec les extensions Powershell.
  2) Lancez le script "mainRecord.ps1". Il va générer les fichiers .txt utilisés par le scipt de replay.
  3) Lancez le script "mainReplay.ps1" pour rejouer les actions enregistrées.

OU

  1) Ouvrez une console Powershell, naviguez vers le bon dossier
  2) ".\mainRecord.ps1"
  3) ".\mainReplay.ps1"
  
  


III) Bug connus :
- si plusieurs instances d'une même application sont ouvertes et enregistrées, ces dernières peuvent être confondues par le script de replay
- le script de replay redimmensionne parfois la fenêtre d'une autre application à celle ouverte précédemment, faussant la suite du replay pour l'application en question
- des combinaisons de touches ne sont pas reconnues.
