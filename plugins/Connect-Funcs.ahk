;;
;; Connect Plugin for AdminHelper.ahk
;; Description: Плагин позволяет подключаться/переподключаться к серверам, не выходя из игры
;; CMD: /connect, /reconnect
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b10 (Fev 11, 2015)
;; Required modules: SAMP-UDF-Ex, SAMP-UDF-Addon, CMD
;;

class Connect
{
  _serversList := []

  serversListRead()
  {
    Global ConnectServersFile

    this.serversList := []
    ServerName =

    FileRead, Contents, %A_ScriptDir%\%ConnectServersFile%
    if not ErrorLevel
    {
      Loop, Parse, Contents, `n, `r
      {
        Line := Trim(A_LoopField)
        if (StrLen(Line)) {
          RegExMatch(Line, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", IP)

          if (SubStr(Line, 1, 1) = "[" && SubStr(Line, 0) = "]") {
            ServerName := SubStr(Line, 2, -1)
          } else if (StrLen(IP) && IP = Line && StrLen(ServerName)) {
            ServerObject := {}
            ServerObject["name"] := ServerName
            ServerObject["ip"] := IP
            this._serversList.Insert(ServerObject)
            ServerName := ""
          }
        }
      }
    } else {
      MsgBox, Ошибка: не удаётся открыть файл со списком серверов

      Return False
    }

    Return True
  }

  connect(Data)
  {
    Server := Data[2]

    this.serversListRead()

    RegExMatch(Server, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", IP)
    RegExMatch(Server, "(\d){1,2}", ServerIndex)
    ServerIndex := ServerIndex - 0

    if (StrLen(IP) && IP = Data[1]) {
      addMessageToChatWindow("{FFFF00}Подключение к серверу {CCCCCC}" IP ".")
      connect(IP)
    } else if (StrLen(ServerIndex) && ServerIndex = Server && this._serversList[ServerIndex]) {
      addMessageToChatWindow("{FFFF00}Подключение к серверу {CCCCCC}" this._serversList[ServerIndex].name ".")
      connect(this._serversList[ServerIndex].ip)
    }

    Return
  }

  restart()
  {
    restart()

    Return
  }
}

Connect := new Connect()


CMD.commands["connect"] := "Connect.connect"
CMD.commands["reconnect"] := "Connect.restart"
