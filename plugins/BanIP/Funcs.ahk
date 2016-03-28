;;
;; BanIP Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class BanIP
{
  lastBanIP := ""
  checkAccountIsBanned := 0
  checkAccountIsOffline := 0

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

  banWithBanIP(Data) {
    Global Config

    if (Data[4] && StrLen(Data[4]) && Data[4] = "1") {
      this.lastBanIP := ""

      Sleep 1200

      checkAccountIsOffline := 0

      Chatlog.reader()

      if (this.checkAccountIsOffline = 1) {
        Return
      }

      if (!this.lastBanIP || !StrLen(this.lastBanIP)) {
        Return
      }

      sendChatMessage("/banip " this.lastBanIP)

      if (Config["AdminLVL"] >= 4 && Config["plugins"]["BanIP"]["GetIPUsersBoolean"]) {
        sendChatMessage("/pgetip 4 " this.lastBanIP)
      }
    }

    Return
  }

  offbanWithBanIP(Data) {
    if (Data[4] && StrLen(Data[4]) && Data[4] = "1") {
      NickName := RegExReplace(Data[2], "[^a-zA-Z0-9\_]", "")

      if (!NickName || !StrLen(NickName) || NickName != Data[2] || StrLen(NickName) < 3 || StrLen(NickName) > 20) {
        Return
      }

      Sleep 1200

      this.checkAccountIsBanned := 0

      Chatlog.reader()

      if (this.checkAccountIsBanned = 1) {
        Return
      }

      GetIP.RegGetIP :=
      GetIP.LastGetIP :=

      sendChatMessage("/agetip " NickName)

      Sleep 1200

      Chatlog.reader()

      if (!GetIP.LastGetIP || !StrLen(GetIP.LastGetIP)) {
        Return
      }

      sendChatMessage("/banip " GetIP.LastGetIP)
    }

    Return
  }
}

BanIP := new BanIP()


CMD.commands["banipn"] := "BanIP.nick"
CMD.commands["unbanipn"] := "BanIP.nick"
CMD.commands["ban"] := "BanIP.banWithBanIP"
CMD.commands["sban"] := "BanIP.banWithBanIP"
CMD.commands["iban"] := "BanIP.banWithBanIP"
CMD.commands["offban"] := "BanIP.offbanWithBanIP"
CMD.commands["ioffban"] := "BanIP.offbanWithBanIP"


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

  if (InStr(ChatlogString, "Этот аккаунт уже забанен")) {
    BanIP.checkAccountIsBanned := 1
  }

  if (InStr(ChatlogString, "Игрок оффлайн!")) {
    BanIP.checkAccountIsOffline := 1
  }
}

Chatlog.checker.Insert("BanIPChatlogChecker")

HotKeyRegister(Config["plugins"]["BanIP"]["Key"], "BanIPHotKey")
