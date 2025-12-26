@echo off
setlocal ENABLEDELAYEDEXPANSION
cls

echo ===============================================
echo   OPTIMIZED MP4 ENCODER (GPU Accelerated)
echo ===============================================
echo.

set "targetfile=%__cd__%%~n1"
set "original_file=%~f1"
set "file_name=%~nx1"

echo Input: %file_name%
echo Output: %~n1.mp4
echo.

:: Detect GPU acceleration (OPTIMIZATION)
set "encoder=libx264"
set "hw_decoder="
set "encoder_preset=medium"

:: Try NVIDIA NVENC
ffmpeg -hide_banner -encoders 2>nul | findstr /C:"h264_nvenc" >nul
if %errorlevel%==0 (
    echo [GPU] NVIDIA NVENC detected - Using hardware acceleration
    set "encoder=h264_nvenc"
    set "hw_decoder=-hwaccel cuda"
    set "encoder_preset=-preset p4 -tune hq -rc vbr"
    goto :encode
)

:: Try Intel QuickSync
ffmpeg -hide_banner -encoders 2>nul | findstr /C:"h264_qsv" >nul
if %errorlevel%==0 (
    echo [GPU] Intel QuickSync detected - Using hardware acceleration
    set "encoder=h264_qsv"
    set "hw_decoder=-hwaccel qsv"
    set "encoder_preset=-preset medium"
    goto :encode
)

:: Try AMD AMF
ffmpeg -hide_banner -encoders 2>nul | findstr /C:"h264_amf" >nul
if %errorlevel%==0 (
    echo [GPU] AMD AMF detected - Using hardware acceleration
    set "encoder=h264_amf"
    set "hw_decoder=-hwaccel d3d11va"
    set "encoder_preset=-quality quality"
    goto :encode
)

echo [CPU] No GPU acceleration detected - Using CPU encoding
set "encoder_preset=-preset medium -crf 23"

:encode
echo Encoder: %encoder%
echo.

:: Optimized encoding with better parameters (OPTIMIZATION)
ffmpeg -y %hw_decoder% -i "%original_file%" -c:v %encoder% %encoder_preset% -threads 0 -c:a aac -b:a 192k -movflags +faststart "%targetfile%.mp4"

if errorlevel 1 (
    echo.
    echo ERROR: Encoding failed!
    pause
    exit /b
)

echo.
echo ===============================================
echo   ENCODING COMPLETE
echo ===============================================
echo Output: %~n1.mp4
echo.
pause
