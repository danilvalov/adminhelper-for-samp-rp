;;
;; Example UserBinds.ahk for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;
;;
;; *Краткая инструкция:*
;;
;; Если хотим отправить сообщение в чат с сохранением в истории чата (клавиша "вверх" в строке чата),
;; то используем команду `sendChatSavingMessage(Текст сообщения)`.
;;
;; Если хотим отправить сообщения без сохранения в истории чата,
;; то используем команду `sendChatMessage(Текст сообщения)`.
;;
;; Если хотим просто ввести текст в строку чата без отправки,
;; то используем команду `sendChatSavingMessage(Текст сообщения, False)`
;; - параметр False отключает автоматическую отправку сообщения.
;;

Numpad0::                  ; Numpad0
{
  sendChatSavingMessage("/a", False)

  Return
}

!Numpad0::                 ; Alt + Numpad0
{
  sendChatSavingMessage("/aad", False)

  Return
}

#Numpad0::                 ; Win + Numpad0
{
  sendChatSavingMessage("/o", False)

  Return
}

Numpad1::                  ; Numpad1
{
  sendChatSavingMessage("/re", False)

  Return
}

Numpad4::                  ; Numpad4
{
  sendChatSavingMessage("/slap", False)

  Return
}

Numpad5::                  ; Numpad5
{
  sendChatSavingMessage("/prison", False)

  Return
}

!Numpad5::                 ; Alt+Numpad5
{
  sendChatSavingMessage("/offprison", False)

  Return
}

+!Numpad5::                ; Shift+Alt+Numpad5
{
  sendChatSavingMessage("/tjail", False)

  Return
}

Numpad6::                  ; Numpad6
{
  sendChatSavingMessage("/warn", False)

  Return
}

Numpad7::                  ; Numpad7
{
  sendChatSavingMessage("/mute", False)

  Return
}

Numpad8::                  ; Numpad8
{
  sendChatSavingMessage("/kick", False)

  Return
}

Numpad9::                  ; Numpad9
{
  sendChatSavingMessage("/ban", False)

  Return
}

NumpadDiv::                ; Numpad "/"
{
  sendChatSavingMessage("/spcars", False)

  Return
}

!NumpadDiv::               ; Alt + Numpad "/"
{
  sendChatSavingMessage("/setnik", False)

  Return
}

NumpadMult::               ; Numpad "*"
{
  sendChatMessage("/gotomark")

  Return
}

!NumpadMult::              ; Alt + Numpad "*"
{
  sendChatMessage("/mark")

  Return
}

NumpadDot::                ; Numpad "Del"
{
  sendChatSavingMessage("/goto", False)

  Return
}

!NumpadDot::               ; Alt + Numpad "Del"
{
  sendChatSavingMessage("/gethere", False)

  Return
}

NumpadSub::                ; Numpad "-"
{
  sendChatMessage("/hp")

  Return
}

NumpadAdd::                ; Numpad "+"
{
  sendChatSavingMessage("/hi", False)

  Return
}

NumpadEnter::              ; Numpad "Enter"
{
  sendChatMessage("/tp")

  Return
}

F2::                       ; F2
{
  sendChatMessage("/alock")

  Return
}

!F2::                      ; Alt + F2
{
  sendChatMessage("/lock")

  Return
}

F3::                       ; F3
{
  sendChatMessage("/exit")

  Return
}

!F12::                      ; Alt + F12
{
  sendChatMessage("/admins")

  Return
}

!vk51::                    ; Alt + Q
{
  sendChatMessage("/time")

  Return
}

!vk49::                    ; Alt + I
{
  sendChatSavingMessage("/id", False)

  Return
}

+!vk50::                   ; Shift + Alt + P
{
  sendChatSavingMessage("/pm", False)

  Return
}
