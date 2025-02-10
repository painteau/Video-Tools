@echo off
setlocal enabledelayedexpansion

:: Configuration
set /p EXTENSION_VIDEO=Please input the 3 letters of the extension of the files to merge together. (ex: mp4 or mkv)  

:: Get parent folder name for output file
for %%a in ("%~dp0\.") do set "parent=%%~nxa"
set OUTPUT_VIDEO=%parent%.%EXTENSION_VIDEO%
Title "Merging to %OUTPUT_VIDEO%"

echo This will merge all %EXTENSION_VIDEO% files in this folder to %OUTPUT_VIDEO%
pause

:: Verify if FFmpeg is installed
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo FFmpeg not found. Please install it and ensure it is in the system PATH.
    pause
    exit /b
)

:: Verify file compatibility before merging
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,r_frame_rate -of csv=p=0 "*.%EXTENSION_VIDEO%" > video_info.log 2>nul
if %errorlevel% neq 0 (
    echo Some files might not be compatible. Ensure all videos have the same codec, resolution, and framerate.
    pause
)

:: Ask user if they want to re-encode the video
set /p REENCODE="Do you want to re-encode the videos? (y/n): "

:: Generate FFmpeg concat list
if exist merge_list.txt del merge_list.txt
(for %%f in (*.%EXTENSION_VIDEO%) do echo file '%%f') >> merge_list.txt

:: Merge videos
if /I "%REENCODE%"=="y" (
    echo Re-encoding enabled. This may take longer...
    ffmpeg -f concat -safe 0 -i merge_list.txt -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 192k -bufsize 5000k "%OUTPUT_VIDEO%"
) else (
    echo Merging without re-encoding...
    ffmpeg -f concat -safe 0 -i merge_list.txt -c copy "%OUTPUT_VIDEO%" 2> merge_errors.log
    if %errorlevel% neq 0 (
        echo An error occurred during merging. Check merge_errors.log for details.
        pause
    )
)

:: Cleanup
del merge_list.txt

echo Merging Complete. Press any key plus Enter to exit.
pause
