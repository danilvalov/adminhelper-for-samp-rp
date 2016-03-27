;;
;; ReconViewer Plugin for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
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
