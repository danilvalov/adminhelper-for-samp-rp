;;
;; Parachute Event for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class ParachuteEvent
{
  _playersList := []
  _playersSMSList := []
  minSMSLVL := 1
  __step := 1
  __running := 0

  __hasValueInArray(Array, Value)
  {
    for Key, Val in Array {
      if (Val = Value) {
        Return Key
      }
    }
    Return 0
  }

  start(Data)
  {
    if (this.__running) {
      this.stop()

      Return
    }

    Chatlog.reader()

    hardUpdateOScoreboardData()

    this.minSMSLVL := 1

    MinLVL := 1
    if (StrLen(Trim(Data[3])) && StrLen(RegExReplace(Trim(Data[3]), "[^0-9]", ""))) {
      MinLVL := Trim(Data[3])
      MinLVL := RegExReplace(MinLVL, "[^0-9]", "")
    }
    if (MinLVL) {
      this.minSMSLVL := MinLVL
    }

    addMessageToChatWindow("{FFFF00}Начинается телепортация игроков для Мероприятия ""Парашюты"".")
    this.__running := 1

    SetTimer, ParachuteEventTimer, 1200

    Chatlog.startTimer()

    Return
  }

  stop()
  {
    if (this.__running) {
      Chatlog.stopTimer()

      this.__running := 0

      this.__step := 1

      this._playersList := []

      addMessageToChatWindow("{FFFF00}Мероприятие ""Парашюты"" было остановлено.")

      Return True
    }

    Return False
  }

  timer()
  {
    if (this.__running) {
      if (this._playersSMSList.MaxIndex()) {
        if (this.__step = 1) {
          sendChatMessage("/givegun " this._playersSMSList[1] " 46 1")

          showGameText("Parachute [ID: " this._playersSMSList[1] "] [" (this._playersList.MaxIndex() + 1 - this._playersSMSList.MaxIndex()) "/" this._playersList.MaxIndex() "]", 2400, 4)

          this.__step := 2
        } else {
          sendChatMessage("/gethere " this._playersSMSList[1])

          this._playersSMSList.RemoveAt(1)

          this.__step := 1
        }
      }
    } else {
      SetTimer, ParachuteEventTimer, Off
    }

    Return
  }
}

ParachuteEvent := new ParachuteEvent()


ParachuteEventChatlogChecker(ChatlogString)
{
  if (ParachuteEvent.__running && SubStr(ChatlogString, 2, 5) = "SMS: " && InStr(ChatlogString, ". Отправитель: ")) {
    RegExMatch(SubStr(ChatlogString, StrLen(ChatlogString) - 3), "(\d){1,3}", Id)

    if (StrLen(Id) > 0 && !ParachuteEvent.__hasValueInArray(ParachuteEvent._playersSMSList, Id)) {
      PlayerNick := SubStr(ChatlogString, InStr(ChatlogString, ". Отправитель: ") + StrLen(". Отправитель: "))
      PlayerNick := SubStr(PlayerNick, 1, InStr(PlayerNick, "[") - 1)

      if (checkInIgnoreList(PlayerNick)) {
        addMessageToChatWindow("{FF0000} " PlayerNick "[" Id "] пропущен (находится в игнор-листе).")
      } else if (getPlayerScoreById(Id) < ParachuteEvent.minSMSLVL) {
        addMessageToChatWindow("{FF0000} " PlayerNick "[" Id "] пропущен (не подходит по LVL).")
      } else {
        if (!ParachuteEvent.__hasValueInArray(ParachuteEvent._playersList, Id)) {
          ParachuteEvent._playersList.Insert(Id)
        }

        ParachuteEvent._playersSMSList.Insert(Id)

        addMessageToChatWindow("{00D900}[" ParachuteEvent._playersList.MaxIndex() "] Добавлен игрок " PlayerNick "[" Id "]")
      }
    }
  }
}

Chatlog.checker.Insert("ParachuteEventChatlogChecker")
