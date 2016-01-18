;;
;; VersionChecker for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b4 (May 25, 2015)
;;


if (A_AhkVersion < "1.1.21.03") {
  MsgBox, 262147, DECISION, ���� ������ AutoHotkey (%A_AhkVersion%) ��������.`n��������� ����� ����� ������ (1.1.21.03 � ����).`n`n����������, ���������� ��������� ������ AHK ������:`nhttp://ahkscript.org/download/ahk-install.exe`n`n������� ������� ���������� ������?

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
