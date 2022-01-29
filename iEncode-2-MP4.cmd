@echo off
set "targetfile=%__cd__%%~n1.mp4"
set "original_file=%~f1"
set "file_name=%~nx1"
set "file_dir=%~dp1"
set bitrate=6000k
set audio=160k
cls
ffmpeg -i "%original_file%" -preset fast -codec:a aac -b:a %audio% -codec:v libx264 -pix_fmt yuv420p -b:v %bitrate% -minrate %bitrate% -maxrate %bitrate% -bufsize %bitrate% "%targetfile%"
pause


