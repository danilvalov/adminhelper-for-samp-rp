;;
;; PMToLastMuteOrDM Plugin for AdminHelper.ahk
;; Description: Плагин добавляет возможность быстро отвечать игроку, которому вы только что выдали БЧ или посадили в ДМ
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b (Apr 18, 2015)
;; Required modules: SAMP-UDF-Ex, SendChatSavingMessage, Chatlog, SAMP-UsersListUpdater
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
