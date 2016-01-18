;;
;; IgnoreList for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b (Apr 11, 2015)
;;

checkInIgnoreList(PlayerNick)
{
  global IgnoreList

  if (PlayerNick = getUsername()) {
    Return True
  }

  for Key, Nick in IgnoreList {
    if (Nick = PlayerNick) {
      Return True
    }
  }

  Return False
}
