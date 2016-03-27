;;
;; AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

#UseHook
#NoEnv
#IfWinActive GTA:SA:MP
#SingleInstance force
#Include %A_ScriptDir%
SetWorkingDir %A_ScriptDir%


; VersionChecker

#Include %A_ScriptDir%\scripts\VersionChecker.ahk

#Include %A_ScriptDir%\Updater.ahk

#Include %A_ScriptDir%\scripts\ConfigReader.ahk

If (FileExist(".cache\AdminHelper.ahk")) {
	Run .cache\AdminHelper.ahk %1%
	ExitApp
	Return
}

AdminHelper := {}
AdminHelper["Modules"] := []
AdminHelper["Plugins"] := []
AdminHelper["Events"] := []

Loop, Files, %A_ScriptDir%\modules\*.*, D
{
  AdminHelper["Modules"].Insert(A_LoopFileName)
}

Loop, % Config["EnabledPlugins"].MaxIndex()
{
  IniRead, PluginAdminLVL, % A_ScriptDir "\plugins\" Config["EnabledPlugins"][A_Index] "\Meta.ini", Config, AdminLVL

  If (Config["AdminLVL"] >= PluginAdminLVL) {
    AdminHelper["Plugins"].Insert(Config["EnabledPlugins"][A_Index])
  }
}

Loop, Files, %A_ScriptDir%\events\*.*, D
{
  AdminHelper["Events"].Insert(A_LoopFileName)
}


MergedFile =

MergedFile .= "#UseHook`n"
MergedFile .= "#NoEnv`n"
MergedFile .= "#IfWinActive GTA:SA:MP`n"
MergedFile .= "#SingleInstance force`n"
MergedFile .= "#Include " A_ScriptDir "`n"
MergedFile .= "SetWorkingDir " A_ScriptDir "`n"

MergedFile .= "`n`n`;`; Configs`n`n"
MergedFile .= "#Include scripts\ConfigReader.ahk`n"

MergedFile .= "`n`n`;`; Libraries`n`n"

Loop, Files, %A_ScriptDir%\libraries\*.ahk, F
{
  MergedFile .= "#Include libraries\" A_LoopFileName "`n"
}

MergedFile .= "`n`n`;`; Modules Funcs`n`n"

Loop, % AdminHelper["Modules"].MaxIndex()
{
  ModuleName := AdminHelper["Modules"][A_Index]

  If (FileExist(A_ScriptDir "\modules\" ModuleName "\Funcs.ahk")) {
    MergedFile .= "#Include modules\" ModuleName "\Funcs.ahk`n"
  }
}

MergedFile .= "`n`n`;`; Events Funcs`n`n"

Loop, % AdminHelper["Events"].MaxIndex()
{
  EventName := AdminHelper["Events"][A_Index]

  If (FileExist(A_ScriptDir "\events\" EventName "\Funcs.ahk")) {
    MergedFile .= "#Include events\" EventName "\Funcs.ahk`n"
  }
}

MergedFile .= "`n`n`;`; Plugins Funcs`n`n"

Loop, % AdminHelper["Plugins"].MaxIndex()
{
  PluginName := AdminHelper["Plugins"][A_Index]

  If (FileExist(A_ScriptDir "\plugins\" PluginName "\Funcs.ahk")) {
    MergedFile .= "#Include plugins\" PluginName "\Funcs.ahk`n`n"
  }
}

MergedFile .= "`n`n`;`; GUI`n`n"
MergedFile .= "#Include GUI.ahk`n"

MergedFile .= "`n`n`;`; Modules Binds`n`n"

Loop, % AdminHelper["Modules"].MaxIndex()
{
  ModuleName := AdminHelper["Modules"][A_Index]

  If (FileExist(A_ScriptDir "\modules\" ModuleName "\Binds.ahk")) {
    MergedFile .= "#Include modules\" ModuleName "\Binds.ahk`n`n"
  }
}

MergedFile .= "`n`n`;`; Binds`n`n"

MergedFile .= "#Include UserBinds.ahk`n"

MergedFile .= "`n`nReturn`n`n"

MergedFile .= "`n`n`;`; Modules Labels`n`n"

Loop, % AdminHelper["Modules"].MaxIndex()
{
  ModuleName := AdminHelper["Modules"][A_Index]

  If (FileExist(A_ScriptDir "\modules\" ModuleName "\Labels.ahk")) {
    MergedFile .= "#Include modules\" ModuleName "\Labels.ahk`n`n"
  }
}

MergedFile .= "`n`n`;`; Events Labels`n`n"

Loop, % AdminHelper["Events"].MaxIndex()
{
  EventName := AdminHelper["Events"][A_Index]

  If (FileExist(A_ScriptDir "\events\" EventName "\Labels.ahk")) {
    MergedFile .= "#Include events\" EventName "\Labels.ahk`n"
  }
}

MergedFile .= "`n`n`;`; Plugins Labels`n`n"

Loop, % AdminHelper["Plugins"].MaxIndex()
{
  PluginName := AdminHelper["Plugins"][A_Index]

  If (FileExist(A_ScriptDir "\plugins\" PluginName "\Labels.ahk")) {
    MergedFile .= "#Include plugins\" PluginName "\Labels.ahk`n`n"
  }
}

FileAppend, %MergedFile%`n, .cache\AdminHelper.ahk

Sleep 1000

Run .cache\AdminHelper.ahk %1%
