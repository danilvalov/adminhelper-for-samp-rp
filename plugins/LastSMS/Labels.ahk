;;
;; LastSMS Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

LastSMSHotKey:
{
  Chatlog.reader()

  if (StrLen(LastSMS)) {
    sendChatSavingMessage("/t " LastSMS, False)
  } else {
    sendChatSavingMessage("/t", False)
  }

  Return
}
