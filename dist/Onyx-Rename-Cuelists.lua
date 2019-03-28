-- ShowCockpit LUA Script: RenameCuelists
--   created on ShowCockpit v2.13.0
--   by Spb8 Lighting
--   on 08-11-2018

-------------
-- Purpose --
-------------
-- This script allows to rename list of cuelist

---------------
-- Changelog --
---------------
-- 28-03-2019 - 1.1: Increase WaitTime to avoid missing cue renaming
-- 08-11-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
  WaitTime = 0.5
}

ScriptInfos = {
  version = "1.1",
  name = "RenameCuelist"
}

-- ShowCockpit LUA Script: LuaHeader for Spb8 Lighting LUA Script

---------------
-- Changelog --
---------------
-- 04-01-2019 - 1.6: RecordPreset() function has been added
-- 29-12-2018 - 1.5: DeleteGroup() function & ListGroup() has been added
-- 16-11-2018 - 1.4: InputNumber() function now accept MinValue as Infos to SetMinValue (default stays 1)
-- 08-11-2018 - 1.3: New InputText() function
--							+	New replace() function
-- 07-09-2018 - 1.2: Fix input number max issue
--              + add Word.Script.Cancel text value
--              + add Form.Preset list values
--              + update Default Preset Appearance to match Onyx Colors
--              + reword some function parameter name
--              + add ListCuelit()
--              + add the possibility to define default value for InputNumber and InputFloatNumber
-- 06-09-2018 - 1.1: Add Preset Name Framing, Add Generic GetPresetName, Add Generic DeletePreset
-- 05-09-2018 - 1.0: Creation

--------------------
--    Variables   --
--------------------

if Settings.WaitTime == nil or Settings.WaitTime == "" then
	Settings.WaitTime = 0.5
end

PresetName = {
  Intensity = "Intensity",
	PanTilt = "PanTilt",
	Color = "Color",
	Gobo = "Gobo",
	Beam = "Beam",
	BeamFX = "BeamFX",
	Framing = "Framing"
}

ScriptInfos = {
	version = ScriptInfos.version,
	name = ScriptInfos.name,
	author = "Sylvain Guiblain",
	contact = "sylvain.guiblain@gmail.com",
	website = "https://github.com/Spb8Lighting/OnyxLuaScripts"
}

Infos = {
	Sentence = "Scripted by " .. ScriptInfos.author .. "\r\n\r\n" .. ScriptInfos.contact .. "\r\n\r\n" .. ScriptInfos.website,
	Script = ScriptInfos.name .. " v" .. ScriptInfos.version
}

Appearance = {
	White = "#-1551",
	Red = "#-2686966",
	Orange = "#-33280",
	Yellow = "#-2560",
	Lime = "#-3342592",
	Green = "#-16711936",
	Cyan = "#-167714241",
	LightBlue = "#-16746497",
	Blue = "#-16769537",
	Uv = "#-13959025",
	Pink = "#-52996",
	Magenta = "#-65333"
}

DefaultAppearance = {
	Intensity = Appearance.White,
	PanTilt = Appearance.Red,
	Color = Appearance.White,
  Gobo = Appearance.Green,
	Beam = Appearance.Yellow,
	BeamFX = Appearance.Cyan,
	Framing = Appearance.Magenta
}

BPMTiming = {
	Half = "1/2",
	Third = "1/3",
	Quarter = "1/4"
}

Word = {
	Script = {
			Cancel = "Script has been cancelled! Nothing performed."
	},
	Ok = "Ok",
	Cancel = "Cancel",
	Reset = "Reset",
	Yes = "Yes",
	No = "No",
	Vertical = "Vertical",
	Horizontal = "Horizontal"
}

Form = {
	Ok = {
		Word.Ok
	},
	OkCancel = {
		Word.Ok,
		Word.Cancel
	},
	YesNo = {
		Word.Yes,
		Word.No
    },
	Preset = {
		PresetName.Intensity,
		PresetName.PanTilt,
		PresetName.Color,
		PresetName.Gobo,
		PresetName.Beam,
		PresetName.BeamFX,
		PresetName.Framing
	}
}

-- Get Onyx Software object

Onyx = GetElement("Onyx")

--------------------
--General Function--
--------------------

function HeadPrint()
	LogInformation(Infos.Script .. "\r\n\t" .. Infos.Sentence) --Notification
end

function FootPrint(Sentence)
	LogInformation(Sentence .. "\r\n\t" .. Infos.Sentence)
	Infos = {
		Question = Infos.Script,
		Description = Sentence .. "\r\n\r\n" .. Infos.Sentence,
		Buttons = Form.Ok,
		DefaultButton = Word.Ok
	}
	InputYesNo(Infos)
end

function Cancelled(variable)
	if variable == nil or variable == "" then
		FootPrint(Word.Script.Cancel)
		return true
	else
		return false
	end
end

function CheckInput(Infos, Answer)
	if Answer["button"] == Word.Yes then
		Answer["input"] = true
	end
	if Infos.Cancel == true then
		if Answer["button"] == Word.Yes then
			Answer["input"] = true
		elseif Answer["button"] == Word.Cancel or Answer["button"] == Word.No then
			Answer["input"] = nil
		end
	end
	return Answer
end

function Input(Infos, Type)
	-- Create the Prompt
	Prompt = CreatePrompt(Infos.Question, Infos.Description)

	-- Prompt settings
	if Type then
		Prompt.SetType(Type)
	end
	Prompt.SetButtons(Infos.Buttons)
	Prompt.SetDefaultButton(Infos.DefaultButton)

	-- Return the prompt
	return Prompt
end

function InputDropDown(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos, "DropDown")
	-- Prompt settings
	Prompt.SetDropDownOptions(Infos.DropDown)
	Prompt.SetDefaultValue(Infos.DropDownDefault)

	return ShowInput(Prompt, Infos)
end

function InputYesNo(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos)
	return ShowInput(Prompt, Infos)
end

function InputNumber(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos, "IntegerInput")
	-- Prompt settings
	if Infos.MinValue then
		Prompt.SetMinValue(Infos.MinValue)
	else
		Prompt.SetMinValue(1)
	end
	Prompt.SetMaxValue(10000)
	if Infos.CurrentValue then
		Prompt.SetDefaultValue(Infos.CurrentValue)
	end

	return ShowInput(Prompt, Infos)
end

function InputFloatNumber(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos, "FloatInput")
	-- Prompt settings
	Prompt.SetMinValue(0)
	if Infos.CurrentValue then
		Prompt.SetDefaultValue(Infos.CurrentValue)
	end

	return ShowInput(Prompt, Infos)
end

function InputText(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos, "TextInput")
	-- Prompt settings
	if Infos.CurrentValue then
		Prompt.SetDefaultValue(Infos.CurrentValue)
	end

	return ShowInput(Prompt, Infos)
end

function ShowInput(Prompt, Infos)
	-- Display the prompt
	Answer = Prompt.Show()

	return CheckInput(Infos, Answer)["input"]
end

--------------------
--     Logging    --
--------------------

Messages = {}

function LogActivity(text)
	table.insert(Messages, text)
end

function GetActivity()
	local Feedback = ""
	for i, Message in pairs(Messages) do
		Feedback = Feedback .. "\n" .. Message
	end
	return Feedback
end

--------------------
--   Functions    --
--------------------

function replace(str, what, with)
    what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
    with = string.gsub(with, "[%%]", "%%%%")
    return string.gsub(str, what, with)
end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function CopyCue(CuelistIDSource, CueID, CuelistIDTarget)
	Sleep(Settings.WaitTime)
	Onyx.SelectCuelist(CuelistIDSource)
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Copy")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Cue")
	Sleep(Settings.WaitTime)
	KeyNumber(CueID)
	Onyx.Key_ButtonClick("At")
	Sleep(Settings.WaitTime)
	Onyx.SelectCuelist(CuelistIDTarget)
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Enter")
	Sleep(Settings.WaitTime)
end

function KeyNumber(Number)
	if string.find(Number, "%d", 1, false) then
		a = string.match(Number, "(.+)")
		for c in a:gmatch "." do
			Onyx.Key_ButtonClick("Num" .. c)
		end
		Sleep(Settings.WaitTime)
	end
end

function DeleteGroup(GroupID)
	Onyx.Key_ButtonClick("Delete")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Group")
	Sleep(Settings.WaitTime)
	KeyNumber(GroupID)
	Onyx.Key_ButtonClick("Enter")
	return true
end

function RecordCuelist(CuelistID)
	Onyx.Key_ButtonClick("Record")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Slash")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Slash")
	KeyNumber(CuelistID)
	Onyx.Key_ButtonClick("Enter")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Enter")
	return true
end

function CheckEmpty(Chain, default)
	if Chain == nil or Chain == "" then
		if default then
			return default
		else
			return "---"
		end
	else
		return Chain
	end
end

function GetPresetName(PresetType, PresetID)
	if PresetType == PresetName.PanTilt then
		return CheckEmpty(Onyx.GetPanTiltPresetName(PresetID))
	elseif PresetType == PresetName.Color then
		return CheckEmpty(Onyx.GetColorPresetName(PresetID))
	elseif PresetType == PresetName.Intensity then
		return CheckEmpty(Onyx.GetIntensityPresetName(PresetID))
	elseif PresetType == PresetName.Gobo then
		return CheckEmpty(Onyx.GetGoboPresetName(PresetID))
	elseif PresetType == PresetName.Beam then
		return CheckEmpty(Onyx.GetBeamPresetName(PresetID))
	elseif PresetType == PresetName.BeamFX then
		return CheckEmpty(Onyx.GetBeamFXPresetName(PresetID))
	elseif PresetType == PresetName.Framing then
		return CheckEmpty(Onyx.GetFramingPresetName(PresetID))
	else
		return false
	end
end

function GetPresetAppearance(PresetType, PresetID)
	if PresetType == PresetName.PanTilt then
		return CheckEmpty(Onyx.GetPanTiltPresetAppearance(PresetID), DefaultAppearance.PanTilt)
	elseif PresetType == PresetName.Color then
		return CheckEmpty(Onyx.GetColorPresetAppearance(PresetID), DefaultAppearance.Color)
	elseif PresetType == PresetName.Intensity then
		return CheckEmpty(Onyx.GetIntensityPresetAppearance(PresetID), DefaultAppearance.Intensity)
	elseif PresetType == PresetName.Gobo then
		return CheckEmpty(Onyx.GetGoboPresetAppearance(PresetID), DefaultAppearance.Gobo)
	elseif PresetType == PresetName.Beam then
		return CheckEmpty(Onyx.GetBeamPresetAppearance(PresetID), DefaultAppearance.Beam)
	elseif PresetType == PresetName.BeamFX then
		return CheckEmpty(Onyx.GetBeamFXPresetAppearance(PresetID), DefaultAppearance.BeamFX)
	elseif PresetType == PresetName.Framing then
		return CheckEmpty(Onyx.GetFramingPresetAppearance(PresetID), DefaultAppearance.Framing)
	else
		return false
	end
end

function DeletePreset(PresetType, PresetID)
	if PresetType == PresetName.PanTilt then
		Onyx.DeletePanTiltPreset(PresetID)
	elseif PresetType == PresetName.Color then
		Onyx.DeleteColorPreset(PresetID)
	elseif PresetType == PresetName.Intensity then
		Onyx.DeleteIntensityPreset(PresetID)
	elseif PresetType == PresetName.Gobo then
		Onyx.DeleteGoboPreset(PresetID)
	elseif PresetType == PresetName.Beam then
		Onyx.DeleteBeamPreset(PresetID)
	elseif PresetType == PresetName.BeamFX then
		Onyx.DeleteBeamFXPreset(PresetID)
	elseif PresetType == PresetName.Framing then
		Onyx.DeleteFramingPreset(PresetID)
	end
	return true
end

function RecordPreset(PresetType, Preset, Merging)
	if PresetType == PresetName.PanTilt then
		Onyx.RecordPanTiltPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Color then
		Onyx.RecordColorPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Intensity then
		Onyx.RecordIntensityPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Gobo then
		Onyx.RecordGoboPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Beam then
		Onyx.RecordBeamPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.BeamFX then
		Onyx.RecordBeamFXPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Framing then
		Onyx.RecordFramingPreset(Preset.Position, Preset.Name, Merging)
	end
	return true
end

function ListPreset(PresetType, PresetIDStart, PresetIDEnd)
	Presets = {}
	for i = PresetIDStart, PresetIDEnd, 1 do
		table.insert(
			Presets,
			{
				id = i,
				name = GetPresetName(PresetType, i),
				appearance = GetPresetAppearance(PresetType, i)
			}
		)
	end
	return Presets
end

function ListCuelist(CuelistIDStart, CuelistIDEnd)
	Cuelists = {}
	for i = CuelistIDStart, CuelistIDEnd, 1 do
		table.insert(
			Cuelists,
			{
				id = i,
				name = CheckEmpty(Onyx.GetCuelistName(i))
			}
		)
	end
	return Cuelists
end

function ListGroup(GroupIDStart, GroupIDEnd)
	Groups = {}
	for i = GroupIDStart, GroupIDEnd, 1 do
		table.insert(
			Groups,
			{
				id = i,
				name = CheckEmpty(Onyx.GetGroupName(i))
			}
		)
	end
	return Groups
end
HeadPrint()
-- End of Header --



----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

--------------------------
-- Sentence and Wording --
--------------------------

Content = {
	Done = "Rename Finished!",
	CuelistList = "Cuelists List:",
	Cuelist = {
		Option = "Cuelist Options:",
		OptionString = "Rename settings:",
		From = {
			Question = "From Cuelist n°",
			Description = "Indicate the first Cuelist ID number to rename"
		},
		To = {
			Question = "To Cuelist n°",
			Description = "Indicate the last Cuelist ID number to rename"
		},
		String = {
			PRE = {
				Question = "[PRE] Actual value to be change:",
				Description = "Indicate the string to be change"
			},
			POST = {
				Question = "[POST] New value to replace actual one:",
				Description = "Indicate the new string value"
			}
		}
	},
	Validation = {
		Question = "Do you agree to rename the cuelist(s)?",
		Description = "WARNING, it can't be UNDO! Use it with caution!"
	}
}

--------------------------
-- Collect Informations --
--------------------------

--# REQUEST the Cuelist Range # --
----------------------------------

-- Request the Start Cuelist ID n°
InputSettings = {
	Question = Content.Cuelist.From.Question,
	Description = Content.Cuelist.From.Description,
	Buttons = Form.OkCancel,
	DefaultButton = Word.Ok,
	Cancel = true
}

Settings.CuelistIDStart = InputNumber(InputSettings)

if Cancelled(Settings.CuelistIDStart) then
	goto EXIT
end

-- Request the Last Cuelist ID n°
InputSettings.Question = Content.Cuelist.To.Question
InputSettings.Description = Content.Cuelist.To.Description
InputSettings.CurrentValue = Settings.CuelistIDStart + 1

Settings.CuelistIDEnd = InputNumber(InputSettings)

if Cancelled(Settings.CuelistIDEnd) then
	goto EXIT
end

--# REQUEST the Cuelist Replacement Action # --
-----------------------------------------

-- Request the PRE value to be replaced
InputSettings.Question = Content.Cuelist.String.PRE.Question
InputSettings.Description = Content.Cuelist.String.PRE.Description
InputSettings.CurrentValue = Onyx.GetCuelistName(Settings.CuelistIDStart)
Settings.PRE = InputText(InputSettings)

if Cancelled(Settings.PRE) then
	goto EXIT
end

-- Request the PRE value to be replaced
InputSettings.Question = Content.Cuelist.String.POST.Question
InputSettings.Description = Content.Cuelist.String.POST.Description
InputSettings.CurrentValue = Settings.PRE

Settings.POST = InputText(InputSettings)

if Cancelled(Settings.POST) then
	goto EXIT
end

--# LOG all user choice # --
----------------------------

-- RESUME of action to be performed

-- RESUME for Cuelist
LogActivity(Content.Cuelist.Option)
LogActivity("\r\n\t" .. "- Rename Cuelists from n°" .. Settings.CuelistIDStart .." to n°" .. Settings.CuelistIDEnd )

-- RESUME for Cue
LogActivity("\r\n\r\n" .. Content.Cuelist.OptionString)
LogActivity("\r\n\t" .. "- Replace <" .. Settings.PRE .. "> by <" .. Settings.POST .. ">")

-- DETAIL of impacted Cuelists
LogActivity("\r\n" .. Content.CuelistList)

Cuelists = ListCuelist(Settings.CuelistIDStart, Settings.CuelistIDEnd)

for i, Cuelist in pairs(Cuelists) do
    LogActivity("\r\n\t" .. '- n°' .. Cuelist.id .. ' ' .. Cuelist.name)
end

--# USER Validation # --
------------------------

InputValidationSettings = {
	Question = Content.Validation.Question,
	Description = Content.Validation.Description .. "\n\r\n\r" .. GetActivity(),
	Buttons = Form.YesNo,
	DefaultButton = Word.Yes
}

Settings.Validation = InputYesNo(InputValidationSettings)

--------------------------
--      Execution       --
--------------------------

if Settings.Validation then
	-- Iterate through the Cuelist list
for CuelistID = Settings.CuelistIDStart, Settings.CuelistIDEnd do
	Onyx.SelectCuelist(CuelistID)
		Sleep(Settings.WaitTime)
	-- Get Cuelist Name and prepare new string for change
	Settings.ActualCuelistName = Onyx.GetCuelistName(CuelistID)
		Sleep(Settings.WaitTime)
	Settings.NewCuelistName = replace(Settings.ActualCuelistName, Settings.PRE, Settings.POST)
		Sleep(Settings.WaitTime)
	Onyx.RenameCuelist(Settings.NewCuelistName)
		Sleep(Settings.WaitTime)
	end
	-- Display a end pop-up
FootPrint(Content.Done)
else
Cancelled()
end
::EXIT::
