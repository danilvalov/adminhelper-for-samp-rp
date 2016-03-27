;;
;; HotKeyRegister Module for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

HotKeyRegister(HotKey, Callback)
{
  if (HotKey && StrLen(HotKey) && Hparse(HotKey, false)) {
    Hotkey, % Hparse(HotKey, false), % Callback
  }

  Return
}
