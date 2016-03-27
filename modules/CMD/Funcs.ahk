;;
;; CMD Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

ClipPutText(Text, LocaleID=0x419)
{
  CF_TEXT:=1, CF_LOCALE:=16, GMEM_MOVEABLE:=2
  TextLen   :=StrLen(Text)
  HmemText  :=DllCall("GlobalAlloc", "UInt", GMEM_MOVEABLE, "UInt", TextLen+1)  ; Запрос перемещаемой
  HmemLocale:=DllCall("GlobalAlloc", "UInt", GMEM_MOVEABLE, "UInt", 4)  ; памяти, возвращаются хэндлы.
  If(!HmemText || !HmemLocale)
    Return
  PtrText   :=DllCall("GlobalLock",  "UInt", HmemText)   ; Фиксация памяти, хэндлы конвертируются
  PtrLocale :=DllCall("GlobalLock",  "UInt", HmemLocale) ; в указатели (адреса).
  DllCall("msvcrt\memcpy", "UInt", PtrText, "Str", Text, "UInt", TextLen+1, "Cdecl") ; Копирование текста.
  NumPut(LocaleID, PtrLocale+0)                   ; Запись идентификатора локали.
  DllCall("GlobalUnlock",     "UInt", HmemText)   ; Расфиксация памяти.
  DllCall("GlobalUnlock",     "UInt", HmemLocale)
  If not DllCall("OpenClipboard", "UInt", 0)      ; Открытие буфера обмена.
  {
    DllCall("GlobalFree", "UInt", HmemText)    ; Освобождение памяти,
    DllCall("GlobalFree", "UInt", HmemLocale)  ; если открыть не удалось.
    Return
  }
  DllCall("EmptyClipboard")                     ; Очистка.
  DllCall("SetClipboardData", "UInt", CF_TEXT,   "UInt", HmemText)   ; Помещение данных.
  DllCall("SetClipboardData", "UInt", CF_LOCALE, "UInt", HmemLocale)
  DllCall("CloseClipboard")     ; Закрытие.
}

ClipGetText(CodePage=1251)
{
  CF_TEXT:=1, CF_UNICODETEXT:=13, Format:=0
  If not DllCall("OpenClipboard", "UInt", 0)                 ; Открытие буфера обмена.
    Return
  Loop
  {
    Format:=DllCall("EnumClipboardFormats", "UInt", Format)  ; Перебор форматов.
    If(Format=0 || Format=CF_TEXT || Format=CF_UNICODETEXT)
      Break
  }
  If(Format=0) {      ; Текста не найдено.
    DllCall("CloseClipboard")
    Return
  }
  If(Format=CF_TEXT)
  {
    HmemText:=DllCall("GetClipboardData", "UInt", CF_TEXT)  ; Получение хэндла данных.
    PtrText :=DllCall("GlobalLock",       "UInt", HmemText) ; Конвертация хэндла в указатель.
    TextLen :=DllCall("msvcrt\strlen",    "UInt", PtrText, "Cdecl")  ; Измерение длины найденного текста.
    VarSetCapacity(Text, TextLen+1)  ; Переменная под этот текст.
    DllCall("msvcrt\memcpy", "Str", Text, "UInt", PtrText, "UInt", TextLen+1, "Cdecl") ; Текст в переменную.
    DllCall("GlobalUnlock", "UInt", HmemText)  ; Расфиксация памяти.
  }
  Else If(Format=CF_UNICODETEXT)
  {
    HmemTextW:=DllCall("GetClipboardData", "UInt", CF_UNICODETEXT)
    PtrTextW :=DllCall("GlobalLock",       "UInt", HmemTextW)
    TextLen  :=DllCall("msvcrt\wcslen",    "UInt", PtrTextW, "Cdecl")
    VarSetCapacity(Text, TextLen+1)
    DllCall("WideCharToMultiByte", "UInt", CodePage, "UInt", 0, "UInt", PtrTextW
                                 , "Int", TextLen+1, "Str", Text, "Int", TextLen+1
                                 , "UInt", 0, "Int", 0)  ; Конвертация из Unicode в ANSI.
    DllCall("GlobalUnlock", "UInt", HmemTextW)
  }
  DllCall("CloseClipboard")  ; Закрытие.
  Return Text
}

class CMD
{
  commands := {}

  __getLocale()
  {
    SetFormat, Integer, H

    WinGet, WinID,, A
    ThreadID := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
    InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")

    SetFormat, Integer, D

    Return %InputLocaleID%
  }

  __setLocale(Locale)
  {
    SendMessage, 0x50,, %Locale%,, A

    Return
  }

  __hasValueInArray(Array, Value)
  {
    for Key, Val in Array {
      if (Val = Value) {
        Return Key
      }
    }
    Return 0
  }

  __strToLower(String)
  {
    StringLower, String, String

    Return String
  }

  get()
  {
    Locale_Default := this.__getLocale()

    ClipboardReset := ClipGetText()
    Sleep 10
    Clipboard =

    this.__setLocale(0x4090409)

    if (IsInChat()) {
      SendInput ^a^c{Right}
      Sleep 100
      ChatInput := ClipGetText()
      if (SubStr(ChatInput, 1, 1) = "/" && StrLen(Trim(ChatInput)) > 1) {
        ChatInput := Trim(ChatInput)
        ChatInputEx := StrSplit(ChatInput, " ")
        Command := RegExReplace(this.__strToLower(ChatInputEx[1]), "[^a-z]", "")
        Callback := this.commands[Command]
        if (Callback) {
          Sleep 10
          CallbackSplit := StrSplit(Callback, ".")
          if (CallbackSplit.MaxIndex() = 1) {
            if (isFunc(%CallbackFunc%)) {
              %Callback%(ChatInputEx)
            }
          } else if (CallbackSplit.MaxIndex() = 2) {
            CallbackFunc := CallbackSplit[1]
            if (isFunc(%CallbackFunc%[CallbackSplit[2]])) {
              %CallbackFunc%[CallbackSplit[2]](ChatInputEx)
            }
          }
        }
      }
    }

    Sleep 10
    this.__setLocale(Locale_Default)
    Sleep 10
    ClipPutText(ClipboardReset)

    Return
  }
}

CMD := new CMD()
