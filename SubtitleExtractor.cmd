@echo off
setlocal ENABLEDELAYEDEXPANSION
set "targetfile=%__cd__%%~n1"
set "original_file=%~f1"
set "file_name=%~nx1"
set "file_dir=%~dp1"
cls
echo extracting subtitle from %original_file% 
for /l %%x in (0,1,6) do (
ffmpeg -y -v error -stats -i "%original_file%" -vn -an -dn -map 0:%%x "%targetfile%"."%%x".srt"
)
pause

