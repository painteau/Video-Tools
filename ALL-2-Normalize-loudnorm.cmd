@echo off
for %%a in (ORIGINAL\*.mp4) do (
TITLE "%%~na"
ffmpeg -i "%%a" -filter:a loudnorm "OUTPUT\%%~na".mp4
)
pause