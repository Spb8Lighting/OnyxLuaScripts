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

--##LUAHEADERINCLUDE##--

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
