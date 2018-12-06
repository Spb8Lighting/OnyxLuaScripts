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
-- 06-12-2018 - 0.0.0.0.0.1: Initialisation, not working yet
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
	version = "0.0.0.0.0.1",
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
RepID = "%GROUPID%"

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
    Standard = "8bits (standard)",
    Fine = "16Bits (fine)"
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

-- If Color preference is not already set, and PresetType is Color, request the color preferences to be applied
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

--# REQUEST the Fixtures Group # --
-----------------------------------

if Settings.Groups == nil then
  ::GROUPS::
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

  -- Preset Resolution to get
  PresetsResolution = {PresetName.Intensity, PresetName.Color}

  -- Request EU details for each group
  for i = 1, Settings.NbOfGroups, 1 do
    -- Request the Group ID
    InputSettings.Question = replace(Content.GroupID.Question, Rep, i),
    InputSettings.Description = replace(Content.GroupID.Description, Rep, i)

    local Group = {}
    Group.Resolution = {}
    Group.ID = InputNumber(InputSettings)

    if Cancelled(GroupID) then
        goto EXIT
    end

    -- Get the Group Name
    Group.Name = Onyx.GetGroupName(Group.ID)

    -- Request EU details for each PRESET TYPE resolution
    InputSettings = false
    InputSettings = {
      Buttons = Form.OkCancel,
      DefaultButton = Word.Ok,
      DropDown = {Content.Resolution.Standard, Content.Resolution.Fine},
      DropDownDefault = Content.Resolution.Standard,
      Cancel = true
    }
    for idPreset, LocalPreset in pairs(PresetsResolution) do
      ReplaceRepID = "n°" .. i .. " ID: " .. Group.ID .. " Name: " .. Group.Name
      InputSettings.Question = replace(replace(Content.Resolution.Question, Rep, LocalPreset), RepID, ReplaceRepID),
      InputSettings.Description = replace(replace(Content.Resolution.Description, Rep, LocalPreset), ReplaceRepID)

      Group.Resolution[LocalPreset] = InputDropDown(InputSettings)

        -- If not PresetType defined, exit
      if Cancelled(Group[LocalPreset]) then
        goto EXIT
      end
    end
    -- Inset into the global Groups table
    table.insert(Settings.Groups, Group)

    -- RESUME of GROUPS
    LogActivity(Content.Groups.Options)
    LogActivity("\r\n\t" .. "- " .. Settings.NbOfGroups .. " group(s)")

    -- DETAIL of GROUPS
    LogActivity("\r\n" .. Content.Groups.List)
    for i, Group in pairs(Settings.Groups) do
        LogActivity("\r\n\t" .. "- n°" .. Group.id .. " - " .. Group.name)
        for Key, Value in pairs(Group.Resolution) do
          LogActivity("\r\n\t\t" .. "- " .. Key .. ": " .. Value)
        end
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
    goto GROUPS
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

  if Settings.Validation then
    if Settings.Type == PresetName.Color then
    end

    -- Don't exit, purpose to continue for a next action!
    goto START
  end
-- POPULATE ACTION
elseif Settings.Action == Content.Action.Populate then

  -- Don't exit, purpose to continue for a next action!
  goto START
end

::EXIT::
