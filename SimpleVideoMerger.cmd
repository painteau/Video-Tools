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

del /f run.cmd
ECHO | set /p=ffmpeg >> run.cmd

for %%f in (*.%EXTENSION_VIDEO%) do ( 
ECHO | set /p=-i %%f >> run.cmd 
ECHO %%f Added in the queue
)

ECHO|set /p=-filter_complex >> run.cmd
ECHO|set /p=^^""" >> run.cmd

set /a COUNTER=0
for %%f in (*.mp4) do ( 
(ECHO|set /p=[!COUNTER!:v:0][!COUNTER!:a:0])>>run.cmd 
set /a COUNTER+=1
)

(ECHO|set /p = concat=n=%COUNTER%:v=1:a=1[outv][outa])>> run.cmd
ECHO|set /p=^^"" " >> run.cmd

ECHO|set /p=-map "[outv]" -map "[outa]" %OUTPUT_VIDEO% >> run.cmd

ECHO Batch merging script done, running
::timeout 1 > NUL
call run.cmd

::timeout 3 > NUL
del run.cmd
ECHO Merging Complete. Press any key plus Enter to exit. 

pause
