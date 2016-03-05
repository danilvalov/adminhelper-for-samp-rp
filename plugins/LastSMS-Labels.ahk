;;
;; LastSMS Plugin for AdminHelper.ahk
;; Description: Плагин добавляет возможность быстро отвечать на SMS без ввода Id отправителя
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b11 (Mar 06, 2015)
;; Required modules: SAMP-UDF-Ex, SendChatSavingMessage, Chatlog
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
