;;
;; Hbj Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class Hbj
{
  hbjsList := {}
  currentHbjList := []
  currentHbjIndex := 1
  currentCmdIndex := 1
  currentSlot := 0
  _playersList := []
  _playersCount := 0
  _run := 0

  __strToLower(String)
  {
    StringLower, String, String

    Return String
  }

  hbjsListRead()
  {
    Global Config

    HbjListFile := Config["plugins"]["Hbj"]["ListFile"]

    this.hbjsList := {}
    HbjName =

    FileRead, Contents, %HbjListFile%
    if not ErrorLevel
    {
      Loop, Parse, Contents, `n, `r
      {
        Line := Trim(A_LoopField)
        if (StrLen(Line)) {
          if (SubStr(Line, 1, 1) = "[" && SubStr(Line, 0) = "]") {
            HbjName := SubStr(Line, 2, -1)
            HbjName := StrReplace(HbjName, " ", "_")
            HbjName := this.__strToLower(HbjName)

            if (!this.hbjsList[HbjName]) {
              this.hbjsList[HbjName] := []
            }
          } else if (SubStr(Line, 1, 1) = "/" && StrLen(HbjName)) {
            this.hbjsList[HbjName].Insert(Line)
          }
        }
      }
    } else {
      MsgBox, Ошибка: не удаётся открыть файл со списком объектов

      Return False
    }

    Return True
  }

  checkHbjName()
  {
    if (!this.currentHbjList.MaxIndex()) {
      this.currentHbjList := [""]
    }

    for HbjKey, HbjectName in this.currentHbjList {
      if (!StrLen(HbjectName) || !this.hbjsList[HbjectName]) {
        if (StrLen(HbjectName)) {
          addMessageToChatWindow("{FF0000}Введённый объект не найден в списке.")
          addMessageToChatWindow("{FFFF00}Для выдачи объектов конкретному игроку введите:")
          addMessageToChatWindow("{FFFFFF}/hbj [id_игрока,id_другого_игрока,id_третьего_игрока,...] [название_объекта,название_объекта,...]")
          addMessageToChatWindow("{FFFF00}Для выдачи объектов игрокам, находящимся рядом:")
          addMessageToChatWindow("{FFFFFF}/hbjs [название_объекта,название_объекта,...] [радиус_выдачи] [lvl игроков] [1 - этот лвл и больше, 0 - этот лвл и меньше]")

          HbjectName := StrReplace(HbjectName, "ё", "е")

          CurrentHbjList := []

          for hbjName, hbjObj in this.hbjsList {
            if (InStr(StrReplace(hbjName, "ё", "е"), HbjectName)) {
              CurrentHbjList.Insert(hbjName)
            }
          }
        }

        if (StrLen(HbjectName) && CurrentHbjList.MaxIndex()) {
          addMessageToChatWindow("{FFFF00}Возможно, вы хотели ввести одно из следующих названий объектов:")

          for HbjKey, HbjName in CurrentHbjList {
            addMessageToChatWindow("{00D900} - " + HbjName)
          }
        } else {
          addMessageToChatWindow("{FFFF00}Вот полный список доступных объектов:")

          for HbjName, HbjObj in this.hbjsList {
            addMessageToChatWindow("{00D900} - " + HbjName)
          }
        }

        Return False
      }
    }

    Return True
  }

  hbj(Data)
  {
    if (!this._run) {
      this.stop()

      Ids := Trim(Data[2])
      Ids := RegExReplace(Ids, "([^0-9,])", "")

      HbjName := Trim(Data[3])
      HbjName := this.__strToLower(HbjName)
      this.currentHbjList := StrSplit(HbjName, ",")

      if (StrLen(Ids) && StrLen(HbjName) && this.checkHbjName()) {
        this._playersList := StrSplit(Ids, ",")
        this._playersCount := this._playersList.MaxIndex()
        this.start()
      } else if (!StrLen(Ids) || !StrLen(HbjName)) {
        this.checkHbjName()
      }
    } else {
      this.stop()
    }

    Return
  }

  nearby(Data)
  {
    if (!this._run) {
      this.stop()

      HbjName := Trim(Data[2])
      HbjName := this.__strToLower(HbjName)
      this.currentHbjList := StrSplit(HbjName, ",")

      if (!StrLen(HbjName) || !this.checkHbjName()) {
        if (!StrLen(HbjName)) {
          this.checkHbjName()
        }

        Return
      }

      Data.RemoveAt(2)

      this._playersList := NearbyPlayers.get(Data)
      this._playersCount := this._playersList.MaxIndex()

      if (this._playersList.MaxIndex()) {
        this.start()
      }
    } else {
      this.stop()
    }

    Return
  }

  start()
  {
    if (!this._run) {
      this._run := 1

      addMessageToChatWindow("{FFFF00}Цикл выдачи объектов запущен.")

      SetTimer, HbjTimer, 1200
    }

    Return
  }

  stop()
  {
    if (this._run) {
      this._run := 0
      SetTimer, HbjTimer, Off
      this.currentCmdIndex := 1
      this.currentHbjIndex := 1
      this.currentSlot := 0
      this._playersList := []

      addMessageToChatWindow("{FFFF00}Цикл выдачи объектов был остановлен.")

      Sleep 1200
    }

    Return
  }

  timer()
  {
    if (this._run && this._playersList.MaxIndex()) {
      CmdLine := this.hbjsList[this.currentHbjList[this.currentHbjIndex]][this.currentCmdIndex]
      CmdLine := StrReplace(CmdLine, "[id]", this._playersList[1])
      CmdLine := StrReplace(CmdLine, "[slot]", this.currentSlot)

      sendChatMessage(CmdLine)

      showGameText("Hbj [ID: " this._playersList[1] "] [CMD:" this.currentCmdIndex "/" this.hbjsList[this.currentHbjList[this.currentHbjIndex]].MaxIndex() "] [Obj:" this.currentHbjIndex "/" this.currentHbjList.MaxIndex() "] [Players:" (this._playersCount + 1 - this._playersList.MaxIndex()) "/" this._playersCount "]", 1200, 4)

      this.currentCmdIndex++
      if (SubStr(CmdLine, 1, StrLen("/hbject ")) = "/hbject ") {
        this.currentSlot++
      }

      if (this.currentCmdIndex > this.hbjsList[this.currentHbjList[this.currentHbjIndex]].MaxIndex()) {
        this.currentCmdIndex := 1

        this.currentHbjIndex++
      }

      if (this.currentHbjIndex > this.currentHbjList.MaxIndex() || this.currentSlot >= 10) {
        this.currentCmdIndex := 1
        this.currentHbjIndex := 1
        this.currentSlot := 0
        this._playersList.RemoveAt(1)
      }
    } else {
      this._run := 0
      SetTimer, HbjTimer, Off
      this.currentCmdIndex := 1
      this.currentHbjIndex := 1
      this.currentSlot := 0

      addMessageToChatWindow("{FFFF00}Цикл выдачи объектов закончен.")
    }

    Return
  }
}

Hbj := new Hbj()

Hbj.hbjsListRead()


CMD.commands["hbj"] := "Hbj.hbj"
CMD.commands["hbjs"] := "Hbj.nearby"
