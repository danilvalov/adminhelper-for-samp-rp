;;
;; AutoGetIP Plugin for AdminHelper.ahk
;; Description: Плагин добавляет функционал получения местоположения игрока по его IP
;; CMD: /tgetip, /geoip
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b3 (May 17, 2015)
;; Required modules: SAMP-UDF-Ex, Chatlog, CMD, JSON
;;

class GetIP
{
  SetNikLastId := ""
  RegGetIP := ""
  LastGetIP := ""

  __thousandsSep(x, s=",")
  {
  	Return RegExReplace(x, "\G\d+?(?=(\d{3})+(?:\D|$))", "$0" s)
  }

  __deg2rad(deg)
  {
    rad := deg * .01745329252

    Return rad
  }

  __distance(lat1, lng1, lat2, lng2)
  {
    lat1 := this.__deg2rad(lat1)
    lng1 := this.__deg2rad(lng1)
    lat2 := this.__deg2rad(lat2)
    lng2 := this.__deg2rad(lng2)

    delta_lat := (lat2 - lat1)
    delta_lng := (lng2 - lng1)

    Return Round(6378137 * ACOS(COS(lat1) * COS(lat2) * COS(lng1 - lng2) + SIN(lat1) * SIN(lat2)))
  }

  get(notAdminChat = False)
  {
    global GetIPToAdminChatBoolean

    Chatlog.reader()

    if (!StrLen(this.LastGetIP) || !StrLen(this.RegGetIP)) {
      Sleep 1100

      Chatlog.reader()
    }

    if (!StrLen(this.LastGetIP) || !StrLen(this.RegGetIP)) {
      addMessageToChatWindow("{FF0000} Данные по IP не найдены в чате.")

      Return False
    }

    DistanceNull := False

    if (StrLen(this.RegGetIP) && StrLen(this.LastGetIP)) {
      UrlDownloadToFile, % "http://ip-api.com/json/" this.RegGetIP, reggetip.json
      FileRead, RegGetIP_JSON, *P65001 reggetip.json
      FileDelete, reggetip.json
      RegGetIP_Data := JSON.parse(RegGetIP_JSON)

      UrlDownloadToFile, % "http://ip-api.com/json/" this.LastGetIP, lastgetip.json
      FileRead, LastGetIP_JSON, *P65001 lastgetip.json
      FileDelete, lastgetip.json
      LastGetIP_Data := JSON.parse(LastGetIP_JSON)

      Distance := "N/A"
      DistanceValue := "N/A"

      if (StrLen(RegGetIP_Data["lat"]) && StrLen(RegGetIP_Data["lon"]) && StrLen(LastGetIP_Data["lat"]) && StrLen(LastGetIP_Data["lon"])) {
        Distance := this.__distance(RegGetIP_Data["lat"], RegGetIP_Data["lon"], LastGetIP_Data["lat"], LastGetIP_Data["lon"])
        DistanceValue := Distance = 0 ? "0 км" : "По прямой: " this.__thousandsSep(Round(Distance / 1000, 2)) " км"
      }

      DistanceNull := Distance = 0 ? True : False

      if (!DistanceNull && StrLen(RegGetIP_Data["isp"]) >= 3 && RegGetIP_Data["isp"] = LastGetIP_Data["isp"]) {
        DistanceNull := True
      }

      if (RegGetIP_Data["status"] = "success") {
        RegGetIP_Location := StrLen(RegGetIP_Data["city"]) ? RegGetIP_Data["city"] : ""
        RegGetIP_Location := StrLen(RegGetIP_Data["country"]) ? (StrLen(RegGetIP_Location) ? RegGetIP_Location ", " : "") RegGetIP_Data["country"] : RegGetIP_Location
        RegGetIP_Location := StrLen(RegGetIP_Location) ? RegGetIP_Location : "N/A"

        FullRegGetIP_Location := StrLen(RegGetIP_Data["city"]) ? RegGetIP_Data["city"] : ""
        FullRegGetIP_Location := StrLen(RegGetIP_Data["regionName"]) ? (RegGetIP_Data["regionName"] = FullRegGetIP_Location ? FullRegGetIP_Location : (StrLen(FullRegGetIP_Location) ? FullRegGetIP_Location ", " : "") RegGetIP_Data["regionName"]) : FullRegGetIP_Location
        FullRegGetIP_Location := StrLen(RegGetIP_Data["country"]) ? (StrLen(FullRegGetIP_Location) ? FullRegGetIP_Location ", " : "") RegGetIP_Data["country"] : FullRegGetIP_Location
        FullRegGetIP_Location := StrLen(RegGetIP_Data["isp"]) ? (StrLen(FullRegGetIP_Location) ? FullRegGetIP_Location ". " : "") "Провайдер: " RegGetIP_Data["isp"] : FullRegGetIP_Location
        FullRegGetIP_Location := StrLen(FullRegGetIP_Location) ? FullRegGetIP_Location "." : "N/A"
      } else {
        RegGetIP_Location := "N/A"

        FullRegGetIP_Location := "N/A"
      }

      if (RegGetIP_Data["status"] = "success") {
        LastGetIP_Location := StrLen(LastGetIP_Data["city"]) ? LastGetIP_Data["city"] : ""
        LastGetIP_Location := StrLen(LastGetIP_Data["country"]) ? (StrLen(LastGetIP_Location) ? LastGetIP_Location ", " : "") LastGetIP_Data["country"] : LastGetIP_Location
        LastGetIP_Location := StrLen(LastGetIP_Location) ? LastGetIP_Location : "N/A"

        FullLastGetIP_Location := StrLen(LastGetIP_Data["city"]) ? LastGetIP_Data["city"] : ""
        FullLastGetIP_Location := StrLen(LastGetIP_Data["regionName"]) ? (LastGetIP_Data["regionName"] = FullLastGetIP_Location ? FullLastGetIP_Location : (StrLen(FullLastGetIP_Location) ? FullLastGetIP_Location ", " : "") LastGetIP_Data["regionName"]) : FullLastGetIP_Location
        FullLastGetIP_Location := StrLen(LastGetIP_Data["country"]) ? (StrLen(FullLastGetIP_Location) ? FullLastGetIP_Location ", " : "") LastGetIP_Data["country"] : FullLastGetIP_Location
        FullLastGetIP_Location := StrLen(LastGetIP_Data["isp"]) ? (StrLen(FullLastGetIP_Location) ? FullLastGetIP_Location ". " : "") "Провайдер: " LastGetIP_Data["isp"] : FullLastGetIP_Location
        FullLastGetIP_Location := StrLen(FullLastGetIP_Location) ? FullLastGetIP_Location "." : "N/A"
      } else {
        LastGetIP_Location := "N/A"

        FullLastGetIP_Location := "N/A"
      }

      addMessageToChatWindow("Регистрация: " FullRegGetIP_Location)
      addMessageToChatWindow("Текущий IP: " FullLastGetIP_Location)

      if (GetIPToAdminChatBoolean && !notAdminChat) {
        sendChatMessage("/a Возможно: " RegGetIP_Location " / " LastGetIP_Location " / " DistanceValue)
      }
    } else {
      addMessageToChatWindow("{FF0000} Не найдено ни одного IP")
    }

    Return DistanceNull
  }

  getOnlyForMe(Data)
  {
    User := RegExReplace(Data[2], "[^a-zA-Z0-9\_]", "")

    if (StrLen(User) && User = Data[2]) {
      Sleep 1200

      UserId := RegExReplace(Data[2], "[^0-9]", "")

      Chatlog.reader()

      this.RegGetIP :=
      this.LastGetIP :=

      if (StrLen(UserId) && UserId = User) {
        sendChatMessage("/getip " UserId)
      } else {
        sendChatMessage("/agetip " User)
      }

      Sleep 500

      this.get(True)
    } else {
      if (!StrLen(User)) {
        addMessageToChatWindow("{FF0000} Вы не указали ID игрока или его ник")
      } else {
        addMessageToChatWindow("{FF0000} Вы указали некорректный ID игрока или его ник")
      }

      addMessageToChatWindow("{FFFF00} Правильный формат ввода: {FFFFFF}/geoip [id_игрока] {FFFF00}или {FFFFFF}/geoip [ник_игрока]")
    }

    Return
  }

  setNik()
  {
    Chatlog.reader()

    if (StrLen(this.SetNikLastId) && StrLen(this.SetNikLastNick)) {
      if (this.SetNikLastNick = getPlayerNameById(this.SetNikLastId)) {
        this.setNikChecker()
      } else {
        if(hardUpdateOScoreboardData()) {
          if (this.SetNikLastNick = getPlayerNameById(this.SetNikLastId)) {
            this.setNikChecker()
          } else {
            addMessageToChatWindow("{FF0000} Игрок, запрашивающий смену ника, уже вышел из игры.")
          }
        }
      }
    } else {
      addMessageToChatWindow("{FF0000} Не найдено ни одного активного запроса на смену ника.")
    }

    Return
  }

  setNikChecker()
  {
    Chatlog.reader()

    this.RegGetIP :=
    this.LastGetIP :=

    sendChatMessage("/getip " GetIP.SetNikLastId)

    Sleep 1000

    Chatlog.reader()

    if (GetIP.get()) {
      sendChatSavingMessage("/setnik " GetIP.SetNikLastId, False)
    }

    Return
  }

  twinks(Data)
  {
    Id := Trim(Data[2])
    Id := RegExReplace(Id, "[^0-9]", "")

    if (StrLen(Id)) {
      if (StrLen(getPlayerNameById(Id))) {
        Chatlog.reader()

        Sleep 1200

        sendChatMessage("/getip " Id)

        this.RegGetIP :=
        this.LastGetIP :=

        Sleep 1100

        Chatlog.reader()

        Sleep 100

        if (!StrLen(this.LastGetIP)) {
          Sleep 1100

          Chatlog.reader()
        }

        if (StrLen(this.LastGetIP)) {
          sendChatMessage("/pgetip 4 " this.LastGetIP)
        } else {
          addMessageToChatWindow("{FF0000} Данные по IP не найдены в чате.")
        }
      }
    }

    Return
  }
}

GetIP := new GetIP()

GetIPChatlogChecker(ChatlogString)
{
  if (SubStr(Trim(ChatlogString), 1, 5) = "Nik [" && (InStr(ChatlogString, "R-IP [") || InStr(ChatlogString, "Register-IP [")) && (InStr(ChatlogString, "L-IP [") || InStr(ChatlogString, "Last-IP ["))) {
      RegExMatch(ChatlogString, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", RegTempGetIP)
      RegExMatch(ChatlogString, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", LastTempGetIP, -17)

      if (StrLen(RegTempGetIP) && StrLen(LastTempGetIP)) {
        GetIP.RegGetIP := RegTempGetIP
        GetIP.LastGetIP := LastTempGetIP
      }
    }
}

Chatlog.checker.Insert("GetIPChatlogChecker")

GetIPSetNikChatlogChecker(ChatlogString)
{
  if (SubStr(Trim(ChatlogString), 1, StrLen("[Заявка на смену ника]")) = "[Заявка на смену ника]" && InStr(ChatlogString, "просит сменить ник на:")) {
    SetNikStringId := SubStr(ChatlogString, InStr(ChatlogString, "просит сменить ник на:") - 6)
    SetNikStringId := SubStr(SetNikStringId, InStr(SetNikStringId, "["))
    SetNikStringId := SubStr(SetNikStringId, 1, InStr(SetNikStringId, "]"))
    Nick := SubStr(ChatlogString, InStr(ChatlogString, "[Заявка на смену ника] ") + StrLen("[Заявка на смену ника] "))
    Nick := SubStr(Nick, 1, InStr(Nick, "[", false, InStr(Nick, "просит сменить ник на:") - 6) - 1)
    Nick := Trim(Nick)
    RegExMatch(SetNikStringId, "(\d){1,3}", Id)

    if (StrLen(Id) && StrLen(Nick)) {
      GetIP.SetNikLastId := Id
      GetIP.SetNikLastNick := Nick
    }
  }
}

Chatlog.checker.Insert("GetIPSetNikChatlogChecker")

CMD.commands["tgetip"] := "GetIP.twinks"
CMD.commands["geoip"] := "GetIP.getOnlyForMe"

Hotkey, %GetIPKey%, GetIPHotKey

Hotkey, %GetIPSetNikKey%, GetIPSetNikHotKey
