;;
;; AutoConnect Plugin for AdminHelper.ahk
;; Description: Плагин позволяет подключаться к серверу в один клик
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b10 (Fev 11, 2015)
;; Required modules: SAMP-UDF-Ex, SAMP-UDF-Addon, Chatlog
;;

AutoConnectGUIOpen:
  AutoConnect.generateGUI(1)

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
