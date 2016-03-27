;;
;; UsersListUpdater Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class hardUpdateOScoreboardDataClass
{
  __updateCount := 0
  __maxUpdateCount := 10

  __objCount(Obj) {
    if (!IsObject(Obj))
      Return 0

    z := 0

    for k in Obj
      z += 1

    Return z
  }

  update()
  {
    global oScoreboardData

    updateOScoreboardData()
    sleep 200

    if (this.__objCount(oScoreboardData)) {
      this.__updateCount := 0

      Return True
    } else if (this.__updateCount < this.__maxUpdateCount) {
      this.__updateCount := this.__updateCount + 1

      this.update()
    } else {
      this.__updateCount := 0

      showGameText("Error updating users list.~n~Try again later.", 3000, 4)

      Return False
    }
  }
}

hardUpdateOScoreboardDataClass := new hardUpdateOScoreboardDataClass()

hardUpdateOScoreboardData()
{
  Return hardUpdateOScoreboardDataClass.update()
}
