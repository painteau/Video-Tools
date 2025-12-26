@echo off
setlocal ENABLEDELAYEDEXPANSION
set "targetfile=%__cd__%%~n1"
set "original_file=%~f1"
set "file_name=%~nx1"
set "file_dir=%~dp1"

cls
echo ===============================================
echo   OPTIMIZED SUBTITLE EXTRACTOR
echo ===============================================
echo.
echo Processing: %file_name%
echo.

:: First, detect the number of subtitle streams using ffprobe (OPTIMIZATION)
echo [1/2] Detecting subtitle streams...
set subtitle_count=0

for /f "tokens=*" %%i in ('ffprobe -v error -select_streams s -show_entries stream^=index -of csv^=p^=0 "%original_file%" 2^>^&1') do (
    set /a subtitle_count+=1
    set "stream_!subtitle_count!=%%i"
)

if %subtitle_count%==0 (
    echo.
    echo WARNING: No subtitle streams found in this video.
    echo.
    pause
    exit /b
)

echo Found %subtitle_count% subtitle stream(s)
echo.

:: Extract only the detected subtitle streams (OPTIMIZATION - no wasteful attempts)
echo [2/2] Extracting subtitles...
for /l %%x in (1,1,%subtitle_count%) do (
    set "stream_index=!stream_%%x!"
    echo   - Extracting stream !stream_index! to "%~n1.!stream_index!.srt"
    ffmpeg -y -v error -stats -i "%original_file%" -vn -an -dn -map 0:!stream_index! "%targetfile%"."!stream_index!".srt"
)

echo.
echo ===============================================
echo   EXTRACTION COMPLETE
echo ===============================================
echo Extracted %subtitle_count% subtitle file(s)
echo.
pause
