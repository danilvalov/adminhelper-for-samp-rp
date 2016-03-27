;;
;; GiveGuns Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class GiveGuns
{
  _run := 0
  _playersList := []
  _playersCount := 0
  gunIDs := []
  currentGunIndex := 1

  timer()
  {
    if (this._run && this._playersList.MaxIndex()) {
      CurrentGunID := this.gunIDs[this.currentGunIndex]
      sendChatMessage("/givegun " this._playersList[1] " " CurrentGunID " 999")

      showGameText("GiveGuns [ID: " this._playersList[1] "] [Guns: " this.currentGunIndex "/" this.gunIDs.MaxIndex() "] [Players: " (this._playersCount + 1 - this._playersList.MaxIndex()) "/" this._playersCount "]", 1200, 4)

      this.currentGunIndex++

      if (this.currentGunIndex > this.gunIDs.MaxIndex()) {
        this.currentGunIndex := 1
        this._playersList.RemoveAt(1)
      }
    } else {
      this._run := 0
      SetTimer, GiveGunsTimer, Off
      this.currentGunIndex := 1

      addMessageToChatWindow("{FFFF00}Цикл выдачи оружия закончен.")
    }

    Return
  }

  _stop()
  {
    if (this._run) {
      this._run := 0
      this.currentGunIndex := 1
      SetTimer, GiveGunsTimer, Off

      addMessageToChatWindow("{FFFF00}Цикл выдачи оружия был остановлен.")

      Return True
    }

    Return False
  }

  _addPlayers(Ids)
  {
    playersIds := StrSplit(Ids, ",")
    this._playersList := []

    addMessageToChatWindow("{FFFF00}Добавлены в список выдачи оружия следующие игроки:")

    hardUpdateOScoreboardData()

    Loop, % playersIds.MaxIndex()
    {
      Id := Trim(playersIds[A_Index])
      Id := RegExReplace(Id, "[^0-9]", "")
      PlayerName := getPlayerNameById(Id)

      if (StrLen(Id) && StrLen(PlayerName)) {
        this._playersList.Insert(Id)
        addMessageToChatWindow("{00D900} " PlayerName "[" Id "]")
      }
    }

    if (!this._playersList.MaxIndex()) {
      addMessageToChatWindow("{FF0000}Неверно введены IDы, или все указанные игроки оффлайн.")
    }

    Return
  }

  ids(Data)
  {
    Ids := RegExReplace(Data[2], "[^0-9,]", "")
    CheckIds := RegExReplace(Data[2], "[^0-9]", "")

    if (!StrLen(CheckIds)) {
      addMessageToChatWindow("{FF0000}Неверный формат. {FFFFFF}Введите: {FFFF00}/giveiguns [id_игроков,через_запятую] [id_оружия,через_запятую]")
    }

    if (!this._stop()) {
      Sleep 1200

      this._addPlayers(Ids)

      GunID := RegExReplace(Data[3], "[^0-9,]", "")
      GunID := StrLen(GunID) ? GunID : 31

      this.gunIDs := StrSplit(GunID, ",")

      this._run := 1
      this._playersCount := this._playersList.MaxIndex()

      if (this._playersList.MaxIndex()) {
        addMessageToChatWindow("{FFFF00}Цикл выдачи оружия запущен.")

        SetTimer, GiveGunsTimer, 1200
      } else {
        this._run := 0
      }
    }

    Return
  }

  nearby(Data)
  {
    if (!this._stop()) {
      Sleep 1200

      GunID := RegExReplace(Data[2], "[^0-9,]", "")
      GunID := StrLen(GunID) ? GunID : 31

      this.gunIDs := StrSplit(GunID, ",")

      Data.RemoveAt(2)

      this._run := 1
      this._playersList := NearbyPlayers.get(Data)
      this._playersCount := this._playersList.MaxIndex()

      if (this._playersList.MaxIndex()) {
        addMessageToChatWindow("{FFFF00}Цикл выдачи оружия запущен.")

        SetTimer, GiveGunsTimer, 1200
      } else {
        this._run := 0
      }
    }

    Return
  }
}

GiveGuns := new GiveGuns()


CMD.commands["giveguns"] := "GiveGuns.nearby"
CMD.commands["giveiguns"] := "GiveGuns.ids"
