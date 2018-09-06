-- ShowCockpit LUA Script: CreatePlaybacksFromPresets
--   created on ShowCockpit v2.4.2
--   by Spb8 Lighting
--   on 05-09-2018

-------------
-- Purpose --
-------------
-- This script allows to create playback(s) cuelist from preset(s)

---------------
-- Changelog --
---------------
-- 07-09-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
    WaitTime = 0.5,
    HarmonizeCLName = true, -- Default: true > If preset name has the group name, the script will remove take the preset name without the group name to format the cuelist name
    Optimize = true, -- Default: true > Activate optimization to speed up execution (take care, this option can break the result) [-6 x Waitime per playback button]
    RenameCue = false -- Default: false > Activate the cue Renaming with preset name (increase the performance)
}

ScriptInfos = {
    version = "1.0",
    name = "CreatePlaybacksFromPresets"
}

--##LUAHEADERINCLUDE##--

----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

Content = {
    StopMessage = "Stopped!" .. "\r\n\t" .. "The Preset type defined in the script configuration is not supported",
    Done = "Deletion Ended!",
    Options = "Delete Options:",
    Presets = {
        Options = "Presets Options:",
        PresetList = "Preset list:"
    },
    Select = {
        Question = "Which type of preset will be used to create playback?",
        Description = "Please select the preset type to create playback from the list:"
    },
    Groups = {
        Question = "How many fixture groups will be used?",
        Description = "Please indicate the quantity of groups where to create playbacks:"
    },
    Cuelist = {
        From = {
            Question = "Create playbacks from Preset n°",
            Description = "Indicate the first Preset ID number:"
        },
        To = {
            Question = "Create playbacks until Preset n°",
            Description = "Indicate the last Preset ID number:"
        },
        Time = {
            Question = "Cuelist Release Time:",
            Description = "Indicate the awaiting Cuelist release time (in seconds)"
        }
    },
    Playback = {
        Page = {
            Question = "Which playback page n° to create playbacks?",
            Description = "Indicate playback page ID where to create playbacks:"
        },
        Button = {
            Question = "Which playback button n° to start creating playback?",
            Description = "Indicate playback button ID number where to start creating playback:"
        },
        Arrangement = {
            Question = "Which playback arrangement do you want?",
            Description = "Choose the playback button arrangement of your choice:"
        },
        Grid = {
            Question = "What is your playback page width?",
            Description = "Indicate the playback page width (column):"
        }
    },
    Cue = {
        Time = {
            Question = "Cue Fade Time:",
            Description = "Indicate the awaiting Cue fade time (in seconds)"
        }
    },
    Validation = {
        Question = "Do you want to create the playbacks?"
    }
}

Settings.Step = 1

-- Request the Preset Type
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
        PresetType == PresetName.Color or PresetType == PresetName.Intensity or PresetType == PresetName.Gobo or
            PresetType == PresetName.Beam or
            PresetType == PresetName.BeamFX or
            PresetType == PresetName.Framing
     then
        Settings.Type = PresetType
    else
        LogInformation(Content.StopMessage)
        goto EXIT
    end
    LogInformation("Preset Type: " .. PresetType .. "\r\n\t" .. "Create " .. PresetType .. " Playbacks")
end

function SleepOption()
    if Settings.Optimize == false then
        Sleep(Settings.WaitTime)
    end
end

function CuelistName(GroupName, NamePreset, OnlyPresetName)
    function RemoveGroup()
        return trim(string.gsub(NamePreset, GroupName, ""))
    end
    local CLName = GroupName .. " - " .. NamePreset
    if Settings.HarmonizeCLName == true then
        if string.find(NamePreset, GroupName, 1, true) then
            if OnlyPresetName == true then
                return RemoveGroup()
            else
                return GroupName .. " - " .. RemoveGroup()
            end
        else
            if OnlyPresetName == true then
                return NamePreset
            else
                return CLName
            end
        end
    else
        if OnlyPresetName == true then
            return NamePreset
        else
            return CLName
        end
    end
end

-- Request EU number of groups to be threated
InputSettings = {
    Question = Content.Groups.Question,
    Description = Content.Groups.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    Cancel = true
}
Settings.NbOfGroups = InputNumber(InputSettings)
if Cancelled(Settings.NbOfGroups) then
    goto EXIT
end

-- Indicate the number of Groups to be threated
Settings.Groups = {}

-- Request EU details for each group
for i = 1, Settings.NbOfGroups, 1 do
    -- Request the Group ID
    InputSettings = {
        Question = "Group n°" .. i .. " ID",
        Description = "Please indicate the Group n°" .. i .. " ID:",
        Buttons = Form.OkCancel,
        DefaultButton = Word.Ok,
        Cancel = true
    }
    GroupID = InputNumber(InputSettings)
    if Cancelled(GroupID) then
        goto EXIT
    end
    table.insert(Settings.Groups, {id = GroupID, name = Onyx.GetGroupName(GroupID)})
end

-- Feedback to EU about group declaration
LogActivity(Settings.NbOfGroups .. " groups declared:")
for i, Group in pairs(Settings.Groups) do
    LogActivity("\t" .. "- n°" .. Group.id .. " - " .. Group.name)
end

-- Request the Start Preset ID n°
InputSettings = {
    Question = Content.Cuelist.From.Question,
    Description = Content.Cuelist.From.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    Cancel = true
}
Settings.PTStart = InputNumber(InputSettings)
if Cancelled(Settings.PTStart) then
    goto EXIT
end
-- Request the Last Preset ID n°
InputSettings.Question = Content.Cuelist.To.Question
InputSettings.Description = Content.Cuelist.To.Description
InputSettings.CurrentValue = Settings.PTStart + 1
Settings.PTEnd = InputNumber(InputSettings)
if Cancelled(Settings.PTEnd) then
    goto EXIT
end

-- Extract Preset Name, ID and Appearance
LogActivity(Content.Presets.Options)
LogActivity("\r\n\t" .. "- " .. PresetType .. " Presets, from n°" .. Settings.PTStart .. " to n°" .. Settings.PTEnd)

-- Get all preset name
LogActivity("\r\n" .. Content.Presets.PresetList)

Presets = ListPreset(PresetType, Settings.PTStart, Settings.PTEnd)

Settings.NumberOfPreset = Settings.PTEnd - Settings.PTStart + 1

for i, Preset in pairs(Presets) do
    LogActivity("\r\n\t" .. "- n°" .. Preset.id .. " " .. Preset.name)
end

-- Request EU informations about playback

-- Starting playback button page
InputSettings.Question = Content.Playback.Page.Question
InputSettings.Description = Content.Playback.Page.Description
Settings.PlaybackButtonPage = InputNumber(InputSettings)
if Cancelled(Settings.PlaybackButtonPage) then
    goto EXIT
end

-- First playback button
InputSettings.Question = Content.Playback.Button.Question
InputSettings.Description = Content.Playback.Button.Description
Settings.PlaybackButtonStart = InputNumber(InputSettings)
if Cancelled(Settings.PlaybackButtonStart) then
    goto EXIT
end

-- Playback arrangement
InputSettings = {
    Question = Content.Playback.Arrangement.Question,
    Description = Content.Playback.Arrangement.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    DropDown = {Word.Vertical, Word.Horizontal},
    DropDownDefault = Word.Vertical,
    Cancel = true
}
Settings.TextOrientation = InputDropDown(InputSettings)

-- Playback Grid Width
InputSettings.Question = Content.Playback.Grid.Question
InputSettings.Description = Content.Playback.Grid.Description
InputSettings.CurrentValue = Settings.NbOfGroups
Settings.PlaybackWidth = InputNumber(InputSettings)
if Cancelled(Settings.PlaybackButtonPage) then
    goto EXIT
end

-- Feedback to EU about playback
LogActivity("Playback options:")
LogActivity("\t" .. "- Playback page n°" .. Settings.PlaybackButtonPage)
LogActivity("\t" .. "- Start from Playback button n°" .. Settings.PlaybackButtonStart)
Settings.GridSize = Settings.NbOfGroups .. " groups of " .. Settings.NumberOfPreset .. " presets"
LogActivity(
    "\t" ..
        "- " ..
            Settings.TextOrientation ..
                " arrangement for " .. Settings.GridSize .. " on " .. Settings.PlaybackWidth .. " grid width"
)

-- Request EU the first Cuelist Number to record
Settings.StartingEmptyCueList = Onyx.GetNextCuelistNumber()
-- Request the Cue Fade Time
InputSettings.Question = Content.Cue.Time.Question
InputSettings.Description = Content.Cue.Time.Description
Settings.TimeFade = InputFloatNumber(InputSettings)
if Cancelled(Settings.TimeFade) then
    goto EXIT
end

-- Request the Cuelist Release Time
InputSettings.Question = Content.Cuelist.Time.Question
InputSettings.Description = Content.Cuelist.Time.Description
Settings.TimeRelease = InputFloatNumber(InputSettings)
if Cancelled(Settings.TimeRelease) then
    goto EXIT
end

-- Feedback to EU about playback
LogActivity("Record options:")
LogActivity("\t" .. "- new Cuelist from n°" .. Settings.StartingEmptyCueList)
LogActivity("\t" .. "- Cue Fade Time: " .. Settings.TimeFade .. "s")
LogActivity("\t" .. "- Cuelist Release Time: " .. Settings.TimeRelease .. "s")

InputValidationSettings = {
    Question = Content.Validation.Question,
    Description = "Do you agree to generate " ..
        PresetType ..
            " Playbacks for " ..
                Settings.GridSize ..
                    ", on Playback page n°" .. Settings.PlaybackButtonPage .. "?" .. "\n\r\n\r" .. GetActivity(),
    Buttons = Form.YesNo,
    DefaultButton = Word.Yes
}
Settings.Validation = InputYesNo(InputValidationSettings)

Counter = {
    Cuelist = Settings.StartingEmptyCueList,
    PlaybackNumber = Settings.PlaybackButtonStart
}
::START::
if Settings.Validation then
    Onyx.Key("Record") -- Trick to avoid first empty playback button, don't know why it happens ...
    for i, Group in pairs(Groups) do
        --¨For each preset
        for i, Preset in pairs(Presets) do
            Onyx.ClearProgrammer()
            if Settings.Step == 1 then
                Sleep(Settings.WaitTime)
                Onyx.SelectGroup(Group.id)
                SleepOption()
                if PresetType == PresetName.PanTilt then
                    Onyx.SelectPanTiltPreset(Preset.id)
                elseif PresetType == PresetName.Color then
                    Onyx.SelectColorPreset(Preset.id)
                elseif PresetType == PresetName.Intensity then
                    Onyx.SelectIntensityPreset(Preset.id)
                elseif PresetType == PresetName.Gobo then
                    Onyx.SelectGoboPreset(Preset.id)
                elseif PresetType == PresetName.Beam then
                    Onyx.SelectBeamPreset(Preset.id)
                end
                Sleep(Settings.WaitTime)
                Onyx.RecordCuelist(Counter.Cuelist)
                Sleep(Settings.WaitTime)
                Onyx.CopyCuelistFromDirectoryToPlaybackButton(
                    Counter.Cuelist,
                    Settings.PlaybackButtonPage,
                    Counter.PlaybackNumber
                )
                Sleep(Settings.WaitTime)
                Onyx.SetSelectedCuelistName(CuelistName(Group.name, Preset.name, false))
                if Settings.RenameCue == true then
                    Sleep(Settings.WaitTime)
                    Onyx.RenameCue(1, CuelistName(Group.name, Preset.name, false))
                end
                SleepOption()
                Onyx.SetCueTimeFade(1, Settings.TimeFade)
                SleepOption()
                Onyx.SetCuelistTimeRelease(Counter.Cuelist, Settings.TimeRelease)
            elseif Settings.Step == 2 then
                Onyx.SelectCuelist(Counter.Cuelist)
                Onyx.SetCuelistAppearance(Counter.Cuelist, Preset.appearance) -- Apply the preset appearance to the cuelist
            end
            Counter.Cuelist = Counter.Cuelist + 1 -- Go to next cuelist
            if Settings.Orientation == true then -- Vertical Orientation
                Counter.PlaybackNumber = Counter.PlaybackNumber + Settings.PlaybackWidth -- Set the next position
            else -- Horizontal Orientation
                Counter.PlaybackNumber = Counter.PlaybackNumber + 1 -- Set the next position
            end
        end
        if Settings.Orientation == true then -- Vertical Orientation
            Counter.PlaybackNumber = Settings.PlaybackButtonStart + i
        else -- Horizontal Orientation
            Counter.PlaybackNumber = Settings.PlaybackButtonStart + (Settings.PlaybackWidth * i)
        end
    end
    Sleep(Settings.WaitTime)
    if Settings.Step == 1 then
        Counter.Cuelist = Settings.StartingEmptyCueList
        Counter.PlaybackNumber = Settings.PlaybackButtonStart
        Settings.Step = 2
        goto START
    end

    FootPrint("Creation finished!")
else
    Cancelled()
end

::EXIT::
