@echo off
    REM Turn off command echoing

setlocal enabledelayedexpansion
    REM Allow list expansion

pushd %~dp0
    REM Change working directory to current directory of .bat file

if [%1]==[] goto scan
    REM If no file is dropped into the batch, scan directory instead

    REM Drag & Drop
set file=%1
set name=%~n1
    REM Set variables to full path + file name

    REM Check if 'remuxed' folder exists, if not create it
if not exist "remuxed" ( mkdir "remuxed" )

    REM Do Command
ffmpeg -i !file! -ar 22050 -crf 0 -tune animation -preset veryslow -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy "./remuxed/!name!.mp4"

    REM Ending Command
echo Finished.
pause >nul
exit

:scan 
    REM Function for scanning files
echo .mkv files found:
echo. 

for %%i in ("*.mkv") do ( echo %%i )
    REM List all mkv files in the current directory

echo.

for %%a in ("*.mkv") do (
    set namescan=%%~na

    REM Check if 'remuxed' folder exists, if not create it
    if not exist "remuxed" ( mkdir "remuxed" )

    REM Remux
    ffmpeg -i "%%a" -ar 22050 -crf 0 -tune animation -preset veryslow -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy "./remuxed/!namescan!.mp4"
)
    REM Ending Command
echo Finished.
pause >nul 
exit