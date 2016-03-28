;;
;; IgnoreList Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class IgnoreList
{
  _ignoreList := []

  __hasValueInArray(Array, Value)
  {
    for Key, Val in Array {
      if (Val = Value) {
        Return Key
      }
    }
    Return 0
  }

  ignoreListRead()
  {
    Global Config

    IgnoreListFile := Config["modules"]["IgnoreList"]["File"]

    FileRead, Contents, %IgnoreListFile%
    if not ErrorLevel
    {
      Loop, parse, Contents, `n, `r
      {
        ListString := Trim(A_LoopField)

        if (StrLen(ListString) > 0) {
          RegExMatch(ListString, "([a-zA-Z0-9\_]){3,20}", PlayerNick)

          if (PlayerNick) {
            this._ignoreList.Insert(PlayerNick)
          }
        }
      }

      Contents =
    }

    Return
  }

  check(PlayerNick)
  {
    this.ignoreListRead()

    if (PlayerNick = getUsername()) {
      Return True
    }

    for Key, Nick in this._ignoreList {
      if (Nick = PlayerNick) {
        Return True
      }
    }

    Return
  }

  getNicksFromData(Data)
  {
    Nicks := []

    Loop, % (Data.MaxIndex() - 1)
    {
      DataValue := Data[A_Index + 1]

      NickName := RegExReplace(DataValue, "[^a-zA-Z0-9\_]", "")

      if (StrLen(NickName) && NickName = Data[2]) {
        UserId := RegExReplace(DataValue, "[^0-9]", "")

        if (StrLen(UserId) && StrLen(UserId) >= 0 && StrLen(UserId) <= 999 && UserId = NickName) {
          hardUpdateOScoreboardData()

          NickName := getPlayerNameById(UserId)

          if (!NickName) {
            addMessageToChatWindow("{FF0000} »грок с ID " UserId " не найден в игре.")

            Continue
          }

          Nicks.Insert(NickName)
        } else {
          if (StrLen(NickName) < 3 || StrLen(NickName) > 20) {
            addMessageToChatWindow("{FF0000} Ќеверно введЄн ник игрока: " NickName ".")

            Continue
          }

          Nicks.Insert(NickName)
        }
      }
    }

    Return Nicks
  }

  add(Data)
  {
    addMessageToChatWindow("{FFFF00}ƒобавлены в »гнорЋист следующие игроки:")

    NickNames := this.getNicksFromData(Data)

    Loop, % NickNames.MaxIndex()
    {
      NickName := NickNames[A_Index]

      if (this.__hasValueInArray(this._ignoreList, NickName)) {
        addMessageToChatWindow("{FF0000} " NickName " пропущен, т.к. уже находитс€ в »гнорЋисте.")

        Continue
      }

      this._ignoreList.Insert(NickNames[A_Index])
      addMessageToChatWindow("{00D900} " NickName)
    }

    Return
  }

  remove(Data)
  {
    addMessageToChatWindow("{FFFF00}”далены из »гнорЋиста следующие игроки:")

    NickNames := this.getNicksFromData(Data)

    Loop, % NickNames.MaxIndex()
    {
      NickName := NickNames[A_Index]
      NickNameIndex := this.__hasValueInArray(this._ignoreList, NickName)

      if (!NickNameIndex) {
        addMessageToChatWindow("{FF0000} " NickName " не найден в »гнорЋисте.")

        Continue
      }

      this._ignoreList.RemoveAt(NickNameIndex)
      addMessageToChatWindow("{00D900} " NickName)
    }

    Return
  }
}

IgnoreList := new IgnoreList()

CMD.commands["/ignore"] := "IgnoreList.add"
CMD.commands["/unignore"] := "IgnoreList.remove"

checkInIgnoreList(PlayerNick)
{
  Return IgnoreList.check(PlayerNick)
}
