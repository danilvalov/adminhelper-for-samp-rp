;;
;; ReconViewer Plugin for AdminHelper.ahk
;; Description: Плагин добавляет возможность быстро переключаться по игрокам в Recon (предыдущий/следующий игрок)
;; CMD: /rerun, /restop, /relvl, /retime
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b11 (Mar 06, 2015)
;; Required modules: SAMP-UDF-Ex, SAMP-UsersListUpdater, CMD
;;

ReconViewerNextHotKey:
{
  ReconViewer.stop()
  ReconViewer.step(+1)

  Return
}

ReconViewerPrevHotKey:
{
  ReconViewer.stop()
  ReconViewer.step(-1)

  Return
}

ReconViewerStartHotKey:
{
  ReconViewer.start()

  Return
}

ReconViewerStopHotKey:
{
  ReconViewer.stop()

  Return
}

ReconViewerTimer:
{
  global ReconViewerTimeout

  if (ReconViewerTimeout < 1.2) {
    ReconViewerTimeout := 1.2
  }

  ReconViewerTimeout := RegExReplace(ReconViewerTimeout, "[^0-9\.]", "")

  if (ReconViewer.__timerRunning) {
    ReconViewer.step(+1)
  } else {
    SetTimer, ReconViewerTimer, Off
  }

  Return
}
