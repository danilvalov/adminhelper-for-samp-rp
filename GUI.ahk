;;
;; GUI for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b7 (Nov 08, 2015)
;;

#NoEnv

#SingleInstance Force

class AdminHelperGui
{
  windowTitle := "Настройки - AdminHelper.ahk"

  windowWidth := 900
  windowHeight := 700

  countSymbolsBeforeComments := 50

  adminLVL := {}
  ignoreList := {}

  modulesList := {}
  modulesListRequired := {}
  pluginsList := {}
  pluginsConfigsList := {}
  moduleIncludeStartLine := "#include modules\"
  pluginIncludeStartLine := "#include plugins\"

  __hasValueInArray(Array, Value)
  {
    for Key, Val in Array {
      if (Val = Value) {
        Return Key
      }
    }

    Return 0
  }

  __stringJoin(Array, Delimiter = ";")
  {
    Result =
    Loop
      If Not Array[A_Index] Or Not Result .= (Result ? Delimiter : "") Array[A_Index]
        Return Result
  }

  trayMenuGeneration()
  {
    Menu, Tray, NoStandard
    Menu, Tray, Add, AdminHelper, GuiOpen
    Menu, Tray, Disable, AdminHelper
    Menu, Tray, Add
    Menu, Tray, Add, Перезапустить, ScriptReload
    Menu, Tray, Add, Настройки, GuiOpen
    Menu, Tray, Default, Настройки
    Menu, Tray, Add
    Menu, Tray, Add, Выйти, AppExit

    Return
  }

  guiGeneration()
  {
    Gui, New

    Gui, Default

    Gui, +LastFound

    this.pluginsViewGeneration()

    this.userBindsGeneration()

    this.ignoreListGeneration()

    Gui, Tab

    Gui, Add, Button, x10 gGuiSave, Сохранить

    Gui, Add, Button, x+5 gGuiClose, Отменить

    Gui, Show, , % this.windowTitle

    Return WinExist()
  }

  pluginsListRead()
  {
    FileRead, Contents, %A_ScriptDir%\AdminHelper.ahk
    if not ErrorLevel
    {
      Loop, Parse, Contents, `n, `r
      {
        Line := Trim(A_LoopField)
        if (InStr(Line, this.moduleIncludeStartLine)) {
          ModulePath := SubStr(Line, InStr(Line, "#include ") + StrLen("#include "))
          ModulePath := SubStr(ModulePath, 1, InStr(ModulePath, ".ahk") + 3)
          ModulePath := Trim(ModulePath)
          ModuleName := SubStr(Line, InStr(Line, this.moduleIncludeStartLine) + StrLen(this.moduleIncludeStartLine))
          ModuleName := SubStr(ModuleName, 1, InStr(ModuleName, ".ahk") - 1)
          if (InStr(ModuleName, "-Funcs")) {
            ModuleName := SubStr(ModuleName, 1, InStr(ModuleName, "-Funcs") - 1)
          }
          if (InStr(ModuleName, "-Labels")) {
            ModuleName := SubStr(ModuleName, 1, InStr(ModuleName, "-Labels") - 1)
          }
          if (InStr(ModuleName, "-Binds")) {
            ModuleName := SubStr(ModuleName, 1, InStr(ModuleName, "-Binds") - 1)
          }
          if (!this.modulesList[ModuleName]) {
            ModuleStatus := (SubStr(Line, 1, 1) = ";" ? 0 : 1)
            this.modulesList[ModuleName] := {}
            this.modulesList[ModuleName]["Paths"] := {}
            this.modulesList[ModuleName]["Paths"][A_Index] := ModulePath
            this.modulesList[ModuleName]["Status"] := ModuleStatus

            FileRead, Contents, %A_ScriptDir%\%ModulePath%
            if not ErrorLevel
            {
              Loop, Parse, Contents, `n, `r
              {
                ModuleLine := Trim(A_LoopField)
                if (SubStr(ModuleLine, 1, 1) = ";" && InStr(ModuleLine, "Required modules:")) {
                  this.modulesList[ModuleName]["RequiredModules"] := []
                  ModuleRequiredModules := SubStr(ModuleLine, InStr(ModuleLine, "Required modules:") + StrLen("Required modules:"))
                  ModuleRequiredModules := Trim(ModuleRequiredModules)
                  Loop, Parse, ModuleRequiredModules, `,
                  {
                    ModuleRequiredModule := Trim(A_LoopField)
                    this.modulesList[ModuleName]["RequiredModules"].Insert(ModuleRequiredModule)
                  }
                }
              }
            }
          } else {
            this.modulesList[ModuleName]["Paths"][A_Index] := ModulePath
          }
        }
        if (InStr(Line, this.pluginIncludeStartLine)) {
          PluginPath := SubStr(Line, InStr(Line, "#include ") + StrLen("#include "))
          PluginPath := SubStr(PluginPath, 1, InStr(PluginPath, ".ahk") + 3)
          PluginPath := Trim(PluginPath)
          PluginName := SubStr(Line, InStr(Line, this.pluginIncludeStartLine) + StrLen(this.pluginIncludeStartLine))
          PluginName := SubStr(PluginName, 1, InStr(PluginName, ".ahk") - 1)
          if (InStr(PluginName, "-Funcs")) {
            PluginName := SubStr(PluginName, 1, InStr(PluginName, "-Funcs") - 1)
          }
          if (InStr(PluginName, "-Labels")) {
            PluginName := SubStr(PluginName, 1, InStr(PluginName, "-Labels") - 1)
          }
          if (InStr(PluginName, "-Binds")) {
            PluginName := SubStr(PluginName, 1, InStr(PluginName, "-Binds") - 1)
          }
          if (!this.pluginsList[PluginName]) {
            PluginDescription =
            PluginCmd =
            PluginStatus := (SubStr(Line, 1, 1) = ";" ? 0 : 1)
            this.pluginsList[PluginName] := {}
            this.pluginsList[PluginName]["Paths"] := {}
            this.pluginsList[PluginName]["Paths"][A_Index] := PluginPath
            this.pluginsList[PluginName]["Status"] := PluginStatus

            FileRead, Contents, %A_ScriptDir%\%PluginPath%
            if not ErrorLevel
            {
              Loop, Parse, Contents, `n, `r
              {
                PluginLine := Trim(A_LoopField)
                if (SubStr(PluginLine, 1, 1) = ";" && InStr(PluginLine, "Description:")) {
                  PluginDescription := SubStr(PluginLine, InStr(PluginLine, "Description:") + StrLen("Description:"))
                  PluginDescription := Trim(PluginDescription)
                  this.pluginsList[PluginName]["Description"] := PluginDescription
                }
                if (SubStr(PluginLine, 1, 1) = ";" && InStr(PluginLine, "CMD:")) {
                  PluginCmd := SubStr(PluginLine, InStr(PluginLine, "CMD:") + StrLen("CMD:"))
                  PluginCmd := Trim(PluginCmd)
                  this.pluginsList[PluginName]["CMD"] := PluginCmd
                }
                if (SubStr(PluginLine, 1, 1) = ";" && InStr(PluginLine, "Required modules:")) {
                  this.pluginsList[PluginName]["RequiredModules"] := []
                  PluginRequiredModules := SubStr(PluginLine, InStr(PluginLine, "Required modules:") + StrLen("Required modules:"))
                  PluginRequiredModules := Trim(PluginRequiredModules)
                  Loop, Parse, PluginRequiredModules, `,
                  {
                    PluginRequiredModule := Trim(A_LoopField)
                    if (this.modulesList[PluginRequiredModule]) {
                      this.pluginsList[PluginName]["RequiredModules"].Insert(PluginRequiredModule)
                    }
                  }
                }
              }
            }
          } else {
            this.pluginsList[PluginName]["Paths"][A_Index] := PluginPath
          }
        }
      }
    }

    Return
  }

  pluginsViewGeneration()
  {
    this.pluginsListRead()

    TabString := "Плагины|Биндер|ИгнорЛист"
    TabString := this.tabPluginsListGenerator(TabString)

    TabWidth := this.windowWidth - 20
    TabHeight := this.windowHeight - 40
    LabelWidth := TabWidth - 35
    Gui, Add, Tab2, w%TabWidth% h%TabHeight%, %TabString%

    this.pluginsListGeneration(LabelWidth)

    this.pluginsTabsGeneration(LabelWidth)

    Return
  }

  pluginsListGeneration(LabelWidth)
  {
    Global

    Gui, Tab, 1

    Local AdminLVLValue := this.adminLVL.Value
    Local AdminLVLDescription := this.adminLVL.Description
    this.inputGeneration("AdminLVL", AdminLVLValue, AdminLVLDescription, LabelWidth)

    Local PluginName, PluginData

    For PluginName, PluginData in this.pluginsList {
      Local PluginStatus := PluginData["Status"]
      Local PluginDescription := PluginData["Description"]
      Gui, Add, Checkbox, +Wrap w%LabelWidth% y+15 vGuiPlugin%PluginName%Status checked%PluginStatus%, %PluginName% - %PluginDescription%
    }

    Return
  }

  pluginsTabsGeneration(LabelWidth)
  {
    For PluginName, PluginVariableObject in this.pluginsConfigsList {
      PluginDescription := this.pluginsList[PluginName]["Description"]
      PluginCmd := this.pluginsList[PluginName]["Cmd"]
      Gui, Tab, %PluginName%, , Exact
      Gui, Font, Bold
      Gui, Add, Text, +Wrap w%LabelWidth% y+15, %PluginName%
      Gui, Font
      Gui, Add, Text, +Wrap w%LabelWidth% y+10, %PluginDescription%

      if (StrLen(PluginCmd)) {
        Gui, Add, Text, +Wrap w%LabelWidth% y+10, Список доступных команд: %PluginCmd%
      }

      For VariableName, VariableData in PluginVariableObject {
        VariableValue := VariableData.Value
        VariableDescription := VariableData.Description
        this.inputGeneration(VariableName, VariableValue, VariableDescription, LabelWidth)
      }
    }

    Return
  }

  inputGeneration(VariableName, VariableValue, VariableDescription, LabelWidth)
  {
    Global

    if (SubStr(VariableName, -2) = "Key") {
      Gui, Add, Text, +Wrap w%LabelWidth% y+15, %VariableDescription%:
      Gui, Add, Hotkey, w150 vGui%VariableName%Input y+5, %VariableValue%
    } else if (SubStr(VariableName, -6) = "Boolean") {
      if (SubStr(VariableDescription, 1, 4) = "1 - ") {
        VariableDescription := SubStr(VariableDescription, 5)
      }
      Gui, Add, Checkbox, +Wrap w%LabelWidth% y+15 vGui%VariableName%Input checked%VariableValue%, %VariableDescription%
    } else if (SubStr(VariableName, -3) = "File") {
       Local TextAreaWidth := this.windowWidth - 45
       Local TextAreaRowsCount := (this.windowHeight - 170) / 14
       Local FileContents
       FileRead, FileContents, %A_ScriptDir%\%VariableValue%
       Gui, Add, Text, +Wrap w%LabelWidth% y+15, %VariableDescription%:
       Gui, Add, Edit, r%TextAreaRowsCount% w%TextAreaWidth% vGui%VariableName%Input, %FileContents%
     } else {
      Gui, Add, Text, +Wrap w%LabelWidth% y+15, %VariableDescription%:
      if (StrLen(VariableValue) >= 10 || StrLen(VariableValue) = 0) {
        Gui, Add, Edit, w%LabelWidth% vGui%VariableName%Input y+5, %VariableValue%
      } else {
        Gui, Add, Edit, w150 vGui%VariableName%Input y+5, %VariableValue%
      }
    }

    Return
  }

  configReader()
  {
    FileRead, Contents, %A_ScriptDir%\Config.ahk
    if not ErrorLevel
    {
      Loop, Parse, Contents, `n, `r
      {
        PluginConfigVariableDescription =

        Line := Trim(A_LoopField)
        PluginConfigVariableLineNumber := A_Index

        if (StrLen(Line) && SubStr(Line, 1, 1) <> ";") {
          if (SubStr(Line, 1, StrLen("AdminLVL")) = "AdminLVL") {
            this.adminLVL.Line := PluginConfigVariableLineNumber

            if (InStr(Line, ";")) {
              this.adminLVL.Description := SubStr(Line, InStr(Line, ";") + 1)
              this.adminLVL.Description := Trim(this.adminLVL.Description)
              if (SubStr(this.adminLVL.Description, 1, 1) = ";") {
                this.adminLVL.Description := Trim(SubStr(this.adminLVL.Description, 2))
              }

              Line := SubStr(Line, 1, InStr(Line, ";") - 1)
              Line := Trim(Line)
            }

            if (InStr(Line, ":=")) {
              this.adminLVL.Value := SubStr(Line, InStr(Line, ":=") + StrLen(":="))
              this.adminLVL.Value := Trim(this.adminLVL.Value)
              if (SubStr(this.adminLVL.Value, 1, 1) = Trim(" """" ")) {
                this.adminLVL.Value := SubStr(this.adminLVL.Value, 2, -1)
                this.adminLVL.Value := Trim(this.adminLVL.Value)
              }
            } else if (InStr(Line, "=")) {
              this.adminLVL.Value := SubStr(Line, InStr(Line, "=") + StrLen("="))
              this.adminLVL.Value := Trim(this.adminLVL.Value)
            }

            Continue
          }

          if (SubStr(Line, 1, StrLen("IgnoreList")) = "IgnoreList") {
            IgnoreListValue =


            this.ignoreList.Items := []

            this.ignoreList.Line := PluginConfigVariableLineNumber

            if (InStr(Line, ";")) {
              this.ignoreList.Description := SubStr(Line, InStr(Line, ";") + 1)
              this.ignoreList.Description := Trim(this.ignoreList.Description)
              if (SubStr(this.ignoreList.Description, 1, 1) = ";") {
                this.ignoreList.Description := Trim(SubStr(this.ignoreList.Description, 2))
              }

              Line := SubStr(Line, 1, InStr(Line, ";") - 1)
              Line := Trim(Line)
            }

            if (InStr(Line, ":=")) {
              IgnoreListValue := SubStr(Line, InStr(Line, ":=") + StrLen(":="))
              IgnoreListValue := Trim(IgnoreListValue)
              if (SubStr(IgnoreListValue, 1, 1) = Trim(" """" ")) {
                IgnoreListValue := SubStr(IgnoreListValue, 2, -1)
                IgnoreListValue := Trim(IgnoreListValue)
              }
            } else if (InStr(Line, "=")) {
              IgnoreListValue := SubStr(Line, InStr(Line, "=") + StrLen("="))
              IgnoreListValue := Trim(IgnoreListValue)
            }

            if (StrLen(IgnoreListValue)) {
              Loop, Parse, IgnoreListValue, `,
              {
                IgnoreListItem := RegExReplace(A_LoopField, "[^a-zA-Z0-9\_]", "")
                this.ignoreList.Items.Insert(IgnoreListItem)
              }
            }

            Continue
          }

          For PluginName, PluginData in this.pluginsList {
            if (SubStr(Line, 1, StrLen(PluginName)) = PluginName) {
              PluginConfigLine := Line
              if (InStr(PluginConfigLine, ";")) {
                PluginConfigVariableDescription := SubStr(PluginConfigLine, InStr(PluginConfigLine, ";") + 1)
                PluginConfigVariableDescription := Trim(PluginConfigVariableDescription)
                if (SubStr(PluginConfigVariableDescription, 1, 1) = ";") {
                  PluginConfigVariableDescription := Trim(SubStr(PluginConfigVariableDescription, 2))
                }

                PluginConfigLine := SubStr(PluginConfigLine, 1, InStr(PluginConfigLine, ";") - 1)
                PluginConfigLine := Trim(PluginConfigLine)
              }

              if (!this.pluginsConfigsList[PluginName]) {
                this.pluginsConfigsList[PluginName] := {}
              }

              PluginConfigVariableName =

              if (InStr(PluginConfigLine, ":=")) {
                PluginConfigVariableName := SubStr(PluginConfigLine, 1, InStr(PluginConfigLine, ":=") - 1)
                PluginConfigVariableName := Trim(PluginConfigVariableName)
                PluginConfigVariableValue := SubStr(PluginConfigLine, InStr(PluginConfigLine, ":=") + StrLen(":="))
                PluginConfigVariableValue := Trim(PluginConfigVariableValue)
                if (SubStr(PluginConfigVariableValue, 1, 1) = Trim(" """" ")) {
                  PluginConfigVariableValue := SubStr(PluginConfigVariableValue, 2, -1)
                  PluginConfigVariableValue := Trim(PluginConfigVariableValue)
                }
              } else if (InStr(PluginConfigLine, "=")) {
                PluginConfigVariableName := SubStr(PluginConfigLine, 1, InStr(PluginConfigLine, "=") - 1)
                PluginConfigVariableName := Trim(PluginConfigVariableName)
                PluginConfigVariableValue := SubStr(PluginConfigLine, InStr(PluginConfigLine, "=") + StrLen("="))
                PluginConfigVariableValue := Trim(PluginConfigVariableValue)
              }

              if (StrLen(PluginConfigVariableName)) {
                this.pluginsConfigsList[PluginName][PluginConfigVariableName] := {}
                this.pluginsConfigsList[PluginName][PluginConfigVariableName].Line := PluginConfigVariableLineNumber
                this.pluginsConfigsList[PluginName][PluginConfigVariableName].Value := PluginConfigVariableValue
                this.pluginsConfigsList[PluginName][PluginConfigVariableName].Description := PluginConfigVariableDescription

                Break
              }
            }
          }
        }
      }
    }

    Return
  }

  tabPluginsListGenerator(TabString)
  {
    this.configReader()

    For PluginName, pluginVariable in this.pluginsConfigsList {
      TabString := TabString "|" PluginName
    }

    Return TabString
  }

  ignoreListGeneration()
  {
    Global

    Local TabWidth := this.windowWidth - 20
    Local LabelWidth := TabWidth - 35

    Gui, Tab, 3

    Local IgnoreListDescription := this.ignoreList.Description
    Local IgnoreListString := this.__stringJoin(this.ignoreList.Items, "`n")
    this.ignoreList.String := IgnoreListString
    Local IgnoreListWidth := this.windowWidth - 45
    Local IgnoreListRowsCount := (this.windowHeight - 100) / 14
    Gui, Add, Text, +Wrap w%LabelWidth% y+15, %IgnoreListDescription%:
    Gui, Add, Edit, r%IgnoreListRowsCount% w%IgnoreListWidth% y+15 vGuiIgnoreListInput, %IgnoreListString%

    Return
  }

  userBindsGeneration()
  {
    Global

    Gui, Tab, 2

    Local UserBindsWidth := this.windowWidth - 45
    Local UserBindsRowsCount := (this.windowHeight - 60) / 14
    Local FileContents
    FileRead, FileContents, %A_ScriptDir%\UserBinds.ahk
    Gui, Add, Edit, r%UserBindsRowsCount% w%UserBindsWidth% vGuiUserBindsInput, %FileContents%

    Gui, Tab

    Return
  }

  dataUpdate()
  {
    For PluginName, PluginVariableObject in this.pluginsList {
      GuiControlGet, GuiPlugin%PluginName%Status

      this.pluginsList[PluginName]["Status"] := GuiPlugin%PluginName%Status
    }

    For PluginName, PluginVariableObject in this.pluginsConfigsList {
      For VariableName, VariableData in PluginVariableObject {
        if (SubStr(VariableName, -3) <> "File") {
          VariableInputName = Gui%VariableName%Input
          GuiControlGet, %VariableInputName%
          VariableInputValue := %VariableInputName%
          this.pluginsConfigsList[PluginName][VariableName].Value := VariableInputValue
        }
      }
    }

    GuiControlGet, GuiAdminLVLInput
    this.adminLVL.Value := GuiAdminLVLInput

    GuiControlGet, GuiIgnoreListInput
    this.ignoreList.String := GuiIgnoreListInput

    this.modulesStatusesUpdate()

    this.pluginsStatusesSave()

    this.configSave()

    this.userBindsSave()

    Return
  }

  modulesStatusesUpdate()
  {
    this.modulesListRequired := {}

    For PluginName, PluginData in this.pluginsList {
      if (PluginData["Status"]) {
        For Key, RequiredModule in PluginData["RequiredModules"] {
          if (this.modulesList[RequiredModule] && !this.modulesListRequired[RequiredModule]) {
            this.modulesListRequired[RequiredModule] := this.modulesList[RequiredModule]
          }
        }
      }
    }

    For ModuleName, ModuleData in this.modulesList {
      if (this.modulesListRequired[ModuleName]) {
        For Key, RequiredModule in ModuleData["RequiredModules"] {
          if (this.modulesList[RequiredModule] && !this.modulesListRequired[RequiredModule]) {
            this.modulesListRequired[RequiredModule] := this.modulesList[RequiredModule]
          }
        }
      }
    }

    Return
  }

  pluginsStatusesSave()
  {
    LinesList := {}
    For ModuleName, ModuleData in this.modulesList {
      For ModulePathLine, ModulePath in ModuleData["Paths"] {
        LinesList[ModulePathLine] := (this.modulesListRequired[ModuleName] ? "True" : "False")
      }
    }
    For PluginName, PluginData in this.pluginsList {
      For PluginPathLine, PluginPath in PluginData["Paths"] {
        LinesList[PluginPathLine] := (PluginData["Status"] ? "True" : "False")
      }
    }

    FileDelete, AdminHelper.ahk.tmp

    FileRead, Contents, %A_ScriptDir%\AdminHelper.ahk
    if not ErrorLevel
    {
      StringReplace, TmpVar, Contents,`n,`n, UseErrorLevel
      CountLines := ErrorLevel + 1
      Loop, Parse, Contents, `n, `r
      {
        Line := A_LoopField
        if (LinesList[A_Index]) {
          LineStatus := !InStr(SubStr(Line, 1, InStr(Line, "#include") - 1), ";")
          if (LineStatus && LinesList[A_Index] = "False") {
            Line := ";" Line
          } else if (!LineStatus && LinesList[A_Index] = "True") {
            Line := SubStr(Line, InStr(Line, "#include"))
          }
        }
        NewLine := Line
        if (A_Index < CountLines) {
          NewLine := NewLine "`n"
        }
        FileAppend, %NewLine%, AdminHelper.ahk.tmp
      }

      FileCopy, AdminHelper.ahk.tmp, AdminHelper.ahk, 1
    }

    FileDelete, AdminHelper.ahk.tmp

    Return
  }

  configSave()
  {
    ConfigLinesList := {}
    For PluginName, VariablesData in this.pluginsConfigsList {
      For VariableName, VariableData in VariablesData {
        ConfigLinesList[VariableData.Line] := {}
        ConfigLinesList[VariableData.Line].Name := VariableName
        ConfigLinesList[VariableData.Line].Value := VariableData.Value
      }
    }

    if (this.adminLVL.Line) {
      ConfigLinesList[this.adminLVL.Line] := {}
      ConfigLinesList[this.adminLVL.Line].Name := "AdminLVL"
      ConfigLinesList[this.adminLVL.Line].Value := this.adminLVL.Value
    }

    if (this.ignoreList.Line) {
      IgnoreListString := "`["""
      IgnoreListArray := StrSplit(this.ignoreList.String, "`n")
      IgnoreListCleanArray := []
      For IgnoreListKey, IgnoreListItem in IgnoreListArray {
        if (!this.__hasValueInArray(IgnoreListCleanArray, IgnoreListItem)) {
          If (IgnoreListKey > 1) {
            IgnoreListString := IgnoreListString Trim(" ""`, "" ")
          }
          IgnoreListString := IgnoreListString IgnoreListItem
          IgnoreListCleanArray.Insert(IgnoreListItem)
        }
      }
      IgnoreListString := IgnoreListString Trim(" ""] ")
      this.ignoreList.Value := IgnoreListString

      this.ignoreList.Items := IgnoreListCleanArray
      IgnoreListString := this.__stringJoin(IgnoreListCleanArray, "`n")
      this.ignoreList.String := IgnoreListString

      GuiControl,, GuiIgnoreListInput, %IgnoreListString%

      ConfigLinesList[this.ignoreList.Line] := {}
      ConfigLinesList[this.ignoreList.Line].Name := "IgnoreList"
      ConfigLinesList[this.ignoreList.Line].Value := this.ignoreList.Value
    }

    FileDelete, Config.ahk.tmp

    FileRead, Contents, %A_ScriptDir%\Config.ahk
    if not ErrorLevel
    {
      StringReplace, TmpVar, Contents,`n,`n, UseErrorLevel
      CountLines := ErrorLevel + 1
      Loop, Parse, Contents, `n, `r
      {
        Line := A_LoopField
        if (ConfigLinesList[A_Index]) {
          Comment =
          if (InStr(Line, ";")) {
            Comment := SubStr(Line, InStr(Line, ";"))
          }
          Line := ConfigLinesList[A_Index].Name
          if (SubStr(Trim(ConfigLinesList[A_Index].Value), 1, 1) = "[") {
            Line := Line " := " ConfigLinesList[A_Index].Value
          } else {
            Line := Line " = " ConfigLinesList[A_Index].Value
          }
          if (this.countSymbolsBeforeComments > StrLen(Line) + 1) {
            Loop, % (this.countSymbolsBeforeComments - StrLen(Line) - 1)
            {
              Comment := " " Comment
            }
          } else {
            Comment := " " Comment
          }
          Line := Line Comment

          if (SubStr(ConfigLinesList[A_Index].Name, -3) = "File") {
            this.textAreaSave(ConfigLinesList[A_Index].Name, ConfigLinesList[A_Index].Value)
          }
        }
        NewLine := Line
        if (A_Index < CountLines) {
          NewLine := NewLine "`n"
        }
        FileAppend, %NewLine%, Config.ahk.tmp
      }

      FileCopy, Config.ahk.tmp, Config.ahk, 1
    }

    FileDelete, Config.ahk.tmp

    Return
  }

  textAreaSave(VariableName, File)
  {
    FileDelete, %File%.tmp

    GuiControlGet, Gui%VariableName%Input
    GuiTextAreaInputValue := Gui%VariableName%Input
    FileAppend, %GuiTextAreaInputValue%, %File%.tmp
    FileCopy, %File%.tmp, %File%, 1
    FileDelete, %File%.tmp

    Return
  }

  userBindsSave()
  {
    FileDelete, UserBinds.ahk.tmp

    GuiControlGet, GuiUserBindsInput
    FileAppend, %GuiUserBindsInput%, UserBinds.ahk.tmp
    FileCopy, UserBinds.ahk.tmp, UserBinds.ahk, 1
    FileDelete, UserBinds.ahk.tmp

    Return
  }

  guiClose()
  {
    Gui, Destroy

    Return
  }

  open()
  {
    IfWinExist, % this.windowTitle
    {
      WinActivate
    } else {
      this.guiGeneration()
    }

    Return
  }

  done()
  {
    Gui, Submit, NoHide

    this.dataUpdate()

    Run "%A_AhkPath%" /r "%A_ScriptFullPath%" /saved

    Return
  }
}

AdminHelperGui := new AdminHelperGui()

AdminHelperGui.trayMenuGeneration()

if (%0%) {
  AdminHelperGui.open()
  MsgBox, Введённые данные сохранены успешно.`nНовые параметры уже применены.
} else if (A_ScriptName <> "AdminHelper.ahk") {
  AdminHelperGui.open()
}

Return

GuiOpen:
{
  AdminHelperGui.open()

  Return
}

GuiSave:
{
  AdminHelperGui.done()

  Return
}

ButtonCancel:
GuiClose:
{
  AdminHelperGui.guiClose()
  
  if (A_ScriptName <> "AdminHelper.ahk") {
    ExitApp
  }

  Return
}

ScriptReload:
{
  Reload

  Return
}

AppExit:
{
  ExitApp

  Return
}
