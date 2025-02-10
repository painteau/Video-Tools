@echo off
setlocal

:: Vérifier si FFmpeg est installé
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo FFmpeg not found. Please install FFmpeg and ensure it is in the system PATH.
    pause
    exit /b
)

:: Demander à l'utilisateur d'entrer le fichier source
set /p input_file="Enter the input video file (e.g., video.mp4): "
if not exist "%input_file%" (
    echo Error: File "%input_file%" not found.
    pause
    exit /b
)

:: Demander à l'utilisateur l'heure de début
set /p start_time="Enter the start time (HH:MM:SS.mmm): "

:: Demander à l'utilisateur la durée de l'extrait
set /p duration="Enter the duration (HH:MM:SS.mmm): "

:: Demander un nom de fichier de sortie
set /p output_file="Enter the output file name (e.g., output.mp4): "

:: Vérifier si l'utilisateur veut extraire une image précise (par défaut: non)
set /p extract_frame="Extract a single frame? (y/n) [default: n]: "
if "%extract_frame%"=="" set extract_frame=n

if /I "%extract_frame%"=="y" (
    ffmpeg -ss %start_time% -i "%input_file%" -frames:v 1 "%output_file%"
) else (
    ffmpeg -ss %start_time% -i "%input_file%" -t %duration% -c copy "%output_file%"
)

if %errorlevel% neq 0 (
    echo Extraction failed. Please check your input values.
) else (
    echo Extraction completed successfully!
)

pause
exit /b
