;;
;; AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b5 (Jul 19, 2015)
;;

#UseHook

#NoEnv

#IfWinActive GTA:SA:MP

#Include %A_ScriptDir%

#SingleInstance force

SetWorkingDir %A_ScriptDir%


; VersionChecker

#include VersionChecker.ahk


; Configs

#include Config.ahk


; Modules Funcs

#include modules\JSON.ahk
#include modules\Chatlog-Funcs.ahk
#include modules\SAMP-UDF-Ex.ahk
#include modules\SAMP-UDF-Addon.ahk
#include modules\SAMP-UsersListUpdater.ahk
#include modules\SAMP-NearbyPlayers.ahk
#include modules\SendChatSavingMessage.ahk
#include modules\CMD-Funcs.ahk
#include modules\IgnoreList.ahk


; Plugins Funcs

#include plugins\LastSMS-Funcs.ahk
#include plugins\Connect-Funcs.ahk
;#include plugins\AutoConnect-Funcs.ahk

;;   1 lvl
if (AdminLVL >= 1) {
#include plugins\LastPM-Funcs.ahk
#include plugins\PMToLastMuteOrDM-Funcs.ahk
}

;;   2 lvl
if (AdminLVL >= 2) {
#include plugins\AutoHP-Funcs.ahk
#include plugins\ReconLastPM-Funcs.ahk
#include plugins\ReconLastWarning-Funcs.ahk
#include plugins\ReconViewer-Funcs.ahk
#include plugins\TagName-Funcs.ahk
}

;;   3 lvl
if (AdminLVL >= 3) {
#include plugins\TP-Funcs.ahk
#include plugins\BanIP-Funcs.ahk
}

;;   4 lvl
if (AdminLVL >= 4) {
#include plugins\GetIP-Funcs.ahk
}

;;   5 lvl
if (AdminLVL >= 5) {
#include plugins\SetHPs-Funcs.ahk
#include plugins\GiveGuns-Funcs.ahk
#include plugins\Uninvites-Funcs.ahk
#include plugins\Hbj-Funcs.ahk
}

; GUI

#include GUI.ahk


; Modules Binds

#include modules\CMD-Binds.ahk


; Binds

#include UserBinds.ahk

Return


; Modules Labels

#include modules\Chatlog-Labels.ahk


; Plugins Labels

#include plugins\LastSMS-Labels.ahk
;#include plugins\AutoConnect-Labels.ahk

;;   1 lvl
if (AdminLVL >= 1) {
#include plugins\LastPM-Labels.ahk
#include plugins\PMToLastMuteOrDM-Labels.ahk
}

;;   2 lvl
if (AdminLVL >= 2) {
#include plugins\AutoHP-Labels.ahk
#include plugins\ReconLastPM-Labels.ahk
#include plugins\ReconLastWarning-Labels.ahk
#include plugins\ReconViewer-Labels.ahk
#include plugins\TagName-Labels.ahk
}

;;   3 lvl
if (AdminLVL >= 3) {
#include plugins\TP-Labels.ahk
#include plugins\BanIP-Labels.ahk
}

;;   4 lvl
if (AdminLVL >= 4) {
#include plugins\GetIP-Labels.ahk
}

;;   5 lvl
if (AdminLVL >= 5) {
#include plugins\SetHPs-Labels.ahk
#include plugins\GiveGuns-Labels.ahk
#include plugins\Uninvites-Labels.ahk
#include plugins\Hbj-Labels.ahk
}
