-- ShowCockpit LUA Script: PanPresetOffset
--   created on ShowCockpit v3.5.0
--   by Spb8 Lighting
--   on 11-07-2019

-------------
-- Purpose --
-------------
-- This script allows to apply Pan offset on existing preset from a group of fixture

---------------
-- Changelog --
---------------
-- 11-07-2019 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
  WaitTime = 0.5
}

ScriptInfos = {
  version = "1.0",
  name = "PanPresetOffset"
}

--##LUAHEADERINCLUDE##--

----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

--------------------------
-- Sentence and Wording --
--------------------------

Content = {
	Done = "Pan Offset Done!",
	Offset = {
		Options = "Offset Options:",
		From = {
			Question = "Compute Offset - Actual Pan Value",
			Description = "Indicate the actual Pan Value (Digital Display)"
		},
		To = {
			Question = "Compute Offset - Target Pan Value",
			Description = "Indicate the target Pan Value (Digital Display)"
		}
	},
	Groups = {
		Options = "Groups Options:",
		List = "Group list:",
		Question = "Group fixture n°",
		Description = "Please indicate the group fixture ID where to apply Pan Offset:"
	},
	Preset = {
		List = "Preset List:",
		Options = "Preset Options:",
		OptionString = "Pan Offset settings:",
		From = {
			Question = "From Preset n°",
			Description = "Indicate the first Preset ID number to offset"
		},
		To = {
			Question = "To Preset n°",
			Description = "Indicate the last Preset ID number to offset"
		}
	},
	Validation = {
		Question = "Do you agree to offset the Pan preset(s)?",
		Description = "WARNING, it can't be UNDO! Use it with caution!"
	}
}
--------------------------
-- Collect Informations --
--------------------------

-- Request the Group ID n°
InputSettings = {
	Question = Content.Groups.Question,
	Description = Content.Groups.Description,
	Buttons = Form.OkCancel,
	DefaultButton = Word.Ok,
	Cancel = true
}

Settings.GroupID = InputNumber(InputSettings)

if Cancelled(Settings.GroupID) then
	goto EXIT
end

Settings.GroupName = CheckEmpty(Onyx.GetGroupName(Settings.GroupID))

-- Request the Start Offset
InputSettings = {
	Question = Content.Offset.From.Question,
	Description = Content.Offset.From.Description,
	Buttons = Form.OkCancel,
	DefaultButton = Word.Ok,
	MinValue = 0,
	MaxValue = 65535,
	Cancel = true
}

Settings.OffsetStart = InputNumber(InputSettings)

if Cancelled(Settings.OffsetStart) then
	goto EXIT
end
-- Request the End Offset
InputSettings.Question = Content.Offset.To.Question
InputSettings.Description = Content.Offset.To.Description
InputSettings.CurrentValue = Settings.Offset

Settings.OffsetEnd = InputNumber(InputSettings)

if Cancelled(Settings.OffsetEnd) then
	goto EXIT
end

-- Compute the DMX Offset Value
Settings.Offset = Settings.OffsetEnd - Settings.OffsetStart

-- Request the Start Preset ID n°
InputSettings = false
InputSettings = {
	Question = Content.Preset.From.Question,
	Description = Content.Preset.From.Description,
	Buttons = Form.OkCancel,
	DefaultButton = Word.Ok,
	Cancel = true
}

Settings.PresetIDStart = InputNumber(InputSettings)

if Cancelled(Settings.PresetIDStart) then
	goto EXIT
end
-- Request the Last Preset ID n°
InputSettings.Question = Content.Preset.To.Question
InputSettings.Description = Content.Preset.To.Description
InputSettings.CurrentValue = Settings.PresetIDStart + 1

Settings.PresetIDEnd = InputNumber(InputSettings)

if Cancelled(Settings.PresetIDEnd) then
	goto EXIT
end

-- Compute the number of Presets
Settings.NumberOfPreset = Settings.PresetIDEnd - Settings.PresetIDStart + 1

--# LOG all user choice # --
----------------------------

-- RESUME of GROUPS
LogActivity(Content.Groups.List)
LogActivity("\r\n\t" .. "- n°" .. Settings.GroupID .. " -  " .. Settings.GroupName)

-- RESUME of OFFSET
LogActivity(Content.Offset.Options)
LogActivity("\r\n\t" .. "- Actual Pan value: " .. Settings.OffsetStart)
LogActivity("\r\n\t" .. "- Target Pan value: " .. Settings.OffsetEnd)
LogActivity("\r\n\t" .. "- Computed Pan offset: " .. Settings.Offset)

-- RESUME of PRESETS
LogActivity("\r\n" .. Content.Preset.Options)
LogActivity("\r\n\t" .. "- " .. PresetName.PanTilt .. " Presets, from n°" .. Settings.PresetIDStart .. " to n°" .. Settings.PresetIDEnd)

-- DETAIL of PRESETS
LogActivity("\r\n" .. Content.Preset.List)

Settings.Presets = ListPreset(PresetName.PanTilt, Settings.PresetIDStart, Settings.PresetIDEnd)

for i, Preset in pairs(Settings.Presets) do
    LogActivity("\r\n\t" .. "- n°" .. Preset.id .. " " .. Preset.name)
end

--# USER Validation # --
------------------------

InputValidationSettings = {
    Question = Content.Validation.Question,
    Description = "Do you agree to apply " .. Settings.Offset .. " Pan offset?" .. "\n\r\n\r" .. GetActivity(),
    Buttons = Form.YesNo,
    DefaultButton = Word.Yes
}

Settings.Validation = InputYesNo(InputValidationSettings)

--------------------------
--      Execution       --
--------------------------

if Settings.Validation then
	Onyx.ClearProgrammer()
	-- Iterate through the Preset list
	for PresetID = Settings.PresetIDStart, Settings.PresetIDEnd do
			Onyx.SelectPanTiltPreset(PresetID)
			Onyx.SelectGroup(Settings.GroupID)
				Sleep(Settings.WaitTime)
			Onyx.SetAttributeVal('Pan', Settings.Offset, false)
				Sleep(Settings.WaitTime)
			Onyx.RecordPanTiltPreset(PresetID, '', true)
				Sleep(Settings.WaitTime)
			Onyx.ClearProgrammer()
				Sleep(Settings.WaitTime)
	end
	-- Display a end pop-up
	FootPrint(Content.Done)
else
	Cancelled()
end
::EXIT::
