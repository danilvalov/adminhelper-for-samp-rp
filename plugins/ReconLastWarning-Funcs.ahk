;;
;; ReconLastWarning Plugin for AdminHelper.ahk
;; Description: Плагин добавляет возможность быстро подключаться к ID, указанному в последнем Warning'е
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b (Apr 04, 2015)
;; Required modules: SAMP-UDF-Ex, SendChatSavingMessage, Chatlog
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

Hotkey, %ReconLastWarningKey%, ReconLastWarningHotKey
