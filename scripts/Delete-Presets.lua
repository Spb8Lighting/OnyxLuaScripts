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
    version = "1.3",
    name = "DeleteRangeOfPreset"
}

--##LUAHEADERINCLUDE##--

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
InputSettings.CurrentValue = Settings.PTStart + 1
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
