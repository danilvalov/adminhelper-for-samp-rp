;;
;; TagName Plugin for AdminHelper.ahk
;; Description: Плагин добавляет возможность видеть ники игроков и их ID сквозь стены и на максимальной дальности.
;; CMD: /wh
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b6 (Jul 26, 2015)
;; Required modules: SAMP-UDF-Ex
;;

class TagName
{
  _run := 0

  _defaultDistance := -1

  start() {
    this._run := 1
    SetTimer, TagNameTimer, 50

    Return
  }

  stop() {
    this._run := 0

    Return
  }

  toggle() {
    if (!this._run) {
      this.start()
    } else {
      this.stop()
    }

    Return
  }

  timer()
  {
    if (this._run) {
      if (this._defaultDistance = -1) {
        this._defaultDistance := getTagNameDistance()

        if (this._defaultDistance = -1) {
          Return False
        } else {
          addMessageToChatWindow("{FFFF00}WH включён.")
        }
      }

      setTagNameDistance(1, 1500.0)
    } else {
      SetTimer, TagNameTimer, Off

      setTagNameDistance(0, this._defaultDistance)

      addMessageToChatWindow("{FFFF00}WH выключен.")
    }

    Return
  }
}

TagName := new TagName()

if (TagNameAutostartBoolean) {
  TagName.start()
}


CMD.commands["wh"] := "TagName.toggle"
