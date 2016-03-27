;;
;; DayZ Event for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class DayZEvent
{
  __running := 0
  __zero := -1
  __step := 1

  __allZombies := []
  __zombies := []
  __zombieStep := 1

  __nearestPlayer := {}
  __nearestPlayerDistance := -1

  __hasValueInArray(Array, Value)
    {
      for Key, Val in Array {
        if (Val = Value) {
          Return Key
        }
      }
      Return 0
    }

  start(Data) {
    Id := Trim(Data[3])
    Id := RegExReplace(Id, "[^0-9]", "")

    if (StrLen(Id) && getPlayerNameById(Id)) {
      this.__zero := Id
      this.__running := 1

      addMessageToChatWindow("{FFFF00} Мероприятие ""День Z"" запущено. Нулевой пациент - " getPlayerNameById(this.__zero) "[" this.__zero "].")

      SetTimer, DayZEventCmdTimer, 1200
    } else {
      addMessageToChatWindow("{FF0000} Для запуска Мероприятия ""День Z"" нужно указать ID игрока, с которого начнётся заражение.")
      addMessageToChatWindow("{FFFFFF} Введите {FFFF00}/event dayz [Id_нулевого_пациента].")
    }

    Return
  }

  stop() {
    if (this.__running) {
      this.__running := 0
      this.__zero := -1
      this.__step := 1

      this.__allZombies := []
      this.__zombies := []
      this.__zombieStep := 1

      addMessageToChatWindow("{FF0000} Мероприятие ""День Z"" остановлено.")

      SetTimer, DayZEventCmdTimer, Off
      SetTimer, DayZEventStatusTimer, Off

      Return True
    }

    Return False
  }

  checkZeroHP() {
    NearestPlayer := NearbyPlayers.getNearestPlayer()

    if (!NearestPlayer.ID || !NearestPlayer.Distance || NearestPlayer.Distance > 1) {
      ;; /re refresh

      Return
    }

    if (NearestPlayer.HP <= 0) {
      this.__nearestPlayer := {}
      this.__nearestPlayer["ID"] := -1
      this.__nearestPlayerDistance := -1

      callFuncForAllStreamedInPlayers("DayZEventNearestPlayerLoop", 1000)

      if (this.__nearestPlayer["ID"] >= 0) {
        this.__zero := this.__nearestPlayer["ID"]
        this.__step := 1

        addMessageToChatWindow("{FF0000} Нулевой пациент изменён на " getPlayerNameById(this.__zero) "[" this.__zero "].")
      } else {
        this.stop()

        addMessageToChatWindow("{FF0000} Причина: поблизости нет ни одного подходящего нулевого пациента.")
        addMessageToChatWindow("{FFFFFF} Введите {FFFF00}/event dayz [Id_нового_нулевого_пациента].")
      }
    }

    Return
  }

  checkNearbyPlayers() {
    callFuncForAllStreamedInPlayers("DayZEventNearbyLoop", 5)

    Return
  }

  statusTimer() {
    if (this.__running) {
      this.checkZeroHP()
      this.checkNearbyPlayers()
    } else {
      SetTimer, DayZEventStatusTimer, Off
    }

    Return
  }

  cmdTimer() {
    if (this.__running) {
      if (this.__step = 1) {
        sendChatMessage("/re " this.__zero)

        SetTimer, DayZEventStatusTimer, 300

        this.__step := 2
      } else if (this.__step = 2) {
        sendChatMessage("/sethp " this.__zero " 255")

        this.__step := 3
      } else if (this.__step = 3) {
        sendChatMessage("/pm " this.__zero " Вы - нулевой пациент. Касаясь живых людей, Вы превращаете их в зомби.")

        this.__step := 4
      } else if (this.__step = 4) {
        sendChatMessage("/pm " this.__zero " Ваша цель - заразить как можно больше людей. Удачи.")

        this.__step := 5
      } else if (this.__step = 5) {
        sendChatMessage("/hbject " this.__zero " 0 2906 1 0.24 0.06 0.488 14.699 -81.999 -0.398 1.485 1.413 1.547")

        this.__step := 6
      } else if (this.__step = 6) {
        sendChatMessage("/hbject " this.__zero " 1 2907 1 -0.051 0.071 0.033 91.801 -172.199 -91.898 2.157 0.998 2.815")

        this.__step := 7
      } else if (this.__step = 7) {
        sendChatMessage("/hbject " this.__zero " 2 2908 1 0.622 0.134 0.045 1.998 170 -81.699 2.674 2.335 2.368")

        this.__step := 8
      } else if (this.__step = 8) {
        sendChatMessage("/hbject " this.__zero " 3 2906 1 0.324 0.121 -0.359 107.899 95 -119.299 1.876 1.292 1.250")

        this.__step := 9
      } else if (this.__step = 9) {
        sendChatMessage("/hbject " this.__zero " 4 2905 10 -0.323 0.226 0.032 -4.499 -3.199 -77.899 2.302 1.278 2.686")

        this.__step := 10
      } else if (this.__step = 10) {
        sendChatMessage("/hbject " this.__zero " 5 2905 9 -0.26 0.143 0.064 -140 174.901 93 2.573 1.110 2.330")

        this.__step := 11
      } else if (this.__step = 11) {
        if (this.__zombies.MaxIndex()) {
          if (this.__zombieStep = 1) {
            showGameText("DayZ [ID: " this.__zombies[1] "] [" (this.__allZombies.MaxIndex() + 1 - this.__zombies.MaxIndex()) "/" this.__allZombies.MaxIndex() "]", 5000, 4)

            sendChatMessage("/pm " this.__zombies[1] " Теперь Вы - Зомби. Ваша цель - убивать живых (без оружия). Проявите фантацию и отыграйте РП.")

            this.__zombieStep := 2
          } else if (this.__zombieStep = 2) {
            sendChatMessage("/hbject " this.__zombies[1] " 0 2906 1 0.24 0.06 0.488 14.699 -81.999 -0.398 1.485 1.413 1.547")

            this.__zombieStep := 3
          } else if (this.__zombieStep = 3) {
            sendChatMessage("/hbject " this.__zombies[1] " 1 2907 1 -0.051 0.071 0.033 91.801 -172.199 -91.898 2.157 0.998 2.815")

            this.__zombieStep := 4
          } else if (this.__zombieStep = 4) {
            sendChatMessage("/hbject " this.__zombies[1] " 2 2908 1 0.622 0.134 0.045 1.998 170 -81.699 2.674 2.335 2.368")

            this.__zombieStep := 5
          } else if (this.__zombieStep = 5) {
            sendChatMessage("/hbject " this.__zombies[1] " 3 2906 1 0.324 0.121 -0.359 107.899 95 -119.299 1.876 1.292 1.250")

            this.__zombieStep := 6
          } else if (this.__zombieStep = 6) {
            sendChatMessage("/hbject " this.__zombies[1] " 4 2905 10 -0.323 0.226 0.032 -4.499 -3.199 -77.899 2.302 1.278 2.686")

            this.__zombieStep := 7
          } else if (this.__zombieStep = 7) {
            sendChatMessage("/hbject " this.__zombies[1] " 5 2905 9 -0.26 0.143 0.064 -140 174.901 93 2.573 1.110 2.330")

            this.__zombieStep := 1
            this.__zombies.RemoveAt(1)
          }
        }
      }
    } else {
      SetTimer, DayZEventCmdTimer, Off
    }

    Return
  }
}

DayZEvent := new DayZEvent()


DayZEventNearbyLoop(Player) {
  if (!Player) {
    Return
  }

  if (DayZEvent.__zero <> Player["ID"] && !checkInIgnoreList(Player.NAME) && !DayZEvent.__hasValueInArray(DayZEvent.__allZombies, Player["ID"])) {
    DayZEvent.__zombies.Insert(Player["ID"])
    DayZEvent.__allZombies.Insert(Player["ID"])

    addMessageToChatWindow("{00D900} Стал Zombie " Player.NAME "[" Player.ID "]")
  }

  Return
}

DayZEventNearestPlayerLoop() {
  if (!Player) {
    Return
  }

  if (DayZEvent.__zero <> Player["ID"] && !checkInIgnoreList(Player.NAME)) {
    Distance := getDist(getCoordinates(), Player.POS)

    if (DayZEvent.__nearestPlayerDistance < 0 || Distance < DayZEvent.__nearestPlayerDistance) {
      DayZEvent.__nearestPlayer := Player
      DayZEvent.__nearestPlayerDistance := Distance
    }
  }

  Return
}
