@echo off
:start
cls
:: Load configuration once before processing videos (OPTIMIZATION FIX)
for /f "delims=" %%x in (stream.config) do (set "%%x")

:: Process videos with optimized configuration loading
for %%a in (videos\*.mp4) do (
    echo [%time%] Streaming: %%a
    :: Replaced deprecated libvo_aacenc with aac codec (OPTIMIZATION)
    :: Added error handling - continue to next video if stream fails
    ffmpeg -re -i "%%a" -vf "movie=overlay.png [movie]; [in] [movie] overlay=0:0 [out]" -acodec aac -ar 48000 -ab "%bitaudio%k" -ac 2 -vcodec libx264 -preset veryfast -r 30 -g 60 -s "%resolution%" -b:v "%bitrate%k" -maxrate "%bitrate%k" -bufsize "%buffersize%k" -f flv "%serveur%"
    if errorlevel 1 (
        echo [%time%] ERROR: Failed to stream %%a, continuing to next file...
    )
)
goto start