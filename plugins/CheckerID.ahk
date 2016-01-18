;;
;; CheckerID Plugin for AdminHelper.ahk
;; Description: Плагин является дополнением к s0beit'у. Добавляет команды, позволяющие добавлять в чекер не только по нику, но и по ID, если игрок онлайн
;; CMD: /addcheckid, /delcheckid, /dellcheckid
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b (Apr 04, 2015)
;; Required modules: SAMP-UDF-Ex, SAMP-UsersListUpdater, SendChatSavingMessage, CMD
;;

class CheckerID
{
  add(Data)
  {
    if (hardUpdateOScoreboardData()) {
      if (StrLen(Data[2])) {
        Id := Trim(Data[2])
        Id := RegExReplace(Id, "[^0-9]", "")

        if (StrLen(Id)) {
          PlayerNick := getPlayerNameById(Id)

          if (StrLen(PlayerNick)) {
            Sleep 200
            Description := Data[3]
            sendChatMessage("/addcheck " PlayerNick " " Description)
          }
        }
      }
    }
  }
  
  remove(Data)
  {
    if (hardUpdateOScoreboardData()) {
      Id := Trim(Data[2])
      Id := RegExReplace(Id, "[^0-9]", "")

      if (StrLen(Id)) {
        PlayerNick := getPlayerNameById(Id)

        if (StrLen(PlayerNick)) {
          Sleep 200
          sendChatMessage("/dellcheck " PlayerNick)
        }
      }
    }
  }
}

CheckerID := new CheckerID()

CMD.commands["addcheckid"] := "CheckerID.add"
CMD.commands["delcheckid"] := "CheckerID.remove"
CMD.commands["dellcheckid"] := "CheckerID.remove"
