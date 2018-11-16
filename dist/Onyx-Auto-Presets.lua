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

-- ShowCockpit LUA Script: LuaHeader for Spb8 Lighting LUA Script

---------------
-- Changelog --
---------------
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

HeadPrint()
-- End of Header --



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

PresetsConfiguration = {
  Intensity = {
    {name = "Dimmer 100%", 		    color = "255, 255, 255",		value=255, 		          position = Settings.PresetINTENSITYStartPosition},
    {name = "Dimmer 50%", 		    color = "160, 160, 160", 		value=127,		          position = Settings.PresetINTENSITYStartPosition+Settings.PresetGridWidth},
    {name = "Dimmer 0%", 			    color = "96, 96, 96", 			value=0,		            position = Settings.PresetINTENSITYStartPosition+Settings.PresetGridWidth*2},
    
    {name = "Strobe Fast", 		    color = "255, 255, 0", 			value=nil,	          	position = Settings.PresetINTENSITYStartPosition+1},
    {name = "Strobe Mid", 		    color = "255, 255, 128", 		value=nil,	          	position = Settings.PresetINTENSITYStartPosition+Settings.PresetGridWidth+1},
    {name = "Strobe Low", 		    color = "255, 255, 204", 		value=nil,	          	position = Settings.PresetINTENSITYStartPosition+Settings.PresetGridWidth*2+1},
    
    {name = "Shutter Open", 	    color = "255, 255, 255", 		value=nil,		          position = Settings.PresetINTENSITYStartPosition+2},
    {name = "Shutter Closed",     color = "0, 0, 0", 				  value=nil,		          position = Settings.PresetINTENSITYStartPosition+Settings.PresetGridWidth+2}
  },
  Gobo = {
		{name = "No Gobo",	 			    color = "0, 0, 0", 			  	value=nil,		          position = Settings.PresetGOBOStartPosition},
		{name = "Gobo Rot CW Slow", 	color = "255, 0, 0", 		  	value=nil,		          position = Settings.PresetGOBOStartPosition+Settings.PresetGridWidth},
		{name = "Gobo Rot CW Fast", 	color = "255, 255, 0", 			value=nil,		          position = Settings.PresetGOBOStartPosition+Settings.PresetGridWidth*2},
		{name = "Gobo fixed", 			  color = "160, 160, 160", 		value=nil,		          position = Settings.PresetGOBOStartPosition+1},
		{name = "Gobo Rot CCW Slow", 	color = "0, 0, 255", 		  	value=nil,		          position = Settings.PresetGOBOStartPosition+Settings.PresetGridWidth+1},
		{name = "Gobo Rot CCW Fast", 	color = "0, 255, 255", 			value=nil,		          position = Settings.PresetGOBOStartPosition+Settings.PresetGridWidth*2+1}
	},
	Beam = {
		{name = "No prism", 			    color = "0, 0, 0", 			  	value=nil,			        position = Settings.PresetBEAMStartPosition},
		{name = "Prism Rot CW Slow", 	color = "255, 0, 0", 			  value=nil,			        position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth},
		{name = "Prism Rot CW Fast", 	color = "255, 255, 0", 			value=nil,			        position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth*2},
		{name = "Prism fixed", 			  color = "160, 160, 160", 		value=nil,			        position = Settings.PresetBEAMStartPosition+1},
		{name = "Prism Rot CCW Slow", color = "0, 0, 255", 			  value=nil,			        position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth+1},
		{name = "Prism Rot CCW Fast", color = "0, 255, 255", 			value=nil,			        position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth*2+1},
		
		{name = "Focus Near", 			  color = "0, 0, 0", 				  value={Focus=0},		  	position = Settings.PresetBEAMStartPosition+2},
		{name = "Focus Middle", 		  color = "160, 160, 160", 		value={Focus=127},			position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth+2},
		{name = "Focus Far", 			    color = "255, 0, 0", 			  value={Focus=255},			position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth*2+2},
		
		{name = "Frost 100%", 			  color = "255, 255, 255",		value={Frost=255},			position = Settings.PresetBEAMStartPosition+3},
		{name = "Frost 50%", 			    color = "160, 160, 160", 		value={Frost=127},			position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth+3},
		{name = "Frost 0%", 			    color = "96, 96, 96", 			value={Frost=0},			  position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth*2+3},
		
		{name = "Zoom 100%", 		    	color = "255, 255, 255",		value={Zoom=255},		    position = Settings.PresetBEAMStartPosition+4},
		{name = "Zoom 50%", 		    	color = "160, 160, 160", 		value={Zoom=127},		    position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth+4},
		{name = "Zoom 0%", 				    color = "96, 96, 96", 			value={Zoom=0},			    position = Settings.PresetBEAMStartPosition+Settings.PresetGridWidth*2+4}
  },
  ColorFull = {
    {name = "CTB", 					      color = "-8071681", 	                              position = Settings.PresetCOLORStartPosition,
      value={Red=215,		Green=243,		Blue=255,	  White=255,	Amber=0,		UV=0,		  Cyan=40,	Magenta=12,	  Yellow=0}},	
    {name = "White", 				      color = "-327682", 			                            position = Settings.PresetCOLORStartPosition+1,
      value={Red=255,		Green=255,		Blue=255,	  White=255,	Amber=0,		UV=0,		  Cyan=0,		Magenta=0,		Yellow=0}},
    {name = "CTO", 					      color = "-6824", 									                  position = Settings.PresetCOLORStartPosition+2,
      value={Red=255,		Green=216,		Blue=176,	  White=255,	Amber=255,	UV=0,		  Cyan=0,		Magenta=39,		Yellow=79}},
    {name = "Salmon", 			      color = "-65536", 									                position = Settings.PresetCOLORStartPosition+3,
      value={Red=255,		Green=39,		  Blue=28,	  White=25,		Amber=0,		UV=0,		  Cyan=0,		Magenta=216,	Yellow=227}},
    {name = "Red", 					      color = "-65536", 									                position = Settings.PresetCOLORStartPosition+4,
      value={Red=255,		Green=0,		  Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=255}},
    {name = "Peach", 				      color = "-65536", 								                	position = Settings.PresetCOLORStartPosition+5,
      value={Red=252,		Green=85,		  Blue=37,	  White=0,		Amber=0,		UV=0,		  Cyan=3,		Magenta=170,	Yellow=218}},
    {name = "Orange", 			      color = "-33280", 									                position = Settings.PresetCOLORStartPosition+6,
      value={Red=255,		Green=127,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=127,	Yellow=255}},
    {name = "Yellow", 			      color = "-2560", 									                  position = Settings.PresetCOLORStartPosition+7,
      value={Red=255,		Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=0,		Yellow=255}},
    {name = "Lime", 				      color = "-2560", 									                  position = Settings.PresetCOLORStartPosition+8,
      value={Red=191,		Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=64,	Magenta=0,		Yellow=255}},
    {name = "Green", 				      color = "-10879232", 								                position = Settings.PresetCOLORStartPosition+9,
      value={Red=0,		  Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=0,		Yellow=255}},
    {name = "Turquoise", 		      color = "-16712449", 								                position = Settings.PresetCOLORStartPosition+10,
      value={Red=0,		  Green=191,		Blue=127,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=64,		Yellow=127}},
    {name = "Cyan", 			      	color = "-16712449", 							                	position = Settings.PresetCOLORStartPosition+11,
      value={Red=0,		  Green=255,		Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=0,		Yellow=0}},
    {name = "Azure", 				      color = "-16712449", 								                position = Settings.PresetCOLORStartPosition+12,
      value={Red=0,		  Green=160,		Blue=207,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=96,		Yellow=48}},
    {name = "Light Blue",       	color = "-16769537", 								                position = Settings.PresetCOLORStartPosition+13,
      value={Red=17,		Green=118,		Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=238,	Magenta=137,	Yellow=0}},
    {name = "Blue", 				      color = "-16769537", 								                position = Settings.PresetCOLORStartPosition+14,
      value={Red=0,		  Green=0,		  Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=255,	Yellow=0}},
    {name = "Dark Blue", 		      color = "-16769537", 								                position = Settings.PresetCOLORStartPosition+15,
      value={Red=0,		  Green=16,		  Blue=128,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=239,	Yellow=127}},
    {name = "Lavender", 		      color = "-136631233", 								              position = Settings.PresetCOLORStartPosition+16,
      value={Red=64,		Green=0,		  Blue=128,	  White=0,		Amber=0,		UV=0,		  Cyan=191,	Magenta=255,	Yellow=127}},
    {name = "Uv", 					      color = "-136631233", 								              position = Settings.PresetCOLORStartPosition+17,
      value={Red=13,		Green=4,		  Blue=113,	  White=0,		Amber=0,		UV=255,		Cyan=242,	Magenta=251,	Yellow=142}},
    {name = "Bright Pink", 	      color = "-65308", 									                position = Settings.PresetCOLORStartPosition+18,
      value={Red=221,		Green=2,		  Blue=96,	  White=0,		Amber=0,		UV=0,		  Cyan=34,	Magenta=253,	Yellow=159}},
    {name = "Pink", 				      color = "-65308", 									                position = Settings.PresetCOLORStartPosition+19,
      value={Red=255,		Green=127,		Blue=127,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=127,	Yellow=127}},
    {name = "Flash Pink", 	      color = "-65308", 									                position = Settings.PresetCOLORStartPosition+20,
      value={Red=223,		Green=32,		  Blue=96,	  White=0,		Amber=0,		UV=0,		  Cyan=32,	Magenta=223,	Yellow=159}},
    {name = "Sunset Pink", 	      color = "-65308", 									                position = Settings.PresetCOLORStartPosition+21,
      value={Red=255,		Green=0,		  Blue=85,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=170}},
    {name = "Magenta", 			      color = "-65434", 									                position = Settings.PresetCOLORStartPosition+22,
      value={Red=255,		Green=0,		  Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=0}}
  },
  Color = {
    {name = "White", 				      color = "-327682", 									                position = Settings.PresetCOLORStartPosition,
      value={Red=255,		Green=255,		Blue=255,	  White=255,	Amber=0,		UV=0,		  Cyan=0,		Magenta=0,		Yellow=0}},
    {name = "Red", 					      color = "-65536", 									                position = Settings.PresetCOLORStartPosition+1,
      value={Red=255,		Green=0,		  Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=255}},
    {name = "Orange", 			      color = "-33280", 									                position = Settings.PresetCOLORStartPosition+2,
      value={Red=255,		Green=127,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=127,	Yellow=255}},
    {name = "Yellow", 			      color = "-2560", 									                  position = Settings.PresetCOLORStartPosition+3,
      value={Red=255,		Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=0,		Yellow=255}},
    {name = "Lime", 				      color = "-2560", 									                  position = Settings.PresetCOLORStartPosition+4,
      value={Red=191,		Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=64,	Magenta=0,		Yellow=255}},
    {name = "Green", 				      color = "-10879232", 								                position = Settings.PresetCOLORStartPosition+5,
      value={Red=0,		  Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=0,		Yellow=255}},
    {name = "Cyan", 				      color = "-16712449", 								                position = Settings.PresetCOLORStartPosition+6,
      value={Red=0,		  Green=255,		Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=0,		Yellow=0}},
    {name = "Light Blue", 	      color = "-16769537", 								                position = Settings.PresetCOLORStartPosition+7,
      value={Red=17,		Green=118,		Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=238,	Magenta=137,	Yellow=0}},
    {name = "Blue", 				      color = "-16769537", 								                position = Settings.PresetCOLORStartPosition+8,
      value={Red=0,		  Green=0,		  Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=255,	Yellow=0}},
    {name = "Uv", 					      color = "-136631233", 								              position = Settings.PresetCOLORStartPosition+9,
      value={Red=13,		Green=4,		  Blue=113,	  White=0,		Amber=0,		UV=255,		Cyan=242,	Magenta=251,	Yellow=142}},
    {name = "Pink", 				      color = "-65308", 									                position = Settings.PresetCOLORStartPosition+10,
      value={Red=255,		Green=127,		Blue=127,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=127,	Yellow=127}},
    {name = "Magenta", 			      color = "-65434", 									                position = Settings.PresetCOLORStartPosition+11,
      value={Red=255,		Green=0,		  Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=0}}
  }
}


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
