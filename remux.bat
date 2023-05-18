:: ----------------------------------------------------------------------------------------------
:: remux.bat
:: ./remux.bat /? for usage
::
:: Source Code: https://github.com/ssenr/remux-script
::
:: Script Version: 0.1.0
::
:: Version History: 
:: 
:: 2023-05-16: Script created. No release version yet.
:: 2023-05-18: First stable release (0.1.0)
:: 
:: ----------------------------------------------------------------------------------------------

@echo off
    REM Turn off command echoing

setlocal enabledelayedexpansion
    REM Allow list expansions
setlocal enableextensions
    REM Enable command extensions

pushd %~dp0
    REM Change working directory to current directory of .bat file

    REM Check if conf.ini exists, if not create and populate it
if not exist "conf.ini" (
    REM Create conf.ini file
    copy NUL conf.ini

    REM Populate File with default values
    REM Set file to conf
    set config="conf.ini"

    REM Add default values
    >>"conf.tmp" echo [MAIN]
    >>"conf.tmp" echo CRF=20
    >>"conf.tmp" echo PRESET=5
    >>"conf.tmp" echo TUNE=1
    >>"conf.tmp" echo ColorspaceConversion=0
    >>"conf.tmp" echo ConvertToProRes=0

    REM Copy tmp file to config file
    move /y "conf.tmp" !config! > nul 
)

    REM Reading and mapping config file
    REM ------------------------------------------------------------
    REM For loop to set conf vars
    for /F "tokens=1,*delims==" %%a in ('type "conf.ini"') do set %%a=%%b

    REM Variable Mappings
        REM Preset Mappings
    if "!PRESET!"=="0" set _preset="ultrafast"
    if "!PRESET!"=="1" set _preset="superfast"
    if "!PRESET!"=="2" set _preset="veryfast"
    if "!PRESET!"=="3" set _preset="faster"
    if "!PRESET!"=="4" set _preset="fast"
    if "!PRESET!"=="5" set _preset="medium"
    if "!PRESET!"=="6" set _preset="slow"
    if "!PRESET!"=="7" set _preset="slower"
    if "!PRESET!"=="8" set _preset="veryslow"

        REM Tune Mappings
    if "!TUNE!"=="0" set _tune="film"
    if "!TUNE!"=="1" set _tune="animation"
    if "!TUNE!"=="2" set _tune="grain"
    if "!TUNE!"=="3" set _tune="stillimage"
    if "!TUNE!"=="4" set _tune="fastdecode"
    if "!TUNE!"=="5" set _tune="zerolatency"
    
    REM Check for /? flag
if [%1]==[/?] goto help
    REM Go to help when /? is passed

if [%1]==[] goto scan
    REM If no file is dropped into the batch, scan directory instead

    REM ------------------------------------------------------------    Drag & Drop
    REM Set variables to full path + file name
set file=%1
set name=%~n1
    
    REM Check if 'remuxed' folder exists, if not create it
if not exist "remuxed" ( mkdir "remuxed" )
    

    REM Remux Step:
        REM Four logical cases:
        REM     1. Don't convert to prores and don't convert colorspace
        REM     2. Don't convert to prores but convert colorspace
        REM     3. Convert to prores but don't convert colorspace
        REM     4. Convert to prores and convert colorspace
        REM     ----------------------------------------------------
    if "!ConvertToProRes!"=="1" (
        if "!ColorspaceConversion!"=="0" (
            ffmpeg -i !file! -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -strict -2 -acodec pcm_f32le -vcodec prores_ks "./remuxed/!name!.mov"
        ) else if "!ColorspaceConversion!"=="1" (
            ffmpeg -i !file! -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -strict -2 -acodec pcm_f32le -vcodec prores_ks -c:v libx264rgb "./remuxed/!name!.mov"
        )
    ) else (
        if "!ColorspaceConversion!"=="0" (
            ffmpeg -i !file! -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy "./remuxed/!name!.mp4"
        ) else if "!ColorspaceConversion!"=="1" (
            ffmpeg -i !file! -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy -c:v libx264rgb "./remuxed/!name!.mp4"
        )
    ) 
    REM Ending Command
echo Finished.
goto end

    REM ------------------------------------------------------------    Scan
:scan 
    REM Function for scanning files

    REM List all mkv files in the current directory
echo .mkv files found:
echo. 
for %%i in ("*.mkv") do ( echo %%i )
echo.

for %%a in ("*.mkv") do (
    set namescan=%%~na

    REM Check if 'remuxed' folder exists, if not create it
    if not exist "remuxed" ( mkdir "remuxed" )

    REM Remux Step
    if "!ConvertToProRes!"=="1" (
        if "!ColorspaceConversion!"=="0" (
            ffmpeg -i "%%a" -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -strict -2 -acodec pcm_f32le -vcodec prores_ks "./remuxed/!namescan!.mov"
        ) else if "!ColorspaceConversion!"=="1" (
            ffmpeg -i "%%a" -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -strict -2 -acodec pcm_f32le -vcodec prores_ks -c:v libx264rgb "./remuxed/!namescan!.mov"
        )
    ) else (
        if "!ColorspaceConversion!"=="0" (
            ffmpeg -i "%%a" -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy "./remuxed/!namescan!.mp4"
        ) else if "!ColorspaceConversion!"=="1" (
            ffmpeg -i "%%a" -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy -c:v libx264rgb "./remuxed/!namescan!.mp4"
        )
    ) 
)
    REM Ending Command
echo Finished.
goto end

:help
    REM Usage Instructions
    REM Put docs
echo Please see the README.md on the github page: https://github.com/ssenr/remux-script
echo.
echo Please open the script file regularly to remux a batch or drag a single video over the script to remux a single video.
goto end

:end 
pause >nul 
exit 