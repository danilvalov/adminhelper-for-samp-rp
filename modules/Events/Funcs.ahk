;;
;; Events Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class Events {
  list := {}

  __strToLower(String)
  {
    StringLower, String, String

    Return String
  }

  init() {
    Global Config

    Loop, Files, events\*.*, D
    {
      IniRead, EventAdminLVL, % "events\" A_LoopFileName "\Meta.ini", Config, AdminLVL

      if (EventAdminLVL <= Config["AdminLVL"]) {
        EventName := this.__strToLower(A_LoopFileName)

        this.list[EventName] := {}
        this.list[EventName]["Object"] := A_LoopFileName "Event"

        IniRead, EventName, % "events\" A_LoopFileName "\Meta.ini", About, Name
        this.list[EventName]["Name"] := EventName

        IniRead, EventDescription, % "events\" A_LoopFileName "\Meta.ini", About, Description
        this.list[EventName]["Description"] := EventDescription
      }
    }

    Return
  }

  event(Data) {
    currentEvent := this.__strToLower(Trim(Data[2]))

    eventList := []

    checkStartedEvent := 0

    For EventName, EventData in this.list {
      eventList.Insert(EventName)

      EventObject := this.list[EventName]["Object"]

      if (isFunc(%EventObject%.stop) && %EventObject%.stop()) {
        checkStartedEvent := 1
      }
    }

    if (checkStartedEvent) {
      Return
    }

    if (StrLen(currentEvent) && this.list[currentEvent]) {
      EventObject := this.list[currentEvent]["Object"]

      if (isFunc(%EventObject%.start)) {
        %EventObject%.start(Data)
      }

      Return
    }

    if (StrLen(currentEvent)) {
      addMessageToChatWindow("{FF0000} Указанное мероприятие не найдено в списке.")
    }

    addMessageToChatWindow("{FFFF00}Список доступных мероприятий:")

    if (!eventList.MaxIndex()) {
      addMessageToChatWindow("{FF0000} Не найдено ни одного доступного Вам мероприятия.")

      Return
    }

    Loop, % eventList.MaxIndex()
    {
      addMessageToChatWindow("{00D900}  /event " eventList[A_Index])
      addMessageToChatWindow("{FFFFFF} " this.list[eventList[A_Index]].Description)
    }

    Return
  }
}

Events := new Events()

Events.init()

CMD.commands["event"] := "Events.event"
CMD.commands["test"] := "Events.init"
