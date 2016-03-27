;;
;; ReconLastPM Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

ReconLastPM =

ReconLastPMChatlogChecker(ChatlogString)
{
  global ReconLastPM

  if (SubStr(ChatlogString, 2, StrLen("∆алоба от ")) = "∆алоба от ") {
    NickName := SubStr(ChatlogString, InStr(ChatlogString, " на ") + StrLen(" на "))
    NickName := SubStr(NickName, 1, InStr(NickName, ":") - 1)

    if (StrLen(NickName)) {
        RegExMatch(NickName, "\[(\d){1,3}]", ReconLastPMID)

        if (StrLen(ReconLastPMID) && SubStr(ReconLastPMID, 2, -1) > 0) {
          ReconLastPMID := SubStr(ReconLastPMID, 2, -1)
        } else if (StrLen(NickName)) {
          RegExMatch(NickName, "([a-zA-Z0-9\_]){3,20}", NickName)

          if (StrLen(NickName)) {
            ReconLastPMID := getPlayerIdByName(NickName)
          }
        }

        if (!StrLen(ReconLastPMID) && StrLen(NickName)) {
          hardUpdateOScoreboardData()
          Sleep 500
          ReconLastPMID := getPlayerIdByName(NickName)
        }

        if (!(StrLen(ReconLastPMID) && ReconLastPMID >= 0)) {
          RegExMatch(SubStr(ChatlogString, InStr(ChatlogString, ": ") + 2), "(\d){1,3}", ReconLastPMID)
        }
      }

    if (StrLen(ReconLastPMID)) {
      ReconLastPM := ReconLastPMID
    }
  }
}

Chatlog.checker.Insert("ReconLastPMChatlogChecker")

HotKeyRegister(Config["plugins"]["ReconLastPM"]["Key"], "ReconLastPMHotKey")
