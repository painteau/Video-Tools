@echo off
setlocal enabledelayedexpansion

::config
set /p EXTENSION_VIDEO=Please input the 3 letters of the extension of the files to merge together. (ex: mp4 or mkv)  

::code

::get parent folder to give name for the file
for %%a in ("%~dp0\.") do set "parent=%%~nxa"
set OUTPUT_VIDEO=%parent%.%EXTENSION_VIDEO%
Title "Merging to %OUTPUT_VIDEO%"

echo This will merge all %EXTENSION_VIDEO% files in this folder to %OUTPUT_VIDEO%"
pause

del /f merge.db
ECHO 

for %%f in (*.%EXTENSION_VIDEO%) do ( 
ECHO file '%%f' >> merge.db
)

ffmpeg -f concat -i merge.db -vcodec copy -acodec copy %OUTPUT_VIDEO%


::del run.cmd
ECHO Merging Complete. Press any key plus Enter to exit. 

pause
