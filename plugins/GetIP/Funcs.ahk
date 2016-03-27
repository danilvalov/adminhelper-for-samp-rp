;;
;; AutoGetIP Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class GetIP
{
  SetNikLastId := ""
  GetIPUser := ""
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

  getIPData(IP)
  {
    RegExMatch(IP, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", CheckIP)

    if (StrLen(IP) && StrLen(CheckIP) && IP = CheckIP) {
      UrlDownloadToFile, % "http://ip-api.com/json/" IP, .cache\ip.json
      FileRead, IP_JSON, *P65001 .cache\ip.json
      FileDelete, .cache\ip.json
      RegGetIP_Data := JSON.parse(IP_JSON)

      Return RegGetIP_Data
    } else {
      addMessageToChatWindow("{FF0000} Введённый IP некорректен.")

      Return False
    }
  }

  get(notAdminChat = False)
  {
    global Config

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
      RegGetIP_Data := this.getIPData(this.RegGetIP)
      LastGetIP_Data := this.getIPData(this.LastGetIP)

      if (!RegGetIP_Data || !LastGetIP_Data) {
        Return False
      }

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
        FullLastGetIP_Location := StrLen(FullLastGetIP_Location) ? FullLastGetIP_Location : "N/A"
      } else {
        LastGetIP_Location := "N/A"

        FullLastGetIP_Location := "N/A"
      }

      addMessageToChatWindow("{C4EFFF}Игрок: {FFFF00}" this.GetIPUser)
      addMessageToChatWindow("{C4EFFF}Регистрация: {FFFFFF}" FullRegGetIP_Location "{C4EFFF}.")
      addMessageToChatWindow("{C4EFFF}Текущий IP: {FFFFFF}" FullLastGetIP_Location "{C4EFFF}.")
      addMessageToChatWindow("{C4EFFF}Дистанция: " (Distance = "N/A" ? "{FFFFFF}" : (Distance = 0 ? "{00FF00}" : (Round(Distance / 1000, 2) < 300 ? "{FFFF00}" : "{FF0000}"))) DistanceValue "{C4EFFF}.")

      if (Config["plugins"]["GetIP"]["ToAdminChatBoolean"] && !notAdminChat) {
        if (Config["plugins"]["GetIP"]["GetIPWithNickNameBoolean"]) {
          sendChatMessage("/a " this.GetIPUser ": " RegGetIP_Location " / " LastGetIP_Location " / " DistanceValue ".")
        } else {
          sendChatMessage("/a Возможно: " RegGetIP_Location " / " LastGetIP_Location " / " DistanceValue ".")
        }
      }
    } else {
      addMessageToChatWindow("{FF0000} Не найдено ни одного IP.")
    }

    Return DistanceNull
  }

  getOnlyForMe(Data)
  {
    User := RegExReplace(Data[2], "[^a-zA-Z0-9\_]", "")
    RegExMatch(Data[2], "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", UserIP)

    if (StrLen(User) && User = Data[2]) {
      Sleep 1200

      UserId := RegExReplace(Data[2], "[^0-9]", "")

      Chatlog.reader()

      this.GetIPUser := ""
      this.RegGetIP := ""
      this.LastGetIP := ""

      if (StrLen(UserId) && UserId = User) {
        sendChatMessage("/getip " UserId)
      } else {
        this.GetIPUser := User
        sendChatMessage("/agetip " User)
      }

      Sleep 500

      this.get(!StrLen(Data[3]))
    } else if (StrLen(UserIP) && UserIP = Data[2]) {
      GetIP_Data := this.getIPData(UserIP)

      if (StrLen(Data[3])) {
        GetIP_Location := StrLen(GetIP_Data["city"]) ? GetIP_Data["city"] : ""
        GetIP_Location := StrLen(GetIP_Data["country"]) ? (StrLen(GetIP_Location) ? GetIP_Location ", " : "") GetIP_Data["country"] : GetIP_Location
        GetIP_Location := StrLen(GetIP_Location) ? GetIP_Location : "N/A"

        Sleep 1200

        sendChatMessage("/a IP " UserIP " расположен: " GetIP_Location ".")
      }

      FullGetIP_Location := StrLen(GetIP_Data["city"]) ? GetIP_Data["city"] : ""
      FullGetIP_Location := StrLen(GetIP_Data["regionName"]) ? (GetIP_Data["regionName"] = FullGetIP_Location ? FullGetIP_Location : (StrLen(FullGetIP_Location) ? FullGetIP_Location ", " : "") GetIP_Data["regionName"]) : FullGetIP_Location
      FullGetIP_Location := StrLen(GetIP_Data["country"]) ? (StrLen(FullGetIP_Location) ? FullGetIP_Location ", " : "") GetIP_Data["country"] : FullGetIP_Location
      FullGetIP_Location := StrLen(GetIP_Data["isp"]) ? (StrLen(FullGetIP_Location) ? FullGetIP_Location ". " : "") "Провайдер: " GetIP_Data["isp"] : FullGetIP_Location
      FullGetIP_Location := StrLen(FullGetIP_Location) ? FullGetIP_Location : "N/A"

      addMessageToChatWindow("Местоположение IP " UserIP ": " FullGetIP_Location ".")
    } else {
      if (!StrLen(User)) {
        addMessageToChatWindow("{FF0000} Вы не указали ID игрока или его ник.")
      } else {
        addMessageToChatWindow("{FF0000} Вы указали некорректный ID игрока или его ник.")
      }

      addMessageToChatWindow("{FFFF00} Правильный формат ввода: {FFFFFF}/geoip [id_игрока] {FFFF00}или {FFFFFF}/geoip [ник_игрока] {FFFF00}или {FFFFFF}/geoip [ip_игрока]")
    }

    Return
  }

  aStats(Data)
  {
    User := RegExReplace(Data[2], "[^a-zA-Z0-9\_]", "")

    if (StrLen(User) && User = Data[2]) {
      UserId := RegExReplace(Data[2], "[^0-9]", "")

      if (StrLen(UserId) && UserId = User) {
        hardUpdateOScoreboardData()

        Sleep 1000

        User := getPlayerNameById(UserId)

        if (User && StrLen(User)) {
          sendChatMessage("/agetstats " User)
        } else {
          addMessageToChatWindow("{FF0000} Игрок с ID " UserId " не найден в игре. Откройте и закройте Tab, после чего попробуйте повторить попытку.")
        }
      } else {
        sendChatMessage("/agetstats " User)
      }
    } else {
      addMessageToChatWindow("{FFFF00} Правильный формат ввода: {FFFFFF}/astats [id_игрока]")
    }

    Return
  }

  allStats(Data)
  {
    User := RegExReplace(Data[2], "[^a-zA-Z0-9\_]", "")

    if (StrLen(User) && User = Data[2]) {
      UserId := RegExReplace(Data[2], "[^0-9]", "")

      this.getOnlyForMe(Data)

      Sleep 1200

      sendChatMessage("/pgetip 4 " this.LastGetIP)

      Sleep 1200

      if (StrLen(UserId) && UserId = User) {
        sendChatMessage("/agetstats " getPlayerNameById(UserId))
      } else {
        sendChatMessage("/agetstats " User)
      }
    } else {
      addMessageToChatWindow("{FFFF00} Правильный формат ввода: {FFFFFF}/allstats [id_игрока] {FFFF00}или {FFFFFF}/allstats [ник_игрока]")
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

    this.GetIPUser := ""
    this.RegGetIP := ""
    this.LastGetIP := ""

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

        this.GetIPUser := ""
        this.RegGetIP := ""
        this.LastGetIP := ""

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
    TempGetIPUser := SubStr(Trim(ChatlogString), StrLen("Nik [") + 1)
    TempGetIPUser := SubStr(TempGetIPUser, 1, InStr(TempGetIPUser, "]") - 1)

    RegExMatch(ChatlogString, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", RegTempGetIP)
    RegExMatch(ChatlogString, "(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}", LastTempGetIP, -17)

    if (StrLen(RegTempGetIP) && StrLen(LastTempGetIP)) {
      GetIP.GetIPUser := TempGetIPUser
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
CMD.commands["astats"] := "GetIP.aStats"
CMD.commands["allstats"] := "GetIP.allStats"

HotKeyRegister(Config["plugins"]["GetIP"]["Key"], "GetIPHotKey")
HotKeyRegister(Config["plugins"]["GetIP"]["SetNikKey"], "GetIPSetNikHotKey")
