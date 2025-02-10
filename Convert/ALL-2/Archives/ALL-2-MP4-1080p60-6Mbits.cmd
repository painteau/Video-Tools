for %%a in (ORIGINAL\*.*) do (
TITLE "%%~na"
ffmpeg -i "%%a" -preset fast -codec:a aac -b:a 128k -codec:v libx264 -pix_fmt yuv420p -b:v 6000k -minrate 6000k -maxrate 6000k -bufsize 6000k "OUTPUT\%%~na".mp4
)
pause

