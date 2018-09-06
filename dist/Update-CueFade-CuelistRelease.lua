-- ShowCockpit LUA Script: DeleteRangeOfCuelist
--   created on ShowCockpit v2.4.2
--   by Spb8 Lighting
--   on 05-09-2018

-------------
-- Purpose --
-------------
-- This script allows to update the cues fade times in the meantime of the cuelist release time

---------------
-- Changelog --
---------------
-- 07-09-2018 - 1.1: Fix issue with time value of 0 which was cancelling the script
-- 05-09-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
	WaitTime = 0.05
}

ScriptInfos = {
	version = "1.1",
	name = "UpdateCueFadeCuelistRelease"
}

-- ShowCockpit LUA Script: LuaHeader for Spb8 Lighting LUA Script

---------------
-- Changelog --
---------------
-- 07-09-2018 - 1.2: Fix input number max issue, reword some function parameter name, add ListCuelit(), add the possibility to define default value for InputNumber and InputFloatNumber
-- 06-09-2018 - 1.1: Add Preset Name Framing, Add Generic GetPresetName, Add Generic DeletePreset
-- 05-09-2018 - 1.0: Creation

--------------------
--    Variables   --
--------------------
if Settings.WaitTime == nil or Settings.WaitTime == "" then
	Settings.WaitTime = 0.5
end
PresetName = {
	PanTilt = "PanTilt",
	Color = "Color",
	Intensity = "Intensity",
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
BPMTiming = {
	Half = "1/2",
	Third = "1/3",
	Quarter = "1/4"
}
Word = {
	Ok = "Ok",
	Cancel = "Cancel",
	Reset = "Reset",
	Yes = "Yes",
	No = "No"
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
		FootPrint("Script has been cancelled! Nothing performed.")
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
	Prompt.SetMinValue(1)
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

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function CopyCue(CuelistIDSource, CueID, CuelistIDTarget)
	Sleep(Settings.WaitTime)
	Onyx.SelectCuelist(CuelistIDSource)
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Copy")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Cue")
	Sleep(Settings.WaitTime)
	KeyNumber(CueID)
	Onyx.Key_ButtonPress("At")
	Sleep(Settings.WaitTime)
	Onyx.SelectCuelist(CuelistIDTarget)
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Enter")
	Sleep(Settings.WaitTime)
end

function KeyNumber(Number)
	if string.find(Number, "%d", 1, false) then
		a = string.match(Number, "(.+)")
		for c in a:gmatch "." do
			Onyx.Key_ButtonPress("Num" .. c)
		end
		Sleep(Settings.WaitTime)
	end
end

function RecordCuelist(CuelistID)
	Onyx.Key_ButtonPress("Record")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Slash")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Slash")
	KeyNumber(CuelistID)
	Onyx.Key_ButtonPress("Enter")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Enter")
	return true
end

function CheckEmpty(Chain)
	if Chain == nil or Chain == "" then
		return "---"
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

function ListPreset(PresetType, PresetIDStart, PresetIDEnd)
	Presets = {}
	for i = PresetIDStart, PresetIDEnd, 1 do
		table.insert(
			Presets,
			{
				id = i,
				name = GetPresetName(PresetType, i)
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

HeadPrint()
-- End of Header --



----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

Content = {
	StopMessage = "Stopped!" .. "\r\n\t" .. "The Preset type defined in the script configuration is not supported",
	Done = "Update Finished!",
	CuelistList = "Cuelists List:",
	Cuelist = {
		Option = "Cuelist Options:",
		From = {
			Question = "From Cuelist n°",
			Description = "Indicate the first Cuelist ID number where to update the release time (and its cue(s) fade time)"
		},
		To = {
			Question = "To Cuelist n°",
			Description = "Indicate the first Cuelist ID number where to update the release time (and its cue(s) fade time)"
		},
		Time = {
			Question = "Cuelist Release Time:",
			Description = "Indicate the awaiting Cuelist release time (in seconds)"
		}
	},
	Cue = {
		Option = "Cue Options:",
		From = {
			Question = "From Cue n°",
			Description = "Indicate the first Cue ID number where to update the fade time"
		},
		To = {
			Question = "To Cue n°",
			Description = "Indicate the last Cue ID number where to update the fade time"
		},
		Time = {
			Question = "Cue Fade Time:",
			Description = "Indicate the awaiting Cue fade time (in seconds)"
		}
	},
	Validation = {
		Question = "Do you agree to update the cue fade and cuelist release time?",
		Description = "WARNING, it can't be UNDO! Use it with caution!"
	}
}
-- Request the Start Cuelist ID n°
InputSettings = {
	Question = Content.Cuelist.From.Question,
	Description = Content.Cuelist.From.Description,
	Buttons = Form.OkCancel,
	DefaultButton = Word.Ok,
	Cancel = true
}
Settings.CLStart = InputNumber(InputSettings)
if Cancelled(Settings.CLStart) then
	goto EXIT
end
-- Request the Last Cuelist ID n°
InputSettings.Question = Content.Cuelist.To.Question
InputSettings.Description = Content.Cuelist.To.Description
Settings.CLEnd = InputNumber(InputSettings)
if Cancelled(Settings.CLEnd) then
	goto EXIT
end

-- Request the Cuelist Release Time
InputSettings.Question = Content.Cuelist.Time.Question
InputSettings.Description = Content.Cuelist.Time.Description
Settings.TimeRelease = InputFloatNumber(InputSettings)
if Cancelled(Settings.TimeRelease) then
	goto EXIT
end
LogActivity(Content.Cuelist.Option)
LogActivity("\r\n\t" .. "- Update Release Time " .. Settings.TimeRelease .. "s for Cuelists from n°" .. Settings.CLStart .." to n°" .. Settings.CLEnd )

-- Request the start Cue ID n°
InputSettings.Question = Content.Cue.From.Question
InputSettings.Description = Content.Cue.From.Description
Settings.CueStart = InputNumber(InputSettings)
if Cancelled(Settings.CueStart) then
	goto EXIT
end

-- Request the Last Cue ID n°
InputSettings.Question = Content.Cue.To.Question
InputSettings.Description = Content.Cue.To.Description
Settings.CueEnd = InputNumber(InputSettings)
if Cancelled(Settings.CueEnd) then
	goto EXIT
end

-- Request the Cue Fade Time
InputSettings.Question = Content.Cue.Time.Question
InputSettings.Description = Content.Cue.Time.Description
Settings.TimeFade = InputFloatNumber(InputSettings)
if Cancelled(Settings.TimeFade) then
	goto EXIT
end

LogActivity("\r\n\r\n" .. Content.Cue.Option)
LogActivity("\r\n\t" .. "- Set Fade Time " .. Settings.TimeFade .. "s for Cues from n°" .. Settings.CueStart .. " to n°" .. Settings.CueEnd)

-- Get all cuelist name
LogActivity("\r\n" .. Content.CuelistList)

Cuelists = ListCuelist(Settings.CLStart, Settings.CLEnd)

for i, Cuelist in pairs(Cuelists) do
    LogActivity("\r\n\t" .. '- n°' .. Cuelist.id .. ' ' .. Cuelist.name)
end

InputValidationSettings = {
	Question = Content.Validation.Question,
	Description = Content.Validation.Description .. "\n\r\n\r" .. GetActivity(),
	Buttons = Form.YesNo,
	DefaultButton = Word.Yes
}
Settings.Validation = InputYesNo(InputValidationSettings)
if Settings.Validation then
	for CL = Settings.CLStart, Settings.CLEnd do
		Onyx.SelectCuelist(CL)
		Sleep(Settings.WaitTime)
		for ActCue = Settings.CueStart, Settings.CueEnd do
			Onyx.SetCueFadeTime(ActCue, Settings.TimeFade)
			Sleep(Settings.WaitTime)
		end
		Onyx.SetCuelistReleaseTime(CL, Settings.TimeRelease)
		Sleep(Settings.WaitTime)
	end
	FootPrint(Content.Done)
else
	Cancelled()
end
::EXIT::
