;;
;; AutoGetIP Plugin for AdminHelper.ahk
;; Description: Плагин добавляет функционал получения местоположения игрока по его IP
;; CMD: /tgetip, /geoip
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b3 (May 17, 2015)
;; Required modules: SAMP-UDF-Ex, Chatlog, CMD, JSON
;;

GetIPHotKey:
{
  GetIP.get()

  Return
}

GetIPSetNikHotKey:
{
  GetIP.setNik()

  Return
}
