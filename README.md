# RecordWhatIDo

Pour tester le projet, vous devez préalablement désactiver Windows Defender :
  1) allez dans les paramètres Windows -> "Virus & threat protection" -> "Virus & threat protection settings" -> "Manage settings"
  2) désactivez "Real-Time protection"
  3) sous "Exclusions" -> "Add or remove exclusions"
  4) "Add an exclusion" puis ajoutez le dossier dans lequel vous télécharger le Git.

Sans ces étapes, le sous-programme keyboardRecord.ps1 sera bloqué ou supprimé par Windows Defender


Test du projet :

Ouvrez le projet sous Powershell ISE ou sous Visual Studio Code avec les extensions Powershell.

Lancez le script "mainRecord.ps1". Il va générer les fichiers txt utilisé par le scipt de replay.

Lancez le script "mainReplay.ps1" pour rejouer les actions enregistrées.
