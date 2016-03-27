;;
;; BanIP Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class BanIP
{
  lastBanIP :=

  nick(Data)
  {
    NickName := RegExReplace(Data[2], "[^a-zA-Z0-9\_]", "")

    if (StrLen(NickName) < 3 || StrLen(NickName) > 20) {
      addMessageToChatWindow("{FF0000} Неверно введён ник игрока.")

      Return False
    }

    Sleep 1200

    sendChatMessage("/agetip " NickName)

    GetIP.RegGetIP :=
    GetIP.LastGetIP :=

    Sleep 1100

    Chatlog.reader()

    Sleep 100

    if (!StrLen(GetIP.LastGetIP)) {
      Sleep 1100

      Chatlog.reader()
    }

    if (StrLen(GetIP.LastGetIP)) {
      sendChatMessage(SubStr(Data[1], 1, -1) " " GetIP.LastGetIP)
    } else {
      addMessageToChatWindow("{FF0000} Данные по IP не найдены в чате.")
    }

    Return
  }

  hotkey()
  {
    global Config

    Chatlog.reader()

    if (StrLen(this.lastBanIP)) {
      if (Config["plugins"]["BanIP"]["EnterBoolean"]) {
        sendChatMessage("/banip " this.lastBanIP)

        Sleep 1200
      }

      if (Config["AdminLVL"] >= 4 && Config["plugins"]["BanIP"]["GetIPUsersBoolean"]) {
        sendChatMessage("/pgetip 4 " this.lastBanIP)
      }

      if (!Config["plugins"]["BanIP"]["EnterBoolean"]) {
        sendChatSavingMessage("/banip " this.lastBanIP, False)
      }
    } else {
      sendChatSavingMessage("/banip", False)
    }

    Return
  }
}

BanIP := new BanIP()


CMD.commands["banipn"] := "BanIP.nick"
CMD.commands["unbanipn"] := "BanIP.nick"


BanIPChatlogChecker(ChatlogString)
{
  Global Config

  if (SubStr(ChatlogString, 1, 9) = "    Nik [" && InStr(ChatlogString, "R-IP [") && InStr(ChatlogString, "L-IP [")) {
    RegExMatch(ChatlogString, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", LastBanIP, -17)

    if (StrLen(LastBanIP)) {
      BanIP.lastBanIP := LastBanIP
    }
  }

  if (!Config["plugins"]["BanIP"]["EnterBoolean"] && Config["plugins"]["BanIP"]["GetIPBoolean"] && SubStr(Trim(ChatlogString), 1, 5) = "Nik [" && (InStr(ChatlogString, "R-IP [") || InStr(ChatlogString, "Register-IP [")) && (InStr(ChatlogString, "L-IP [") || InStr(ChatlogString, "Last-IP ["))) {
    RegExMatch(ChatlogString, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", LastBanIP, -17)

    if (StrLen(LastBanIP)) {
      BanIP.lastBanIP := LastBanIP
    }
  }
}

Chatlog.checker.Insert("BanIPChatlogChecker")

HotKeyRegister(Config["plugins"]["BanIP"]["Key"], "BanIPHotKey")
