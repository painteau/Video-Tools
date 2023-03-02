@echo off
set "targetfile=%__cd__%%~n1.mp4"
set "original_file=%~f1"
set "file_name=%~nx1"
set "file_dir=%~dp1"
cls
ffmpeg -i "%original_file%" -c:v copy -c:a aac -strict experimental -b:a 128k "%targetfile%"
pause


