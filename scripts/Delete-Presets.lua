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
-- 07-09-2018 - 1.4: Update function to check the PresetType
--                  + Add some block of comment for clearer code reading
--                  + Rename some variables for clearer code reading
-- 07-09-2018 - 1.3: The "To ID Preset" is now automatically populate with the "From ID Preset" +1
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
    version = "1.4",
    name = "DeleteRangeOfPreset"
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

--------------------------
-- Collect Informations --
--------------------------

--# REQUEST the Preset Type # --
--------------------------------

InputSettings = {
    Question = Content.Select.Question,
    Description = Content.Select.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    DropDown = Form.Preset,
    DropDownDefault = PresetName.Intensity,
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
    LogInformation("Preset Type: " .. PresetType .. "\r\n\t" .. "Delete " .. PresetType .. " presets")
end

--# REQUEST the Preset Range # --
---------------------------------

-- Request the Start Preset ID n°
InputSettings = {
    Question = Content.From.Question,
    Description = Content.From.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    Cancel = true
}

Settings.PresetIDStart = InputNumber(InputSettings)

if Cancelled(Settings.PresetIDStart) then
    goto EXIT
end

-- Request the Last Preset ID n°
InputSettings.Question = Content.To.Question
InputSettings.Description = Content.To.Description
InputSettings.CurrentValue = Settings.PresetIDStart + 1

Settings.PresetIDEnd = InputNumber(InputSettings)

if Cancelled(Settings.PresetIDEnd) then
    goto EXIT
end

--# LOG all user choice # --
----------------------------

-- RESUME of action to be performed
LogActivity(Content.Options)
LogActivity("\r\n\t" .. "- Delete " .. PresetType .. " Presets, from n°" .. Settings.PresetIDStart .." to n°" .. Settings.PresetIDEnd )

-- DETAIL of impacted presets
LogActivity("\r\n" .. Content.PresetList)

Presets = ListPreset(PresetType, Settings.PresetIDStart, Settings.PresetIDEnd)

for i, Preset in pairs(Presets) do
    LogActivity("\r\n\t" .. '- n°' .. Preset.id .. ' ' .. Preset.name)
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
    -- Iterate through the Preset list
    for PresetID = Settings.PresetIDStart, Settings.PresetIDEnd do
        DeletePreset(PresetType, PresetID)
        Sleep(Settings.WaitTime)
    end
    -- Display a end pop-up
    FootPrint(Content.Done)
else
    Cancelled()
end

::EXIT::
