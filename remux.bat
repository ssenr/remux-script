:: ----------------------------------------------------------------------------------------------
:: remux.bat
:: ./remux.bat /? for usage
::
:: Source Code: https://github.com/ssenr/remux-script
::
:: Script Version: 0.2.0
::
:: Version History: 
:: 
:: 2023-05-16: Script created. No release version yet.
:: 2023-05-18: First stable release (0.1.0)
:: 2023-05-18: Second stable releast (0.2.0)
:: 
::                   __,__
::          .--.  .-"     "-.  .--.
::         / .. \/  .-. .-.  \/ .. \
::        | |  '|  /   Y   \  |'  | |
::        | \   \  \ 0 | 0 /  /   / |
::         \ '- ,\.-"`` ``"-./, -' /
::          `'-' /_   ^ ^   _\ '-'`
::          .--'|  \._   _./  |'--. 
::        /`    \   \ `~` /   /    `\
::       /       '._ '---' _.'       \
::      /           '~---~'   |       \
::     /        _.             \       \
::    /   .'-./`/        .'~'-.|\       \
::   /   /    `\:       /      `\'.      \
::  /   |       ;      |         '.`;    /
::  \   \       ;      \           \/   /
::   '.  \      ;       \       \   `  /
::     '._'.     \       '.      |   ;/_
::  jgs  /__>     '.       \_ _ _/   ,  '--.
::     .'   '.   .-~~~~~-. /     |--'`~~-.  \
::    // / .---'/  .-~~-._/ / / /---..__.'  /
::   ((_(_/    /  /      (_(_(_(---.__    .'
::             | |     _              `~~`
::             | |     \'.
::             \ '....' |
::              '.,___.'
::
::           ^ Sonder Lead's ^
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
    >>"conf.tmp" echo CRF=0
    >>"conf.tmp" echo PRESET=8
    >>"conf.tmp" echo TUNE=1
    >>"conf.tmp" echo CONV_COLORSPACE=0
    >>"conf.tmp" echo CONV_PRORES=0
    >>"conf.tmp" echo CONV_AVI=0

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
    
    REM Grab Escape Character
    call :setESC

    REM Check for /? flag and go to help function when /? is passed
if [%1]==[/?] goto help

if [%1]==[] goto scan
    REM If no file is dropped into the batch, scan directory instead

    REM ------------------------------------------------------------    Drag & Drop
    REM Set variables to full path + file name
set file=%1
set name=%~n1

    REM Repeat Drag & Drop 
    echo %ESC%[95m Proceeding to remux %ESC%[0m
    echo.
    echo       %ESC%[92m !name! %ESC%[0m

    REM Pause for five seconds
    ping localhost -n 3 > nul
    
    REM Check if 'remuxed' folder exists, if not create it
if not exist "remuxed" ( mkdir "remuxed" )
    
    REM Remux Step:
        REM Four logical cases:
        REM     1. Don't convert to prores and don't convert colorspace
        REM     2. Don't convert to prores but convert colorspace
        REM     3. Convert to prores but don't convert colorspace
        REM     4. Convert to prores and convert colorspace
        REM     ----------------------------------------------------
    
    REM Set File Extension Variable
    set ext=".mp4"
    if "!CONV_PRORES!"=="1" (
        set ext=".mov"
            REM Check for converting .avi
            REM If so, exception caught
        if "!CONV_AVI!"=="1" (
            echo.
            echo %ESC%[91m Invalid codec and container combination %ESC%[0m
            echo %ESC%[92m Please disable CONV_AVI or CONV_PRORES in the conf.ini file %ESC%[0m
            echo.
            echo For more information on codec and container support please visit: %ESC%[36m https://en.wikipedia.org/wiki/Comparison_of_video_container_formats %ESC%[0m
            echo.
            echo This information can also be found within the README.md on the GitHub page.
            goto end
        )

        if "!CONV_COLORSPACE!"=="0" (
            ffmpeg -i !file! -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -strict -2 -acodec pcm_f32le -vcodec prores_ks "./remuxed/!name!!ext!"
        ) else if "!CONV_COLORSPACE!"=="1" (
            ffmpeg -i !file! -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -strict -2 -acodec pcm_f32le -vcodec prores_ks -c:v libx264rgb "./remuxed/!name!!ext!"
        )
    ) else (
            REM Check for converting .avi
        if "!CONV_AVI!"=="1" set ext=".avi"

        if "!CONV_COLORSPACE!"=="0" (
            ffmpeg -i !file! -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy "./remuxed/!name!!ext!"
        ) else if "!CONV_COLORSPACE!"=="1" (
            ffmpeg -i !file! -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy -c:v libx264rgb "./remuxed/!name!!ext!"
        )
    ) 
    REM Ending Command
echo.
echo %ESC%[92mOperation completed successfully. %ESC%[0m
echo %ESC%[93mYou may hit any key, or close the prompt. %ESC%[0m
goto end

    REM ------------------------------------------------------------    Scan
:scan 
    REM Function for scanning files

    REM List all mkv files in the current directory
echo.
echo %ESC%[95mProceeding to remux the following files: %ESC%[95m
echo. 
for %%i in ("*.mkv") do ( echo      %ESC%[92m %%i %ESC%[0m)
echo.

REM Pause for five seconds
ping localhost -n 3 > nul

for %%a in ("*.mkv") do (
    set namescan=%%~na

    REM Check if 'remuxed' folder exists, if not create it
    if not exist "remuxed" ( mkdir "remuxed" )

    REM Remux Step
        REM Set extension variable
    set ext=".mp4"

    if "!CONV_PRORES!"=="1" (
        REM Default file extension for ProRes
        set ext=".mov"

        REM Check for avi conversion
            REM If so, exception found
        if "!CONV_AVI!"=="1" (
            echo %ESC%[91m Invalid codec and container combination %ESC%[0m
            echo %ESC%[92m Please disable CONV_AVI or CONV_PRORES in the conf.ini file %ESC%[0m
            echo.
            echo For more information on codec and container support please visit: %ESC%[36m https://en.wikipedia.org/wiki/Comparison_of_video_container_formats %ESC%[0m
            goto end
        )

        if "!CONV_COLORSPACE!"=="0" (
            ffmpeg -i "%%a" -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -strict -2 -acodec pcm_f32le -vcodec prores_ks "./remuxed/!namescan!!ext!"
        ) else if "!CONV_PRORES!"=="1" (
            ffmpeg -i "%%a" -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -strict -2 -acodec pcm_f32le -vcodec prores_ks -c:v libx264rgb "./remuxed/!namescan!!ext!"
        )
    ) else (
        REM Check for avi conversion
        if "!CONV_AVI!"=="1" set ext=".avi"

        if "!CONV_COLORSPACE!"=="0" (
            ffmpeg -i "%%a" -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy "./remuxed/!namescan!!ext!"
        ) else if "!CONV_COLORSPACE!"=="1" (
            ffmpeg -i "%%a" -crf !CRF! -tune !_tune! -preset !_preset! -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy -c:v libx264rgb "./remuxed/!namescan!!ext!"
        )
    ) 
)
    REM Ending Command
echo.
echo %ESC%[92mOperation's completed successfully. %ESC%[0m
echo %ESC%[93mYou may hit any key, or close the prompt. %ESC%[0m
goto end

:help
    REM Usage Instructions
    REM Put docs
echo Please see the README.md on the github page: %ESC%[36mhttps://github.com/ssenr/remux-script %ESC%[0m
echo.
echo %ESC%[91mPlease open the script file regularly to remux a batch or drag a single video over the script to remux a single video. %ESC%[0m
goto end

:end 
pause >nul 
exit 

REM https://gist.github.com/mlocati/fdabcaeb8071d5c75a2d51712db24011
:setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
  exit /B 0
)
