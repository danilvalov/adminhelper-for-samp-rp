;;
;; TakeNearby Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class TakeNearby
{
  _run := 0

  _type := "guns"

  _playersList := []
  _currentPlayersList := []

  _step := 1

  start() {
    this._step := 1

    this._playersList := NearbyPlayers.get(["/take", "8"])

    if (!this._playersList.MaxIndex()) {
      Return
    }

    this._currentPlayersList := this._playersList.Clone()

    this._run := 1

    addMessageToChatWindow("{FFFF00}Сбор " (this._type = "narko" ? "наркотиков" : "оружия") " запущен.")

    Sleep 600

    SetTimer, TakeNearbyTimer, 600

    Return
  }

  stop() {
    this._run := 0

    Return
  }

  toggle() {
    if (!this._run) {
      this.start()
    } else {
      this.stop()
    }

    Return
  }

  getNeededPosition(DialogText) {
    DialogTextSplit := StrSplit(DialogText, "`n")

    Loop, % DialogTextSplit.MaxIndex()
    {
      if (InStr(DialogTextSplit[A_Index], (this._type = "narko" ? "Наркотики" : "Оружие"))) {
        Return A_Index
      }
    }

    Return False
  }

  take() {
    if (isInChat()) {
      DialogText := getDialogText()

      if (!DialogText) {
        Return False
      }

      NeededPosition := this.getNeededPosition(DialogText)

      if (!NeededPosition || this.step = 2) {
        SendInput {Esc}

        this._step := 1

        Return False
      }

      Loop, % (NeededPosition - 2)
      {
        SendInput {Down}
      }

      SendInput {Enter}

      this._step := 2
    } else {
      if (!this._currentPlayersList.MaxIndex()) {
        SetTimer, TakeNearbyTimer, Off

        this._run := 0

        showGameText("Take" (this._type = "narko" ? "Narko" : "Guns") " [ID: " this._currentPlayersList[1] "] [Players: " (this._playersList.MaxIndex() - this._currentPlayersList.MaxIndex()) " / " this._playersList.MaxIndex() "]", 1200, 4)

        addMessageToChatWindow("{FFFF00}Сбор " (this._type = "narko" ? "наркотиков" : "оружия") " закончен.")

        Return
      }

      sendChatMessage("/take " this._currentPlayersList[1])

      this._currentPlayersList.RemoveAt(1)

      Return
    }

    Return
  }

  timer() {
    if (this._run) {
      this.take()
    } else {
      SetTimer, TakeNearbyTimer, Off

      addMessageToChatWindow("{FF0000}Сбор " (this._type = "narko" ? "наркотиков" : "оружия") " принудительно остановлен.")
    }

    Return
  }

  guns(Data) {
    this._type := "guns"

    this.toggle()

    Return
  }

  narko(Data) {
    this._type := "narko"

    this.toggle()

    Return
  }
}

TakeNearby := new TakeNearby()

CMD.commands["takeguns"] := "TakeNearby.guns"
CMD.commands["takenarko"] := "TakeNearby.narko"
