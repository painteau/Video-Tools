for %%a in (ORIGINAL\*.*) do (
TITLE "%%~na"
cls
ffmpeg -i "%%a" -vcodec copy -acodec copy "OUTPUT\%%~na".mp4
DEL /F "%%a"
)

