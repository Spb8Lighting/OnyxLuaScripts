-- ShowCockpit LUA Script: DeleteRangeOfCuelist
--   created on ShowCockpit v2.15.2
--   by Spb8 Lighting
--   on 15-11-2018

-------------
-- Purpose --
-------------
-- This script allows to create automatically presets based on a fixture selection

---------------
-- Changelog --
---------------
-- 16-11-2018 - 0.0.0.0.0.0.1: Initialisation, not working yet

-------------------
-- Configuration --
-------------------

Settings = {
  WaitTime = 0.5,
  PresetINTENSITYStartPosition = 1,	  -- Adjust the start point from the first line for INTENSITY presets
  PresetCOLORStartPosition = 1,		    -- Adjust the start point from the first line for COLOR presets
  PresetGOBOStartPosition = 1,		    -- Adjust the start point from the first line for Gobo presets
  PresetBEAMStartPosition = 1		      -- Adjust the start point from the first line for BEAM presets
}

ScriptInfos = {
	version = "0.0.0.0.0.0.1",
	name = "AutoPresets"
}

--##LUAHEADERINCLUDE##--

----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

--------------------------
-- Sentence and Wording --
--------------------------

Rep = "%VAR%"

Content = {
  StopMessage = "Stopped!" .. "\r\n\t" .. "The value defined in the script configuration is not supported",
  Action = {
    Question = "What action do you want to perform?",
    Description = "Please select what you want to do:",
    Create = "Create",
    Populate = "Populate"
  },
  Create = {
    Question = "Which type of preset do you want to " .. Rep .. "?",
    Description = "Please select the preset type to " .. Rep .. ":"
  },
  CreateValidation = {
    Question = "Are you sure to create empty " .. Rep .. " presets?",
    Description = "WARNING, it can't be UNDO! Use it with caution!"
  },
  PopulateValidation = {
    Question = "Are you sure to populate " .. Rep .. " presets?",
    Description = "WARNING, it can't be UNDO! Use it with caution!"
  },
  Grid = {
    Question = "What is your preset grid width?",
    Description = "Indicate the preset grid width (min 4):"
  },
  Color = {
    Question = "What is your color preference?",
    Description = "Select your color palette preference (Extended > 20 colors, Basic = 12 colors):",
    Extended = "Extended",
    Basic = "Basic"
  }
}

--------------------------
--      Functions       --
--------------------------


--------------------------
-- Collect Informations --
--------------------------

--# REQUEST the Preset Grid Width # --
--------------------------------

InputSettings.Question = Content.Grid.Question
InputSettings.Description = Content.Grid.Description
InputSettings.CurrentValue = CheckEmpty(GetVar("Settings.PresetGridWidth"), 8)
InputSettings.MinValue = 4

Settings.PresetGridWidth = InputNumber(InputSettings)

if Cancelled(Settings.PresetGridWidth) then
    goto EXIT
else
  SetVar("Settings.PresetGridWidth", Settings.PresetGridWidth)
  LogActivity("\r\n\t" .. "Preset Grid Width: " .. Settings.PresetGridWidth)
end

--##LUAPRESETSINCLUDE##--

::START::

--# REQUEST the Action type # --
--------------------------------
InputSettings = false
InputSettings = {
  Question = Content.Action.Question,
  Description = Content.Action.Description,
  Buttons = Form.OkCancel,
  DefaultButton = Word.Ok,
  DropDown = {Content.Action.Create, Content.Action.Populate},
  DropDownDefault = CheckEmpty(GetVar("Settings.Action"), Content.Action.Create),
  Cancel = true
}

ActionType = InputDropDown(InputSettings)

-- If not ActionType defined, exit
if Cancelled(ActionType) then
  goto EXIT
else
  if Content.Action[ActionType] then
      Settings.Action = ActionType
  else
      LogInformation(Content.StopMessage)
      goto EXIT
  end
  SetVar("Settings.Action", Settings.Action)
  LogActivity("\r\n\t" .."Action: " .. Settings.Action)
end

--# REQUEST the Preset Type # --
--------------------------------
InputSettings = false
InputSettings = {
  Question = replace(Content.Create.Question, Rep, Settings.Action),
  Description = replace(Content.Create.Description, Rep, Settings.Action),
  Buttons = Form.OkCancel,
  DefaultButton = Word.Ok,
  DropDown = {PresetName.Intensity, PresetName.Color, PresetName.Gobo, PresetName.Beam},
  DropDownDefault = CheckEmpty(GetVar("Settings.Type"), PresetName.Intensity),
  Cancel = true
}

PresetType = InputDropDown(InputSettings)

-- If not PresetType defined, exit
if Cancelled(PresetType) then
  goto EXIT
else
  if PresetName[PresetType] then
      Settings.Type = PresetType
  else
      LogInformation(Content.StopMessage)
      goto EXIT
  end
  SetVar("Settings.Type", Settings.Type)
  LogActivity("\r\n\t" .."Preset Type: " .. Settings.Type)
end

-- If Color preferencens not already set, and PresetType is Color, request the color preferences to apply
if Settings.Color == nil then
  if Settings.Type == PresetName.Color then
    InputSettings = false
    InputSettings = {
      Question = Content.Color.Question,
      Description = Content.Color.Description,
      Buttons = Form.OkCancel,
      DropDown = {Content.Color.Extended, Content.Color.Basic},
      DropDownDefault = CheckEmpty(GetVar("Settings.Color"), Content.Color.Basic)
    }
    Settings.Color = InputDropDown(InputSettings)

    -- If not PresetType defined, exit
    if Cancelled(Settings.Color) then
      goto EXIT
    else
      SetVar("Settings.Color", Settings.Color)
      LogActivity("\r\n\t" .."Color Preference: " .. Settings.Color)
    end
  end
end

----------------------------
-- Execution for Creation --
----------------------------

if Settings.Action == Content.Action.Create then
  --# USER Validation # --
  ------------------------

  InputValidationSettings = {
    Question = replace(Content.CreateValidation.Question, Rep, Settings.Type),
    Description = Content.CreateValidation.Description .. "\n\r\n\r" .. GetActivity(),
    Buttons = Form.YesNo,
    DefaultButton = Word.Yes
  }

  Settings.Validation = InputYesNo(InputValidationSettings)

  if Settings.Validation then
    goto START
  end
elseif Settings.Action == Content.Action.Populate then
  goto START
end

::EXIT::
