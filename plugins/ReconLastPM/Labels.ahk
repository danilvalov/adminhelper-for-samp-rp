;;
;; ReconLastPM Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

ReconLastPMHotKey:
{
  Chatlog.reader()
  
  if (StrLen(ReconLastPM)) {
    sendChatMessage("/re " ReconLastPM)
  } else {
    sendChatSavingMessage("/re", False)
  }

  Return
}
