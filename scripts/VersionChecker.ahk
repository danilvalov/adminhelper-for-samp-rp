;;
;; VersionChecker for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

if (A_AhkVersion < "1.1.21.03") {
  MsgBox, 262147, DECISION, Ваша версия AutoHotkey (%A_AhkVersion%) устарела.`nТребуется более новая версия (1.1.21.03 и выше).`n`nПожалуйста, установите последнюю версию AHK отсюда:`nhttp://ahkscript.org/download/ahk-install.exe`n`nЖелаете скачать обновление сейчас?

  IfMsgBox, CANCEL
  {
    Return
  }

  IfMsgBox, NO
  {
    Return
  }

  Run, http://ahkscript.org/download/ahk-install.exe

  ExitApp

  Return
}
