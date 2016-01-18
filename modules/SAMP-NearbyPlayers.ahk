;;
;; NearbyPlayers Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b (Apr 18, 2015)
;; Required modules: SAMP-UDF-Ex, Chatlog
;;

class nearbyPlayers
{
  defaultRadius := 30
  defaultMinLVL := 1
  defaultMaxLVL := 100

  radius := this.defaultRadius
  minLVL := this.defaultMinLVL
  maxLVL := this.defaultMaxLVL

  _playersList := []

  get(Data)
  {
    RegExMatch(Data[2], "(\d){1,3}", Radius)
    if (!StrLen(Radius)) {
      Radius := this.defaultRadius
    }

    RegExMatch(Data[3], "(\d){1,2}-(\d){1,2}", LVL)
    if (StrLen(LVL)) {
      LVLArray := StrSplit(LVL, "-")
      this.minLVL := LVLArray[1]
      this.maxLVL := LVLArray[2]
    } else {
      RegExMatch(Data[3], "(\d){1,2}", LVL)
      this.minLVL := LVL
      this.maxLVL := this.defaultMaxLVL
    }
    if (!StrLen(this.minLVL)) {
      minLVL := this.defaultMinLVL
    }
    if (!StrLen(this.maxLVL)) {
      maxLVL := this.defaultMaxLVL
    }

    this._playersList := []

    callFuncForAllStreamedInPlayers("nearbyPlayersLoop", Radius)

    if (this._playersList.MaxIndex()) {
      addMessageToChatWindow("{FFFF00}Сбор игроков, находящихся рядом, закончен [" this._playersList.MaxIndex() "].")
    } else {
      addMessageToChatWindow("{FF0000}Рядом не найдено ни одного подходящего игрока.")
    }

    Return this._playersList
  }
}

nearbyPlayers := new nearbyPlayers()

nearbyPlayersLoop(Player)
{
  if (!Player) {
    Return
  }

  if (checkInIgnoreList(Player.NAME)) {
    addMessageToChatWindow("{FF0000} " Player.NAME "[" Player.ID "] пропущен (находится в игнор-листе)")
  } else if (Player.SCORE < nearbyPlayers.minLVL || Player.SCORE > nearbyPlayers.maxLVL) {
    addMessageToChatWindow("{FF0000} " Player.NAME "[" Player.ID "] пропущен (не подходит по LVL)")
  } else {
    nearbyPlayers._playersList.Insert(Player.ID)
    addMessageToChatWindow("{00D900} " Player.NAME "[" Player.ID "]")
  }

  Return
}
