;;
;; ReconLastWarning Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

ReconLastWarning =

ReconLastWarningChatlogChecker(ChatlogString)
{
  global ReconLastWarning

  if (SubStr(ChatlogString, 2, 10) = "<Warning> ") {
    RegExMatch(SubStr(ChatlogString, InStr(ChatlogString, ":") - 5), "\[(\d){1,3}]", ReconLastWarningID)
    
    if (StrLen(ReconLastWarningID) > 0) {
      ReconLastWarning := SubStr(ReconLastWarningID, 2, -1)
    }
  }
}

Chatlog.checker.Insert("ReconLastWarningChatlogChecker")

HotKeyRegister(Config["plugins"]["ReconLastWarning"]["Key"], "ReconLastWarningHotKey")
