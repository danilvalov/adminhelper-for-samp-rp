;;
;; SetHPs Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class SetHPs
{
  _playersList := []
  _playersCount := 0
  _run := 0
  _hp := 110

  timer()
  {
    if (this._run && this._playersList.MaxIndex()) {
      sendChatMessage("/sethp " this._playersList[1] " " this._hp)

      showGameText("SetHP [ID: " this._playersList[1] "] [" (this._playersCount + 1 - this._playersList.MaxIndex()) "/" this._playersCount "]", 1200, 4)

      this._playersList.RemoveAt(1)
    } else {
      this._run := 0
      SetTimer, SetHPsTimer, Off

      addMessageToChatWindow("{FFFF00}Цикл выдачи HP закончен.")
    }

    Return
  }

  init(Data)
  {
    if (!this._run) {
      Sleep 1200

      HP := RegExReplace(Data[2], "[^0-9]", "")
      HP := StrLen(HP) ? HP : 110
      this._hp := HP

      Data.RemoveAt(2)

      this._run := 1
      this._playersList := NearbyPlayers.get(Data)
      this._playersCount := this._playersList.MaxIndex()

      if (this._playersCount) {
        addMessageToChatWindow("{FFFF00}Цикл выдачи HP запущен.")

        SetTimer, SetHPsTimer, 1200
      } else {
        this._run := 0
      }
    } else {
      this._run := 0
      SetTimer, SetHPsTimer, Off

      addMessageToChatWindow("{FFFF00}Цикл выдачи HP был остановлен.")
    }

    Return
  }
}

SetHPs := new SetHPs()


CMD.commands["sethps"] := "SetHPs.init"
