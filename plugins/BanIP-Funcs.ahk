;;
;; BanIP Plugin for AdminHelper.ahk
;; Description: Плагин банит по IP последнего забаненного игрока
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b9 (Jan 24, 2015)
;; Required modules: SAMP-UDF-Ex, SendChatSavingMessage, Chatlog
;; Required plugins: GetIP
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
      sendChatMessage("/banip " GetIP.LastGetIP)
    } else {
      addMessageToChatWindow("{FF0000} Данные по IP не найдены в чате.")
    }

    Return
  }

  hotkey()
  {
    global AdminLVL, BanIPGetIPUsersBoolean, BanIPEnterBoolean

    Chatlog.reader()

    if (StrLen(this.lastBanIP)) {
      if (BanIPEnterBoolean) {
        sendChatSavingMessage("/banip " this.lastBanIP)

        Sleep 1200
      }

      if (AdminLVL >= 4 && BanIPGetIPUsersBoolean) {
        sendChatSavingMessage("/pgetip 4 " this.lastBanIP)
      }

      if (!BanIPEnterBoolean) {
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


BanIPChatlogChecker(ChatlogString)
{
  if (SubStr(ChatlogString, 1, 9) = "    Nik [" && InStr(ChatlogString, "R-IP [") && InStr(ChatlogString, "L-IP [")) {
    RegExMatch(ChatlogString, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", LastBanIP, -17)

    if (StrLen(LastBanIP)) {
      BanIP.lastBanIP := LastBanIP
    }
  }
}

Chatlog.checker.Insert("BanIPChatlogChecker")


Hotkey, %BanIPKey%, BanIPHotKey
