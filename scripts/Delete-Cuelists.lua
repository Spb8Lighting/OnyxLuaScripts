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
-- 05-09-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
	WaitTime = 0.05
}

ScriptInfos = {
	version = "1.0",
	name = "DeleteRangeOfCuelist"
}

--##LUAHEADERINCLUDE##--

----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

Content = {
	StopMessage = "Stopped!" .. "\r\n\t" .. "The Preset type defined in the script configuration is not supported",
	Done = "Deletion Ended!",
	Options = "Delete Options:",
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
-- Request the Start Preset ID n°
InputSettings = {
	Question = Content.From.Question,
	Description = Content.From.Description,
	Buttons = Form.OkCancel,
	DefaultButton = Word.Ok,
	Cancel = true
}
Settings.CLStart = InputNumber(InputSettings)
if Cancelled(Settings.CLStart) then
	goto EXIT
end
-- Request the Last Preset ID n°
InputSettings.Question = Content.To.Question
InputSettings.Description = Content.To.Description
Settings.CLEnd = InputNumber(InputSettings)
if Cancelled(Settings.CLEnd) then
	goto EXIT
end

LogActivity(Content.Options)
LogActivity("\r\n\t" .. "- From Cuelist n°" .. Settings.CLStart)
LogActivity("\r\n\t" .. "- To Cuelist n°" .. Settings.CLEnd)

InputValidationSettings = {
	Question = Content.Validation.Question,
	Description = Content.Validation.Description .. "\n\r\n\r" .. GetActivity(),
	Buttons = Form.YesNo,
	DefaultButton = Word.Yes
}
Settings.Validation = InputYesNo(InputValidationSettings)

if Settings.Validation then
	for CLNum = Settings.CLStart, Settings.CLEnd do
		Onyx.DeleteCuelist(CLNum)
		Sleep(Settings.WaitTime)
	end
	FootPrint(Content.Done)
else
	Cancelled()
end

::EXIT::
