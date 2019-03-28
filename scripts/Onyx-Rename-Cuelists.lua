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

--##LUAHEADERINCLUDE##--

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
