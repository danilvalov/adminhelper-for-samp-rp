;;
;; AutoGetIP Plugin for AdminHelper.ahk
;; Description: ������ ��������� ���������� ��������� �������������� ������ �� ��� IP
;; CMD: /tgetip, /geoip
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b11 (Mar 06, 2015)
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
