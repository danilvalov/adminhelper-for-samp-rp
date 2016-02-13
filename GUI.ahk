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

  modulesList := {}
  modulesListRequired := {}
  modulesConfigsList := {}
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
    Menu, Tray, Add, AdminHelper, SettingsGuiOpen
    Menu, Tray, Disable, AdminHelper
    Menu, Tray, Add
    Menu, Tray, Add, Перезапустить, ScriptReload
    Menu, Tray, Add, Настройки, SettingsGuiOpen
    Menu, Tray, Default, Настройки
    Menu, Tray, Add
    Menu, Tray, Add, Выйти, AppExit

    Return
  }

  guiGeneration()
  {
    Gui, Settings:New

    Gui, Settings:Default

    Gui, Settings:+LastFound

    this.pluginsViewGeneration()

    this.userBindsGeneration()

    Gui, Settings:Tab

    Gui, Settings:Add, Button, x10 gGuiSave, Сохранить

    Gui, Settings:Add, Button, x+5 gSettingsGuiClose, Отменить

    Gui, Settings:Show, , % this.windowTitle

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
                if (SubStr(ModuleLine, 1, 1) = ";" && InStr(ModuleLine, "Description:")) {
                  ModuleDescription := SubStr(ModuleLine, InStr(ModuleLine, "Description:") + StrLen("Description:"))
                  ModuleDescription := Trim(ModuleDescription)
                  this.modulesList[ModuleName]["Description"] := ModuleDescription
                }
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

    TabString := "Плагины|Биндер"
    TabString := this.tabListGenerator(TabString)

    TabWidth := this.windowWidth - 20
    TabHeight := this.windowHeight - 40
    LabelWidth := TabWidth - 35
    Gui, Settings:Add, Tab2, w%TabWidth% h%TabHeight%, %TabString%

    this.modulesTabsGeneration(LabelWidth)

    this.pluginsListGeneration(LabelWidth)

    this.pluginsTabsGeneration(LabelWidth)

    Return
  }

  pluginsListGeneration(LabelWidth)
  {
    Global

    Gui, Settings:Tab, 1

    Local AdminLVLValue := this.adminLVL.Value
    Local AdminLVLDescription := this.adminLVL.Description
    this.inputGeneration("AdminLVL", AdminLVLValue, AdminLVLDescription, LabelWidth)

    Local PluginName, PluginData

    For PluginName, PluginData in this.pluginsList {
      Local PluginStatus := PluginData["Status"]
      Local PluginDescription := PluginData["Description"]
      Gui, Settings:Add, Checkbox, +Wrap w%LabelWidth% y+15 vGuiPlugin%PluginName%Status checked%PluginStatus%, %PluginName% - %PluginDescription%
    }

    Return
  }

  modulesTabsGeneration(LabelWidth)
  {
    For ModuleName, ModuleVariableObject in this.modulesConfigsList {
      ModuleDescription := this.modulesList[ModuleName]["Description"]
      ModuleCmd := this.modulesList[ModuleName]["Cmd"]
      Gui, Settings:Tab, %ModuleName%, , Exact
      Gui, Settings:Font, Bold
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %ModuleName%
      Gui, Settings:Font
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+10, %ModuleDescription%

      if (StrLen(ModuleCmd)) {
        Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+10, Список доступных команд: %ModuleCmd%
      }

      For VariableName, VariableData in ModuleVariableObject {
        VariableValue := VariableData.Value
        VariableDescription := VariableData.Description
        this.inputGeneration(VariableName, VariableValue, VariableDescription, LabelWidth)
      }
    }

    Return
  }

  pluginsTabsGeneration(LabelWidth)
  {
    For PluginName, PluginVariableObject in this.pluginsConfigsList {
      PluginDescription := this.pluginsList[PluginName]["Description"]
      PluginCmd := this.pluginsList[PluginName]["Cmd"]
      Gui, Settings:Tab, %PluginName%, , Exact
      Gui, Settings:Font, Bold
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %PluginName%
      Gui, Settings:Font
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+10, %PluginDescription%

      if (StrLen(PluginCmd)) {
        Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+10, Список доступных команд: %PluginCmd%
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
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %VariableDescription%:
      Gui, Settings:Add, Hotkey, w150 vGui%VariableName%Input y+5, %VariableValue%
    } else if (SubStr(VariableName, -6) = "Boolean") {
      if (SubStr(VariableDescription, 1, 4) = "1 - ") {
        VariableDescription := SubStr(VariableDescription, 5)
      }
      Gui, Settings:Add, Checkbox, +Wrap w%LabelWidth% y+15 vGui%VariableName%Input checked%VariableValue%, %VariableDescription%
    } else if (SubStr(VariableName, -3) = "File") {
       Local TextAreaWidth := this.windowWidth - 45
       Local TextAreaRowsCount := (this.windowHeight - 170) / 14
       Local FileContents
       FileRead, FileContents, %A_ScriptDir%\%VariableValue%
       Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %VariableDescription%:
       Gui, Settings:Add, Edit, r%TextAreaRowsCount% w%TextAreaWidth% vGui%VariableName%Input, %FileContents%
     } else {
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %VariableDescription%:
      if (StrLen(VariableValue) >= 10 || StrLen(VariableValue) = 0) {
        Gui, Settings:Add, Edit, w%LabelWidth% vGui%VariableName%Input y+5, %VariableValue%
      } else {
        Gui, Settings:Add, Edit, w150 vGui%VariableName%Input y+5, %VariableValue%
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
        ModuleConfigVariableDescription =
        PluginConfigVariableDescription =

        Line := Trim(A_LoopField)
        ConfigVariableLineNumber := A_Index

        if (StrLen(Line) && SubStr(Line, 1, 1) <> ";") {
          if (SubStr(Line, 1, StrLen("AdminLVL")) = "AdminLVL") {
            this.adminLVL.Line := ConfigVariableLineNumber

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

          For ModuleName, ModuleData in this.modulesList {
            if (SubStr(Line, 1, StrLen(ModuleName)) = ModuleName) {
              ModuleConfigLine := Line
              if (InStr(ModuleConfigLine, ";")) {
                ModuleConfigVariableDescription := SubStr(ModuleConfigLine, InStr(ModuleConfigLine, ";") + 1)
                ModuleConfigVariableDescription := Trim(ModuleConfigVariableDescription)
                if (SubStr(ModuleConfigVariableDescription, 1, 1) = ";") {
                  ModuleConfigVariableDescription := Trim(SubStr(ModuleConfigVariableDescription, 2))
                }

                ModuleConfigLine := SubStr(ModuleConfigLine, 1, InStr(ModuleConfigLine, ";") - 1)
                ModuleConfigLine := Trim(ModuleConfigLine)
              }

              if (!this.modulesConfigsList[ModuleName]) {
                this.modulesConfigsList[ModuleName] := {}
              }

              ModuleConfigVariableName =

              if (InStr(ModuleConfigLine, ":=")) {
                ModuleConfigVariableName := SubStr(ModuleConfigLine, 1, InStr(ModuleConfigLine, ":=") - 1)
                ModuleConfigVariableName := Trim(ModuleConfigVariableName)
                ModuleConfigVariableValue := SubStr(ModuleConfigLine, InStr(ModuleConfigLine, ":=") + StrLen(":="))
                ModuleConfigVariableValue := Trim(ModuleConfigVariableValue)
                if (SubStr(ModuleConfigVariableValue, 1, 1) = Trim(" """" ")) {
                  ModuleConfigVariableValue := SubStr(ModuleConfigVariableValue, 2, -1)
                  ModuleConfigVariableValue := Trim(ModuleConfigVariableValue)
                }
              } else if (InStr(ModuleConfigLine, "=")) {
                ModuleConfigVariableName := SubStr(ModuleConfigLine, 1, InStr(ModuleConfigLine, "=") - 1)
                ModuleConfigVariableName := Trim(ModuleConfigVariableName)
                ModuleConfigVariableValue := SubStr(ModuleConfigLine, InStr(ModuleConfigLine, "=") + StrLen("="))
                ModuleConfigVariableValue := Trim(ModuleConfigVariableValue)
              }

              if (StrLen(ModuleConfigVariableName)) {
                this.modulesConfigsList[ModuleName][ModuleConfigVariableName] := {}
                this.modulesConfigsList[ModuleName][ModuleConfigVariableName].Line := ConfigVariableLineNumber
                this.modulesConfigsList[ModuleName][ModuleConfigVariableName].Value := ModuleConfigVariableValue
                this.modulesConfigsList[ModuleName][ModuleConfigVariableName].Description := ModuleConfigVariableDescription

                Break
              }
            }
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
                this.pluginsConfigsList[PluginName][PluginConfigVariableName].Line := ConfigVariableLineNumber
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

  tabListGenerator(TabString)
  {
    this.configReader()

    For ModuleName, ModuleVariable in this.modulesConfigsList {
      TabString := TabString "|" ModuleName
    }

    For PluginName, PluginVariable in this.pluginsConfigsList {
      TabString := TabString "|" PluginName
    }

    Return TabString
  }

  userBindsGeneration()
  {
    Global

    Gui, Settings:Tab, 2

    Local UserBindsWidth := this.windowWidth - 45
    Local UserBindsRowsCount := (this.windowHeight - 60) / 14
    Local FileContents
    FileRead, FileContents, %A_ScriptDir%\UserBinds.ahk
    Gui, Settings:Add, Edit, r%UserBindsRowsCount% w%UserBindsWidth% vGuiUserBindsInput, %FileContents%

    Gui, Settings:Tab

    Return
  }

  dataUpdate()
  {
    For ModuleName, ModuleVariableObject in this.modulesConfigsList {
      For VariableName, VariableData in ModuleVariableObject {
        if (SubStr(VariableName, -3) <> "File") {
          VariableInputName = Gui%VariableName%Input
          GuiControlGet, %VariableInputName%
          VariableInputValue := %VariableInputName%
          this.modulesConfigsList[ModuleName][VariableName].Value := VariableInputValue
        }
      }
    }

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

    For ModuleName, VariablesData in this.modulesConfigsList {
      For VariableName, VariableData in VariablesData {
        ConfigLinesList[VariableData.Line] := {}
        ConfigLinesList[VariableData.Line].Name := VariableName
        ConfigLinesList[VariableData.Line].Value := VariableData.Value
      }
    }

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
    Gui, Settings:Destroy

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
    Gui, Settings:Submit, NoHide

    this.dataUpdate()

    Run "%A_AhkPath%" /r "%A_ScriptFullPath%" /saved

    Return
  }
}

AdminHelperGui := new AdminHelperGui()

if (%0%) {
  AdminHelperGui.open()
  MsgBox, Введённые данные сохранены успешно.`nНовые параметры уже применены.
} else if (A_ScriptName <> "AdminHelper.ahk") {
  AdminHelperGui.open()
} else {
  AdminHelperGui.trayMenuGeneration()
}

Return

SettingsGuiOpen:
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
SettingsGuiClose:
{
  if (A_ScriptName <> "AdminHelper.ahk") {
    ExitApp
  } else {
    AdminHelperGui.guiClose()
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
