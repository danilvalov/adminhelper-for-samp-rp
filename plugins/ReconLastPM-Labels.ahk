;;
;; ReconLastPM Plugin for AdminHelper.ahk
;; Description: ѕлагин добавл€ет возможность быстро подключатьс€ к ID, указанному в последней жалобе в репорт
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b8 (Jan 19, 2015)
;; Required modules: SAMP-UDF-Ex, SendChatSavingMessage, Chatlog
;;

ReconLastPMHotKey:
{
  Chatlog.reader()
  
  if (StrLen(ReconLastPM)) {
    sendChatSavingMessage("/re " ReconLastPM)
  } else {
    sendChatSavingMessage("/re", False)
  }

  Return
}
