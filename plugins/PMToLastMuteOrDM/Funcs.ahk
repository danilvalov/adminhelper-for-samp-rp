;;
;; PMToLastMuteOrDM Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

PMToLastMuteOrDM =

PMToLastMuteOrDMChatlogChecker(ChatlogString)
{
  global PMToLastMuteOrDM

  LocalNickName := getUsername()

  NickName :=

  if (StrLen(LocalNickName)) {
    if (InStr(ChatlogString, "Администратор " LocalNickName) && InStr(ChatlogString, " посадил в Деморган")) {
      NickName := SubStr(ChatlogString, InStr(ChatlogString, " посадил в Деморган ") + StrLen(" посадил в Деморган "))
      NickName := SubStr(NickName, 1, InStr(NickName, ",") - 1)
      NickName := Trim(NickName)
    } else if (InStr(ChatlogString, " получил бан чата от администратора " LocalNickName)) {
      NickName := SubStr(ChatlogString, 2, InStr(ChatlogString, " получил") - 2)
      NickName := Trim(NickName)
    } else if (InStr(ChatlogString, "Администратор " LocalNickName " снял бан чата у ")) {
      NickName := SubStr(ChatlogString, InStr(ChatlogString, "снял бан чата у") + StrLen("снял бан чата у") + 1)
      NickName := Trim(NickName)
    } else if (SubStr(ChatlogString, 2, StrLen("Вы посадили")) = "Вы посадили") {
      NickName := SubStr(ChatlogString, StrLen("Вы посадили") + 3)
      NickName := SubStr(NickName, 1, InStr(NickName, "на") - 2)
      NickName := Trim(NickName)
    }
  }

  if (StrLen(NickName)) {
    RegExMatch(NickName, "\[(\d){1,3}]", Ids)

    if (StrLen(Ids)) {
      Id := SubStr(Ids, 2, -1)
    } else if (StrLen(NickName)) {
      Id := getPlayerIdByName(NickName)
    }

    if (!StrLen(Id) && StrLen(NickName) >= 0) {
      hardUpdateOScoreboardData()
      Sleep 500
      Id := getPlayerIdByName(NickName)
    }

    if (StrLen(Id) && Id >= 0) {
      PMToLastMuteOrDM := Id
    }
  }
}

Chatlog.checker.Insert("PMToLastMuteOrDMChatlogChecker")

HotKeyRegister(Config["plugins"]["PMToLastMuteOrDM"]["Key"], "PMToLastMuteOrDMHotKey")
