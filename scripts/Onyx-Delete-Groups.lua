-- ShowCockpit LUA Script: DeleteRangeOfGroup
--   created on ShowCockpit v2.4.2
--   by Spb8 Lighting
--   on 29-12-2018

-------------
-- Purpose --
-------------
-- This script allows to delete a range of cuelist (batch mode)

---------------
-- Changelog --
---------------
-- 29-12-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
	WaitTime = 0.05
}

ScriptInfos = {
	version = "1.0",
	name = "DeleteRangeOfGroup"
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
	GroupList = "Groups List:",
	From = {
		Question = "Delete from Group n°",
		Description = "Indicate the first Group ID number"
	},
	To = {
		Question = "To Group n°",
		Description = "Indicate the last Group ID number"
	},
	Validation = {
		Question = "Are you sure to delete following Groups?",
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

Settings.GroupIDStart = InputNumber(InputSettings)

if Cancelled(Settings.GroupIDStart) then
	goto EXIT
end
-- Request the Last Cuelist ID n°
InputSettings.Question = Content.To.Question
InputSettings.Description = Content.To.Description
InputSettings.CurrentValue = Settings.GroupIDStart + 1

Settings.GroupIDEnd = InputNumber(InputSettings)

if Cancelled(Settings.GroupIDEnd) then
	goto EXIT
end

--# LOG all user choice # --
----------------------------

-- RESUME of action to be performed
LogActivity(Content.Options)
LogActivity("\r\n\t" .. "- Delete Groups, from n°" .. Settings.GroupIDStart .." to n°" .. Settings.GroupIDEnd )

-- DETAIL of impacted Cuelists
LogActivity("\r\n" .. Content.GroupList)

Groups = ListGroup(Settings.GroupIDStart, Settings.GroupIDEnd)

for i, Group in pairs(Groups) do
    LogActivity("\r\n\t" .. '- n°' .. Group.id .. ' ' .. Group.name)
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
	for GroupID = Settings.GroupIDStart, Settings.GroupIDEnd do
		DeleteGroup(GroupID)
		Sleep(Settings.WaitTime)
    end
    -- Display a end pop-up
	FootPrint(Content.Done)
else
	Cancelled()
end

::EXIT::
