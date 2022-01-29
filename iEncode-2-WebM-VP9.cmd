@echo off
set "targetfile=%__cd__%%~n1.webm"
set "original_file=%~f1"
set "file_name=%~nx1"
set "file_dir=%~dp1"
set bitrate=6M
set audio=160k
cls
ffmpeg -i "%original_file%" -vf yadif -c:v libvpx-vp9 -crf 10 -b:v %bitrate% -b:a %audio% -r 60 -c:a libopus -auto-alt-ref 0 "%targetfile%"
pause


