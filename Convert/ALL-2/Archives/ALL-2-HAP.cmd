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

:: Conversion des fichiers en HAP
for %%a in (ORIGINAL\*.*) do (
    TITLE "Processing: %%~na"
    echo Converting "%%~na" to HAP format...
    ffmpeg -i "%%a" -c:v hap -format hap_alpha -chunked 1 -b:v 500M "OUTPUT\%%~na.mov"
    if %errorlevel% neq 0 (
        echo Error processing "%%~na", skipping...
    ) else (
        echo Successfully converted "%%~na" to HAP.
    )
)

echo Conversion complete!
pause
exit /b