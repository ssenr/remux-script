REM for %%a in ("*.mkv") do ffmpeg -i "%%a" -vcodec copy -acodec copy "newfiles\%%~na.mp4"
for %%a in ("*.mkv") do ffmpeg -i "%%a" -ar 22050 -crf 18 -movflags +faststart -pix_fmt yuv420p -strict -2 -acodec copy -vcodec copy "%%~na.mp4"
pause
