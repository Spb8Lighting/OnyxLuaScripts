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
-- 09-09-2019 - 0.1: Allow to adjust the preset creation position + For Color preset, the Color Palette choice (Basic or Full) is asked back (previous choice kept) to enhance the workflow
-- 05-01-2019 - 0.0.1: Preset Populate is active
-- 04-01-2019 - 0.0.0.1: Preset creation works, not the populate part
-- 06-12-2018 - 0.0.0.0.0.1: Initialisation, not working yet
-- 16-11-2018 - 0.0.0.0.0.0.1: Initialisation, not working yet

-------------------
-- Configuration --
-------------------

Settings = {
  WaitTime = 0.5,
  PresetStartPosition = {}
}

ScriptInfos = {
	version = "0.1",
	name = "AutoPresets"
}

--##LUAHEADERINCLUDE##--

Settings.PresetStartPosition[PresetName.Intensity] = 1	  -- Adjust the start point from the first line for INTENSITY presets
Settings.PresetStartPosition[PresetName.Color] = 1		    -- Adjust the start point from the first line for COLOR presets
Settings.PresetStartPosition[PresetName.Gobo] = 1		      -- Adjust the start point from the first line for Gobo presets
Settings.PresetStartPosition[PresetName.Beam] = 1		      -- Adjust the start point from the first line for BEAM presets

--##LUAPRESETSINCLUDE##--

----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

--------------------------
-- Sentence and Wording --
--------------------------

Rep = "%VAR%"
RepID = "%GROUPID%"

AutoPresetTypes = {PresetName.Intensity, PresetName.Color, PresetName.Gobo, PresetName.Beam}

Content = {
  StopMessage = "Stopped!" .. "\r\n\t" .. "The value defined in the script configuration is not supported",
  Action = {
    Question = "What action do you want to perform?",
    Description = "Please select what you want to do:",
    Create = "Create",
    Populate = "Populate"
  },
  Groups = {
    ReuseGroup = "Do you want to keep your previous groups definition?",
    Options = "Groups Options:",
    List = "Group list:",
    Question = "How many fixture groups will be used?",
    Description = "Please indicate the quantity of groups where to populate presets:"
  },
  GroupID = {
    Question = "What is the Group n°".. Rep .." ID?",
    Description = "Please indicate the Group n°".. Rep .." ID:"
  },
  Resolution = {
    Question = "[" .. Rep .. "] What is the " .. Rep .. " resolution for the group ".. RepID .."?",
    Description = "[" .. Rep .. "] Please select the " .. Rep .. " resolution for the group ".. RepID ..":",
    Standard = "8 bits (standard)",
    Fine = "16 bits (fine)"
  },
  PresetPosition = {
    Question = "Where do you want to start recording " .. Rep .. " presets?",
    Description = "This option permit to define where to start recording " .. Rep .. " presets"
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

function SetSettingsType()
  if Settings.Type == PresetName.Color then
    -- Define the color preset type following preferences
    if Settings.Color == Content.Color.Extended then
      Settings.PresetTyping = 'ColorFull'
    else
      Settings.PresetTyping = 'Color'
    end
  else
    -- Define the preset type
    Settings.PresetTyping = Settings.Type
  end
end

function ApplyPresetContent(Group, Preset)
  if Preset.Value ~= nil then
    -- If the preset type is color, record additional value for color macro
    if Settings.Type == PresetName.Color then
      Onyx.SetAttributeVal('Color Macro', 0, true)
    end
    if type(Preset.Value) == 'table' then
      for Key, Value in pairs(Preset.Value) do
        -- Set value on 16 bits if needed of course!
        if Group.Resolution[Settings.Type] == Content.Resolution.Fine then
          Value = Value * 257
        end
        -- Set the attribute and its value
        Onyx.SetAttributeVal(Key, Value, true)
      end
    else
      Onyx.SetAttributeVal(Settings.Type, Preset.Value, true)
    end
    -- Record into Preset
    RecordPreset(Settings.Type, Preset, true)
    Sleep(Settings.WaitTime)
  end
end

--------------------------
-- Collect Informations --
--------------------------

--# REQUEST the Preset Grid Width # --
--------------------------------

InputSettings = {
  Question = Content.Grid.Question,
  Description = Content.Grid.Description,
  CurrentValue = CheckEmpty(GetVar("Settings.PresetGridWidth"), 8),
  MinValue = 4,
  Buttons = Form.OkCancel,
  DefaultButton = Word.Ok
}

Settings.PresetGridWidth = InputNumber(InputSettings)

if Cancelled(Settings.PresetGridWidth) then
    goto EXIT
else
  SetVar("Settings.PresetGridWidth", Settings.PresetGridWidth)
  LogActivity("\r\n\t" .. "Preset Grid Width: " .. Settings.PresetGridWidth)
end

-- START POINT, to loop actions
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
  DropDown = AutoPresetTypes,
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

--# REQUEST the Preset Start Position # --
--------------------------------
InputSettings = false
InputSettings = {
  Question = replace(Content.PresetPosition.Question, Rep, Settings.Type),
  Description = replace(Content.PresetPosition.Description, Rep, Settings.Type),
  Buttons = Form.OkCancel,
  DefaultButton = Word.Ok,
  CurrentValue = CheckEmpty(GetVar("Settings.PresetStartPosition" .. Settings.Type), Settings.PresetStartPosition[Settings.Type]),
  Cancel = true
}
Settings.PresetStartPosition[Settings.Type] = InputNumber(InputSettings)

-- If not PresetType defined, exit
if Cancelled(Settings.PresetStartPosition[Settings.Type]) then
  goto EXIT
else
  SetVar("Settings.PresetStartPosition" .. Settings.Type, Settings.PresetStartPosition[Settings.Type])
  LogActivity("\r\n\t" .. Settings.Type .. " Preset Start Position: " .. Settings.PresetStartPosition[Settings.Type])
end

-- If Color preference is not already set, and PresetType is Color, request the color preferences to be applied
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

--# REQUEST the Fixtures Group # --
-----------------------------------
::GROUPS::
-- Request Fixtures Group setting when Populate preset Only
if Settings.Action == Content.Action.Populate then
  if Settings.Groups == nil then
    -- Request EU number of groups to be threated
    InputSettings = false
    InputSettings = {
      Question = Content.Groups.Question,
      Description = Content.Groups.Description,
      Buttons = Form.OkCancel,
      DefaultButton = Word.Ok,
      Cancel = true
    }

    Settings.NbOfGroups = InputNumber(InputSettings)

    if Cancelled(Settings.NbOfGroups) then
      goto EXIT
    end

    -- Indicate the number of Groups to be threated
    Settings.Groups = {}

    -- Request EU details for each group
    for i = 1, Settings.NbOfGroups, 1 do
      -- Request the Group ID
      InputSettings.Question = replace(Content.GroupID.Question, Rep, i)
      InputSettings.Description = replace(Content.GroupID.Description, Rep, i)

      local Group = {}
      Group.Resolution = {}
      Group.ID = InputNumber(InputSettings)

      if Cancelled(Group.ID) then
          goto EXIT
      end

      -- Get the Group Name
      Group.Name = CheckEmpty(Onyx.GetGroupName(Group.ID))

      -- Request EU details for each PRESET TYPE resolution
      InputSettings = false
      InputSettings = {
        Buttons = Form.OkCancel,
        DefaultButton = Word.Ok,
        DropDown = {Content.Resolution.Standard, Content.Resolution.Fine},
        DropDownDefault = Content.Resolution.Standard,
        Cancel = true
      }
      for idPreset, LocalPreset in pairs(AutoPresetTypes) do
        ReplaceRepID = "n°" .. i .. " " .. Group.Name .. "[" .. Group.ID .. "]"
        InputSettings.Question = replace(replace(Content.Resolution.Question, Rep, LocalPreset), RepID, ReplaceRepID)
        InputSettings.Description = replace(replace(Content.Resolution.Description, Rep, LocalPreset), RepID, ReplaceRepID)

        Group.Resolution[LocalPreset] = InputDropDown(InputSettings)

          -- If not PresetType defined, exit
        if Cancelled(Group.Resolution[LocalPreset]) then
          goto EXIT
        end
      end
      -- Inset into the global Groups table
      table.insert(Settings.Groups, Group)
    end
    -- RESUME of GROUPS
    LogActivity("\r\n" .. Content.Groups.Options)
    LogActivity("\r\n\t" .. "- " .. Settings.NbOfGroups .. " group(s)")

    -- DETAIL of GROUPS
    LogActivity("\r\n" .. Content.Groups.List)
    for i, Group in pairs(Settings.Groups) do
        LogActivity("\r\n\t" .. "- n°" .. Group.ID .. " - " .. Group.Name)
        for Key, Value in pairs(Group.Resolution) do
          LogActivity("\r\n\t\t" .. "- " .. Key .. ": " .. Value)
        end
    end
  else
    InputSettings = false
    InputSettings = {
      Question = Content.Groups.ReuseGroup,
      Description = Content.Groups.ReuseGroup,
      Buttons = Form.YesNo,
      DefaultButton = Word.Yes
    }

    if InputYesNo(InputValidationSettings) then
    else
      Settings.Groups = nil
      goto GROUPS
    end
  end
end

----------------------------
-- Execution for Creation --
----------------------------

-- CREATE ACTION
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
  -- RESET Log Messages
  Messages = {}

  if Settings.Validation then
    PresetsConfiguration = GetPresetsConfiguration()
    SetSettingsType()
    -- Create Preset
    for i, InnerPreset in pairs(PresetsConfiguration[Settings.PresetTyping]) do
      RecordPreset(Settings.Type, InnerPreset, true)
      Sleep(Settings.WaitTime)
    end
    -- Don't exit, purpose to continue for a next action!
    Onyx.ClearProgrammer()
    goto START
  end
-- POPULATE ACTION
elseif Settings.Action == Content.Action.Populate then
  --# USER Validation # --
  ------------------------
  InputValidationSettings = {
    Question = replace(Content.PopulateValidation.Question, Rep, Settings.Type),
    Description = Content.PopulateValidation.Description .. "\n\r\n\r" .. GetActivity(),
    Buttons = Form.YesNo,
    DefaultButton = Word.Yes
  }

  Settings.Validation = InputYesNo(InputValidationSettings)
  -- RESET Log Messages
  Messages = {}

  if Settings.Validation then
    SetSettingsType()
    for i, Group in pairs(Settings.Groups) do
      Onyx.ClearProgrammer()
      -- Create Preset
      Onyx.SelectGroup(Group.ID)
      Sleep(Settings.WaitTime)
      for i, InnerPreset in pairs(PresetsConfiguration[Settings.PresetTyping]) do
        ApplyPresetContent(Group, InnerPreset)
        Sleep(Settings.WaitTime)
      end
    end
    -- Don't exit, purpose to continue for a next action!
    Onyx.ClearProgrammer()
    goto START
  end
end

::EXIT::
