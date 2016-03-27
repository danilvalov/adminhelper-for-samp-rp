;;
;; ConfigReader.ahk for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class ConfigReader {
  parseIniValues(Values) {
    Result := {}

    SplitValues := StrSplit(Values, "`n")

    Loop, % SplitValues.MaxIndex()
    {
      SplitLine := StrSplit(SplitValues[A_Index], "=")
      Result[Trim(SplitLine[1])] := {}
      Result[Trim(SplitLine[1])] := Trim(SplitLine[2])
    }

    Return Result
  }

  readIniSection(IniFile, SectionName) {
    IniRead, SectionValues, % IniFile, % SectionName

    If (SectionValues && StrLen(SectionValues)) {
      Return this.parseIniValues(SectionValues)
    }

    Return False
  }

  updateValuesForOptions(Options) {
    For OptionName, OptionValue in Options {
      Options[OptionName] := Trim(StrSplit(OptionValue, "|")[1])
    }

    Return Options
  }

  __New() {
    Global Config

    If (!FileExist(".cache")) {
      FileCreateDir, .cache
    }

    Config := this.readIniSection("Meta.ini", "Options")
    Config := this.updateValuesForOptions(Config)

    Config["About"] := this.readIniSection("Meta.ini", "About")

    Config["modules"] := {}
    Config["plugins"] := {}

    Loop, Files, modules\*.*, D
    {
      ModuleName := A_LoopFileName

      If (FileExist("modules\" ModuleName "\Meta.ini")) {
        ModuleOptions := this.readIniSection("modules\" ModuleName "\Meta.ini", "Options")

        If (ModuleOptions) {
          Config["modules"][ModuleName] := this.updateValuesForOptions(ModuleOptions)
        }
      }
    }

    Loop, Reg, HKEY_CURRENT_USER\Software\AdminHelper, V
    {
      RegRead, Value

      IfInString, Value, `n
      {
        Value := StrSplit(Value, "`n")
      }

      If ErrorLevel
        Continue

      Config[A_LoopRegName] := Value
    }

    UpdatedEnabledPlugins := []

    Loop, % Config["EnabledPlugins"].MaxIndex()
    {
      PluginName := Config["EnabledPlugins"][A_Index]

      If (FileExist("plugins\" PluginName "\Meta.ini")) {
        IniRead, PluginAdminLVL, % "plugins\" PluginName "\Meta.ini", Config, AdminLVL

        PluginOptions := this.readIniSection("plugins\" PluginName "\Meta.ini", "Options")

        if (PluginAdminLVL <= Config["AdminLVL"]) {
          UpdatedEnabledPlugins.Insert(PluginName)

          If (PluginOptions) {
            Config["plugins"][PluginName] := this.updateValuesForOptions(PluginOptions)
          }
        }
      }
    }

    Config["EnabledPlugins"] := UpdatedEnabledPlugins

    ModuleName =

    Loop, Reg, HKEY_CURRENT_USER\Software\AdminHelper\modules, KVR
    {
      if (A_LoopRegType = "KEY") {
        ModuleName := A_LoopRegName

        If (!Config["modules"][ModuleName]) {
          Config["modules"][ModuleName] := {}
        }
      } else {
        RegRead, Value

        If ErrorLevel
          Continue

        If (StrLen(ModuleName)) {
          Config["modules"][ModuleName][A_LoopRegName] := Value
        }
      }
    }

    PluginName =

    Loop, Reg, HKEY_CURRENT_USER\Software\AdminHelper\plugins, KVR
    {
      if (A_LoopRegType = "KEY") {
        PluginName := A_LoopRegName

        If (!Config["plugins"][PluginName]) {
          Config["plugins"][PluginName] := {}
        }
      } else {
        RegRead, Value

        If ErrorLevel
          Continue

        If (StrLen(PluginName)) {
          Config["plugins"][PluginName][A_LoopRegName] := Value
        }
      }
    }
  }
}

ConfigReader := new ConfigReader()
