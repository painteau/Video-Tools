for %%a in (ORIGINAL\*.*) do (
TITLE "%%~na"
ffmpeg -i "%%a" -c:v hap -format hap_alpha "OUTPUT\%%~na".mov
)
pause