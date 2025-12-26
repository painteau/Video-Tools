@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo   OPTIMIZED VIDEO MERGER (Re-Encoding)
echo ===============================================
echo.

::config
set /p EXTENSION_VIDEO=Enter video file extension (ex: mp4 or mkv):

::get parent folder to give name for the file
for %%a in ("%~dp0\.") do set "parent=%%~nxa"
set OUTPUT_VIDEO=%parent%.%EXTENSION_VIDEO%

echo.
echo Output file: %OUTPUT_VIDEO%
echo This will merge all *.%EXTENSION_VIDEO% files in this folder
echo.
pause

:: Build ffmpeg command in memory instead of writing to disk (OPTIMIZATION)
set "CMD=ffmpeg"
set /a COUNTER=0

:: Add all input files
echo.
echo [1/3] Building input list...
for %%f in (*.%EXTENSION_VIDEO%) do (
    set "CMD=!CMD! -i "%%f""
    echo   Added: %%f
    set /a COUNTER+=1
)

if %COUNTER%==0 (
    echo.
    echo ERROR: No %EXTENSION_VIDEO% files found in current directory
    pause
    exit /b
)

echo.
echo [2/3] Building filter chain...
:: Build filter_complex string in memory (OPTIMIZATION)
set "FILTER=-filter_complex ^""
set /a LAST_INDEX=%COUNTER%-1

:: Concatenate video and audio streams
for /l %%i in (0,1,%LAST_INDEX%) do (
    set "FILTER=!FILTER![%%i:v:0][%%i:a:0]"
)

:: Add concat filter
set "FILTER=!FILTER!concat=n=%COUNTER%:v=1:a=1[outv][outa]^""

:: Complete command with output mapping
set "CMD=!CMD! !FILTER! -map ^"[outv]^" -map ^"[outa]^" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 192k -movflags +faststart %OUTPUT_VIDEO%"

echo Filter chain built successfully
echo.

echo [3/3] Merging %COUNTER% video files...
echo.
Title "Merging to %OUTPUT_VIDEO%"

:: Execute the command directly from memory (OPTIMIZATION - no disk I/O)
%CMD%

if errorlevel 1 (
    echo.
    echo ERROR: Merge failed!
    pause
    exit /b
)

echo.
echo ===============================================
echo   MERGE COMPLETE
echo ===============================================
echo Output: %OUTPUT_VIDEO%
echo Files merged: %COUNTER%
echo.
pause
