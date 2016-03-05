;;
;; LastSMS Plugin for AdminHelper.ahk
;; Description: Плагин добавляет возможность быстро отвечать на SMS без ввода Id отправителя
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b11 (Mar 06, 2015)
;; Required modules: SAMP-UDF-Ex, SendChatSavingMessage, Chatlog
;;

LastSMS =

LastSMSChatlogChecker(ChatlogString)
{
  global LastSMS, LastSMSOnlyReceivedBoolean

  if (SubStr(ChatlogString, 2, 5) = "SMS: " && (!LastSMSOnlyReceivedBoolean || InStr(ChatlogString, ". Отправитель: "))) {
    RegExMatch(SubStr(ChatlogString, StrLen(ChatlogString) - 3), "(\d){1,3}", LastSMSID)

    if (StrLen(LastSMSID)) {
      LastSMS := LastSMSID
    }
  }
}

Chatlog.checker.Insert("LastSMSChatlogChecker")

if (StrLen(LastSMSKey)) {
  Hotkey, %LastSMSKey%, LastSMSHotKey
}
