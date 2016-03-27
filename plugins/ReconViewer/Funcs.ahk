;;
;; ReconViewer Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class ReconViewer
{
  __timerRunning := 0
  
  __currentId := 0
  
  __usersList := []

  __usersListUpdate()
  {
    global Config, oScoreboardData

    if (hardUpdateOScoreboardData()) {
      Sleep 100

      this.__usersList := []

      for Id, User in oScoreboardData
      {
        if (StrLen(User["NAME"]) && User["SCORE"] > 0 && User["SCORE"] <= Config["plugins"]["ReconViewer"]["MaxLVL"] && !checkInIgnoreList(User["NAME"])) {
          this.__usersList.Insert(Id)
        }
      }

      if (this.__usersList.MaxIndex()) {
        Return True
      } else {
        Return False
      }
    } else {
      Return False
    }
  }

  step(duration)
  {
    global Config

    if (Config["plugins"]["ReconViewer"]["MaxLVL"] < 1) {
      Config["plugins"]["ReconViewer"]["MaxLVL"] := 1
    }

    if (!this.__timerRunning) {
      this.stop()
    }

    if (!this.__usersList.MaxIndex()) {
      this.__usersListUpdate()

      Sleep 1000
    }

    if (!this.__usersList.MaxIndex()) {
      this.__usersListUpdate()

      Sleep 1000
    }

    if (!this.__usersList.MaxIndex()) {
      addMessageToChatWindow("{FF0000}В игре нет ни одного подходящего по LVL игрока")

      Return
    }

    if (this.__currentId + duration > this.__usersList.MaxIndex()) {
      this.__usersListUpdate()
      sleep 200
      currentId := 1
    } else if (this.__currentId + duration <= 0) {
      this.__usersListUpdate()
      sleep 200
      currentId := this.__usersList.MaxIndex()
    } else {
      currentId := this.__currentId + duration
    }

    if (this.__usersList.MaxIndex() && StrLen(currentId) && StrLen(this.__usersList[currentId]) && StrLen(getPlayerNameById(this.__usersList[currentId])) && getPlayerScoreById(this.__usersList[currentId]) > 0 && getPlayerScoreById(this.__usersList[currentId]) <= Config["plugins"]["ReconViewer"]["MaxLVL"] && !checkInIgnoreList(getPlayerNameById(this.__usersList[currentId]))) {
      sendChatMessage("/re " this.__usersList[currentId])
      this.__currentId := currentId
      Sleep 1200
    } else {
      if (this.__usersListUpdate()) {
        sleep 200
        this.step(duration)
      }
    }

    Return
  }

  start()
  {
    global Config

    if (!this.__timerRunning) {
      showGameText("Starting ReconViewer Loop", 2000, 4)
      this.__timerRunning := 1
      SetTimer, ReconViewerTimer, % (Config["plugins"]["ReconViewer"]["Timeout"] * 1000)
    }

    Return
  }

  stop()
  {
    global Config

    if (this.__timerRunning) {
      showGameText("Stoping ReconViewer Loop", (Config["plugins"]["ReconViewer"]["Timeout"] * 1000), 4)
      this.__timerRunning := 0
      SetTimer, ReconViewerTimer, Off
    }

    Return
  }

  changeLVL(data)
  {
    global Config
    
    NewLVL := RegExReplace(data[2], "[^0-9]", "")
    if (NewLVL < 1) {
      NewLVL := 1
    }
    if (StrLen(NewLVL)) {
      Config["plugins"]["ReconViewer"]["MaxLVL"] := NewLVL
      this.__usersListUpdate()
      
      addMessageToChatWindow("{FFFF00}Recon Viewer: {FFFFFF}Максимальный LVL игроков для просмотра изменён на: {FFFF00}" NewLVL)
    } else {
      addMessageToChatWindow("{FFFF00}Recon Viewer: {FFFFFF}Текущий максимальный LVL игроков для просмотра - {FFFF00}" Config["plugins"]["ReconViewer"]["MaxLVL"])
    }

    Return
  }

  changeTimeout(data)
  {
    global Config
    
    NewTimeout := RegExReplace(data[2], "[^0-9.]", "")
    if (StrLen(NewTimeout)) {
      if (NewTimeout < 1.2) {
        NewTimeout := 1.2
      }
      Config["plugins"]["ReconViewer"]["Timeout"] := NewTimeout

      if (this.__timerRunning) {
        SetTimer, ReconViewerTimer, % (Config["plugins"]["ReconViewer"]["Timeout"] * 1000)
      }
      
      addMessageToChatWindow("{FFFF00}Recon Viewer: {FFFFFF}Время между сменой игроков изменено на: " NewTimeout " секунд")
    } else {
      addMessageToChatWindow("{FFFF00}Recon Viewer: {FFFFFF}Текущее время между сменой игроков - {FFFF00}" Config["plugins"]["ReconViewer"]["Timeout"] " секунд")
    }

    Return
  }
}

ReconViewer := new ReconViewer()

CMD.commands["rerun"] := "ReconViewer.start"
CMD.commands["restop"] := "ReconViewer.stop"
CMD.commands["relvl"] := "ReconViewer.changeLVL"
CMD.commands["retime"] := "ReconViewer.changeTimeout"

HotKeyRegister(Config["plugins"]["ReconViewer"]["NextKey"], "ReconViewerNextHotKey")
HotKeyRegister(Config["plugins"]["ReconViewer"]["PrevKey"], "ReconViewerPrevHotKey")
HotKeyRegister(Config["plugins"]["ReconViewer"]["StartKey"], "ReconViewerStartHotKey")
HotKeyRegister(Config["plugins"]["ReconViewer"]["StopKey"], "ReconViewerStopHotKey")
