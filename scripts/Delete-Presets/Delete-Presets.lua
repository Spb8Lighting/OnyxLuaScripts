-- ShowCockpit LUA Script: DeleteRangeOf--##PRESET##--Preset
--   created on ShowCockpit v2.4.2
--   by Spb8 Lighting
--   on 05-09-2018

-------------
-- Purpose --
-------------
-- This script allows to delete a range of --##PRESET##-- presets (batch mode)

---------------
-- Changelog --
---------------
-- 05-09-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

--##PRESETTYPE##--

Settings = {
    WaitTime = 0.05
}

ScriptInfos = {
    version = "1.0",
    name = "DeleteRangeOf--##PRESET##--Preset"
}

--##LUAHEADERINCLUDE##--

----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

Content = {
    StopMessage = "Stopped!" .. "\r\n\t" .. "The Preset type defined in the script configuration is not supported",
    Done = "Deletion Ended!",
	Options = "Delete Options:",
    DeleteFromPreset = {
        Question = "Delete from Preset n°",
        Description = "Indicate the first Preset ID number "
    },
    DeleteToPreset = {
        Question = "To Preset n°",
        Description = "Indicate the last Preset ID number"
    },
    DeleteValidation = {
        Question = "Are you sure to delete following Presets?",
        Description = "WARNING, it can't be UNDO! Use it with caution!"
    }
}

-- If not PresetType defined, exit
if Cancelled(PresetType) then
    goto EXIT
else
    if PresetType == PresetName.PanTilt then
        Settings.Type = "Pan/Tilt"
    elseif PresetType == PresetName.Color then
        Settings.Type = PresetType
    elseif PresetType == PresetName.Intensity then
        Settings.Type = PresetType
    elseif PresetType == PresetName.Gobo then
        Settings.Type = PresetType
    elseif PresetType == PresetName.Beam then
        Settings.Type = PresetType
    elseif PresetType == PresetName.BeamFX then
        Settings.Type = PresetType
    else
        LogInformation(Content.StopMessage)
        goto EXIT
    end
    LogInformation("Preset Type: " .. PresetType .. "\r\n\t" .. "Delete " .. PresetType .. " presets")
end

-- Request the Start Preset ID n°
InputSettings = {
    Question = Content.DeleteFromPreset.Question,
    Description = Content.DeleteFromPreset.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    Cancel = true
}
Settings.PTStart = InputNumber(InputSettings)
if Cancelled(Settings.PTStart) then
    goto EXIT
end
-- Request the Last Preset ID n°
InputSettings.Question = Content.DeleteToPreset.Question
InputSettings.Description = Content.DeleteToPreset.Description
Settings.PTEnd = InputNumber(InputSettings)
if Cancelled(Settings.PTEnd) then
    goto EXIT
end

LogActivity(Content.Options)
LogActivity("\r\n\t" .. "- From Preset n°" .. Settings.PTStart)
LogActivity("\r\n\t" .. "- To Preset n°" .. Settings.PTEnd)

InputValidationSettings = {
    Question = Content.DeleteValidation.Question,
    Description = Content.DeleteValidation.Description .. "\n\r\n\r" .. GetActivity(),
    Buttons = Form.YesNo,
    DefaultButton = Word.Yes
}
Settings.Validation = InputYesNo(InputValidationSettings)

if Settings.Validation then
    for CLNum = Settings.PTStart, Settings.PTEnd do
        if PresetType == PresetName.PanTilt then
            Onyx.DeletePanTiltPreset(CLNum)
        elseif PresetType == PresetName.Color then
            Onyx.DeleteColorPreset(CLNum)
        elseif PresetType == PresetName.Intensity then
            Onyx.DeleteIntensityPreset(CLNum)
        elseif PresetType == PresetName.Gobo then
            Onyx.DeleteGoboPreset(CLNum)
        elseif PresetType == PresetName.Beam then
            Onyx.DeleteBeamPreset(CLNum)
        elseif PresetType == PresetName.BeamFX then
            Onyx.DeleteBeamFXPreset(CLNum)
        end
        Sleep(Settings.WaitTime)
    end
    FootPrint(Content.Done)
else
    Cancelled()
end

::EXIT::
