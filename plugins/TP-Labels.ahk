;;
;; TP Plugin for AdminHelper.ahk
;; Description: ѕлагин добавл€ет возможность быстро собрать список игроков дл€ “елепортировани€ (наход€щихс€ р€дом или по смс) и запустить цикл телепортации
;; CMD: /atp, /rtp, /ltp, /ntp, /gtp, /ctp, /stp, /tphelp, /helptp, /htp
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b9 (Jan 23, 2015)
;; Required modules: SAMP-UDF-Ex, SAMP-UDF-Addon, SAMP-UsersListUpdater, CMD, Chatlog, SAMP-NearbyPlayers, IgnoreList
;;

TPTimer:
{
  TP.timerTPFromList()

  Return
}

TPSMSTimer:
{
  TP.timerTPFromSMS()

  Return
}
