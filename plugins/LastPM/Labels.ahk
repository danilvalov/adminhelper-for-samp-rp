;;
;; LastPM Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

LastPMHotKey:
{
  Chatlog.reader()

  if (StrLen(LastPM)) {
    sendChatSavingMessage("/pm " LastPM, False)
  } else {
    sendChatSavingMessage("/pm", False)
  }

  Return
}
