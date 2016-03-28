;;
;; AutoConnect Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

AutoConnectGUIOpen:
  AutoConnect.generateGUI(1, 0)

  Return

AutoConnectClose:
  Gui, AutoConnect:Destroy

  Return

AutoConnectConnect:
  AutoConnect.connect()

  Return

AutoConnectSAMPFileBrowse:
  FileSelectFile, SAMPFile, 3, % AutoConnect._sampFile, Поиск samp.exe, samp.exe
  If ErrorLevel
  	Return
  else
  	AutoConnect.selectSAMPFile(SAMPFile)

  Return

AutoConnectChatlogFileBrowse:
  FileSelectFile, ChatlogFile, 3, , Поиск chatlog.txt, chatlog.txt
  If ErrorLevel
  	Return
  else
  	AutoConnect.selectChatlogFile(ChatlogFile)

  Return
