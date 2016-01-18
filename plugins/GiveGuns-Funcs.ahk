;;
;; GiveGuns Plugin for AdminHelper.ahk
;; Description: Плагин добавляет возможность быстро раздать оружие всем игрокам, находящимся в указанном радиусе от вас
;; CMD: /giveguns
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b8 (Dec 26, 2015)
;; Required modules: SAMP-UDF-Ex, CMD, SAMP-NearbyPlayers
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

      showGameText("GiveGuns [Guns: " this.currentGunIndex "/" this.gunIDs.MaxIndex() "] [Players: " (this._playersCount + 1 - this._playersList.MaxIndex()) "/" this._playersCount "]", 1200, 4)

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

  init(Data)
  {
    if (!this._run) {
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
    } else {
      this._run := 0
      this.currentGunIndex := 1
      SetTimer, GiveGunsTimer, Off

      addMessageToChatWindow("{FFFF00}Цикл выдачи оружия был остановлен.")
    }

    Return
  }
}

GiveGuns := new GiveGuns()


CMD.commands["giveguns"] := "GiveGuns.init"

