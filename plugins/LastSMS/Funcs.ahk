;;
;; LastSMS Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

LastSMS =

LastSMSChatlogChecker(ChatlogString)
{
  global Config, LastSMS

  if (SubStr(ChatlogString, 2, 5) = "SMS: " && (!Config["plugins"]["LastSMS"]["OnlyReceivedBoolean"] || InStr(ChatlogString, ". Отправитель: "))) {
    RegExMatch(SubStr(ChatlogString, StrLen(ChatlogString) - 3), "(\d){1,3}", LastSMSID)

    if (StrLen(LastSMSID)) {
      LastSMS := LastSMSID
    }
  }
}

Chatlog.checker.Insert("LastSMSChatlogChecker")

HotKeyRegister(Config["plugins"]["LastSMS"]["Key"], "LastSMSHotKey")
