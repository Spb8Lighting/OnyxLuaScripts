-- ShowCockpit LUA Script: DeleteRangeOfCuelist
--   created on ShowCockpit v2.4.2
--   by Spb8 Lighting
--   on 05-09-2018

-------------
-- Purpose --
-------------
-- This script allows to delete a range of cuelist (batch mode)

---------------
-- Changelog --
---------------
-- 07-09-2018 - 1.2: Add some block of comment for clearer code reading
--                  + Rename some variables for clearer code reading
-- 07-09-2018 - 1.1: Fix an issue with the maximum ID Cuelist which was lock to 100.
--                  + Add the list of cuelist to be deleted as information on validation
-- 05-09-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
	WaitTime = 0.05
}

ScriptInfos = {
	version = "1.2",
	name = "DeleteRangeOfCuelist"
}

--##LUAHEADERINCLUDE##--

----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

--------------------------
-- Sentence and Wording --
--------------------------

Content = {
	StopMessage = "Stopped!" .. "\r\n\t" .. "The Preset type defined in the script configuration is not supported",
	Done = "Deletion Ended!",
	Options = "Delete Options:",
	CuelistList = "Cuelists List:",
	From = {
		Question = "Delete from Cuelist n°",
		Description = "Indicate the first Cuelist ID number (from cuelist repository)"
	},
	To = {
		Question = "To Cuelist n°",
		Description = "Indicate the last Cuelist ID number (from cuelist repository)"
	},
	Validation = {
		Question = "Are you sure to delete following Cuelists?",
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
	Question = Content.From.Question,
	Description = Content.From.Description,
	Buttons = Form.OkCancel,
	DefaultButton = Word.Ok,
	Cancel = true
}

Settings.CuelistIDStart = InputNumber(InputSettings)

if Cancelled(Settings.CuelistIDStart) then
	goto EXIT
end
-- Request the Last Cuelist ID n°
InputSettings.Question = Content.To.Question
InputSettings.Description = Content.To.Description
InputSettings.CurrentValue = Settings.CuelistIDStart + 1

Settings.CuelistIDEnd = InputNumber(InputSettings)

if Cancelled(Settings.CuelistIDEnd) then
	goto EXIT
end

--# LOG all user choice # --
----------------------------

-- RESUME of action to be performed
LogActivity(Content.Options)
LogActivity("\r\n\t" .. "- Delete Cuelists, from n°" .. Settings.CuelistIDStart .." to n°" .. Settings.CuelistIDEnd )

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
		Onyx.DeleteCuelist(CuelistID)
		Sleep(Settings.WaitTime)
    end
    -- Display a end pop-up
	FootPrint(Content.Done)
else
	Cancelled()
end

::EXIT::
