;;
;; NearbyPlayers Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
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
  _nearestPlayer := {}
  _nearestPlayerDistance := -1

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

  getNearestPlayer() {
    this._nearestPlayer := {}
    this._nearestPlayer["ID"] := -1
    this._nearestPlayerDistance := -1

    callFuncForAllStreamedInPlayers("nearestPlayerLoop", 1000)

    Return this._nearestPlayer
  }
}

nearbyPlayers := new nearbyPlayers()

nearbyPlayersLoop(Player)
{
  if (!Player) {
    Return -1
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

nearestPlayerLoop(Player)
{
  if (!Player) {
    Return -1
  }

  if (!checkInIgnoreList(Player.NAME)) {
    Distance := getDist(getCoordinates(), Player.POS)

    if (nearbyPlayers._nearestPlayerDistance < 0 || Distance < nearbyPlayers._nearestPlayerDistance) {
      nearbyPlayers._nearestPlayer := Player
      nearbyPlayers._nearestPlayer["Distance"] := Distance
      nearbyPlayers._nearestPlayerDistance := Distance
    }
  }

  Return
}
