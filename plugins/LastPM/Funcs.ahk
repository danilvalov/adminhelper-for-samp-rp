;;
;; LastPM Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

LastPM =
LastSetNik =

LastPMChatlogChecker(ChatlogString)
{
  global Config, LastPM, LastSetNik

  NickName :=

  if (SubStr(ChatlogString, 2, StrLen("Репорт от ")) = "Репорт от ") {
    NickName := SubStr(Trim(ChatlogString), StrLen("Репорт от ") + 1)
    NickName := SubStr(Trim(NickName), 1, InStr(Trim(NickName), ": ") - 1)
    NickName := Trim(NickName)
  } else if (SubStr(ChatlogString, 2, StrLen("Жалоба от ")) = "Жалоба от ") {
    NickName := SubStr(Trim(ChatlogString), StrLen("Жалоба от ") + 1)
    NickName := SubStr(Trim(NickName), 1, InStr(Trim(NickName), " ") - 1)
    NickName := Trim(NickName)
  } else if (!Config["plugins"]["LastPM"]["OnlyReceivedBoolean"] && SubStr(ChatlogString, 1, StrLen("<-Ответ К")) = "<-Ответ К") {
    NickName := SubStr(Trim(ChatlogString), StrLen("<-Ответ К") + 1)
    NickName := SubStr(Trim(NickName), 1, InStr(Trim(NickName), ": ") - 1)
    NickName := Trim(NickName)
  } else if (SubStr(Trim(ChatlogString), 1, StrLen("[Заявка на смену ника]")) = "[Заявка на смену ника]" && InStr(ChatlogString, "просит сменить ник на:")) {
    NickName := SubStr(ChatlogString, InStr(ChatlogString, "[Заявка на смену ника] ") + StrLen("[Заявка на смену ника] "))
    NickName := SubStr(NickName, 1, InStr(NickName, "просит сменить ник на:") - 1)
    NickName := Trim(NickName)
  } else if (SubStr(Trim(ChatlogString), 1, StrLen("->Вопрос")) = "->Вопрос") {
    NickName := SubStr(Trim(ChatlogString), StrLen("->Вопрос") + 1)
    NickName := SubStr(Trim(NickName), 1, InStr(Trim(NickName), ": ") - 1)
    NickName := Trim(NickName)
  }

  if (StrLen(NickName)) {
    RegExMatch(NickName, "\[(\d){1,3}]", LastPMID)
    if (StrLen(LastPMID)) {
      Id := SubStr(LastPMID, 2, -1)
    } else if (StrLen(NickName)) {
      Id := getPlayerIdByName(NickName)
    }

    if (!StrLen(Id) && StrLen(NickName) >= 0) {
      hardUpdateOScoreboardData()
      Sleep 500
      Id := getPlayerIdByName(NickName)
    }

    if (StrLen(Id) && Id >= 0) {
      LastPM := Id

      if (SubStr(Trim(ChatlogString), 1, 22) = "[Заявка на смену ника]" && InStr(ChatlogString, "просит сменить ник на:")) {
        LastSetNik := Id
      }
    }
  }
}

Chatlog.checker.Insert("LastPMChatlogChecker")

HotKeyRegister(Config["plugins"]["LastPM"]["Key"], "LastPMHotKey")
