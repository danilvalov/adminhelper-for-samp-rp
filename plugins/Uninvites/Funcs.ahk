;;
;; Uninvites Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class Uninvites
{
  _playersList := []
  _playersCount := 0
  _playersListInFaction := []
  _playersListWithoutFaction := []
  runOnline := 0
  runOffline := 0
  runOfflineList := 0

  checkItemInArray(CheckArray, Value)
  {
    Loop, % CheckArray.MaxIndex()
    {
      if (CheckArray[A_Index] = Value) {
        Return A_Index
      }
    }

    Return False
  }

  ignore(Data)
  {
    Loop, % (Data.MaxIndex() - 2)
    {
      Player := Trim(Data[A_Index + 2])

      if (RegExReplace(Player, "[^0-9]", "") = Player) {
        PlayerNick := getPlayerNameById(Player)
      } else {
        PlayerNick := Player
      }

      if (StrLen(PlayerNick)) {
        newPlayersList := []
        checkIgnore := False
        for Key, Player in this._playersList {
          if (PlayerNick <> Player) {
            newPlayersList.Insert(Player)
          } else {
            addMessageToChatWindow("{FF0000} Игрок " Player " будет пропущен при увольнении.")
            checkIgnore := True
          }
        }

        if (checkIgnore) {
          this._playersList := newPlayersList
        } else {
          addMessageToChatWindow("{FF0000} Игрок " Player " не был найден во фракции.")
        }
      }
    }

    Return
  }

  online(Data)
  {
    if(!this.stop()) {
      Sleep 1200

      FId := RegExReplace(Data[2], "[^0-9]", "")

      if (StrLen(FId)) {
        Chatlog.reader()

        this._playersList := []

        this.runOnline := 1

        sendChatMessage("/amembers " FId)

        Sleep 1200

        Chatlog.reader()

        this.ignore(Data)

        this._playersCount := this._playersList.MaxIndex()

        this.start()
      } else {
        addMessageToChatWindow("{FFFFFF}Для увольнения игроков онлайн введите: {FFFF00}/uninvites [id_фракции] [ид/ник игрока, которого не нужно увольнять] [ид/ник игрока, которого не нужно увольнять] ...")
      }
    }

    Return
  }

  offline(Data)
  {
    if(!this.stop()) {
      Sleep 1200

      FId := RegExReplace(Data[2], "[^0-9]", "")

      if (StrLen(FId)) {
        Chatlog.reader()

        this._playersList := []

        this.runOffline := 1

        sendChatMessage("/offmembers " FId)

        Sleep 5000

        addMessageToChatWindow("{FFFF00}В течение 5-ти секунд запустится цикл увольнения.")

        Sleep 5000

        Chatlog.reader()

        Sleep 1200

        this.ignore(Data)

        this._playersCount := this._playersList.MaxIndex()

        this.start()
      } else {
        addMessageToChatWindow("{FFFFFF}Для увольнения игроков оффлайн введите: {FFFF00}/offuninvites [id_фракции] [ид/ник игрока, которого не нужно увольнять] [ид/ник игрока, которого не нужно увольнять] ...")
      }
    }

    Return
  }

  list(Data)
  {
    if(!this.stop()) {
      Sleep 1200

      FId := RegExReplace(Data[2], "[^0-9]", "")

      if (StrLen(FId)) {
        Chatlog.reader()

        this._playersList := []
        this._playersListInFaction := []
        this._playersListWithoutFaction := []

        this.readListFile()

        if (!this._playersList.MaxIndex()) {
          addMessageToChatWindow("{FF0000}Список игроков для увольнения пуст.")

          Return
        }

        this.runOfflineList := 1

        sendChatMessage("/offmembers " FId)

        Sleep 5000

        addMessageToChatWindow("{FFFF00}В течение 5-ти секунд запустится цикл увольнения.")

        Sleep 5000

        Chatlog.reader()

        Sleep 1200

        this.checkPlayersWithoutFaction()

        if (this._playersList.MaxIndex()) {
          this.ignore(Data)

          this._playersCount := this._playersList.MaxIndex()

          this.start()
        } else {
          addMessageToChatWindow("{FF0000}Список игроков для увольнения пуст.")

          this.runOfflineList := 0

          this.showPlayerListWithoutFaction()

          this.clearListFile()
        }
      } else {
        addMessageToChatWindow("{FFFFFF}Для увольнения игроков по списку введите: {FFFF00}/listuninvites [id_фракции]")
      }
    } else {
      this.showPlayerListWithoutFaction()
    }

    Return
  }

  checkPlayersWithoutFaction()
  {
    Loop, % this._playersList.MaxIndex()
    {
      if (!this.checkItemInArray(this._playersListInFaction, this._playersList[A_Index])) {
        this._playersListWithoutFaction.Insert(this._playersList[A_Index])
      }
    }

    Loop, % this._playersListWithoutFaction.MaxIndex()
    {
      this._playersList.RemoveAt(this.checkItemInArray(this._playersList, this._playersListWithoutFaction[A_Index]))
    }

    Return
  }

  readListFile()
  {
    Global Config

    FileRead, Contents, % Config["plugins"]["Uninvites"]["ListFile"]
    if not ErrorLevel
    {
      Loop, parse, Contents, `n, `r
      {
        ListString := Trim(A_LoopField)

        if (StrLen(ListString) > 0) {
          RegExMatch(ListString, "([a-zA-Z0-9\_]){3,20}", PlayerNick)

          if (PlayerNick) {
            this._playersList.Insert(PlayerNick)
          }
        }
      }

      Contents =
    }

    Return
  }

  clearListFile()
  {
    Global Config

    FileAppend, , % ".cache\" Config["plugins"]["Uninvites"]["ListFile"] ".tmp"
    FileCopy, % ".cache\" Config["plugins"]["Uninvites"]["ListFile"] ".tmp", % Config["plugins"]["Uninvites"]["ListFile"], 1
    FileDelete, % ".cache\" Config["plugins"]["Uninvites"]["ListFile"] ".tmp"

    addMessageToChatWindow("{FF0000}Очищен файл списка игроков для увольнения.")

    Return
  }

  stop()
  {
    updateOScoreboardData()

    if (this.runOnline || this.runOffline || this.runOfflineList) {
      SetTimer, UninvitesTimer, Off

      addMessageToChatWindow("{FFFF00}Цикл увольнения игроков (" (this.runOffline ? "оффлайн" : (this.runOfflineList ? "по списку" : "онлайн")) ") из фракции остановлен.")

      this.runOnline := 0
      this.runOffline := 0
      this.runOfflineList := 0

      Return True
    }

    Return False
  }

  start()
  {
    if (this._playersList.MaxIndex()) {
      SetTimer, UninvitesTimer, 1200
    }

    Return
  }

  showPlayerListWithoutFaction()
  {
    if (this._playersListWithoutFaction.MaxIndex()) {
      addMessageToChatWindow("{FF0000}Следующие игроки не были уволены, т.к. не состоят в указанной фракции:")

      Loop, % this._playersListWithoutFaction.MaxIndex()
      {
        addMessageToChatWindow("{FF0000} " A_Index ". " this._playersListWithoutFaction[A_Index])
      }

      this._playersListWithoutFaction := []
    }

    Return
  }

  timer()
  {
    updateOScoreboardData()

    if ((this.runOnline || this.runOffline || this.runOfflineList) && this._playersList.MaxIndex()) {
      if (this.runOnline) {
        if (getPlayerIdByName(this._playersList[1]) >= 0) {
          sendChatMessage("/uninvite " getPlayerIdByName(this._playersList[1]) " " (this.runOnline || this.runOffline ? "Расформ" : "!"))
        } else {
          addMessageToChatWindow("{FF0000}Игрок " this._playersList[1] " не найден в игре (возможно, вышел из игры).")
        }
      } else {
        if (getPlayerIdByName(this._playersList[1]) >= 0) {
          sendChatMessage("/uninvite " getPlayerIdByName(this._playersList[1]) " " (this.runOnline || this.runOffline ? "Расформ" : "!"))
        } else {
          sendChatMessage("/offuninvite " this._playersList[1])
        }
      }

      showGameText("Uninvites [" (this._playersCount + 1 - this._playersList.MaxIndex()) "/" this._playersCount "]", 1200, 4)

      this._playersList.RemoveAt(1)
    } else {
      SetTimer, UninvitesTimer, Off

      addMessageToChatWindow("{FFFF00}Цикл увольнения игроков (" (this.runOffline ? "оффлайн" : (this.runOfflineList ? "по списку" : "онлайн")) ") из фракции закончен.")

      if (this.runOfflineList) {
        if (this._playersListWithoutFaction.MaxIndex()) {
          this.showPlayersListWithoutFaction()
        }

        this.clearListFile()
      }

      this.runOnline := 0
      this.runOffline := 0
      this.runOfflineList := 0
    }

    Return
  }
}

Uninvites := new Uninvites()


CMD.commands["uninvites"] := "Uninvites.online"
CMD.commands["offuninvites"] := "Uninvites.offline"
CMD.commands["listuninvites"] := "Uninvites.list"


UninvitesChatlogChecker(ChatlogString)
{
  if (Uninvites.runOnline) {
    RegExMatch(ChatlogString, "\[([0-9]){1,3}] ([a-zA-Z0-9\_]){3,20}  ранг: (\d){1,2}", CheckOnline)

    if (CheckOnline) {
      RegExMatch(SubStr(ChatlogString, InStr(Chatlog, "]") + 2), "\[([a-zA-Z0-9\_]){3,20}]", PlayerNick)
      PlayerNick := SubStr(PlayerNick, 2, -1)
      Uninvites._playersList.Insert(PlayerNick)
    }
  }

  if (Uninvites.runOffline) {
    RegExMatch(ChatlogString, "\[([a-zA-Z0-9\_]){3,20}] \[(\d){1,2}] \[(\d){4}/(\d){2}/(\d){2} (\d){2}:(\d){2}:(\d){2}] \[(\d){4}/(\d){2}/(\d){2} (\d){2}:(\d){2}:(\d){2}]", CheckOffline)

    if (CheckOffline) {
      RegExMatch(ChatlogString, "\[([a-zA-Z0-9\_]){3,20}]", PlayerNick)
      PlayerNick := SubStr(PlayerNick, 2, -1)
      Uninvites._playersList.Insert(PlayerNick)
    }
  }

  if (Uninvites.runOfflineList) {
      RegExMatch(ChatlogString, "\[([a-zA-Z0-9\_]){3,20}] \[(\d){1,2}] \[(\d){4}/(\d){2}/(\d){2} (\d){2}:(\d){2}:(\d){2}] \[(\d){4}/(\d){2}/(\d){2} (\d){2}:(\d){2}:(\d){2}]", CheckOffline)

      if (CheckOffline) {
        RegExMatch(ChatlogString, "\[([a-zA-Z0-9\_]){3,20}]", PlayerNick)
        PlayerNick := SubStr(PlayerNick, 2, -1)
        Uninvites._playersListInFaction.Insert(PlayerNick)
      }
    }
}

Chatlog.checker.Insert("UninvitesChatlogChecker")
