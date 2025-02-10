for %%a in (ORIGINAL\*.*) do (
TITLE "%%~na"
ffmpeg -i "%%a" -vf yadif -c:v libvpx -crf 10 -b:v 6M -b:a 128k -r 60 -c:a libopus -auto-alt-ref 0 "OUTPUT\%%~na".webm
)
pause

