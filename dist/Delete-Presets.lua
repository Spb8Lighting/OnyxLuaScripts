-- ShowCockpit LUA Script: DeleteRangeOfPreset
--   created on ShowCockpit v2.4.2
--   by Spb8 Lighting
--   on 05-09-2018

-------------
-- Purpose --
-------------
-- This script allows to delete a range of presets (batch mode)

---------------
-- Changelog --
---------------
-- 06-09-2018 - 1.2: Add Framing Preset, Add list of preset to be deleted in the final report before validation
-- 06-09-2018 - 1.1: Add a drop down menu Preset Selection instead of having as lua file than preset type
-- 05-09-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
    WaitTime = 0.05
}

ScriptInfos = {
    version = "1.2",
    name = "DeleteRangeOfPreset"
}

-- ShowCockpit LUA Script: LuaHeader for Spb8 Lighting LUA Script

---------------
-- Changelog --
---------------
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
	Sentence = "Scripted by" ..
		"\r\n\t" .. ScriptInfos.author .. "\r\n\t" .. ScriptInfos.contact .. "\r\n\t" .. ScriptInfos.website,
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
end

function Cancelled(variable)
	if variable == nil or variable == "" then
		LogInformation("Cancelled!" .. "\r\n\t" .. Infos.Script .. "\r\n\t" .. Infos.Sentence)
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
		elseif Answer["input"] == 0 or Answer["button"] == Word.Cancel or Answer["button"] == Word.No then
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
	Prompt.SetMinValue(0)

	return ShowInput(Prompt, Infos)
end
function InputFloatNumber(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos, "FloatInput")
	-- Prompt settings
	Prompt.SetMinValue(0)

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
	print(text)
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

function CopyCue(CLOrigin, CUNumber, CLTarget)
	Sleep(Settings.WaitTime)
	Onyx.SelectCuelist(CLOrigin)
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Copy")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Cue")
	Sleep(Settings.WaitTime)
	KeyNumber(CUNumber)
	Onyx.Key_ButtonPress("At")
	Sleep(Settings.WaitTime)
	Onyx.SelectCuelist(CLTarget)
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Enter")
	Sleep(Settings.WaitTime)
end

function KeyNumber(number)
	if string.find(number, "%d", 1, false) then
		a = string.match(number, "(.+)")
		for c in a:gmatch "." do
			Onyx.Key_ButtonPress("Num" .. c)
		end
		Sleep(Settings.WaitTime)
	end
end

function RecordCuelist(number)
	Onyx.Key_ButtonPress("Record")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Slash")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Slash")
	KeyNumber(number)
	Onyx.Key_ButtonPress("Enter")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonPress("Enter")
end

function CheckEmpty(Chain)
	if Chain == nil or Chain == "" then
		return "---"
	else
		return Chain
	end
end

function GetPresetName(PresetType, PresetNumber)
	if PresetType == PresetName.PanTilt then
		return CheckEmpty(Onyx.GetPanTiltPresetName(PresetNumber))
	elseif PresetType == PresetName.Color then
		return CheckEmpty(Onyx.GetColorPresetName(PresetNumber))
	elseif PresetType == PresetName.Intensity then
		return CheckEmpty(Onyx.GetIntensityPresetName(PresetNumber))
	elseif PresetType == PresetName.Gobo then
		return CheckEmpty(Onyx.GetGoboPresetName(PresetNumber))
	elseif PresetType == PresetName.Beam then
		return CheckEmpty(Onyx.GetBeamPresetName(PresetNumber))
	elseif PresetType == PresetName.BeamFX then
		return CheckEmpty(Onyx.GetBeamFXPresetName(PresetNumber))
	elseif PresetType == PresetName.Framing then
		return CheckEmpty(Onyx.GetFramingPresetName(PresetNumber))
	end
end

function DeletePreset(PresetType, CuelistNumber)
	if PresetType == PresetName.PanTilt then
		Onyx.DeletePanTiltPreset(CuelistNumber)
	elseif PresetType == PresetName.Color then
		Onyx.DeleteColorPreset(CuelistNumber)
	elseif PresetType == PresetName.Intensity then
		Onyx.DeleteIntensityPreset(CuelistNumber)
	elseif PresetType == PresetName.Gobo then
		Onyx.DeleteGoboPreset(CuelistNumber)
	elseif PresetType == PresetName.Beam then
		Onyx.DeleteBeamPreset(CuelistNumber)
	elseif PresetType == PresetName.BeamFX then
		Onyx.DeleteBeamFXPreset(CuelistNumber)
	elseif PresetType == PresetName.Framing then
		Onyx.DeleteFramingPreset(CuelistNumber)
	end
end

function ListPreset(PresetType, PresetStart, PresetEnd)
	Presets = {}
	for i = PresetStart, PresetEnd, 1 do
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

HeadPrint()
-- End of Header --



----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

Content = {
    StopMessage = "Stopped!" .. "\r\n\t" .. "The Preset type defined in the script configuration is not supported",
    Done = "Deletion Ended!",
    Options = "Delete Options:",
    PresetList = "Preset list:",
    Select = {
        Question = "Which type of preset do you want to delete?",
        Description = "Please select the preset type you want to delete from the list:"
    },
    From = {
        Question = "Delete from Preset n°",
        Description = "Indicate the first Preset ID number:"
    },
    To = {
        Question = "To Preset n°",
        Description = "Indicate the last Preset ID number:"
    },
    Validation = {
        Question = "Are you sure to delete following Presets?",
        Description = "WARNING, it can't be UNDO! Use it with caution!"
    }
}

-- Request the Start Preset ID n°
InputSettings = {
    Question = Content.Select.Question,
    Description = Content.Select.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    DropDown = {"Intensity", "PanTilt", "Color", "Gobo", "Beam", "BeamFX", "Framing"},
    DropDownDefault = "Intensity",
    Cancel = true
}
PresetType = InputDropDown(InputSettings)

-- If not PresetType defined, exit
if Cancelled(PresetType) then
    goto EXIT
else
    if PresetType == PresetName.PanTilt then
        Settings.Type = "Pan/Tilt"
    elseif
        PresetType == PresetName.Color or
        PresetType == PresetName.Intensity or
        PresetType == PresetName.Gobo or
        PresetType == PresetName.Beam or
        PresetType == PresetName.BeamFX or
        PresetType == PresetName.Framing
    then
        Settings.Type = PresetType
    else
        LogInformation(Content.StopMessage)
        goto EXIT
    end
    LogInformation("Preset Type: " .. PresetType .. "\r\n\t" .. "Delete " .. PresetType .. " presets")
end

-- Request the Start Preset ID n°
InputSettings = {
    Question = Content.From.Question,
    Description = Content.From.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    Cancel = true
}
Settings.PTStart = InputNumber(InputSettings)
if Cancelled(Settings.PTStart) then
    goto EXIT
end
-- Request the Last Preset ID n°
InputSettings.Question = Content.To.Question
InputSettings.Description = Content.To.Description
Settings.PTEnd = InputNumber(InputSettings)
if Cancelled(Settings.PTEnd) then
    goto EXIT
end

LogActivity(Content.Options)
LogActivity("\r\n\t" .. "- Delete " .. PresetType .. " Presets, from n°" .. Settings.PTStart .." to n°" .. Settings.PTEnd )

-- Get all preset name
LogActivity("\r\n" .. Content.PresetList)

Presets = ListPreset(PresetType, Settings.PTStart, Settings.PTEnd)

for i, Preset in pairs(Presets) do
    LogActivity("\r\n\t" .. '- n°' .. Preset.id .. ' ' .. Preset.name)
end

InputValidationSettings = {
    Question = Content.Validation.Question,
    Description = Content.Validation.Description .. "\n\r\n\r" .. GetActivity(),
    Buttons = Form.YesNo,
    DefaultButton = Word.Yes
}
Settings.Validation = InputYesNo(InputValidationSettings)

if Settings.Validation then
    for CuelistNumber = Settings.PTStart, Settings.PTEnd do
        DeletePreset(PresetType, CuelistNumber)
        Sleep(Settings.WaitTime)
    end
    FootPrint(Content.Done)
else
    Cancelled()
end

::EXIT::