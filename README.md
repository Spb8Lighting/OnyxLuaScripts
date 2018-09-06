# Onyx Lua Scripts for ShowCockpit

This repository contains some LUA script which can be run from ShowCockpit to interact with Onyx.

## Script List

* [Delete-Cuelists.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Delete-Cuelists.lua) - This script allows to delete a range of cuelist (batch mode)
* [Delete-Presets.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Delete-Presets.lua) - This script allows to delete a range of presets (batch mode)
* [Update-CueFade-CuelistRelease.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Delete-Presets.lua) - This script allows to update the cues fade times in the meantime of the cuelist release time

## Lua Fonctions

Inside the [header.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/assets/header.lua) script which is include in all scripts, you have access to some functions. Theses last are detailed below if you want to create your own script based on it.

### Interface function

<details>
    <summary>HeadPrint()</summary>
    <p>No Args</p>
    <p>This function will log the in ShowCockpit the Script Name and the Script Version</p>
</details>
<details>
    <summary>FootPrint(sentence)</summary>
    <p>string sentence</p>
    <p>This function will log the in ShowCockpit sentence argument and display the author informations</p>
</details>