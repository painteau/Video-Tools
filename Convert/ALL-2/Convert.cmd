@echo off
setlocal enabledelayedexpansion

:: Vérifier si FFmpeg est installé
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo FFmpeg not found. Please install it and ensure it is in the system PATH.
    pause
    exit /b
)

:: Vérifier si le dossier OUTPUT existe, sinon le créer
if not exist "OUTPUT" mkdir "OUTPUT"

:: Demander à l'utilisateur quel type de conversion effectuer
cls
echo Select the conversion type:
echo [1] MP4 H.264 (re-encode)
echo [2] MP4 H.265 (re-encode)
echo [3] WebM VP8 (re-encode)
echo [4] WebM VP9 (re-encode)
echo [5] AV1 (re-encode)
echo [6] ProRes (re-encode)
echo [7] DNxHD / DNxHR (re-encode)
echo [8] HAP (re-encode)
echo [9] Normalize audio with loudnorm (re-encode)
echo [10] FLV to MP4 (no re-encode, direct stream copy)
set /p CHOICE="Enter your choice (1-10): "

:: Si re-encodage, demander résolution et débit
if "%CHOICE%"=="1" set FORMAT=H.264
if "%CHOICE%"=="2" set FORMAT=H.265
if "%CHOICE%"=="3" set FORMAT=VP8
if "%CHOICE%"=="4" set FORMAT=VP9
if "%CHOICE%"=="5" set FORMAT=AV1
if "%CHOICE%"=="6" set FORMAT=ProRes
if "%CHOICE%"=="7" set FORMAT=DNxHD
if "%CHOICE%"=="8" set FORMAT=HAP

if defined FORMAT (
    echo Available resolutions:
    echo [1] 7680x4320 (8K UHD)
    echo [2] 3840x2160 (4K UHD)
    echo [3] 2560x1440 (1440p QHD)
    echo [4] 1920x1080 (1080p FHD)
    echo [5] 1280x720 (720p HD)
    echo [6] 854x480 (480p SD)
    echo [7] 640x360 (360p)
    echo [8] 320x240 (240p)
    set /p RESOLUTION_CHOICE="Enter resolution choice (1-8): "
    if "%RESOLUTION_CHOICE%"=="1" set RESOLUTION=7680x4320
    if "%RESOLUTION_CHOICE%"=="2" set RESOLUTION=3840x2160
    if "%RESOLUTION_CHOICE%"=="3" set RESOLUTION=2560x1440
    if "%RESOLUTION_CHOICE%"=="4" set RESOLUTION=1920x1080
    if "%RESOLUTION_CHOICE%"=="5" set RESOLUTION=1280x720
    if "%RESOLUTION_CHOICE%"=="6" set RESOLUTION=854x480
    if "%RESOLUTION_CHOICE%"=="7" set RESOLUTION=640x360
    if "%RESOLUTION_CHOICE%"=="8" set RESOLUTION=320x240
)

:: Exécuter la conversion en fonction du choix
for %%a in (ORIGINAL\*.*) do (
    TITLE "Processing: %%~na"
    if "%CHOICE%"=="1" (
        ffmpeg -i "%%a" -c:v libx264 -preset fast -b:v 6000k -s %RESOLUTION% -c:a aac "OUTPUT\%%~na.mp4"
    ) else if "%CHOICE%"=="2" (
        ffmpeg -i "%%a" -c:v libx265 -preset slow -crf 28 -s %RESOLUTION% -c:a aac "OUTPUT\%%~na.mp4"
    ) else if "%CHOICE%"=="3" (
        ffmpeg -i "%%a" -c:v libvpx -b:v 1M -s %RESOLUTION% -c:a libvorbis "OUTPUT\%%~na.webm"
    ) else if "%CHOICE%"=="4" (
        ffmpeg -i "%%a" -c:v libvpx-vp9 -b:v 1M -s %RESOLUTION% -c:a libopus "OUTPUT\%%~na.webm"
    ) else if "%CHOICE%"=="5" (
        ffmpeg -i "%%a" -c:v libaom-av1 -crf 30 -b:v 0 -cpu-used 4 -s %RESOLUTION% -c:a libopus "OUTPUT\%%~na.webm"
    ) else if "%CHOICE%"=="6" (
        ffmpeg -i "%%a" -c:v prores_ks -profile:v 3 -s %RESOLUTION% -c:a pcm_s16le "OUTPUT\%%~na.mov"
    ) else if "%CHOICE%"=="7" (
        ffmpeg -i "%%a" -c:v dnxhd -b:v 115M -s %RESOLUTION% -c:a pcm_s16le "OUTPUT\%%~na.mov"
    ) else if "%CHOICE%"=="8" (
        ffmpeg -i "%%a" -c:v hap -format hap_alpha -chunked 1 -s %RESOLUTION% "OUTPUT\%%~na.mov"
    ) else if "%CHOICE%"=="9" (
        ffmpeg -i "%%a" -af "loudnorm" "OUTPUT\%%~na_normalized.wav"
    ) else if "%CHOICE%"=="10" (
        ffmpeg -i "%%a" -c:v copy -c:a aac "OUTPUT\%%~na.mp4"
    ) else (
        echo Invalid choice, exiting...
        pause
        exit /b
    )
)

echo Conversion complete!
pause
exit /b
