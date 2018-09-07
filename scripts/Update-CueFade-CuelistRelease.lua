-- ShowCockpit LUA Script: UpdateCueFadeCuelistRelease
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
-- 07-09-2018 - 1.2: Add some block of comment for clearer code reading
--                  + Rename some variables for clearer code reading
-- 07-09-2018 - 1.1: Fix issue with time value of 0 which was cancelling the script
-- 05-09-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
	WaitTime = 0.05
}

ScriptInfos = {
	version = "1.2",
	name = "UpdateCueFadeCuelistRelease"
}

--##LUAHEADERINCLUDE##--

----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

--------------------------
-- Sentence and Wording --
--------------------------

Content = {
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

Settings.CuelistIDEnd = InputNumber(InputSettings)

if Cancelled(Settings.CuelistIDEnd) then
	goto EXIT
end

--# REQUEST the Cuelist Release Time # --
-----------------------------------------

InputSettings.Question = Content.Cuelist.Time.Question
InputSettings.Description = Content.Cuelist.Time.Description

Settings.TimeRelease = InputFloatNumber(InputSettings)

if Cancelled(Settings.TimeRelease) then
	goto EXIT
end

--# REQUEST the Cue Range # --
------------------------------

-- Request the start Cue ID n°
InputSettings.Question = Content.Cue.From.Question
InputSettings.Description = Content.Cue.From.Description

Settings.CueIDStart = InputNumber(InputSettings)
if Cancelled(Settings.CueIDStart) then
	goto EXIT
end

-- Request the Last Cue ID n°
InputSettings.Question = Content.Cue.To.Question
InputSettings.Description = Content.Cue.To.Description

Settings.CueIDEnd = InputNumber(InputSettings)
if Cancelled(Settings.CueIDEnd) then
	goto EXIT
end

--# REQUEST the Cue Fading Time # --
------------------------------------

InputSettings.Question = Content.Cue.Time.Question
InputSettings.Description = Content.Cue.Time.Description

Settings.TimeFade = InputFloatNumber(InputSettings)

if Cancelled(Settings.TimeFade) then
	goto EXIT
end

--# LOG all user choice # --
----------------------------

-- RESUME of action to be performed

-- RESUME for Cuelist
LogActivity(Content.Cuelist.Option)
LogActivity("\r\n\t" .. "- Update Release Time " .. Settings.TimeRelease .. "s for Cuelists from n°" .. Settings.CuelistIDStart .." to n°" .. Settings.CuelistIDEnd )

-- RESUME for Cue
LogActivity("\r\n\r\n" .. Content.Cue.Option)
LogActivity("\r\n\t" .. "- Set Fade Time " .. Settings.TimeFade .. "s for Cues from n°" .. Settings.CueIDStart .. " to n°" .. Settings.CueIDEnd)

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
        -- Iterate through the Cue list
		for ActCue = Settings.CueIDStart, Settings.CueIDEnd do
			Onyx.SetCueFadeTime(ActCue, Settings.TimeFade)
			Sleep(Settings.WaitTime)
		end
		Onyx.SetCuelistReleaseTime(CuelistID, Settings.TimeRelease)
		Sleep(Settings.WaitTime)
    end
    -- Display a end pop-up
	FootPrint(Content.Done)
else
	Cancelled()
end
::EXIT::
