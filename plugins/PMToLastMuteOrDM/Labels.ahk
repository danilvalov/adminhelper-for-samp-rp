;;
;; PMToLastMuteOrDM Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

PMToLastMuteOrDMHotKey:
{
  Chatlog.reader()

  if (StrLen(PMToLastMuteOrDM)) {
    sendChatSavingMessage("/pm " PMToLastMuteOrDM, False)
  } else {
    sendChatSavingMessage("/pm", False)
  }

  Return
}
