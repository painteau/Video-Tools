@echo off
setlocal ENABLEDELAYEDEXPANSION
cls

echo ===============================================
echo   OPTIMIZED VP9 ENCODER (Two-Pass)
echo ===============================================
echo.

set "targetfile=%__cd__%%~n1"
set "original_file=%~f1"
set "file_name=%~nx1"

echo Input: %file_name%
echo Output: %~n1.webm
echo.

:: Get video resolution to calculate optimal bitrate (OPTIMIZATION)
echo [1/4] Analyzing video properties...
for /f "tokens=*" %%i in ('ffprobe -v error -select_streams v:0 -show_entries stream^=width^,height -of csv^=s^=x:p^=0 "%original_file%" 2^>^&1') do set "resolution=%%i"

:: Calculate optimal bitrate based on resolution (OPTIMIZATION)
:: Formula: width * height * fps * 0.04 (VP9 is more efficient than H.264)
for /f "tokens=1,2 delims=x" %%a in ("%resolution%") do (
    set /a pixels=%%a*%%b
)

:: Bitrate tiers
if %pixels% geq 8000000 (
    set "bitrate=8000k"
    echo Resolution: 4K+ - Bitrate: 8000k
) else if %pixels% geq 2000000 (
    set "bitrate=4000k"
    echo Resolution: 1080p+ - Bitrate: 4000k
) else if %pixels% geq 900000 (
    set "bitrate=2000k"
    echo Resolution: 720p+ - Bitrate: 2000k
) else (
    set "bitrate=1000k"
    echo Resolution: SD - Bitrate: 1000k
)

echo.

:: Two-pass encoding for better quality (OPTIMIZATION)
echo [2/4] First pass (analyzing)...
ffmpeg -y -i "%original_file%" -c:v libvpx-vp9 -b:v %bitrate% -quality good -cpu-used 4 -row-mt 1 -tile-columns 2 -threads 0 -pass 1 -an -f null NUL

if errorlevel 1 (
    echo ERROR: First pass failed!
    pause
    exit /b
)

echo.
echo [3/4] Second pass (encoding)...
ffmpeg -y -i "%original_file%" -c:v libvpx-vp9 -b:v %bitrate% -quality good -cpu-used 4 -row-mt 1 -tile-columns 2 -threads 0 -pass 2 -c:a libopus -b:a 128k "%targetfile%.webm"

if errorlevel 1 (
    echo ERROR: Second pass failed!
    pause
    exit /b
)

echo.
echo [4/4] Cleaning up temporary files...
del ffmpeg2pass-0.log 2>nul
del ffmpeg2pass-0.log.mbtree 2>nul

echo.
echo ===============================================
echo   ENCODING COMPLETE
echo ===============================================
echo Output: %~n1.webm
echo Codec: VP9 + Opus (Two-Pass)
echo Bitrate: %bitrate%
echo.
pause
