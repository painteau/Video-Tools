@echo off
:start
cls
for %%a in (videos\*.mp4) do (
for /f "delims=" %%x in (stream.config) do (set "%%x")
ffmpeg -re -i "%%a" -vf "movie=overlay.png [movie]; [in] [movie] overlay=0:0 [out]" -acodec libvo_aacenc -ar 44100 -ab "%bitaudio%k" -ac 2 -vcodec libx264 -r 30 -g 60 -s "%resolution%" -b:v "%bitrate%k" -maxrate "%bitrate%k" -bufsize "%buffersize%k" -f flv "%serveur%"
)
goto start