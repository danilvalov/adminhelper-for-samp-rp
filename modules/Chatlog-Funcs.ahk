;;
;; Chatlog Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b (Apr 04, 2015)
;;

class Chatlog
{
  __chatlogFilePath := A_MyDocuments "\GTA San Andreas User Files\SAMP\chatlog.txt"

  __lastLineChatlog := 1

  __timerInit := 0

  checker := []

  timer()
  {
    if (Chatlog.__timerInit) {
      Chatlog.reader()
    } else {
      SetTimer, ChatlogTimer, Off
    }

    Return
  }

  startTimer()
  {
    if (!this.__timerInit) {
      this.__timerInit := 1

      SetTimer, ChatlogTimer, 1000
    }

    Return
  }

  stopTimer()
  {
    if (this.__timerInit) {
      this.__timerInit := 0

      SetTimer, ChatlogTimer, Off
    }

    Return
  }

  reader()
  {
    LineCount := 1
  
    FileRead, Contents, % this.__chatlogFilePath
    if not ErrorLevel
    {
      Loop, parse, Contents, `n, `r
      {
        LineCount := A_Index
        if (this.__lastLineChatlog <= A_Index) {
          ChatlogString := Trim(A_LoopField)
          if (StrLen(ChatlogString) > 0) {
            ChatlogString := SubStr(ChatlogString, 12, StrLen(ChatlogString))
            for chatlogKey, chatlogFunction in this.checker {
              %chatlogFunction%(ChatlogString)
            }
          }
        }
      }

      if (LineCount < this.__lastLineChatlog) {
        this.__lastLineChatlog := 1
        this.reader()
      }

      this.__lastLineChatlog := LineCount

      Contents =
    }

    Return
  }
}

Chatlog := new Chatlog()
