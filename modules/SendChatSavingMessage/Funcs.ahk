;;
;; SendChatSavingMessage Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class sendChatSavingMessageClass
{
  __getLocale()
  {
    SetFormat, Integer, H

    WinGet, WinID,, A
    ThreadID := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
    InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")

    SetFormat, Integer, D

    Return %InputLocaleID%
  }

  __setLocale(Locale)
  {
    SendMessage, 0x50,, %Locale%,, A

    Return
  }

  sendMessage(Message, hasEnter = True) {
    Locale_Default := this.__getLocale()

    this.__setLocale(0x4090409)
    Sleep 20
    this.__setLocale(0x4090409)
    Sleep 20

    if (isInChat()) {
      SendInput {Escape}
    }

    SendInput {F6}^a{Delete}

    this.__setLocale(Locale_Default)

    Sleep 20

    this.__setLocale(Locale_Default)

    Sleep 20

    SendInput %Message%

    if (hasEnter) {
      SendInput {Enter}
    } else {
      SendInput {Space}
    }

    Return
  }
}

sendChatSavingMessageClass := new sendChatSavingMessageClass()

sendChatSavingMessage(Message, hasEnter = True)
{
  sendChatSavingMessageClass.sendMessage(Message, hasEnter)

  Return
}
