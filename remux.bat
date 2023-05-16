@echo off 
    REM Disable Command Echoing

setlocal enabledelayedexpansion
    REM Can access in-scope vars

pushd %~dp0
    REM Add current directory to stack

if [%1]==[] goto scan
    REM Allows for files to be dragged onto the batch file

    REM Enable Drag & Drop
set file=%1
set name=%~n1
    REM Set file to current file and then name to name of current file
    REM Can be accessed by using !var! syntax

pushd %~dp1
    REM Push input file to destination

call :remux
    REM Call remux command

if not exist "remuxed" ( mkdir "remuxed")
    REM Check if remuxed dir exists, if not create one

goto end

:scan
    REM Scan Files
echo Files found:
echo.
for %%a in (*.mkv) do (
    set file=%%a 
    set name=%%~na
    call :remux
    if not exit "remuxed" ( mkdir "remuxed" )
)


:end
    REM Ending Command
echo Remuxing Complete.
pause >nul
exit

:remux
    REM Remuxing commands
set "ffmpeg !file! -crf 25 -movflags +faststart -pix_fmt yuv420p -ar 22050 ./remuxed/!name!.mp4"

