;;
;; LastPM Plugin for AdminHelper.ahk
;; Description: Плагин добавляет возможность быстро отвечать на репорты без ввода Id отправителя жалобы
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b11 (Mar 06, 2015)
;; Required modules: SAMP-UDF-Ex, SendChatSavingMessage, Chatlog
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
