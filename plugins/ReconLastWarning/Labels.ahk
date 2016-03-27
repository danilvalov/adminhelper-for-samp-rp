;;
;; ReconLastWarning Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

ReconLastWarningHotKey:
{
  Chatlog.reader()

  if (StrLen(ReconLastWarning)) {
    sendChatMessage("/re " ReconLastWarning)
  } else {
    sendChatSavingMessage("/re", False)
  }

  Return
}
