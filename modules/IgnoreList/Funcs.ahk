;;
;; IgnoreList Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class IgnoreList
{
  _ignoreList := []

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
}

IgnoreList := new IgnoreList()

checkInIgnoreList(PlayerNick)
{
  Return IgnoreList.check(PlayerNick)
}
